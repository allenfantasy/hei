Surface = require 'famous/core/Surface'
Modifier = require 'famous/core/Modifier'
Transform = require 'famous/core/Transform'
Draggable = require 'famous/modifiers/Draggable'
Transitionable = require 'famous/transitions/Transitionable'
SnapTransition = require 'famous/transitions/SnapTransition'

Transitionable.registerMethod 'snap', SnapTransition

Page = require '../lib/page.coffee'
Slider = require '../lib/widgets/Slider.coffee'

SCREEN_SIZE = [720, 1280] # iphone5
WIDTH_RATIO = window.innerWidth / SCREEN_SIZE[0]
HEIGHT_RATIO = window.innerHeight / SCREEN_SIZE[1]

THUMB_RADIUS = 25 * HEIGHT_RATIO
BAR_HEIGHT = 16 * HEIGHT_RATIO
BAR_WIDTH = 200
BAR_SIDE_PAD = (window.innerWidth - BAR_WIDTH) / 2

sliderPage = new Page(
  name: 'slider'
)

slider = new Slider [BAR_WIDTH, BAR_HEIGHT], THUMB_RADIUS, [0, 200], 10, 0, '#9da9ab', '#41c4d3'

value = 0

valueMod = new Modifier(
  origin: [.5, .5]
  align: [.5, .5]
)
valueBox = new Surface(
  content: '0'
  size: [50, 50]
  properties:
    textAlign: 'center'
    lineHeight: '50px'
)

slider.onSlide 'update', (e) ->
  value = e.position[0]
  valueBox.setContent(value)
  console.log e

slider.onSlide 'end', (e) ->
  console.log e.position

sliderPage.add slider

sliderPage.add valueMod
          .add valueBox

module.exports = sliderPage
