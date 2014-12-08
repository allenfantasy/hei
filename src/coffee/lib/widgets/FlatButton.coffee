Surface = require 'famous/core/Surface'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Modifier = require 'famous/core/Modifier'
Timer = require 'famous/utilities/Timer'
Easing = require 'famous/transitions/Easing'
TweenTransition = require 'famous/transitions/TweenTransition'
EventHandler = require 'famous/core/EventHandler'

TweenTransition.registerCurve 'outQuart', Easing.outQuart

BLUE = '#41c4d3'
CENTER_STATEMODIFIER = new StateModifier(
  align: [.5, .5]
  origin: [.5, .5]
)
CENTER_MODIFIER = new Modifier(
  align: [.5, .5]
  origin: [.5, .5]
)

FlatButton = (options) ->
  ContainerSurface.call @

  @_center = new EventHandler()

  @size = options.size
  @_ink_size = options.inkSize or 50
  @_opacity = options.opacity or 0.3
  @_content = options.content
  @_ink_color = options.color or BLUE
  @_font_size = options.fontSize

  @_ink = new Surface(
    size: [@_ink_size, @_ink_size]
    properties:
      borderRadius: '50%'
      backgroundColor: @_ink_color
      pointerEvents: 'none'
      display: 'none'
      zIndex: 1
  )

  @_inkModifier = new StateModifier(
    opacity: @_opacity
  )

  @_button = new Surface(
    content: @_content
    properties:
      textAlign: 'center'
      fontSize: @_font_size
      border: '1px solid #e6e6e6'
      lineHeight: @size[1]+'px'
  )

  @.setProperties(
    overflow: 'hidden'
  )

  @.add(CENTER_STATEMODIFIER).add(@_inkModifier).add @_ink
  @.add(CENTER_MODIFIER).add @_button

  return

FlatButton:: = Object.create(ContainerSurface::)
FlatButton::constructor = FlatButton

FlatButton::elementType = 'flatbutton'

FlatButton::click = (handler) ->
  $ = @
  @_button.on 'click', (e) ->
    $._center.emit 'beforeClick'
    $._ink.setProperties(
      display: 'inline'
    )
    x = - $.size[0] / 2 + e.offsetX
    y = - $.size[1] / 2 + e.offsetY
    scale = $.size[0] / $._ink_size
    $._inkModifier.setTransform Transform.translate(x, y, 0)
    $._inkModifier.setTransform Transform.scale(scale, scale, 0), {duration: 550, curve: 'outQuart'}, ->
      $._inkModifier.setTransform Transform.scale(0, 0, 0)
      handler()

FlatButton::emitEvent = (event, data) ->
  @_center.emit event, data

FlatButton::onEvent = (type, handler) ->
  @_center.on type, handler

FlatButton::setPointerEvents = (options) ->
  @_button.setProperties(options)

module.exports = FlatButton
