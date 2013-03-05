_ = require 'lodash'


mixinEvents = (obj) ->
  obj_destroy = obj.destroy

  _.extend obj,
    _listeners: {}
    _listeningTo: []

    on: (producer, pattern, callback) ->
      @_listeningTo.push([producer, pattern, callback])
      producer._bindListener(pattern, callback)

    trigger: (pattern, data...) ->
      (f(data...) for f in (@_listeners[pattern] or []))

    destroy: ->
      for [producer, pattern, callback] in @_listeningTo
        producer._unbindListener(pattern, callback)
      @_listeningTo = []
      @_listeners = {}
      obj_destroy?.apply(obj)

    _bindListener: (pattern, callback) ->
      for p in pattern.split(' ')
        @_listeners[pattern] or= []
        @_listeners[pattern].push(callback)

    _unbindListener: (pattern, callback) ->
      for p in pattern.split(' ')
        continue unless @_listeners[pattern]
        idx = @_listeners[pattern].indexOf(callback)
        if idx != -1
          @_listeners[pattern].splice(idx, 1)


module.exports = mixinEvents
