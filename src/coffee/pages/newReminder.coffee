Modifier = require 'famous/core/Modifier'
Transform = require 'famous/core/Transform'
Surface = require 'famous/core/Surface'
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
BAR_SIDE_PAD = (window.innerWidth - BAR_WIDTH) / 2


today = new Date()

container = new ContainerSurface(
  size: [window.innerWidth, window.innerHeight]
  properties:
    color: GREY
)

layout = new SequentialLayout(
  direction: 1
)

surfaces = []

createHeader = (content) ->
  headerContainer = new ContainerSurface(
    size: [window.innerWidth, LINE_HEIGHT]
    properties:
      boxShadow: BOX_SHADOW
  )

  header = new Surface(
    content: content
    size: TRUE_SIZE
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
    # valueBox.setContent(value)
    console.log value
    MY_CENTER.emit type, value

  slider.onSlide 'end', (e) ->
    console.log e.position

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
    month = value * 11 / BAR_WIDTH
    d.setMonth(month)
    date.setContent(generateDate(d))

  MY_CENTER.on '日', (value) ->
    day = value * 30 / BAR_WIDTH + 1
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
    content: t.toFormat('HH24:MI')
    size: TRUE_SIZE
    properties:
      fontSize: TIME_FONT_SIZE
      fontWeight: 'bold'
  )

  MY_CENTER.on '时', (value) ->
    hours = value * 23 / BAR_WIDTH
    t.setHours(hours)
    time.setContent(t.toFormat('HH24:MI'))

  MY_CENTER.on '分', (value) ->
    minutes = value * 59 / BAR_WIDTH
    t.setMinutes(minutes)
    time.setContent(t.toFormat('HH24:MI'))
    
  timeContainer.add(CENTER_MODIFIER).add time

  return timeContainer

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
    newReminder.jumpTo 'homepage'

  confirmButton.on 'click', ->
    newReminder.jumpTo 'homepage'

  return footer

header = createHeader '今天看完《活着》'
footer = createFooter()

surfaces.push header
surfaces.push createSlide('月', [0, BAR_WIDTH], BAR_WIDTH / 11, today.getMonth() * BAR_WIDTH / 11)
surfaces.push createDate(today)
surfaces.push createSlide('日', [0, BAR_WIDTH], BAR_WIDTH / 30, today.getDate() * BAR_WIDTH / 30)
surfaces.push createSlide('时', [0, BAR_WIDTH], BAR_WIDTH / 23, today.getHours() * BAR_WIDTH / 23)
surfaces.push createTime(today)
surfaces.push createSlide('分', [0, BAR_WIDTH], BAR_WIDTH / 59, today.getMinutes() * BAR_WIDTH / 59)
surfaces.push createFive('clock')
surfaces.push createFive('cycling')
surfaces.push footer

layout.sequenceFrom surfaces

container.add(CENTER_MODIFIER).add layout

newReminder.add container

module.exports = newReminder
