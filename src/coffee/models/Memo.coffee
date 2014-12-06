Base = require './Base.coffee'

# obj2 cover obj1
merge = (obj1, obj2) ->
  obj = {}
  for attr of obj1
    obj[attr] = obj1[attr]
  for attr of obj2
    obj[attr] = obj2[attr]
  obj

class Memo extends Base
  constructor: (obj) ->
    obj = merge(Memo.DEFAULTS, obj or {})
    super obj
    @_localStorageName = Memo.STORAGE_NAME
    # use timestamp as id
    @set('id', new Date() - 0 + '') unless @get('id')
    return

  isRepeated: ->
    if @_data['repeated'] then true else false

  isEqual: (other) ->
    @get('id') is other.get('id')

Memo.DEFAULTS =
  name: ''
  date: null
  hasTime: false
  repeated: false
  alarm: [false, false, false, false, false]

Memo.REPEATED_STATE = [
  false
  'day'
  'week'
  'month'
  'year'
]

Memo.STORAGE_NAME = 'hei_memos'

module.exports = Memo
