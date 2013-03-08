Honk! Events!
=============

[Docs live here](http://markchadwick.github.com/honk-events/)

A super-small events package for adding basic events to instances. There's a
simple mechanism to cleanup bindings for objects that are about to be destroyed
(so they don't hang around un-GC-able forever). It's reccomended.

Usage
-----

```coffee
mixinEvents = require 'honk-events'

class Producer
  constructor: ->
    mixinEvents(this)

  announce: (name) ->
    @trigger 'say', name

class Consumer
  constructor: (producer) ->
    mixinEvents(this)

    @on producer, 'say', (name) ->
      console.log "Producer said '#{name}!'"

  destroy: ->
    console.log 'Goodbye cruel world'


producer = new Producer()
consumer = new Consumer()

producer.say 'Hello!'
# >>> Producer said 'Hello!!'

# Clean up any events the consumer has accumulated
consumer.destroy()
# >>> Goodbye curel world
```

Build status
------------
[![Build Status](https://secure.travis-ci.org/markchadwick/honk-events.png)](http://travis-ci.org/markchadwick/honk-events)
