expect  = require('chai').expect

events  = require '../lib/index'
require '../lib/tests'

class Eventted
  constructor: ->
    events(this)


describe 'A mixed in test', ->

  it 'should have event methods mixed in', ->
    expect(this).to.respondTo 'on'
    expect(this).to.respondTo 'trigger'
    expect(this).to.respondTo 'destroy'

  it 'should track events', (done) ->
    eventted = new Eventted()

    expect(Object.keys(@_listeners)).to.have.length 0
    expect(@_listeningTo).to.have.length 0

    @on eventted, 'speak', (name) ->
      expect(name).to.equal 'Frank'
      done()

    eventted.trigger 'speak', 'Frank'
