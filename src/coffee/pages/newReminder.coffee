Modifier = require 'famous/core/Modifier'
Transform = require 'famous/core/Transform'
Surface = require 'famous/core/Surface'
InputSurface = require 'famous/surfaces/InputSurface'
ImageSurface = require 'famous/surfaces/ImageSurface'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
SequentialLayout = require 'famous/views/SequentialLayout'
EventHandler = require 'famous/core/EventHandler'

Page = require '../lib/page.coffee'
Slider = require '../lib/widgets/Slider.coffee'

require 'date-utils'

newReminder = new Page(
  name: 'newReminder'
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

alarm = new Date()

container = new ContainerSurface(
  size: [window.innerWidth, window.innerHeight]
  properties:
    color: GREY
)

layout = new SequentialLayout(
  direction: 1
)

createHeader = (content) ->
  headerContainer = new ContainerSurface(
    size: [window.innerWidth, LINE_HEIGHT]
    properties:
      boxShadow: BOX_SHADOW
  )

  header = new InputSurface(
    value: content || ''
    size: [true, LINE_HEIGHT - 3]
    name: 'name'
    placeholder: '请输入名称'
    type: 'text'
    properties:
      lineHeight: LINE_HEIGHT + 'px'
      fontSize: FONT_SIZE
  )

  headerContainer.add(new Modifier(
    align: [0.05, 0.5]
    origin: [0, 0.5]
  )).add header

  return headerContainer

createSlide = (type, range, step, initial) ->
  slideContainer = new ContainerSurface(
    size: [window.innerWidth, LINE_HEIGHT]
  )

  slider = new Slider [BAR_WIDTH, BAR_HEIGHT], THUMB_RADIUS, range, step, initial, GREY, BLUE

  slider.onSlide 'update', (e) ->
    value = e.position[0]
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

  dateContainer.add(new Modifier(
    align: [0.05, 0.5]
    origin: [0, .5]
  )).add last

  dateContainer.add(CENTER_MODIFIER).add date

  dateContainer.add(new Modifier(
    align: [0.95, 0.5]
    origin: [1, 0.5]
  )).add next

  MY_CENTER.on '月', (value) ->
    month = Math.round(value * 11 / BAR_WIDTH)
    if Date.validateDay(d.getDate(), d.getFullYear(), month)
      d.setMonth(month)
      date.setContent(generateDate(d))
    else
      d.setMonth(month)
      d.setDate(Date.getDaysInMonth(d.getFullYear(), month))
      date.setContent(generateDate(d))

  MY_CENTER.on '日', (value) ->
    day = Math.round(value * 30 / BAR_WIDTH + 1)
    if Date.validateDay(day, d.getFullYear(), d.getMonth())
      d.setDate(day)
      date.setContent(generateDate(d))

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
    hours = Math.round(value * 23 / BAR_WIDTH)
    t.setHours(hours)
    time.setContent(generateTime(t))

  MY_CENTER.on '分', (value) ->
    minutes = Math.round(value * 59 / BAR_WIDTH)
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

  clock = [0, 0, 0, 0, 0]
  cycling = -1
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
      boxShadow: BOX_SHADOW
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
    newReminder.jumpTo 'homepage' # do nothing

  confirmButton.on 'click', ->
    newReminder.jumpTo 'homepage', 'abcd' # TODO: go with model

  return footer

getInitial = (index, step) ->
  return index * step

layout.sequenceFrom [
  createHeader('今天看完《活着》'),
  createSlide('月', [0, BAR_WIDTH], MONTH_STEP, getInitial(alarm.getMonth(), MONTH_STEP)),
  createDate(alarm),
  createSlide('日', [0, BAR_WIDTH], DAY_STEP, getInitial(alarm.getDate(), DAY_STEP)),
  createSlide('时', [0, BAR_WIDTH], HOUR_STEP, getInitial(alarm.getHours(), HOUR_STEP)),
  createTime(alarm),
  createSlide('分', [0, BAR_WIDTH], MINUTE_STEP, getInitial(alarm.getMinutes(), MINUTE_STEP)),
  createFive('clock'),
  createFive('cycling'),
  createFooter()
]

container.add(CENTER_MODIFIER).add layout

newReminder.add container

newReminder.onEvent 'beforeEnter', (data) ->
  console.log data

module.exports = newReminder
