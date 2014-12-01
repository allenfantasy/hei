Modifier = require 'famous/core/Modifier'
Transform = require 'famous/core/Transform'
Surface = require 'famous/core/Surface'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
Scrollview = require 'famous/views/Scrollview'
FlexibleLayout = require 'famous/views/FlexibleLayout'

Page = require '../lib/page.coffee'

util = require '../lib/util.coffee'

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

itemNetHeight = 145 / IPHONE_FIVE_SIZE[1] * window.innerHeight

itemDateHeight = itemDateFontSize = 27 / IPHONE_FIVE_SIZE[1] * window.innerHeight
itemTimeHeight = itemTimeFontSize = 40 / IPHONE_FIVE_SIZE[1] * window.innerHeight
itemDateTopPadding = 36 / IPHONE_FIVE_SIZE[1] * window.innerHeight
itemDateSectionWidth = 146 / IPHONE_FIVE_SIZE[0] * window.innerWidth

itemNameFontSize = 40 / IPHONE_FIVE_SIZE[1] * window.innerHeight
itemNameSectionLeftPadding = 40 / IPHONE_FIVE_SIZE[0] * window.innerWidth

itemBorderWidth = 2
itemButtonSectionWidth = 90 / IPHONE_FIVE_SIZE[0] * window.innerWidth

itemButtonRadius = 27 / IPHONE_FIVE_SIZE[0] * window.innerWidth

CHINESE_WEEKDAY_NAMES = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']

buildDateHTML = (datetime) ->
  "<div class='datetime'>" +
    "<div class='date' style='padding-top:#{itemDateTopPadding}px;height:#{itemDateHeight}px;font-size:#{itemDateFontSize}px;'>" +
      "#{datetime.getMonth()}.#{datetime.getDate()} #{CHINESE_WEEKDAY_NAMES[datetime.getDay()]}" +
    "</div>" +
    "<div class='time' style='height:#{itemTimeHeight}px;font-size:#{itemTimeFontSize}px;'>" + util.formatTime(datetime) + "</div>" +
  "</div>"

buildCircleButton = (radius, isRepeated) ->
  new Surface(
    size: [radius * 2, radius * 2]
    properties:
      borderRadius: radius + 'px'
      border: '1px solid #9da9ab'
  )

buildItem = (name, datetime, scroll, isRepeated) ->
  itemWrapper = new ContainerSurface(
    size: [undefined, itemNetHeight + itemBorderWidth]
    classes: if isRepeated then ['item', 'repeated'] else ['item']
    properties:
      overflow: 'hidden'
  )
  itemLayout = new FlexibleLayout(
    direction: 0
    ratios: [true, 1, true]
  )

  timeSection = new Surface(
    content: buildDateHTML datetime
    size: [itemDateSectionWidth, undefined]
  )
  nameSection = new Surface(
    content: name
    size: [undefined, undefined]
    properties:
      fontSize: itemNameFontSize + 'px'
      lineHeight: itemNetHeight + 'px'
      paddingLeft: itemNameSectionLeftPadding + 'px'
      fontWeight: 'bolder'
  )
  buttonSection = new ContainerSurface(
    size: [itemButtonSectionWidth, undefined]
  )
  button = buildCircleButton itemButtonRadius, isRepeated
  buttonSection.add(new Modifier(
    origin: [.5, .5]
    align: [.5, .5]
  )).add button

  itemLayout.sequenceFrom [timeSection, nameSection, buttonSection]
  itemWrapper.add itemLayout
  itemWrapper.pipe scroll
  itemWrapper

items = ['每周论坛', '心理学史期中考', '绝命毒师'].map (name, index) ->
  buildItem name, new Date(), itemList, index % 2 is 0

itemList.sequenceFrom items
container.add itemList
homepage.add container

module.exports = homepage
