Entity = require 'famous/core/Entity'
View = require 'famous/core/View'
Transform = require 'famous/core/Transform'
RenderController = require 'famous/views/RenderController'

App = ->
  View.apply this, arguments
  @_id = Entity.register this
  @_switcher = new RenderController(
    # overlap: false
    inTransition:
      curve: "easeIn"
      duration: 1000

    outTransition:
      curve: "easeOut"
      duration: 1000
  )
  @_switcher.inTransformFrom App.Default.inTransform
  @_switcher.outTransformFrom App.Default.outTransform

  @_pages = {}
  @_currentPage = null
  @add @_switcher
  return

App.Default =
  inTransform: (progress) ->
    Transform.translate window.innerWidth * (1.0 - progress), 0, 0

  outTransform: (progress) ->
    Transform.translate window.innerWidth * (progress - 1.0), 0, 0

App:: = Object.create(View::)
App::constructor = App

App::registerPage = (page) ->
  pageName = page.getName()
  unless @_pages[pageName]
    @_pages[pageName] = page
    page.setApp this
    if @_currentPage is null
      @_currentPage = page
      @_switcher.show page
  else
    throw new Error("Duplicated page name")
  return

App::switchTo = (pageName, data) ->
  # TODO: set inTransform/outTransform
  page = @_pages[pageName]
  page.emitEvent 'enter', data if data
  unless page
    throw new Error("Unregistered page name!")
    return
  @_currentPage = page
  @_switcher.show page
  return

App::registerWidget = (widget) ->
  return

module.exports = App
