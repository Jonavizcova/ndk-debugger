NDKGDBOpenDialogView = require './ndk/ndk-open-dialog-view'
NDKDebuggerView = require './ndk/ndk-debugger-view'
{CompositeDisposable} = require 'atom'
fs = require 'fs'

module.exports = Debugger =
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'debugger:toggle': => @startDebugging('ndk')
    @subscriptions.add atom.commands.add 'atom-workspace', 'core:close': =>
      @debuggerView?.destroy()
      @debuggerView = null
    # @subscriptions.add atom.commands.add 'atom-workspace', 'core:cancel': =>
    #   @debuggerView?.destroy()
    #   @debuggerView = null

  deactivate: ->
    @subscriptions.dispose()
    @openDialogView.destroy()
    @debuggerView?.destroy()

  serialize: ->


  startDebugging: (whichDebugger)->
    if @debuggerView
       @debuggerView.destroy()

    switch whichDebugger
      when "ndk" then @debug NDKGDBOpenDialogView, NDKDebuggerView
      when "gdb" then @debug GDBOpenDialogView, GDBDebuggerView

  debug: (openDialog,debuggerView)->
    @openDialogView = new openDialog (input) =>
      if input.isValid == true
        @debuggerView = new debuggerView(input)
