{View, TextEditorView} = require 'atom-space-pen-views'
OpenDialogBase = require '../base/open-dialog-base'
fs = require 'fs'


module.exports =
class NaClGDBOpenDialogView extends OpenDialogBase
  @content: ->
    @div tabIndex: -1, class: 'ndk-debugger', =>
      @div class: 'block', =>
        @label 'NaCl Debugger'
        @subview 'targetEditor', new TextEditorView(mini: true, placeholderText: 'nacl debugger path')
        @subview 'irtPathEditor', new TextEditorView(mini: true, placeholderText: 'target irt')
      @div class: 'block', =>
        @button class: 'inline-block btn', outlet: 'attachButton', 'Attach'
        @button class: 'inline-block btn', outlet: 'cancelButton', 'Cancel'

  setupHandlers: (handler) ->
    @cancelButton.on 'click', (e) => @destroy()
    @attachButton.on 'click', (e) =>
      input = {}
      input.isValid = true
      input.gdbPath = @targetEditor.getText()
      input.irtPath = @irtPathEditor.getText()
      atom.config.set('kutti-ndk-debugger.naclGdbPath', input.gdbPath)
      atom.config.set('kutti-ndk-debugger.irtPath', input.irtPath)
      if fs.existsSync(input.gdbPath)
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
    projectPath = atom.config.get('kutti-ndk-debugger.naclGdbPath')
    @targetEditor.setText(projectPath) if fs.existsSync(projectPath)
    irtPath = atom.config.get('kutti-ndk-debugger.irtPath')
    @irtPathEditor.setText(irtPath) if fs.existsSync(irtPath)
