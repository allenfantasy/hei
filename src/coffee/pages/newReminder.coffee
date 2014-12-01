Modifier = require 'famous/core/Modifier'
Transform = require 'famous/core/Transform'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
SequentialLayout = require 'famous/views/SequentialLayout'

Page = require '../lib/page.coffee'
require 'date-utils'

newReminder = new Page(
  name: 'newReminder'
)

BLUE = '#41c4d3'
GREY = '#9da9ab'
LINE_HEIGHT = window.innerHeight / 10
FONT_SIZE = '20px'
TRUE_SIZE = [true, true]
BOX_SHADOW = '0 0 3px #888888'

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
    properties:
      lineHeight: LINE_HEIGHT + 'px'
      fontSize: FONT_SIZE
  )

  headerContainer.add(new Modifier(
    align: [0.1, 0.5]
    origin: [0, 0.5]
  )).add header

  return headerContainer

createSlide = (type) ->
  slideContainer = new ContainerSurface(
    size: [window.innerWidth, LINE_HEIGHT]
  )

  slide = new Surface(
    size: [window.innerWidth - 50, 8]
    properties:
      backgroundColor: GREY
  )

  ball = new Surface(
    size: [20, 20]
    properties:
      borderRadius: '50%'
      backgroundColor: BLUE
  )

  slideContainer.add(new Modifier(
    align: [0.5, 0.5]
    origin: [0.5, 0.5]
  )).add slide

  slideContainer.add(new Modifier(
    align: [0.5, 0.5]
    origin: [0.5, 0.5]
  )).add ball

  return slideContainer

createDate = (d) ->
  dateContainer = new ContainerSurface(
    size: [window.innerWidth, LINE_HEIGHT]
    properties:
      fontSize: '30px'
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
    today.addYears(-1)
    date.setContent(generateDate(today))

  next.on 'click', ->
    today.addYears(1)
    date.setContent(generateDate(today))

  dateContainer.add(new Modifier(
    align: [0.1, 0.5]
    origin: [0, .5]
  )).add last

  dateContainer.add(new Modifier(
    align: [.5, .5]
    origin: [.5, .5]
  )).add date

  dateContainer.add(new Modifier(
    align: [0.9, 0.5]
    origin: [1, 0.5]
  )).add next

  return dateContainer

generateDate = (d) ->
  weekName = switch d.toFormat('DDDD')
    when 'Monday' then '周一'
    when 'Tuesday' then '周二'
    when 'Wednesday' then '周三'
    when 'Thursday' then '周四'
    when 'Friday' then '周五'
    when 'Saturday' then '周六'
    when 'Sunday' then '周日'
  return d.toYMD('.')+'<span class="week-name">'+weekName+'</span>'

createTime = (t) ->
  timeContainer = new ContainerSurface(
    size: [window.innerWidth, LINE_HEIGHT]
  )

  time = new Surface(
    content: t.toFormat('HH24:MI')
    size: TRUE_SIZE
    properties:
      fontSize: '30px'
      fontWeight: 'bold'
  )

  timeContainer.add(new Modifier(
    align: [.5, .5]
    origin: [.5, .5]
  )).add time

  return timeContainer

createFive = (type) ->
  fiveContainer = new ContainerSurface(
    size: [innerWidth, LINE_HEIGHT]
  )
  five = new SequentialLayout(
    direction: 0
    itemSpacing: 40
  )

  reminders = []

  i = 0

  while i < 5
    reminders.push(new ImageSurface(
      content: './img/'+ type + 'off' + i + '.png'
      size: [30, 35]
    ))
    i++

  five.sequenceFrom reminders
  fiveContainer.add(new Modifier(
    origin: [.5, .5]
    align: [.5, .5]
  )).add five

  reminders.forEach (reminder, index) ->
    reminder.on 'click', ->
      reminderContent = reminder._imageUrl
      if /off/.test(reminderContent)
        reminderContent = reminderContent.replace(/off/, "on")
        reminder.setContent reminderContent
      else
        reminderContent = reminderContent.replace(/on/, "off")
        reminder.setContent reminderContent

  return fiveContainer

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

  return footer

header = createHeader '今天看完《活着》'
footer = createFooter()

surfaces.push header
surfaces.push createSlide('月')
surfaces.push createDate(today)
surfaces.push createSlide('日')
surfaces.push createSlide('时')
surfaces.push createTime(today)
surfaces.push createSlide('分')
surfaces.push createFive('clock')
surfaces.push createFive('cycling')
surfaces.push footer

layout.sequenceFrom surfaces

container.add(new Modifier(
  origin: [.5, .5]
  align: [.5, .5]
)).add layout

newReminder.add container

module.exports = newReminder
