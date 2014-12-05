Base = require './Base.coffee'

class Memo extends Base
  constructor: (obj) ->
    super obj
    return

  isRepeated: ->
    if @_data['repeated'] then true else false

  validate:
    # To be implemented
    true

module.exports = Memo
