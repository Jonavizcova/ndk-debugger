{View, TextEditorView} = require 'atom-space-pen-views'
fs = require 'fs'
remote = require "remote"
dialog = remote.require "dialog"


module.exports =
class SettingsView extends View
  @content: ->
    @div tabIndex: -1, class: 'kutti-debugger-setting', =>
      @div class: 'inline-block', =>
        @label 'Kutti Debugger Setting'
        @subview 'ndkPathEditor', new TextEditorView(mini: true, placeholderText: 'Android NDK Path')
        @button class: 'inline-block btn', outlet: 'ndkButton', 'Browse'
      @div class: 'inline-block', =>
        @subview 'sdkPathEditor', new TextEditorView(mini: true, placeholderText: 'Android SDK Path')
        @button class: 'inline-block btn', outlet: 'sdkButton', 'Cancel'

  setupHandlers: (params) ->
    @sdkButton.on 'click', (e) =>
      @selectPath @sdkPathEditor
    @ndkButton.on 'click', (e) =>
      @selectPath @ndkPathEditor
      # params.target = @targetEditor.getText()
      # if fs.existsSync(params.target)
      #   @destroy()
      # else
      #   atom.confirm
      #     message: "The target doesn't exist :(, Check for typos"
      #     buttons: ["Try Again","Cancel"]
      #     if answer == 1
      #       @destroy()

  selectPath: (editor) ->
    path = dialog.showOpenDialog({ properties: ['openDirectory']})
    console.log(path[0])
    editor.setText(path[0])

  initialize: (params) ->
    @panel = atom.workspace.addModalPanel(item: this, visible: true)
    @ndkPathEditor.focus()
    @setupHandlers(params)


  checkIfValid: ->
    return


  destroy: ->
    @panel.destroy()
