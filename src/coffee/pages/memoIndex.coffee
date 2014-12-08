Modifier = require 'famous/core/Modifier'
Transform = require 'famous/core/Transform'
Surface = require 'famous/core/Surface'
RenderNode = require 'famous/core/RenderNode'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
ImageSurface = require 'famous/surfaces/ImageSurface'
Scrollview = require 'famous/views/Scrollview'
FlexibleLayout = require 'famous/views/FlexibleLayout'
Draggable = require 'famous/modifiers/Draggable'
Transitionable = require 'famous/transitions/Transitionable'
SnapTransition = require 'famous/transitions/SnapTransition'

Page = require '../lib/page.coffee'
FloatButton = require '../lib/widgets/FloatButton.coffee'

Memo = require '../models/Memo.coffee'

window.Memo = Memo # Warning: Only for testing, remove it when finished

util = require '../lib/util.coffee'

# Size Constants
SCREEN_SIZE = [720, 1280] # iphone5

WIDTH_RATIO = window.innerWidth / SCREEN_SIZE[0]
HEIGHT_RATIO = window.innerHeight / SCREEN_SIZE[1]

SIZE_CONST =
  ITEM:
    NetHeight: 145  * HEIGHT_RATIO
    DateHeight: 27 * HEIGHT_RATIO
    TimeHeight: 40 * HEIGHT_RATIO
    DateTopPad: 36 * HEIGHT_RATIO
    DateSectionWidth: 146 * WIDTH_RATIO
    NameLeftPad: 40 * WIDTH_RATIO
    BorderWidth: 2
    ButtonSectionWidth: 120 * WIDTH_RATIO
    ButtonRadius: 27 * WIDTH_RATIO

  FONT:
    Date: 27 * HEIGHT_RATIO
    Time: 40 * HEIGHT_RATIO
    Name: 40 * HEIGHT_RATIO

  ADD_BUTTON:
    RightPad: 60 * HEIGHT_RATIO
    BottomPad: 60 * HEIGHT_RATIO
    Size: 155 * HEIGHT_RATIO
    FontSize: 155 / 2 * HEIGHT_RATIO

CHINESE_WEEKDAY_NAMES = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']

EMPTY_IMAGE_URL = './img/empty.png'
TICK_IMAGE_URL = './img/tick.png'
REPEAT_IMAGE_URL = './img/repeat.png'

GREY = '#9da9ab'

TICK_BORDER = '1px solid ' + GREY

buildDateHTML = (datetime) ->
  "<div class='datetime'>" +
    "<div class='date' style='padding-top:#{SIZE_CONST.ITEM.DateTopPad}px;height:#{SIZE_CONST.ITEM.DateHeight}px;font-size:#{SIZE_CONST.FONT.Date}px;'>" +
      "<span class='month-day'>#{datetime.getMonth()+1}.#{datetime.getDate()}</span>" + "#{CHINESE_WEEKDAY_NAMES[datetime.getDay()]}" +
    "</div>" +
    "<div class='time' style='height:#{SIZE_CONST.FONT.Time}px;font-size:#{SIZE_CONST.FONT.Time}px;'>" + util.formatTime(datetime) + "</div>" +
  "</div>"

buildCircleButton = (radius, isRepeated, isFinished) ->
  container = new ContainerSurface(
    size: [radius * 2, radius * 2]
    properties:
      borderRadius: radius + 'px'
      border: TICK_BORDER
  )

  repeatSurface = new ImageSurface(
    content: REPEAT_IMAGE_URL
  )

  if isRepeated then container.add repeatSurface

  container.button = new ImageSurface(
    content: if isFinished then TICK_IMAGE_URL else EMPTY_IMAGE_URL
    properties:
      pointerEvents: 'none'
  )

  container.add container.button

  return container

buildItem = (memo, scroll) ->
  name = memo.get('name')
  datetime = memo.get('date')
  hasTime = memo.get('hasTime')
  isRepeated = memo.isRepeated()
  isFinished = memo.isFinished()

  itemWrapper = new ContainerSurface(
    size: [undefined, SIZE_CONST.ITEM.NetHeight + SIZE_CONST.ITEM.BorderWidth]
    classes: if isRepeated then ['item', 'repeated'] else ['item']
    properties:
      overflow: 'hidden'
  )
  itemLayout = new FlexibleLayout(
    direction: 0
    ratios: [true, 1, true]
  )

  dateTimeSection = new Surface(
    content: if (hasTime and datetime and datetime.getDate) then buildDateHTML datetime else ''
    size: [SIZE_CONST.ITEM.DateSectionWidth, undefined]
  )
  nameSection = new Surface(
    content: name
    size: [undefined, undefined]
    properties:
      fontSize: SIZE_CONST.FONT.Name + 'px'
      lineHeight: SIZE_CONST.ITEM.NetHeight + 'px'
      paddingLeft: SIZE_CONST.ITEM.NameLeftPad + 'px'
      textDecoration: if isFinished then 'line-through' else 'none'
      color: if isFinished then GREY else 'black'
  )

  nameSection.on 'click', ->
    page.jumpTo 'editMemo', memo

  buttonSection = new ContainerSurface(
    size: [SIZE_CONST.ITEM.ButtonSectionWidth, undefined]
  )
  buttonContainer = buildCircleButton SIZE_CONST.ITEM.ButtonRadius, isRepeated, isFinished
  buttonSection.add(new Modifier(
    origin: [.5, .5]
    align: [.5, .5]
  )).add buttonContainer

  itemLayout.sequenceFrom [dateTimeSection, nameSection, buttonSection]
  itemWrapper.add itemLayout
  itemWrapper.pipe scroll

  buttonSection.on 'click', ->
    if memo.isFinished()
      memo.unfinish(
        error: ->
          window.alert "fail to unfinished!"
      )
    else
      memo.finish(
        error: ->
          window.alert "fail to finished!"
      )

  memo.on 'finish', ->
    buttonContainer.button.setContent TICK_IMAGE_URL
    nameSection.setProperties(
      textDecoration: 'line-through'
      color: GREY
    )

  memo.on 'unfinish', ->
    buttonContainer.button.setContent EMPTY_IMAGE_URL
    nameSection.setProperties(
      textDecoration: 'none'
      color: 'black'
    )

  memo.on 'repeat', (d) ->
    dateTimeSection.setContent buildDateHTML(d)

  do ->
    draggable = new Draggable(
      xRange: [0 - window.innerWidth, 0]
      yRange: [0, 0]
    )
    node = new RenderNode(draggable)
    node.add itemWrapper
    node.memo = memo
    itemWrapper.pipe draggable
    draggable.on 'end', (e) ->
      if Math.abs(e.position[0]*2) > window.innerWidth
        @setPosition [0 - window.innerWidth, 0, 0], { duration: 300, curve: 'easeOut' }, ->
          i = memoRenderItems.indexOf(node)
          console.log i
          success = ->
            memoRenderItems.splice(i, 1)
            return

          item = memoRenderItems[i]
          item.memo.destroy success, (err) ->
            window.alert(err.message)
            return
      else
        @setPosition [0, 0, 0], trans

    node

# history memos
memos = JSON.parse(window.localStorage.getItem(Memo.STORAGE_NAME) or '[]').map (data) ->
  data.date = new Date(data.date)
  new Memo data

page = new Page(
  name: 'memoIndex'
)

container = new ContainerSurface(
  size: [window.innerWidth, window.innerHeight]
  properties:
    overflow: 'hidden'
)

memoList = new Scrollview()

trans =
  method: 'snap'
  period: 300
  dampingRatio: 0.3
  velocity: 0

memoRenderItems = memos.map (memo, index) ->
  buildItem memo, memoList

addButtonMod = new Modifier(
  origin: [1,1]
  align: [1,1]
  transform: Transform.translate(0 - SIZE_CONST.ADD_BUTTON.RightPad, 0 - SIZE_CONST.ADD_BUTTON.BottomPad, 0)
)
ADD_BUTTON_SIZE = SIZE_CONST.ADD_BUTTON.Size

addButton = new FloatButton(
  type: 'image'
  imgsrc: './img/ic_add_24px.svg'
  size: [ADD_BUTTON_SIZE, ADD_BUTTON_SIZE]
  classes: ['add-button', 'md-button', 'md-fab']
  properties:
    textAlign: 'center'
    color: 'white'
    fontSize: "#{SIZE_CONST.ADD_BUTTON.FontSize}px"
    borderRadius: "50%"
)

addButton.on 'click', ->
  page.jumpTo 'editMemo'

memoList.sequenceFrom memoRenderItems
container.add memoList
container.add addButtonMod
         .add addButton
page.add container

page.onEvent 'beforeEnter', (memo) ->
  if memo and memo.isRepeated # duck typing
    idx = memos.map((m) ->
      m.get('id')
    ).indexOf memo.get('id')
    if idx isnt -1 # memo exists
      memos[idx] = memo
      memoRenderItems[idx] = buildItem memo, memoList
      memoList.sequenceFrom memoRenderItems
    else
      memos.push(memo)
      memoRenderItems.push(buildItem memo, memoList)


page.onEvent 'afterEnter', (data) ->
  console.log 'after enter'

module.exports = page
