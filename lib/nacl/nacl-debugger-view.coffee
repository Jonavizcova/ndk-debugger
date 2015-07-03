{Point, Range, TextEditor, TextBuffer, CompositeDisposable} = require 'atom'
{View} = require 'atom-space-pen-views'
NaclGdb = require '../nacl/nacl-gdb'
path = require 'path'
AsmViewer = require '../asm-viewer'
DebuggerView = require '../base/debugger-view'
NDKConsoleView = require '../ndk/ndk-console-view'


module.exports =
class NDKDebuggerView extends DebuggerView
  @content: ->
    @div class: 'atom-debugger', =>
      @header class: 'header', =>
        @span class: 'header-item title', 'Nacl/NDK Debugger'
        @span class: 'header-item sub-title', outlet: 'targetLable'
      @div class: 'btn-toolbar', =>
        @div class: 'btn-group', =>
          @div class: 'btn disabled', outlet: 'continueButton', 'Continue'
          @div class: 'btn disabled', outlet: 'nextButton', 'Next'
          @div class: 'btn disabled', outlet: 'stepButton', 'Step In'
          @div class: 'btn disabled', outlet: 'stepOutButton', 'Step Out'
          @div class: 'btn disabled', outlet: 'disableButton', 'Disable breakPoints'
          @div class: 'btn disabled', outlet: 'interruptButton', 'Interrupt'
          @div class: 'btn disabled', outlet: 'runButton', 'Run'



  initialize: (input) ->
    @consoleView = new NDKConsoleView()
    @GDB = new NaclGdb(input.gdbPath,input.irtPath,@consoleView)
    @consoleView.setGDB @GDB
    @targetLable.text(input.gdbPath)
    mainBreak = false;
    @projectDirectories = []

    #@GDB.set 'target-async', 'on', (result) ->
    @GDB.setSourceDirectories atom.project.getPaths(), (done) ->

    @breaks = {}
    @stopped = {marker: null, fullpath: null, line: null}
    @asms = {}
    @cachedEditors = {}
    @handleEvents()

    contextMenuCreated = (event) =>
      if editor = @getActiveTextEditor()
        component = atom.views.getView(editor).component
        position = component.screenPositionForMouseEvent(event)
        @contextLine = editor.bufferPositionForScreenPosition(position).row

    @menu = atom.contextMenu.add {
      'atom-text-editor': [{
        label: 'Toggle Breakpoint',
        command: 'KuttiDebugger:toggle-breakpoint',
        created: contextMenuCreated
      }]
    }

    @gdbPanel = atom.workspace.addTopPanel(item: @, visible: true)
    @panel = atom.workspace.addBottomPanel(item: @consoleView,visible: true)

    @breakPoints = [];
    @loadBreakPoints()
    @listExecFile()

  echoToConsole: (msg)->
    @consoleView.echo msg

  handleEvents: ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace', 'KuttiDebugger:toggle-breakpoint': =>
      @toggleBreak(@getActiveTextEditor(), @contextLine)

    @subscriptions.add atom.workspace.observeTextEditors (editor) =>
      fullpath = editor.getPath()
      @cachedEditors[fullpath] = editor
      @breaks[fullpath] ?= {}
      @refreshBreakMarkers(editor)
      @refreshStoppedMarker(editor)
      @hackGutterDblClick(editor)

    @subscriptions.add atom.project.onDidChangePaths (paths) =>
      @GDB.setSourceDirectories paths, (done) ->

    @runButton.on 'click', =>
      @GDB.run (result) ->

    @continueButton.on 'click', =>
      @GDB.continue (result) ->

    @interruptButton.on 'click', =>
      @GDB.interrupt (result) ->

    @nextButton.on 'click', =>
      @GDB.next (result) ->

    @stepButton.on 'click', =>
      @GDB.step (result) ->

    @stepOutButton.on 'click', =>
      @GDB.exitFunction (result) ->

    @GDB.onExecAsyncRunning (result) =>
      @goRunningStatus()

    @GDB.onExecAsyncStopped (result) =>
      @goStoppedStatus()

      unless frame = result.frame
        @goExitedStatus()
      else
        if frame.file != undefined
          fullpath = path.resolve(frame.file)
          line = Number(frame.line)-1

          @projectDirectories = atom.project.getDirectories()

          gotoNextOrStep = false

          for directory in @projectDirectories
            if directory.contains fullpath
              if @exists(fullpath)
                atom.workspace.open(fullpath, {debugging: true, fullpath: fullpath, startline: line}).done (editor) =>
                  @stopped = {marker: @markStoppedLine(editor, line), fullpath, line}
                gotoNextOrStep = false
                break
              else
                gotoNextOrStep = true;
            else
              gotoNextOrStep = true;

          if(gotoNextOrStep)
              @consoleView.echoToConsole "file (#{fullpath}) not in project paths..."
              @GDB.exitFunction (result) ->

  destroy: ->
    @consoleView.destroy()
    @GDB.destroy()
    super
    @gdbPanel.destroy()
