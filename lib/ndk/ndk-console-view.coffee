{View, TextEditorView} = require 'atom-space-pen-views'
NDKScrollView = require './ndk-console-scroll-view'
{MessagePanelView, LineMessageView} = require 'atom-message-panel'







module.exports =
class NDKConsoleView extends View
  @content: ->
    @div =>
      #@subview 'scrollView', new NDKScrollView()
      @subview 'commandInput', new TextEditorView(mini: true, placeholderText: 'Gdb Command Input')

  initialize: ->
    @commandInput.preempt('keydown',@onKeyDown)
    @messages = new MessagePanelView
        title: 'ndk-gdb Output!'
        closeMethod: 'hide'
    @messages.attach()


  setGDB: (gdb)->
    @GDB = gdb


  echoToConsole: (newText)->
  #  @scrollView.echoToConsole newText
     @messages.add new LineMessageView
         line: 1
         character: 4
         message: newText



  onKeyDown: (event,elementName) =>
    if event.which == 13
      @GDB.echoToStdin @commandInput.getText()
      event.preventDefault()
    true
