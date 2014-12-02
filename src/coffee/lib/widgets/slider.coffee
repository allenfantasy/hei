Surface = require 'famous/core/Surface'
Modifier = require 'famous/core/Modifier'
Transform = require 'famous/core/Transform'
View = require 'famous/core/View'
Draggable = require 'famous/modifiers/Draggable'
Transitionable = require 'famous/transitions/Transitionable'
SnapTransition = require 'famous/transitions/SnapTransition'

Transitionable.registerMethod 'snap', SnapTransition

Slider = (barSize, thumbRadius, range, step, initValue, barColor, thumbColor) ->
  View.call this
  barSidePad = (window.innerWidth - barSize[0])/2
  this.value = initValue || 0

  this._thumb = new Surface(
    size: [thumbRadius * 2, thumbRadius * 2]
    content: ''
    properties:
      backgroundColor: thumbColor
      borderRadius: '50%'
      cursor: 'pointer'
  )
  this._draggable = new Draggable(
    xRange: [0 - step / 2, barSize[0] + step / 2]
    yRange: [0, 0]
    snapX: step
  )
  this._barMod = new Modifier(
    transform: Transform.translate(barSidePad, thumbRadius - barSize[1]/2, 0)
  ) 
  this._bar = new Surface(
    size: barSize
    properties:
      backgroundColor: barColor
  )

  this._thumb.pipe this._draggable

  this._draggable.setPosition [initValue, 0]

  this.add this._barMod
      .add this._bar

  this.add(new Modifier(
    transform: Transform.translate(barSidePad - thumbRadius, 0, 1)
  )).add this._draggable 
    .add this._thumb

  return

Slider:: = Object.create(View::)
Slider::constructor = Slider

Slider::onSlide = (type, handler) ->
  this._draggable.on type, handler

module.exports = Slider
