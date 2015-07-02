{View, TextEditorView} = require 'atom-space-pen-views'
fs = require 'fs'

module.exports =
class OpenDialogBase extends View
  @content: ->
    @div tabIndex: -1, class: 'atom-debugger', =>
      @div class: 'block', =>
        @label 'Gdb Debugger'
        @subview 'targetEditor', new TextEditorView(mini: true, placeholderText: 'Target Binary Path')
      @div class: 'block', =>
        @button class: 'inline-block btn', outlet: 'startButton', 'Start'
        @button class: 'inline-block btn', outlet: 'cancelButton', 'Cancel'

  setupHandlers: (params) ->
    @cancelButton.on 'click', (e) => @destroy()
    @startButton.on 'click', (e) =>
      params.target = @targetEditor.getText()
      if fs.existsSync(params.target)
        @destroy()
      else
        atom.confirm
          message: "The target doesn't exist :(, Check for typos"
          buttons: ["Try Again","Cancel"]
          if answer == 1
            @destroy()


  initialize: (params) ->
    @panel = atom.workspace.addModalPanel(item: this, visible: true)
    @targetEditor.focus()
    @setupHandlers(params)


  checkIfValid: ->
    return


  destroy: ->
    @panel.destroy()
