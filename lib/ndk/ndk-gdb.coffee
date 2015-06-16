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

    constructor: (targetProject) ->
      @breakPoints = []
      @token = 0
      @handler = {}
      @emitter = new Emitter
      @stdoutMessage = "";

      stdout = (lines) =>
        console.log(lines)
        for line in lines.split('\n')
          switch line[0]
            when '+' then null  # status-async-output
            when '=' then null  # notify-async-output
            when '~' then null  # console-stream-output
            when '@' then null  # target-stream-output
            when '&' then null  # log-stream-output
            when '*'            # exec-async-output
              {clazz, result} = parser.parse(line.substr(1))
              @emitter.emit 'exec-async-output', {clazz, result}
              @emitter.emit "exec-async-running", result if clazz == RESULT.RUNNING
              @emitter.emit "exec-async-stopped", result if clazz == RESULT.STOPPED

            else                # result-record
              if line[0] <= '9' and line[0] >= '0'
                {token, clazz, result} = parser.parse(line)
                @handler[token](clazz, result)
                delete @handler[token]


      stderr = (lines) =>
        @errorMessage = lines

      command = '/ndk-gdb-atom'
      ndkGdbPath = atom.config.get('kutti-ndk-debugger.ndkGdbPath')
      adbPath = atom.config.get('kutti-ndk-debugger.adbPath')

      args = []
      if fs.existsSync(ndkGdbPath)
        command = ndkGdbPath

      if fs.existsSync(adbPath)
        args.push("--adb=#{adbPath}")
    
      args.push("--project=#{targetProject}")
      @process = new BufferedProcess({command, args, stdout, stderr}).process
      @stdin = @process.stdin
      @status = STATUS.NOTHING
