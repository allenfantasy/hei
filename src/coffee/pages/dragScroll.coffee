Surface = require 'famous/core/Surface'
Transform = require 'famous/core/Transform'
RenderNode = require 'famous/core/RenderNode'
Scrollview = require 'famous/views/Scrollview'
Draggable = require 'famous/modifiers/Draggable'
Transitionable = require 'famous/transitions/Transitionable'
SnapTransition = require 'famous/transitions/SnapTransition'
Page = require '../lib/page.coffee'

Transitionable.registerMethod 'snap', SnapTransition

page = new Page(
  name: 'dragScroll'
)
scrollview = new Scrollview()
surfaces = []
scrollview.sequenceFrom surfaces

trans =
  method: 'snap'
  period: 300
  dampingRatio: 0.3
  velocity: 0

for i in [0...40]
  do (i) ->
    draggable = new Draggable(
      xRange: [0 - window.innerWidth, 0]
      yRange: [0, 0]
    )
    item = new Surface(
      content: "Surface #{i+1}"
      size: [undefined, 200]
      properties:
        backgroundColor: "hsl(#{i * 360 / 40}, 100%, 50%)"
        lineHeight: "200px"
        textAlign: "center"
    )

    node = new RenderNode(draggable)
    node.__id = i;
    node.add item
    item.pipe draggable
    item.pipe scrollview
    surfaces.push node

    draggable.on 'end', (e) ->
      if Math.abs(e.position[0]*2) > window.innerWidth
        this.setPosition [0 - window.innerWidth, 0, 0], { duration: 300, curve: 'easeOut' }, ->
          index = surfaces.indexOf(node)
          surfaces.splice(index, 1)
      else
        this.setPosition [0, 0, 0], trans

      return

page.add scrollview

module.exports = page
