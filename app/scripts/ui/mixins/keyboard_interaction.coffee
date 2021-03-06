# global keyboard controls mixin, included by the App component

Keyboard = require 'keyboardjs'

module.exports =

  componentDidMount: ->
    @keyBindings = [
      Keyboard.on 'space', @onSpaceKey
      Keyboard.on 'command + z', @undo
      Keyboard.on 'command + shift + z', @redo
    ]

  componentWillUnmount: ->
    binding.clear() for binding in @keyBindings

  onSpaceKey: (e) ->
    e.preventDefault()
    if @props.song.playing
      @props.song.pause()
    else
      @props.song.play()

  undo: (e) ->
    @props.history.undo()

  redo: ->
    @props.history.redo()
