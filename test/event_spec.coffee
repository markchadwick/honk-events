expect  = require('chai').expect
events  = require '../lib/index'


class Eventted
  constructor: (@name='Eventted') ->
    events(this)


describe 'An event-aware instance', ->

  beforeEach ->
    unless events.isApplied(this) then events(this)

  afterEach ->
    @destroy()

  it 'should trigger simple events', (done) ->
    producer = new Eventted()
    consumer = new Eventted()

    consumer.on producer, 'bad', ->
      fail('Should not have gotten message', arguments...)

    consumer.on producer, 'good', (msg) ->
      expect(msg).to.equal 'Howdy!'
      done()

    producer.trigger 'good', 'Howdy!'

  it 'should not confuse events across instances', (done) ->
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

  it 'should not allow events to be re-mixed in', ->
    eventted = new Eventted()
    reMixin  = -> events(eventted)
    expect(reMixin).to.throw /Events already mixed in/

  it 'should know when the mixin is applied', ->
    class User

    user = new User()
    expect(events.isApplied(user)).to.be.false
    events(user)
    expect(events.isApplied(user)).to.be.true

  it 'should invoke subsequent callbacks after an exception is thrown'

  it 'should disassocaite itself with a space-delimited events on destroy'

  describe 'when overriding destroy', ->
    it 'should preserve the original objects destroy method', (done) ->
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

    it 'should pass given arguments to the implementation', ->
      class Destroyable
        constructor: -> events(this)
        destroy: (key) -> expect(key).to.equal 'pantaloons'
      new Destroyable().destroy('pantaloons')

    it 'should return the orig return value', ->
      class Destroyable
        constructor: (@name) -> events(this)
        destroy: (word) -> "#{@name} said #{word}"
      destroyable = new Destroyable('city boy')
      expect(destroyable.destroy('sushi')).to.equal 'city boy said sushi'

    it 'should wait for a deferred if given'

  describe 'as a producer', ->
    it 'should clean up its consumers when destroyed', ->
      producer = new Eventted()
      consumer = new Eventted()

      consumer.on producer, 'my pattern', ->
        throw Error('should have never been called')

      expect(Object.keys(producer._listeners)).to.have.length 2
      expect(consumer._listeningTo).to.have.length 2

      consumer.destroy()
      producer.trigger 'my pattern'

      expect(Object.keys(producer._listeners)).to.have.length 0
      expect(consumer._listeningTo).to.have.length 0


    it 'should trigger all events specified in a pattern', (done) ->
      producer = new Eventted()
      consumer = new Eventted()

      firstCalled = false
      consumer.on producer, 'first', ->
        firstCalled = true

      consumer.on producer, 'second', ->
        expect(firstCalled).to.be.true
        done()

      producer.trigger 'first second'

  describe 'as a consumer', ->
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

    it 'should no receive no callbacks after being destroyed', ->
      producer = new Eventted()
      consumer = new Eventted()

      consumer.on producer, 'event', ->
        throw Error('Should not have happened!')
      consumer.destroy()

      producer.trigger 'event'

    it 'should have "this" properly scoped in the callback', (done) ->
      @myCoolObject =
        name: 'seventeen'
        favoriteNumber: 17

      producer = new Eventted()

      @on producer, 'trigger', (arg) ->
        expect(arg).to.equal 'bonjour'
        expect(@myCoolObject).to.exist
        expect(@myCoolObject.name).to.equal 'seventeen'

        done()

      producer.trigger('trigger', 'bonjour')

describe 'split', ->
  beforeEach ->
    @split = events._split_

  it 'should not split a raw event', ->
    single = @split('single')
    expect(single).to.have.length 1
    expect(single[0]).to.equal 'single'

  it 'should split a basic string', ->
    names = @split('one two')
    expect(names).to.have.length 2
    expect(names[0]).to.equal 'one'
    expect(names[1]).to.equal 'two'

  it 'should ignore whitespace', ->
    names = @split(' one  two  three   ')
    expect(names).to.have.length 3
    expect(names[0]).to.equal 'one'
    expect(names[1]).to.equal 'two'
    expect(names[2]).to.equal 'three'
