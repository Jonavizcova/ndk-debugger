{View, TextEditorView} = require 'atom-space-pen-views'
NDKScrollView = require './ndk-console-scroll-view'



module.exports =
class NDKConsoleView extends View
  @content: ->
    @div =>
      @subview 'scrollView', new NDKScrollView()
      @subview 'commandInput', new TextEditorView(mini: true, placeholderText: 'Gdb Command Input')

  initialize: ->
    @commandInput.preempt('keydown',@onKeyDown)

  setGDB: (gdb)->
    @GDB = gdb


  echoToConsole: (newText)->
    @scrollView.echoToConsole newText


  onKeyDown: (event,elementName) =>
    if event.which == 13
      @GDB.echoToStdin @commandInput.getText()
      event.preventDefault()
    true
