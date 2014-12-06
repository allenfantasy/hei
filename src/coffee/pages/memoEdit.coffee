Modifier = require 'famous/core/Modifier'
Transform = require 'famous/core/Transform'
Surface = require 'famous/core/Surface'
InputSurface = require 'famous/surfaces/InputSurface'
ImageSurface = require 'famous/surfaces/ImageSurface'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
SequentialLayout = require 'famous/views/SequentialLayout'
EventHandler = require 'famous/core/EventHandler'
FlexibleLayout = require 'famous/views/FlexibleLayout'

Page = require '../lib/page.coffee'
Slider = require '../lib/widgets/Slider.coffee'
Memo = require '../models/Memo.coffee'

require 'date-utils'

page = new Page(
  name: 'editMemo'
)

MY_CENTER = new EventHandler()
BLUE = '#41c4d3'
GREY = '#9da9ab'
LINE_HEIGHT = window.innerHeight / 10
FONT_SIZE = '20px'
TIME_FONT_SIZE = '30px'
TRUE_SIZE = [true, true]
BOX_SHADOW = '0 0 3px #888888'
ICON_SIZE = [30, 35]
CENTER_MODIFIER = new Modifier(
  align: [.5, .5]
  origin: [.5, .5]
)

LEFT_MODIFIER = new Modifier(
  align: [0.05, 0.5]
  origin: [0, 0.5]
)

RIGHT_MODIFIER = new Modifier(
  align: [0.95, 0.5]
  origin: [1, 0.5]
)

SCREEN_SIZE = [720, 1280] # iphone5
WIDTH_RATIO = window.innerWidth / SCREEN_SIZE[0]
HEIGHT_RATIO = window.innerHeight / SCREEN_SIZE[1]

THUMB_RADIUS = 25 * HEIGHT_RATIO
BAR_HEIGHT = 16 * HEIGHT_RATIO
BAR_WIDTH = 0.9 * window.innerWidth

MONTH_STEP = BAR_WIDTH / 11
DAY_STEP = BAR_WIDTH / 30
HOUR_STEP = BAR_WIDTH / 23
MINUTE_STEP = BAR_WIDTH / 59

SWITCHON_IMAGE_URL = './img/switch_on.png'
SWITCHOFF_IMAGE_URL = './img/switch_off.png'

WEEKS =
  Mon: '周一'
  Tue: '周二'
  Wed: '周三'
  Thu: '周四'
  Fri: '周五'
  Sat: '周六'
  Sun: '周日'

page.memo = new Memo()  # this is the default one

name = ''
date = new Date()
date.setSeconds(0)
alarm = [false, false, false, false, false]
repeatStateIndex = -1 # store the index of active repeat icon

container = new ContainerSurface(
  size: [window.innerWidth, window.innerHeight]
  properties:
    color: GREY
)

initialRatios = [1, 0, 9] # no time settings
finalRatios = [1, 8, 1]   # has time settings
alarmToggle = false
layout = new FlexibleLayout(
  direction: 1
  ratios: initialRatios
)

createHeader = () ->
  headerContainer = new ContainerSurface(
    size: [window.innerWidth, LINE_HEIGHT]
  )

  input = new InputSurface(
    value: name
    size: [true, LINE_HEIGHT - 3]
    name: 'name'
    placeholder: '请输入名称'
    type: 'text'
    properties:
      lineHeight: LINE_HEIGHT + 'px'
      fontSize: FONT_SIZE
  )

  input.on 'input', ->
    name = input.getValue()
    #console.log name

  headerContainer.add(LEFT_MODIFIER).add input

  switcher = new ImageSurface(
    content: SWITCHOFF_IMAGE_URL
    size: [25, 30]
  )

  headerContainer.add(RIGHT_MODIFIER).add switcher

  switchTimeSettings = ->
    ratios = if alarmToggle then finalRatios else initialRatios
    layout.setRatios(ratios, {curve : 'easeOut', duration : 500})
    switcherContent = if alarmToggle then SWITCHON_IMAGE_URL else SWITCHOFF_IMAGE_URL
    switcher.setContent switcherContent

  switcher.on 'click', ->
    alarmToggle = !alarmToggle
    switchTimeSettings()

  MY_CENTER.on 'update:header', (name) ->
    input.setValue name

  MY_CENTER.on 'update:switcher', (hasTime) ->
    alarmToggle = hasTime
    switchTimeSettings()

  return headerContainer

createSlide = (type, range, step, initial) ->
  slideContainer = new ContainerSurface(
    size: [window.innerWidth, LINE_HEIGHT]
  )

  slider = new Slider [BAR_WIDTH, BAR_HEIGHT], THUMB_RADIUS, range, step, initial, GREY, BLUE

  slider.onSlide 'update', (value) -> # value ISNT physical position
    MY_CENTER.emit type, value

  slider.onSlide 'end', (value) -> # value ISNT physical position
    MY_CENTER.emit type, value

  MY_CENTER.on "update:#{type}", (value) ->
    slider.setValue value

  slideContainer.add(CENTER_MODIFIER).add slider

  return slideContainer

createDate = ->
  dateContainer = new ContainerSurface(
    size: [window.innerWidth, LINE_HEIGHT]
    properties:
      fontSize: TIME_FONT_SIZE
      fontWeight: 'bold'
  )

  dateSurface = new Surface(
    content: generateDate(date)
    size: TRUE_SIZE
  )

  last = new Surface(
    content: '◀'
    size: TRUE_SIZE
  )

  next = new Surface(
    content: '▶'
    size: TRUE_SIZE
  )

  last.on 'click', ->
    date.addYears(-1)
    dateSurface.setContent(generateDate(date))

  next.on 'click', ->
    date.addYears(1)
    dateSurface.setContent(generateDate(date))

  dateContainer.add(LEFT_MODIFIER).add last

  dateContainer.add(CENTER_MODIFIER).add dateSurface

  dateContainer.add(RIGHT_MODIFIER).add next

  MY_CENTER.on 'month', (value) ->
    month = Math.round(value)
    if Date.validateDay(date.getDate(), date.getFullYear(), month)
      date.setMonth(month)
      dateSurface.setContent(generateDate(date))
    else
      date.setMonth(month)
      date.setDate(Date.getDaysInMonth(date.getFullYear(), month))
      dateSurface.setContent(generateDate(date))

  MY_CENTER.on 'day', (value) ->
    day = Math.round(value)
    if Date.validateDay(day, date.getFullYear(), date.getMonth())
      date.setDate(day)
      dateSurface.setContent(generateDate(date))

  MY_CENTER.on 'update:date', (date) ->
    dateSurface.setContent(generateDate(date))

  return dateContainer

generateDate = (d) ->
  weekName = WEEKS[d.toFormat('DDD')]
  return d.toYMD('.')+'<span class="week-name">'+weekName+'</span>'

createTime = ->
  timeContainer = new ContainerSurface(
    size: [window.innerWidth, LINE_HEIGHT]
  )

  time = new Surface(
    content: generateTime(date)
    size: TRUE_SIZE
    properties:
      fontSize: TIME_FONT_SIZE
      fontWeight: 'bold'
  )

  MY_CENTER.on 'hour', (value) ->
    hours = Math.round(value)
    date.setHours(hours)
    time.setContent(generateTime(date))

  MY_CENTER.on 'minute', (value) ->
    minutes = Math.round(value)
    date.setMinutes(minutes)
    time.setContent(generateTime(date))

  MY_CENTER.on 'update:time', (date) ->
    time.setContent(generateTime(date))

  timeContainer.add(CENTER_MODIFIER).add time

  return timeContainer

generateTime = (t) ->
  return t.toFormat 'HH24:MI'

createFive = (type) ->
  fiveContainer = new ContainerSurface(
    size: [innerWidth, LINE_HEIGHT]
  )
  five = new SequentialLayout(
    direction: 0
    itemSpacing: window.innerWidth / 12
  )

  reminders = [0, 1, 2, 3, 4].map (index) ->
    new ImageSurface(
      content: "./img/#{type}off#{index}.png"
      size: ICON_SIZE
    )

  five.sequenceFrom reminders
  fiveContainer.add(CENTER_MODIFIER).add five

  reminders.forEach (reminder, index) ->
    reminder.on 'click', ->
      reminderContent = reminder._imageUrl
      if type is 'alarm'
        unless alarm[index]
          activateIcon reminder, type, index
          alarm[index] = true
        else
          deactivateIcon reminder, type, index
          alarm[index] = false

        #console.log alarm
      if type is 'repeat'
        activeIdx = repeatStateIndex

        if index isnt activeIdx
          activateIcon reminder, type, index
          deactivateIcon reminders[activeIdx], type, activeIdx if activeIdx != -1
          repeatStateIndex = index
        else
          deactivateIcon reminder, type, index
          repeatStateIndex = -1
        #console.log repeatStateIndex

  return fiveContainer

activateIcon = (icon, type, index) ->
  icon.setContent("./img/#{type}on#{index}.png")

deactivateIcon = (icon, type, index) ->
  icon.setContent("./img/#{type}off#{index}.png")

createFooter = ->
  cancelButton = new Surface(
    content: '取消'
    size: TRUE_SIZE
  )

  confirmButton = new Surface(
    content: '确认'
    size : TRUE_SIZE
    properties:
      textAlign: 'center'
  )

  footer = new ContainerSurface(
    size: [window.innerWidth, LINE_HEIGHT]
    properties:
      fontSize: FONT_SIZE
  )

  footer.add(new Modifier(
    align: [0.25, 0.5]
    origin: [0.5, 0.5]
  )).add(cancelButton)

  footer.add(new Modifier(
    align: [0.75, 0.5]
    origin: [0.5, 0.5]
  )).add(confirmButton)

  cancelButton.on 'click', ->
    page.jumpTo 'memoIndex' # do nothing

  confirmButton.on 'click', ->
    if alarmToggle
      attr =
        name: name
        hasTime: true
        date: date
        repeated: if repeatStateIndex is -1 then false else Memo.REPEATED_STATE[repeatStateIndex]
        alarm: alarm
    else
      attr =
        name: name
        hasTime: false

    page.memo.save(
      attr
    ,
      validate: true
      success: (memo) ->
        page.jumpTo 'memoIndex', memo
      error: ->
        # TODO
        window.alert 'something fucked up'
    )

  return footer

dateLayout = new SequentialLayout(
  direction: 1
)

# TODO: get const
dateLayoutItems = [
  createSlide 'month', [0, 11], MONTH_STEP, date.getMonth()
  createDate()
  createSlide 'day', [1, 31], DAY_STEP, date.getDate()
  createSlide 'hour', [0, 23], HOUR_STEP, date.getHours()
  createTime()
  createSlide 'minute', [0, 59], MINUTE_STEP, date.getMinutes()
  createFive 'alarm'
  createFive 'repeat'
]

dateLayout.sequenceFrom dateLayoutItems

dateLayoutContainer = new ContainerSurface(
  size: [undefined, undefined]
  properties:
    overflow: 'hidden'
)

dateLayoutContainer.add dateLayout

layoutItems = [
  createHeader(''),
  dateLayoutContainer,
  createFooter()
]

layout.sequenceFrom layoutItems

container.add(CENTER_MODIFIER).add layout

page.add container

page.onEvent 'beforeEnter', (memo) ->
  if memo && memo.isRepeated # passed a Memo object ==> EDIT
    page.memo = memo
  else # ==> NEW
    page.memo = new Memo()

  memo = memo || page.memo
  name = memo.get('name')
  hasTime = memo.get('hasTime')
  date = memo.get('date') || new Date()
  dateObj =
    month: date.getMonth()
    day: date.getDate()
    hour: date.getHours()
    minute: date.getMinutes()

  MY_CENTER.emit 'update:header', name
  MY_CENTER.emit 'update:switcher', hasTime
  MY_CENTER.emit 'update:date', date
  MY_CENTER.emit 'update:time', date

  ['month', 'day', 'hour', 'minute'].forEach (type) ->
    MY_CENTER.emit "update:#{type}", dateObj[type]
module.exports = page
