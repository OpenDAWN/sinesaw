React = require 'react/addons'
Waveform = require './waveform'
RecordControl = require './record_control'
decoder = require '../dsp/global_context'

module.exports = React.createClass

  # range in pixels for vertical drag to zoom
  range: 300
  dragTypeDistance: 10

  getDefaultProps: ->
    sampleStart: 0

  triggerFileInput: ->
    @refs.input.getDOMNode().click()

  onFileSelect: ->
    file = @refs.input.getDOMNode().files[0]

    if file?
      reader = new FileReader
      reader.onload = (e) =>
        decoder.decodeAudioData e.target.result, (buffer) =>
          sampleData = buffer.getChannelData 0
          @props.sampler.update (sampler) -> sampler.merge {sampleName: file.name, sampleData}
      reader.readAsArrayBuffer file

  clear: ->
    @props.sampler.update (sampler) -> sampler.merge sampleName: null, sampleData: null

  recordSample: ->
    @props.app.launchModal <RecordControl
      onCancel={@props.app.dismissModal}
      onConfirm={
        (sampleData) =>
          @props.sampler.merge {sampleName: 'recording.wav', sampleData}
          @props.app.dismissModal()
      }
    />

  setStart: (value) ->
    @props.sampler.merge
      start: value
      loop: Math.max value, @props.sampler.get 'loop'

  setLoop: (value) ->
    @props.sampler.merge
      loop: value
      start: Math.min value, @props.sampler.get 'start'

  render: ->
    sampler = @props.sampler
    sampleStart = sampler.get 'start'
    loopActive = sampler.get 'loopActive'
    loopValue = sampler.get 'loop'
    sampleData = sampler.get 'sampleData'

    markers = {}

    if sampleStart?
      markers.start =
        value: sampleStart
        onChange: @setStart

    if loopActive == 'loop'
      markers.loop =
        value: loopValue
        onChange: @setLoop

    <div className="ui sample-control">
      <input type="file" ref="input" onChange={@onFileSelect}/>
      <div
        className="display"
        ref="container"
        onClick={if sampleData? then null else @triggerFileInput}
      >
        {if sampleData? then null else <div className="instruction">click to upload</div>}
        <Waveform
          sampleData={sampleData}
          selectionStart={sampleStart or 0}
          selectionEnd={if loopActive == 'loop' then loopValue else 1}
          markers={markers}
        />
      </div>
      <div className="controls">
        <div className="control" onClick={@triggerFileInput}>
          <div className="icon icon-arrow-up"/>
        </div>
        <div className="control" onClick={@recordSample}>
          <div className="icon icon-record"/>
        </div>
        <div className="control" onClick={@clear}>
          <div className="icon icon-cross"/>
        </div>
        <div className="file-name">{@props.sampleName}</div>
      </div>
      <label>{@props.label}</label>
    </div>
