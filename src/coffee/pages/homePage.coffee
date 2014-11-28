Modifier = require 'famous/core/Modifier'
Transform = require 'famous/core/Transform'
Surface = require 'famous/core/Surface'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
Scrollview = require 'famous/views/Scrollview'
FlexibleLayout = require 'famous/views/FlexibleLayout'

Page = require '../lib/page.coffee'

homepage = new Page(
  name: 'homepage'
) 

container = new ContainerSurface(
  size: [window.innerWidth, window.innerHeight]
  properties:
    overflow: 'hidden'
)

itemList = new Scrollview()

# Size Constants
IPHONE_FIVE_SIZE = [720, 1280]

itemNetHeightRatio = 145 / IPHONE_FIVE_SIZE[1]
itemBorderWidth = 2
itemDateSectionWidthRatio = 146 / IPHONE_FIVE_SIZE[0]
itemButtonSectionWidthRatio = 90 / IPHONE_FIVE_SIZE[0]
itemNameSectionWidthRatio = 1 - itemDateSectionWidthRatio - itemButtonSectionWidthRatio

#Item = (name, time, )
buildItem = (name, time, isRepeated) ->
  itemWrapper = new ContainerSurface(
    size: [undefined, itemNetHeightRatio * window.innerHeight + itemBorderWidth]
    properties:
      borderBottom: '1px solid gray'
      lineHeight: '100px'
      overflow: 'hidden'
  )
  itemLayout = new FlexibleLayout(
    direction: 0
    ratios: [true, 1, true]
  )

  timeSection = new Surface(
    content: time.toDateString()
    size: [itemDateSectionWidthRatio * window.innerWidth, undefined]
  )
  nameSection = new Surface(
    content: name
    size: [true, undefined]
  )
  buttonSection = new Surface(
    content: time.toDateString()
    size: [itemDateSectionWidthRatio * window.innerWidth, undefined]
  )
  itemLayout.sequenceFrom([timeSection, nameSection, buttonSection])
  itemWrapper.add(itemLayout)
  itemWrapper

items = ['item1', 'item2', 'item3'].map (name, index) ->
  buildItem name, new Date(), index % 2 is 0
  
itemList.sequenceFrom items
container.add itemList
homepage.add container

module.exports = homepage
