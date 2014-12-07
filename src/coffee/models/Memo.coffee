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
    if @_data['hasTime']
      if @_data['repeated'] and @_data['repeated'] isnt 'no' then true else false
    else
      false

  isEqual: (other) ->
    @get('id') is other.get('id')

Memo.DEFAULTS =
  name: ''
  date: null
  hasTime: false
  repeated: false
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
