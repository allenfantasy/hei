EventHandler = require 'famous/core/EventHandler'

class Base
  constructor: (obj) ->
    @_data = obj or {}
    @_center = new EventHandler()
    @_defaults = (if obj then @_clone(obj) else {})
    @_localStorageName = 'hei_base'
    #@setOptions(obj.options)
    return

  #setOptions: (options) ->
    #@_proxy = 'localStorage'
    # TODO: local, remote(url)
    #if options.localStorage
    #  @_name = options.localStorage

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

  id: ->
    @get 'id'

  getData: ->
    result = {}
    obj = @_data
    Object.keys(obj).forEach (key) ->
      result[key] = obj[key] if obj.hasOwnProperty(key)
      return

    result

  has: (attr) ->
    val = @get(attr)
    val isnt null and val isnt `undefined`

  isNew: ->
    not @has 'id'

  # `cb` would be called when validation failed
  validate: (cb, options) ->
    return true unless options.validate
    # TODO: execute cb function if failed
    # cb should like this: function(err) { // .... }
    true

  save: (obj, options) ->
    options.validate = options.validate || true

    success = options.success
    error = options.error || null
    if @validate(error, options)
      @set obj
      method = if @isNew then 'create' else 'update'
      # save to localStorage
      @sync method, this, options
      success(this)
    this

  sync: (method, model, options) ->
    # only localStorage now
    # TODO: add remote way
    name = @_localStorageName
    records = JSON.parse(window.localStorage.getItem(name) or '[]')
    # BUG: always push
    if method is 'create'
      records.push model
    else
      modelIndex = records.findIndex (obj) ->
        return obj.id() is model.id()
      records[modelIndex] = model# if model.eql(records[modelIndex])

    newRecords = records.map (r) ->
      if r.getData then r.getData() else r # return an acceptable object to JSON.stringify

    window.localStorage.setItem(name, JSON.stringify(newRecords))
    return

  # alias
  toJSON: ->
    @getData()

  _clone: (obj) ->
    return obj if obj is null or typeof obj isnt "object"
    copy = obj.constructor()
    for attr of obj
      copy[attr] = obj[attr] if obj.hasOwnProperty(attr)
    copy


module.exports = Base
