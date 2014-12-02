# load css
require './styles'

# Load polyfills
require 'famous-polyfills'

# import dependencies
Engine = require 'famous/core/Engine'
App = require './lib/app.coffee'

# create the main context
mainContext = Engine.createContext()

# your app here
app = new App()
homepage = require './pages/homePage.coffee'
newReminder = require './pages/newReminder.coffee'
sliderPage = require './pages/slider.coffee'

mainContext.add app

app.registerPage sliderPage
app.registerPage homepage
app.registerPage newReminder # app would set the first page as default
