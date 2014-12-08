Surface = require 'famous/core/Surface'
Modifier = require 'famous/core/Modifier'
Transform = require 'famous/core/Transform'
View = require 'famous/core/View'
Draggable = require 'famous/modifiers/Draggable'
Transitionable = require 'famous/transitions/Transitionable'
SnapTransition = require 'famous/transitions/SnapTransition'
ContainerSurface = require 'famous/surfaces/ContainerSurface'

Transitionable.registerMethod 'snap', SnapTransition

Slider = (barSize, thumbRadius, valueRange, step, initValue, barColor, thumbColor) ->
  View.call @

  barSidePad = (window.innerWidth - barSize[0])/2
  @value = initValue || 0
  @_v = valueRange
  @_p = [0, barSize[0]]

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

  $ = @
  @_bar.on 'click', (e) ->
    val = Math.round p2v($._p, $._v, e.offsetX)
    $.setValue val
    $._draggable.eventOutput.emit 'end', position: $._draggable.getPosition()

  @_thumb.pipe @_draggable

  @_draggable.setPosition [v2p(@_p, @_v, initValue), 0]

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
    handler Math.round p2v($._p, $._v, event.position[0])

# change position
Slider::setValue = (value) ->
  @_draggable.setPosition [v2p(@_p, @_v, value), 0]

# private

# physical position ==> actual value
p2v = (p, v, position) ->
  ratio = (position - p[0]) / (p[1] - p[0])
  v[0] + (v[1] - v[0]) * ratio

# actual value ==> physical position
v2p = (p, v, value) ->
  ratio = (Math.round value - v[0]) / (v[1] - v[0])
  p[0] + (p[1] - p[0]) * ratio

module.exports = Slider
