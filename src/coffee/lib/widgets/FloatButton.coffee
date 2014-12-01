Surface = require 'famous/core/Surface'

FloatButton = (options)->
  if options.type is 'image'
    options.content = "<img width='24px' height='24px' src='#{options.imgsrc}'></img>"
    delete options.imgsrc
  Surface.apply this, [options]
  return

FloatButton:: = Object.create(Surface::)
FloatButton::constructor = FloatButton

FloatButton::elementType = 'button'

module.exports = FloatButton
