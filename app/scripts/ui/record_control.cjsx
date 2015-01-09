# A modal audio recording interface

React = require 'react/addons'
Waveform = require './waveform'
Meter = require './meter'
AudioRecorder = require '../dsp/audio_recorder'
context = require '../dsp/global_context'

defaultState =
  sampleData: null
  error: null
  active: false
  playing: false
  cropStart: 0
  cropEnd: 1


module.exports = React.createClass

  getInitialState: ->
    defaultState

  onClick: ->
    if @state.active
      @stop()
    else unless @state.sampleData?
      @record()

  setCropStart: (value) ->
    @setState
      cropStart: value
      cropEnd: Math.max value, @state.cropStart

  setCropEnd: (value) ->
    @setState
      cropEnd: value
      cropStart: Math.min value, @state.cropEnd

  croppedSampleData: ->
    length = @state.sampleData.length
    @state.sampleData.subarray Math.floor(@state.cropStart * length), Math.floor(@state.cropEnd * length)

  record: ->
    return if @state.active

    @clear()

    navigator.webkitGetUserMedia
      audio: true
      (localMediaStream) =>
        input = context.createMediaStreamSource localMediaStream
        recorder = new AudioRecorder input
        recorder.record()
        @setState {recorder, active: true}
      (errorCode) =>
        @setState error: 'Unable to access microphone'

  stop: ->
    return unless @state.active

    if @state.player
      @state.player.onended = false
      @state.player.stop()

    @state.recorder.stop().getSampleData (sampleData) =>
      @setState
        recorder: null
        sampleData: sampleData
        error: null
        active: false
        playing: false

  play: ->
    if @state.player
      @state.player.onended = null
      @state.player.stop()
      @state.player.disconnect context.destination

    data = @croppedSampleData()

    player = context.createBufferSource()
    player.connect context.destination
    audioBuffer = context.createBuffer 1, data.length, context.sampleRate
    audioBuffer.getChannelData(0).set data
    player.buffer = audioBuffer
    player.onended = => @setState playing: false
    player.start()

    @setState {player, playing: true}

  clear: ->
    @setState defaultState

  confirm: ->
    @props.onConfirm @croppedSampleData()

  render: ->

    leftButtons = [
      <div
        className={"icon icon-record #{if @state.active then ' active' else ''}"}
        key="r"
        onClick={if @state.active then @stop else @record}
      />
    ]

    rightButtons = [
      <div className="icon icon-cross" key="c" onClick={@props.onCancel}/>
    ]

    if @state.sampleData?

      waveform = <Waveform
        sampleData={@state.sampleData}
        selectionStart={@state.cropStart}
        selectionEnd={@state.cropEnd}
        markers={
          start:
            value: @state.cropStart
            onChange: (cropStart) => @setState {cropStart}
          end:
            value: @state.cropEnd
            onChange: (cropEnd) => @setState {cropEnd}
        }
      />

      leftButtons.push <div
        className="icon icon-play #{if @state.playing then ' active' else ''}"
        key="p"
        onClick={if @state.playing then @stop else @play}
      />

      rightButtons.push <div className="icon icon-checkmark" key="s" onClick={@confirm}/>

    else

      message = if @state.error?
        @state.error
      else if @state.active
        'Recording, click to stop'
      else
        'Click to record'

      instruction = <div className="instruction">{message}</div>


    <div className="ui record-control">
      <div className="row sample">
        <div className="display" onClick={@onClick}>
          {waveform}
          {instruction}
        </div>
      </div>
      <div className="row controls">
        <div className="left">
          {leftButtons}
        </div>
        <div className="right">
          {rightButtons}
        </div>
      </div>
    </div>
