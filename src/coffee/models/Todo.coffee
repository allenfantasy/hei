Base = require './Base.coffee'

counter = 0
class Todo extends Base
  constructor: (obj) ->
    super obj
    @set('id', counter++)
  isRepeated: ->
    if @_data['repeated'] then true else false

module.exports = Todo
