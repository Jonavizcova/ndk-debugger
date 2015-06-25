{View, TextEditorView} = require 'atom-space-pen-views'
NDKScrollView = require './ndk-console-scroll-view'
{MessagePanelView, PlainMessageView} = require 'atom-message-panel'







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
        autoScroll: true
    @messages.attach()


  setGDB: (gdb)->
    @GDB = gdb


  echoToConsole: (newText)->
  #  @scrollView.echoToConsole newText
     @messages.add new PlainMessageView
         message: newText
     @messages.updateScroll()




  onKeyDown: (event,elementName) =>
    if event.which == 13
      @GDB.executeUserCommand @commandInput.getText()
      event.preventDefault()
    true
