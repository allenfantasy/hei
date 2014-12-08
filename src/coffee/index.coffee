# load css
require './styles'

# Load polyfills
require 'famous-polyfills'

# import FastClick
attachFastClick = require 'fastclick'
attachFastClick document.body

# import dependencies
Engine = require 'famous/core/Engine'
App = require './lib/app.coffee'

# create the main context
mainContext = Engine.createContext()

# your app here
app = new App()
dragScrollPage = require './pages/dragScroll.coffee'
indexPage = require './pages/memoIndex.coffee'
editPage = require './pages/memoEdit.coffee'
sliderPage = require './pages/slider.coffee'

mainContext.add app

#app.registerPage dragScrollPage
app.registerPage indexPage
app.registerPage editPage
#app.registerPage sliderPage
