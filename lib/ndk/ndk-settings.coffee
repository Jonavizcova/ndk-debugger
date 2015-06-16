 {View, TextEditorView} = require 'atom-space-pen-views'
 fs = require 'fs'
 remote = require "remote"
 dialog = remote.require "dialog"
 SettingsView = require '../base/settings'


 module.exports =
 class NDKSettingsView extends SettingsView
   @content: ->
     @div tabIndex: -1, class: 'project-find padded', =>
      @section class: 'input-block', =>
        @div class: 'input-block-item input-block-item--flex editor-container', =>
          @subview 'ndkPathEditor', new TextEditorView(mini: true, placeholderText: 'Find in project')
          @button class: 'inline-block btn', outlet: 'ndkButton', 'Browse for NDK'

        @div class: 'input-block-item', =>
          @subview 'sdkPathEditor', new TextEditorView(mini: true, placeholderText: 'Android SDK Path')
          @button class: 'inline-block btn', outlet: 'sdkButton', 'Browse for SDK'

      @section class: 'input-block', =>
        @div class: 'input-block-item input-block-item--flex editor-container', =>
          @button class: 'inline-block btn', outlet: 'saveButton', 'Save'
          @button class: 'inline-block btn', outlet: 'cancelButton', 'Cancel'

    setupHandlers: (params) ->
      @sdkButton.on 'click', (e) =>
        @selectPath @sdkPathEditor
      @ndkButton.on 'click', (e) =>
        @selectPath @ndkPathEditor
      @saveButton.on 'click', (e) =>
          @selectPath @sdkPathEditor
      @cancelButton.on 'click', (e) =>
          @selectPath @ndkPathEditor
