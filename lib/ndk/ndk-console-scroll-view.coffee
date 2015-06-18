{View} = require 'atom-space-pen-views'


module.exports =
class NDKScrollView extends View
  @content: ->
    @div class:'ndk-gdb-console-view', =>
      @div class:'ndk-gdb-text-view',outlet: "textView"

  initialize: ->
    @maxLines = 1000
    @currentId = 0
    @textBuffer = "NDK Console View"
    @textView.html("#{@textBuffer}")


  echoToConsole: (newText)->
    @textView.remove("#id#{@currentId}")
    @textView.append("<div id='id#{@currentId}'>#{newText}</div>")
    @textView.append("<div id='id#{@currentId}'>---------------------------</div>")
    @textView.scrollToBottom()
    if @currentId++ >= @maxLines
       @currentId = 0
