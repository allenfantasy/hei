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
    @_localStorageName = 'hei_memos'
    @set('id', new Date() - 0 + '') # use timestamp as id
    # TODO: check 'repeated' validity
    return

  isRepeated: ->
    if @_data['repeated'] then true else false

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

module.exports = Memo
