Surface = require 'famous/core/Surface'
Modifier = require 'famous/core/Modifier'
Transform = require 'famous/core/Transform'
View = require 'famous/core/View'
Draggable = require 'famous/modifiers/Draggable'
Transitionable = require 'famous/transitions/Transitionable'
SnapTransition = require 'famous/transitions/SnapTransition'
ContainerSurface = require 'famous/surfaces/ContainerSurface'

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
    # projection: Draggable.DIRECTION_X
    scale: 1
    xRange: range
    yRange: [0, 0]
    snapX: step
  )
  this._bar = new Surface(
    size: barSize
    properties:
      backgroundColor: barColor
  )

  this._thumb.pipe this._draggable

  this._draggable.setPosition [initValue, 0]

  this.container = new ContainerSurface(
    size: barSize
  )
  this.container.add(new Modifier(
    ailgn: [0, 0]
    origin: [0, 0]
  )).add this._bar

  this.container.add(new Modifier(
    transform: Transform.translate(-thumbRadius, - thumbRadius + barSize[1]/2, 1)
  )).add this._draggable
    .add this._thumb
  this.add this.container

  return

Slider:: = Object.create(View::)
Slider::constructor = Slider

Slider::onSlide = (type, handler) ->
  this._draggable.on type, handler

module.exports = Slider
