{BufferedProcess, Emitter} = require 'atom'
{RESULT, parser} = require '../backend/gdb/gdb-mi-parser'
GDB = require '../backend/gdb/gdb'
fs = require 'fs'

module.exports =
  class NaclGdb extends GDB

    STATUS =
      NOTHING: 0
      RUNNING: 1
      ERROR: 2

    constructor: (targetProject,irtPath,consoleView) ->
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
            when '=' then null  # notify-async-output
            when '~' then null  # console-stream-output
            when '@' then null  # target-stream-output
            when '&' then null  # log-stream-output
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

      command = atom.config.get("#{atom._debugger.name}.naclGdbPath")

      args = []

      args.push("--interpreter=mi2")
      @process = new BufferedProcess({command, args, stdout, stderr}).process
      @stdin = @process.stdin
      @stdin.write("target remote localhost:4014\n")
      @stdin.write("nacl-irt #{irtPath}\n")
      @status = STATUS.NOTHING

    destroy: =>
      @process.kill()
