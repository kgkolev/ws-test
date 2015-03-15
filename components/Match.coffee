noflo = require 'noflo'

class Match extends noflo.Component ->
  
  constructor: ->
    @matches = null
    @methods = null
    @groups = null
    
    @outPorts.add 'out'
    @outPorts.add 'fail'

    @inPorts.add 'match', (event, match) =>
      return unless event == 'data'
      @matches ?= []
      @matches.push new RegExp match

    @inPorts.add 'method', (event, method) =>
      return unless event == 'data'
      @methods ?= []
      @methods.push method.toLowerCase()

    @inPorts.add 'in', (event, payload) =>
      if event == 'connect'
        @groups = []
      else if event == 'begingroup'
        @groups.push payload
      else if event == 'endgroup'
        @groups.pop()
      else if event == 'disconnect'
        @outPorts.out.disconnect() if @outPorts.out.isAttached()
        @outPorts.fail.disconnect() if @outPorts.fail.isAttached()
      else if event == 'data'
        success = true

        # Match HTTP methods
        if @methods?
          method = data.req.method.toLowerCase()
          success = false unless @methods.indexOf(method) > -1

        # Match URL
        if @matches
          url = data.req.url.replace (new RegExp('\\?.+$')), ''
          matched = false
          for match in @matches
            matched = true if url.match(match)?
          success = false unless matched

        # If all pass, forward to OUT; FAIL otherwise
        if success
          @output 'out', data
        else
          @output 'fail', data

  output: (portName, data) ->
    port = @outPorts[portName]

    port.beginGroup group for group in @groups
    port.send data
    port.endGroup() for group in @groups

exports.getComponent = -> new Match