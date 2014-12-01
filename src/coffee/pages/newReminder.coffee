Modifier = require 'famous/core/Modifier'
Transform = require 'famous/core/Transform'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
Scrollview = require 'famous/views/Scrollview'
FlexibleLayout = require 'famous/views/FlexibleLayout'
HeaderFooterLayout = require 'famous/views/HeaderFooterLayout'
SequentialLayout = require 'famous/views/SequentialLayout'

Page = require '../lib/page.coffee'

newReminder = new Page(
  name: 'newReminder'
)

layout = new SequentialLayout(
  direction: 1
)

surfaces = []

createHeader = (content) ->
  header = new Surface(
    content: content
    size: [window.innerWidth, 50]
  )
  return header

createSlide = (type) ->
  slideContainer = new ContainerSurface(
    size: [window.innerWidth, 50]
  )

  slide = new Surface(
    content: type
    size: [true, true]
  )

  slideContainer.add(new Modifier(
    align: [0.5, 0.5]
    origin: [0.5, 0.5]
  )).add slide

  return slideContainer

createDate = (date) ->
  dateContainer = new ContainerSurface(
    size: [window.innerWidth, 100]
  )

  date = new Surface(
    content: date
    size: [true, true]
  )

  last = new Surface(
    content: '◀'
    size: [true, true]
  )

  next = new Surface(
    content: '▶'
    size: [true, true]
  )

  dateContainer.add(new Modifier(
    align: [0.1, 0.5]
    origin: [0.5, .5]
  )).add last

  dateContainer.add(new Modifier(
    align: [.5, .5]
    origin: [.5, .5]
  )).add date

  dateContainer.add(new Modifier(
    align: [0.9, 0.5]
    origin: [0.5, 0.5]
  )).add next

  return dateContainer

createTime = (time) ->
  timeContainer = new ContainerSurface(
    size: [window.innerWidth, 50]
  )

  time = new Surface(
    content: time
    size: [true, true]
  )

  timeContainer.add(new Modifier(
    align: [.5, .5]
    origin: [.5, .5]
  )).add time

  return timeContainer

createFive = (type) ->
  fiveContainer = new ContainerSurface(
    size: [innerWidth, 50]
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
      console.log(index)
      reminderContent = reminder.getContent()
      console.log(reminder)
      reminderContent = reminderContent.replace(/off/, '')
      console.log(reminder)
      reminder.setContent(reminderContent)

  return fiveContainer

createFooter = ->
  cancelButton = new Surface(
    content: '取消'
    size: [true, true]
  )

  confirmButton = new Surface(
    content: '确认'
    size : [true, true]
  )

  footer = new ContainerSurface(
    size: [window.innerWidth, 100]
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
surfaces.push createDate('2014.12.12')
surfaces.push createSlide('日')
surfaces.push createSlide('时')
surfaces.push createTime('12:12')
surfaces.push createSlide('分')
surfaces.push createFive('clock')
surfaces.push createFive('cycling')
surfaces.push footer

layout.sequenceFrom surfaces

newReminder.add layout

module.exports = newReminder
