NDKGDBOpenDialogView = require './ndk/ndk-open-dialog-view'
NDKDebuggerView = require './ndk/ndk-debugger-view'
NDKSettingsView = require './ndk/ndk-settings'
{CompositeDisposable} = require 'atom'
fs = require 'fs'

module.exports = Debugger =
  subscriptions: null

  config:
    ndkGdbPath:
      type: 'string'
      default: "Path to the modified ndk-gdb, see Readme"
    adbPath:
      type: 'string'
      default: "Path to the adb"
    projectPath:
      type: 'string'
      default: "This can be set from the menu too!"

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'KuttiDebugger:start': => @startDebugging('ndk')
    # @subscriptions.add atom.commands.add 'atom-workspace', 'KuttiDebugger:settings': => @showSettings('ndk')
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

  showSettings: (whichDebugger)->
    if @settingsView
       @settingsView.destroy()

    switch whichDebugger
      when "ndk" then @setting NDKSettingsView
      when "gdb" then @setting GDBOpenDialogView

  setting: (settingView)->
    @settingsView = new settingView (input) =>
      alert "Setting done"
