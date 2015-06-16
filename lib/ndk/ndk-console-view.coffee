{ScrollView} = require 'atom-space-pen-views'


module.exports =
class NDKConsoleView extends ScrollView
  @content: ->
    @div class: 'ndk-console', =>
#       @header class: 'header', =>
#         @subview 'targetEditor', new TextEditorView(mini: true, placeholderText: 'Android Project Path')

  initialize: ->
    @textBuffer = "'NDK Console View"
    super
    @height(150)
    @text(@textBuffer)



  echoToConsole: (newText)->
    @textBuffer += '\n' + newText
    @text(@textBuffer)
