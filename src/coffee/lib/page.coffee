View = require 'famous/core/View'
Page = (options) ->
  View.apply this, arguments
  # properties:
  # name
  # app
  # globals
  # model/collection
  return

Page:: = Object.create(View::)
Page::constructor = Page

Page::getName = ->
  @getOptions().name

Page::setApp = (app) ->
  @setOptions app: app

Page::getApp = ->
  @getOptions().app

Page::jumpTo = (pageName) ->
  @getApp().switchTo pageName
  return

module.exports = Page
