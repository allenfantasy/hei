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
memoListPage = require './pages/memoListPage.coffee'
editMemoPage = require './pages/editMemoPage.coffee'
sliderPage = require './pages/slider.coffee'

mainContext.add app

app.registerPage memoListPage
app.registerPage editMemoPage
#app.registerPage sliderPage
