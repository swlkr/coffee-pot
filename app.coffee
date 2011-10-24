# Module dependencies.
express = require 'express'
mongoose = require 'mongoose'
db = mongoose.connect 'mongodb://localhost/coffeepot'
connect = require 'connect'
mongoStore = require 'connect-mongodb'
Session = require './models/Session'

app = module.exports = express.createServer()

# Configuration
# ------------------------------------------------------

helpers = require './helpers.coffee'
app.helpers helpers.helpers

mongoStoreConnectionArgs = ->
  dbname: db.connections[0].db.databaseName
  host: db.connections[0].db.serverConfig.host
  port: db.connections[0].db.serverConfig.port

app.configure = ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.set 'controllers_path', __dirname + '/controllers'
  app.set 'controllers', {}
  app.use express.bodyParser()
  app.use express.cookieParser()
  app.use express.session
    store: mongoStore mongoStoreConnectionArgs()
    secret: 'coffeepot'
  app.use express.methodOverride()
  stylus = require 'stylus'
  app.use stylus.middleware
    src: __dirname + '/public'
  app.use app.router
  app.use express.static __dirname + '/public'
  app.use express.favicon __dirname + '/public/img/favicon.ico'
  
app.configure 'development', ->
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true
  
app.configure 'production', -> 
  app.use express.errorHandler()
  
handleRequest = (req, res) ->
  
  try
    req.controller = require './controllers/' + req.params.controller
  catch err
    req.controller = ''
    res.send '500 Houston we have a problem'
    return
  
  if req.controller.name != 'sessions' and req.controller.name != 'users'
    Session.find { token: req.body.token, email: req.body.email, series: req.body.series } , (err, session) ->
      if not session
        res.send '401 Unauthorized'
        return
  
  # send some json data back to the client
  # by delegating to the controllers
  switch req.method
    when 'GET'
      if req.params.controller.substr(-1) == 's'
        req.controller.list req, res
      else 
        req.controller.read req, res
    when 'POST' then req.controller.create req, res
    when 'PUT' then req.controller.update req, res
    when 'DEL' then req.controller.del req, res

# Routing
# ------------------------------------------------------

# Index
# The starting point for the application
# This is the only html page that gets rendered
app.get '/', (req, res) ->
  res.render 'index'

app.all '/:controller', (req, res) ->
  handleRequest req, res

app.all '/:controller/:id', (req, res, next) ->
  if req.url.indexOf('.js') != -1 or req.url.indexOf('.css') != -1 or req.url.indexOf('.jpg') != -1 or req.url.indexOf('.png') != -1
    next() # express static file server
  else
    handleRequest req, res

app.error (err, req, res) ->
  if err instanceof NotFound
    res.send '404 Whatever it is you were trying to find does not exist. Deal with it.'
  else
    console.log err
    res.send '500 Houston we have a problem.'
    
process.on 'uncaughtException', (err) ->
  console.log 'Caught exception: ' + err

app.listen 3000
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
