{BufferedProcess, Emitter} = require 'atom'
{RESULT, parser} = require '../backend/gdb/gdb-mi-parser'
GDB = require '../backend/gdb/gdb'
fs = require 'fs'

module.exports =
  class NdkGdb extends GDB

    STATUS =
      NOTHING: 0
      RUNNING: 1
      ERROR: 2

    constructor: (targetProject,consoleView) ->
      @breakPoints = []
      @token = 0
      @handler = {}
      @emitter = new Emitter
      @stdoutMessage = "";
      @consoleView = consoleView

      stdout = (lines) =>
        console.log(lines)
        displayInConsole = true
        for line in lines.split('\n')
          switch line[0]
            when '+' then null  # status-async-output
            when '=' then displayInConsole = false;null  # notify-async-output
            when '~' then null  # console-stream-output
            when '@' then null  # target-stream-output
            when '&' then displayInConsole = false;null  # log-stream-output
            when '*'            # exec-async-output
              try
                  {clazz, result} = parser.parse(line.substr(1))
                  @emitter.emit 'exec-async-output', {clazz, result}
                  @emitter.emit "exec-async-running", result if clazz == RESULT.RUNNING
                  @emitter.emit "exec-async-stopped", result if clazz == RESULT.STOPPED
                  displayInConsole = false;
              catch error
                console.log("line: #{line} not understanable by the parser")
                console.error("Error: #{error.message}")

            else                # result-record
              if line[0] <= '9' and line[0] >= '0'
                try
                  {token, clazz, result} = parser.parse(line)
                  @handler[token](clazz, result)
                  delete @handler[token]
                  displayInConsole = false
                catch error
                  console.log("line: #{line} not understanable by the parser")
                  console.error("Error: #{error.message}")


        if displayInConsole
           @consoleView.echoToConsole lines

      stderr = (lines) =>
        @errorMessage = lines

      projectPath = atom.config.get("#{atom._debugger.name}.projectPath")
      if !fs.existsSync(projectPath+"/AndroidManifest.xml")
          alert("#{projectPath} doesn't contain AndroidManifest.xml file!")
          @exit()

      packagesDirs = atom.packages.getPackageDirPaths()

      packagePath = undefined
      for dir in packagesDirs
        if fs.existsSync("#{dir}/#{atom._debugger.name}")
           packagePath = "#{dir}/#{atom._debugger.name}"
           break

      ndkGdbPath = atom.config.get("#{atom._debugger.name}.ndkGdbPath")
      adbPath = atom.config.get("#{atom._debugger.name}.adbPath")

      if fs.existsSync(ndkGdbPath)
        command = ndkGdbPath
      else
        alert("ndk-gdb path not set");
        @destroy

      command = @setupNdkGdb packagePath, ndkGdbPath
      args = []

      if fs.existsSync(adbPath)
        args.push("--adb=#{adbPath}")
      else
        console.log('adb path not set')

      #args.push("--project=#{targetProject}")
      @process = new BufferedProcess({command, args, stdout, stderr}).process
      @stdin = @process.stdin
      @status = STATUS.NOTHING

    #todo optimize
    setupNdkGdb: (path, ndkgdbPath, force) ->
      ndkPath = ndkgdbPath.substring(0,ndkgdbPath.lastIndexOf("/")+1);
      lineArray = []
      atomNdkPath = "#{ndkPath}/ndk-gdb-atom"
      if !force
        if !fs.existsSync(atomNdkPath)
          force = true

      if force == true
          fs = require('fs')
          ndkPathCorrupt = true
          try
            lineArray = fs.readFileSync(ndkgdbPath).toString().split("\n");
            for i in [lineArray.length-1..0]
              if lineArray[i].indexOf('$GDBCLIENT') >= 0
                lineArray[i] = lineArray[i].replace('$GDBCLIENT', '$GDBCLIENT --interpreter=mi2');
                ndkPathCorrupt = false
                break
          catch error
            alert('Error reading ndk-gdb '+error.message)


          if ndkPathCorrupt == true
            alert("#{ndkgdbPath} doesn't seem to point to ndk-gdb")
            @destroy()
          else
           fs = require('fs')
           try
             console.log("Trying to write file #{atomNdkPath}")
             fd = fs.openSync(atomNdkPath, 'w' ,493)# 493 in octal is 0755
             if fd > 0
               for line in lineArray
                 fs.writeSync(fd,"#{line}\n")#
           catch error
             console.log(error)
             alert(error.message);
      atomNdkPath
