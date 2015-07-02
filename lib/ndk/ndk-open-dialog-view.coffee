{View, TextEditorView} = require 'atom-space-pen-views'
OpenDialogBase = require '../base/open-dialog-base'
fs = require 'fs'


module.exports =
class NDKGDBOpenDialogView extends OpenDialogBase
  @content: ->
    @div tabIndex: -1, class: 'ndk-debugger', =>
      @div class: 'block', =>
        @label 'Android NDK Debugger'
        @subview 'targetEditor', new TextEditorView(mini: true, placeholderText: 'Android Project Path')
      @div class: 'block', =>
        @button class: 'inline-block btn', outlet: 'attachButton', 'Attach'
        @button class: 'inline-block btn', outlet: 'runButton', 'Run'
        @button class: 'inline-block btn', outlet: 'cancelButton', 'Cancel'

  setupHandlers: (handler) ->
    @cancelButton.on 'click', (e) => @destroy()
    @attachButton.on 'click', (e) =>
      input = {}
      input.isValid = true
      input.projectPath = @targetEditor.getText()
      atom.config.set("#{atom._debugger.name}.projectPath", input.projectPath)
      if fs.existsSync(input.projectPath)
        @destroy()
        handler(input)
      else
        atom.confirm
          message: "The target doesn't exist :(, Check for typos"
          buttons:
            'Try Again': => # nothing to do here, just let the window close
            Cancel: => # run the delete handler
              @destroy()


  initialize: (handler) ->
    super handler
    projectPath = atom.config.get("#{atom._debugger.name}.projectPath")
    @targetEditor.setText(projectPath) if fs.existsSync(projectPath)
    paths = atom.project.getPaths()
    for path in paths
      if fs.existsSync(path+"/AndroidManifest.xml")
         @targetEditor.setText(path)
         break
