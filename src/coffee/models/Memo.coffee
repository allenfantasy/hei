Base = require './Base.coffee'

# obj2 cover obj1
merge = (obj1, obj2) ->
  obj = {}
  obj = deepCopy(obj1, obj)
  obj = deepCopy(obj2, obj)
  obj

deepCopy = (p, c) ->
  c = c || {}
  for attr of p
    if typeof p[attr] is 'object' and p[attr] isnt null and attr isnt 'date'
      c[attr] = if p[attr].constructor is Array then [] else {}
      deepCopy p[attr], c[attr]
    else
      c[attr] = p[attr]
  return c

class Memo extends Base
  constructor: (obj) ->
    obj = merge(Memo.DEFAULTS, obj or {})
    super obj
    @_localStorageName = Memo.STORAGE_NAME
    return

  isRepeated: ->
    if @hasTime
      if @get('repeated') and @get('repeated') isnt 'no' then true else false
    else
      false

  isFinished: ->
    if @get('finished') then true else false

  hasTime: ->
    @get 'hasTime'

  validate: (cb, options) ->
    return true unless options.validate
    if @get('name')
      true
    else
      cb new Error('请填写备忘内容！')
      false

  finish: (options) ->
    if @isRepeated()
      repeatCycle = @get 'repeated'
      originDate = @get 'date'
      newDate = new Date(originDate.getTime())
      # set newDate based on Memo object's repeated attr
      switch repeatCycle
        when "day"
          newDate.setDate(newDate.getDate() + 1)
        when "week"
          newDate.setDate(newDate.getDate() + 7)
        when "month"
          newDate.setMonth(newDate.getMonth() + 1)
        when "year"
          newDate.setFullYear(newDate.getFullYear() + 1)
        else
          window.alert("something wrong in Memo#finish!")
      @set 'date', newDate
      @_center.emit 'repeat', newDate
    else
      attrs =
        finished: true

      $ = @
      options.success = ->
        $._center.emit 'finish'
      @save attrs, options

  unfinish: (options) ->
    attrs =
      finished: false

    $ = @
    options.success = ->
      $._center.emit 'unfinish'
    @save attrs, options

  isEqual: (other) ->
    @get('id') is other.get('id')

Memo.DEFAULTS =
  name: ''
  date: null
  hasTime: false
  repeated: false
  finished: false
  alarm: [false, false, false, false, false]

Memo.REPEATED_STATE = [
  'no'
  'day'
  'week'
  'month'
  'year'
]

Memo.STORAGE_NAME = 'hei_memos'

module.exports = Memo
