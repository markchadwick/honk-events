# **Honk! Events!** is a very small stand-alone event system that provides the
# means to clean up after itself. Before an instance and produce *or consume*
# events, it must mix in the event library. The simplest example follows.
#
#     mixinEvents = require 'honk-events'
#
#     class Producer
#       constructor: (@name) ->
#         mixinEvents(this)
#
#       say: (message)
#         @trigger 'say', "#{@name} said #{message}"
#
#     class Consumer
#       constructor: (name, producers...) ->
#         mixinEvents(this)
#
#         for producer in producers
#           @on producer, 'say', (message) ->
#             console.log "[#{name}] #{message}"
#
#     producer1 = new Producer('p1')
#     producer2 = new Producer('p2')
#     consumer1 = new Consumer('c1', producer1, producer2)
#     consumer2 = new Consumer('c2', producer1, producer2)
#
#     # Trigger a message on p1 which should be relayed to each of the
#     # consumers.
#     producer1.say 'hello'
#     >>> [c1] p1 said hello
#     >>> [c2] p1 said hello
#
#     # destroy consumer1, cleaning up all of its references
#     consumer1.destory()
#
#     # Trigger a message on p2, which now only has c2 bound to its events, as
#     # c1 has been destroyed.
#     producer2.say 'party anyone?'
#     >>> [c2] p2 said party anyone?
#
# Event Cleanup
# -------------
# One genesis for a li'l event library was proper event cleanup. It's important
# to call `destroy` on an instance after it should no longer receive events.
# With standard event binding, a reference to an instance may leak when scoping
# the callback, which prevents the instance from being garbage collected.
#
# Tests
# -----
# The idea that consumers must be bound to an event-aware instance may clash
# with test code. For [Mocha](http://visionmedia.github.com/mocha/) and
# [Jasmine](http://pivotal.github.com/jasmine/) tests, see the reference [test
# mixin](./tests.html). It will set up the appropriate setup and teardown
# methods so that tests can consume methods.
#
#     require 'honk-events/lib/tests'
#
#     describe 'Echos', ->
#       it 'should produce events', (done) ->
#         echo = new EchoProducer()
#         @on echo, 'echo', (message) ->
#           expect(message).to.equal 'bonjour'
#           done()
#
#         echo.trigger 'echo', 'bonjour'
#
# The provided code can serve as a guide for other test systems. All four lines
# of it.

_ = require 'lodash'


# `isApplied` It's considered an error to mix in the event system to an object
# more than once, so it is sometimes nice to know if it's already been mixed in
# (such as in the case of a cached object factory). This implementation is naive
# and subject to change.
isApplied = (obj) -> obj._listeners?

# Expand an event pattern into a list of discrete event names. For the moment,
# this simply splits on a space and gives any non-empty pattern.
split = (events) -> event for event in events.split(' ') when event

# `mixinEvents` Mix in methods of the event system to an object. It's worth
# noting that events keep track of all their bindings, so it's expected that
# this not be something funky like a function or a class.
mixinEvents = (obj) ->
  if isApplied(obj)
    throw Error("Events already mixed in to #{obj}")

  # The method to clean up event bindings of an instance is `destroy`. However,
  # if a `destroy` property already exists on the object, it will still be
  # invoked. Here a local reference is copied before the method is overwritten.
  obj_destroy = obj.destroy

  _.extend obj,
    _listeners: {}
    _listeningTo: []

    # on(producer, events, callback)
    # -------------------------------
    # Sets up an event binding on a consumer. The pattern may be a
    # space-delimited string of callbacks. For example:
    #
    #     @on producer, 'click hover', (el) ->
    #       console.log('interacted with', el)
    #
    # Unlike some other event libraries, take care to note that the `all` event
    # has no special meaning and will not bind to all events.
    on: (producer, events, callback) ->
      for event in split(events)
        @_listeningTo.push([producer, event, callback])
        producer._bindListener(event, callback)

    # trigger(events, data...)
    # -------------------------
    # Triggers an event and sends the payload to all interested consumers. Each
    # consumer will run in the current thread of execution. If multiple
    # arguments are given, consumers will see them as separate arguments. For
    # example:
    #
    #     mixinEvents = require 'honk-events'
    #
    #     class Producer
    #       constructor: (@prefix) ->
    #         mixinEvents(this)
    #
    #       announce: (message) ->
    #         @trigger('announce, @prefix, message)
    #
    #     class Consumer
    #       constructor: (producer) ->
    #         mixinEvents(this)
    #         producer.on 'announce', (prefix, message) ->
    #           console.log prefix, 'said', message
    #
    # In this example, the consumer's callback will get `@prefix` and `message`
    # as independent arguments to its callback. If its callback only provided
    # one function argument, it would only receive `@prefix`.
    #
    # Note that each callback is invoked in the current thread of execution. If
    # there is a potentially invasive callback, it may prevent other callbacks
    # from running promptly. Similarly, if an exception is thrown
    #
    # If multiple space-delimited event types are given, all will be triggered.
    trigger: (events, data...) ->
      f(data...) for f in (@_listeners[event] or []) for event in split(events)

    # destroy()
    # ---------
    # When an event-aware instance is destroyed, its consuming callbacks are
    # destroyed with it. Likewise, the consumers of its producing callbacks will
    # be cleaned up. As mentioned in the opening, if a `destroy` method is
    # already present on the instance, it will be invoked after all callbacks
    # have been cleaned up.
    destroy: ->
      for [producer, event, callback] in @_listeningTo
        producer._unbindListener(event, callback)
      @_listeningTo = []
      @_listeners = {}
      obj_destroy?.apply(obj)

    # `_bindListener` Takes a pattern of events and binds the callback of each
    # to the producer. This will not (in itself) track any event bindings from
    # the consuer's point of view.
    _bindListener: (pattern, callback) ->
      for p in pattern.split(' ')
        (@_listeners[pattern] or= []).push(callback)

    # `_unbindListener` will will walk the bindings of a producer when a
    # consumer is destroyed and unregister each callback.
    _unbindListener: (event, callback) ->
      return unless @_listeners[event]
      idx = @_listeners[event].indexOf(callback)
      if idx != -1
        @_listeners[event].splice(idx, 1)


mixinEvents.isApplied = isApplied
mixinEvents._split_   = split


module.exports = mixinEvents
