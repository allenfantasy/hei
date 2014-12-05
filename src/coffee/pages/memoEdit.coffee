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

alarm = new Date() # TODO: change this into page.memo
alarm.setSeconds(0)
clock = [0, 0, 0, 0, 0]
cycling = -1

container = new ContainerSurface(
  size: [window.innerWidth, window.innerHeight]
  properties:
    color: GREY
)

initialRatios = [1, 0, 9]
finalRatios = [1, 8, 1]
alarmToggle = false
layout = new FlexibleLayout(
  direction: 1
  ratios: initialRatios
)

createHeader = (content) ->
  headerContainer = new ContainerSurface(
    size: [window.innerWidth, LINE_HEIGHT]
  )

  input = new InputSurface(
    value: content || ''
    size: [true, LINE_HEIGHT - 3]
    name: 'name'
    placeholder: '请输入名称'
    type: 'text'
    properties:
      lineHeight: LINE_HEIGHT + 'px'
      fontSize: FONT_SIZE
  )

  headerContainer.add(LEFT_MODIFIER).add headerContainer.input

  switcher = new ImageSurface(
    content: SWITCHOFF_IMAGE_URL
    size: [25, 30]
  )

  headerContainer.add(RIGHT_MODIFIER).add switcher

  switcher.on 'click', ->
    ratios = if alarmToggle then initialRatios else finalRatios;
    layout.setRatios(ratios, {curve : 'easeOut', duration : 500});
    alarmToggle = !alarmToggle;

    switcherContent = if alarmToggle then SWITCHON_IMAGE_URL else SWITCHOFF_IMAGE_URL
    switcher.setContent switcherContent

  MY_CENTER.on 'update:header', (name) ->
    input.setValue name

  return headerContainer

createSlide = (type, range, step, initial) ->
  slideContainer = new ContainerSurface(
    size: [window.innerWidth, LINE_HEIGHT]
  )

  slider = new Slider [BAR_WIDTH, BAR_HEIGHT], THUMB_RADIUS, range, step, initial, GREY, BLUE

  slider.onSlide 'update', (value) -> # value ISNT physical position
    #console.log value
    MY_CENTER.emit type, value

  slideContainer.add(CENTER_MODIFIER).add slider

  return slideContainer

createDate = (d) ->
  dateContainer = new ContainerSurface(
    size: [window.innerWidth, LINE_HEIGHT]
    properties:
      fontSize: TIME_FONT_SIZE
      fontWeight: 'bold'
  )

  date = new Surface(
    content: generateDate(d)
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
    d.addYears(-1)
    date.setContent(generateDate(d))

  next.on 'click', ->
    d.addYears(1)
    date.setContent(generateDate(d))

  dateContainer.add(LEFT_MODIFIER).add last

  dateContainer.add(CENTER_MODIFIER).add date

  dateContainer.add(RIGHT_MODIFIER).add next

  MY_CENTER.on '月', (value) ->
    month = Math.round(value)
    if Date.validateDay(d.getDate(), d.getFullYear(), month)
      d.setMonth(month)
      date.setContent(generateDate(d))
    else
      d.setMonth(month)
      d.setDate(Date.getDaysInMonth(d.getFullYear(), month))
      date.setContent(generateDate(d))

  MY_CENTER.on '日', (value) ->
    day = Math.round(value)
    if Date.validateDay(day, d.getFullYear(), d.getMonth())
      d.setDate(day)
      date.setContent(generateDate(d))

  MY_CENTER.on 'update:date', (date) ->
    date.setContent(generateDate(date))

  return dateContainer

generateDate = (d) ->
  weekName = switch d.toFormat('DDD')
    when 'Mon' then '周一'
    when 'Tue' then '周二'
    when 'Wed' then '周三'
    when 'Thu' then '周四'
    when 'Fri' then '周五'
    when 'Sat' then '周六'
    when 'Sun' then '周日'
  return d.toYMD('.')+'<span class="week-name">'+weekName+'</span>'

createTime = (t) ->
  timeContainer = new ContainerSurface(
    size: [window.innerWidth, LINE_HEIGHT]
  )

  time = new Surface(
    content: generateTime(t)
    size: TRUE_SIZE
    properties:
      fontSize: TIME_FONT_SIZE
      fontWeight: 'bold'
  )

  MY_CENTER.on '时', (value) ->
    hours = Math.round(value)
    t.setHours(hours)
    time.setContent(generateTime(t))

  MY_CENTER.on '分', (value) ->
    minutes = Math.round(value)
    t.setMinutes(minutes)
    time.setContent(generateTime(t))

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

  reminders = []

  i = 0

  while i < 5
    reminders.push(new ImageSurface(
      content: './img/'+ type + 'off' + i + '.png'
      size: ICON_SIZE
    ))
    i++

  five.sequenceFrom reminders
  fiveContainer.add(CENTER_MODIFIER).add five

  reminders.forEach (reminder, index) ->
    reminder.on 'click', ->
      reminderContent = reminder._imageUrl
      if type == 'clock'
        if /off/.test(reminderContent)
          iconToggle(reminder, /off/, 'on')
          clock[index] = 1
        else
          iconToggle(reminder, /on/, 'off')
          clock[index] = 0
      if type == 'cycling'
        if /off/.test(reminderContent)
          if index != cycling && cycling != -1
            iconToggle(reminder, /off/, 'on')
            iconToggle(reminders[cycling], /on/, 'off')
            cycling = index
          else if cycling == -1
            iconToggle(reminder, /off/, 'on')
            cycling = index
          else if index == cycling
            iconToggle(reminder, /off/, 'on')
        else
          iconToggle(reminder, /on/, 'off')
          cycling = -1

  return fiveContainer

iconToggle = (reminder, reg, target) ->
  reminderContent = reminder._imageUrl
  reminderContentReplaced = reminderContent.replace(reg, target)
  reminder.setContent reminderContentReplaced

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
    page.jumpTo 'memoIndex', 'abcd' # TODO: go with model

  return footer

getInitial = (index, step) ->
  return index * step

dateLayout = new SequentialLayout(
  direction: 1
)

dateLayoutItems = [
  createSlide('月', [0, 11], MONTH_STEP, getInitial(alarm.getMonth(), MONTH_STEP)),
  createDate(alarm),
  createSlide('日', [1, 31], DAY_STEP, getInitial(alarm.getDate(), DAY_STEP)),
  createSlide('时', [0, 23], HOUR_STEP, getInitial(alarm.getHours(), HOUR_STEP)),
  createTime(alarm),
  createSlide('分', [0, 59], MINUTE_STEP, getInitial(alarm.getMinutes(), MINUTE_STEP)),
  createFive('clock'),
  createFive('cycling'),
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
    # update the value of NAME input
    page.memo = memo
    MY_CENTER.emit 'update:header', memo.get('name')

    # update the central HTML of current date
    date = memo.get('date') || new Date()
    MY_CENTER.emit 'update:date', date 

    # update sliders
    ## oh shit...
    #monthP = getInitial(date.getMonth(), MONTH_STEP)
    #dayP = getInitial(date.getDate(), DAY_STEP)
    #hourP = getInitial(date.getHours(), HOUR_STEP)
    #minuteP = getInitial(date.getMinutes(), MINUTE_STEP)
    
    #dateLayoutItems[0].setPosition
    # TODO: update date...

module.exports = page
