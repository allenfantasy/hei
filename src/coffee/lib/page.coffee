View = require 'famous/core/View'
EventHandler = require 'famous/core/EventHandler'

Page = (options) ->
  View.apply this, arguments
  @_center = new EventHandler()
  # properties:
  # name
  # app
  # globals
  # model/collection
  #this.subscribe(@_center)
  return

Page:: = Object.create(View::)
Page::constructor = Page

Page::getName = ->
  @getOptions().name

Page::setApp = (app) ->
  @setOptions app: app

Page::getApp = ->
  @getOptions().app

Page::jumpTo = (pageName, data) ->
  @getApp().switchTo pageName, data
  return

Page::emitEvent = (type, event) ->
  @_center.emit type, event

Page::onEvent = (type, handler) ->
  @_center.on type, handler

module.exports = Page
