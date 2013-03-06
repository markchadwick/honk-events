expect  = require('chai').expect
events  = require '../lib/index'


class Eventted
  constructor: ->
    events(this)


describe 'Events', ->

  it 'should trigger simple events', (done) ->
    producer = new Eventted()
    consumer = new Eventted()

    consumer.on producer, 'bad', ->
      fail('Should not have gotten message', arguments...)

    consumer.on producer, 'good', (msg) ->
      expect(msg).to.equal 'Howdy!'
      done()

    producer.trigger 'good', 'Howdy!'

  it 'should not confuse events accross instances', (done) ->
    producer1 = new Eventted()
    producer2 = new Eventted()
    consumer1 = new Eventted()
    consumer2 = new Eventted()

    consumer1.on producer1, 'say', (name) ->
      expect(name).to.equal 'Producer 1'
      done()

    consumer2.on producer2, 'say', (name) ->
      fail('Consumer should not have gotten', name)

    producer1.trigger 'say', 'Producer 1'

  it 'should pass var arguments', ->
    producer = new Eventted()
    consumer = new Eventted()

    people = {}
    consumer.on producer, 'see', (name, age) -> people[name] = age

    producer.trigger 'see', 'Frank', 45
    producer.trigger 'see', 'Jim', 22

    expect(people['Frank']).to.equal 45
    expect(people['Jim']).to.equal 22

  it 'should clean up references on destroy', ->
    producer  = new Eventted()
    consumer1 = new Eventted()
    consumer2 = new Eventted()

    consumer1Msgs = []
    consumer2Msgs = []

    consumer1.on producer, 'say', (m) -> consumer1Msgs.push(m)
    consumer2.on producer, 'say', (m) -> consumer2Msgs.push(m)

    producer.trigger 'say', 'Hello'
    expect(consumer1Msgs).to.have.length 1
    expect(consumer2Msgs).to.have.length 1

    expect(producer._listeners['say']).to.have.length 2
    consumer1.destroy()
    expect(producer._listeners['say']).to.have.length 1
    producer.trigger 'say', 'There'

    expect(consumer1Msgs).to.have.length 1
    expect(consumer2Msgs).to.have.length 2

    consumer2.destroy()
    expect(producer._listeners['say']).to.be.empty

  it 'should not allow events to be re-mixed in', ->
    eventted = new Eventted()
    reMixin  = -> events(eventted)
    expect(reMixin).to.throw /Events already mixed in/

  it 'should preserve the origional objects destroy method', (done) ->
    class RobertOppenheimer
      constructor: -> events(this)
      destroy: -> done()

    producer  = new Eventted()
    robby     = new RobertOppenheimer()

    expect(robby._listeningTo).to.have.length 0
    robby.on producer, 'say', (name) ->
    expect(robby._listeningTo).to.have.length 1

    robby.destroy()
    expect(robby._listeningTo).to.have.length 0

  it 'should know when the mixin is applied', ->
    class User

    user = new User()
    expect(events.isApplied(user)).to.be.false
    events(user)
    expect(events.isApplied(user)).to.be.true
