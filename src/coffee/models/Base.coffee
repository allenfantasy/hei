EventHandler = require 'famous/core/EventHandler'

# TODO: validation
class Base
  constructor: (obj) ->
    @_data = obj or {}
    @_center = new EventHandler()
    @_defaults = (if obj then @_clone(obj) else {})
    return

  get: (key) ->
    @_data[key]

  set: (key, value) ->
    __this = this
    if typeof key is "object"
      obj = key
      Object.keys(obj).filter((p) ->
        obj.hasOwnProperty p
      ).forEach (p) ->
        __this.set p, obj[p]
        return
    
      return
    unless @_data.hasOwnProperty(key)
      @_center.emit "add", [
        key
        value
      ]

    old = @_data[key]
    if old isnt value
      @_data[key] = value
      @_center.emit "change:" + key, value
      @_center.emit "change", [
        key,
        value
      ]

    return

  remove: (key) ->
    return unless @_data.hasOwnProperty(key)
    val = @_data[key]
    delete @_data[key]
    @_center.emit "remove", [
      key
      val
    ]

    return

  clear: ->
    @_data = {}
    return

  reset: ->
    __this = this
    @_data = @_clone(@_defaults)
    keys = Object.keys(@_defaults).filter((p) ->
      __this._defaults.hasOwnProperty p
    )

    keys.forEach (p) ->
      __this._center.emit("change:" + p, [""])
      __this._center.emit("change", [
        p
        ""
      ])

    return

  on: (eventName, fn, thisObj) ->
    __this = this
    @_center.on eventName, (data) ->
      fn.apply thisObj or this, [__this].concat(data)
      return

    return

  getData: ->
    result = {}
    obj = @_data
    Object.keys(obj).forEach (key) ->
      result[key] = obj[key] if obj.hasOwnProperty(key)
      return
      
    result

  _clone: (obj) ->
    return obj if obj is null or typeof obj isnt "object"
    copy = obj.constructor()
    for attr of obj
      copy[attr] = obj[attr] if obj.hasOwnProperty(attr)
    copy

module.exports = Base
