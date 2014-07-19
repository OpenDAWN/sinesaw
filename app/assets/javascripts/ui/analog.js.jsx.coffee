###* @jsx React.DOM ###

@Analog = React.createClass

  mixins: [Modelable('instrument')]

  setPolyphony: (e) ->
    @props.instrument.setPolyphony parseInt e.target.value

  render: ->
    options = for i in [1..@props.instrument.maxPolyphony]
      `<option key={i} value={i}>{i}</option>`

    `<div className="ui analog">
      <div className="column channel">
        <Slider
          label="Level"
          value={this.state.level}
          onChange={this.props.instrument.createSetterFor('level')}
        />
        <div className="ui">
          <select onChange={this.setPolyphony} value={this.state.polyphony}>{options}</select>
          <label>Poly</label>
        </div>
      </div>
      <div className="column">
        <Envelope
          label="Volume Env"
          env={this.props.instrument.state.volumeEnv}
          onChange={this.props.instrument.createSetterFor('volumeEnv')}
        />
      </div>
      <div className="column">
        <Envelope
          label="Filter Env"
          env={this.props.instrument.state.filterEnv}
          onChange={this.props.instrument.createSetterFor('filterEnv')}
        />
      </div>
      <div className="column oscillators">
        <Filter
          label="Filter"
          filter={this.props.instrument.state.filter}
          onChange={this.props.instrument.createSetterFor('filter')}
        />
        <Oscillator
          label="Osc 1"
          osc={this.props.instrument.state.osc1}
          onChange={this.props.instrument.createSetterFor('osc1')}
        />
        <Oscillator
          label="Osc 2"
          osc={this.props.instrument.state.osc2}
          onChange={this.props.instrument.createSetterFor('osc2')}
        />
      </div>
    </div>`