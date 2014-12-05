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
  @value = initValue || 0
  @range = range
  @barSize = barSize
  console.log @range

  @_thumb = new Surface(
    size: [thumbRadius * 2, thumbRadius * 2]
    content: ''
    properties:
      backgroundColor: thumbColor
      borderRadius: '50%'
      cursor: 'pointer'
      zIndex: '1'
  )

  @_draggable = new Draggable(
    xRange: [0 - step / 2, barSize[0] + step / 2]
    yRange: [0, 0]
    snapX: step
  )

  @_bar = new Surface(
    size: barSize
    properties:
      backgroundColor: barColor
  )

  @_thumb.pipe @_draggable

  @_draggable.setPosition [initValue, 0]

  @container = new ContainerSurface(
    size: barSize
  )
  @container.add(new Modifier(
    ailgn: [0, 0]
    origin: [0, 0]
  )).add @_bar

  @container.add(new Modifier(
    transform: Transform.translate(-thumbRadius, - thumbRadius + barSize[1]/2, 1)
  )).add @_draggable
    .add @_thumb
  @add @container

  return

Slider:: = Object.create(View::)
Slider::constructor = Slider

Slider::onSlide = (type, handler) ->
  $ = @
  @_draggable.on type, (event) ->
    event.value = $.range[0] + event.position[0] * $.barSize[0] / ($.range[1] - $.range[0])
    handler(event)

#Slider::set = (value) ->

module.exports = Slider
