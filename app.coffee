app = require './lib/coffee-pot.coffee'

app.set 'models', './models'
app.set 'controllers', '../controllers'
app.set 'views', './views'
app.set 'static', './public'
app.set 'appName', 'coffee-pot'
app.set 'version', '0.1'

app.listen '3000'
console.log 'Server listening on http://localhost:3000'