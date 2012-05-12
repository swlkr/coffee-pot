# Deps
express = require 'express'
mongoose = require 'mongoose'
db = mongoose.connect 'mongodb://localhost/coffee-pot'
connect = require 'connect'
mongoStore = require 'connect-mongodb'
app = module.exports = express.createServer()
sessions = require './controllers/Sessions.coffee'
users = require './controllers/Users.coffee'
Session = require './models/Session'
User = require './models/User'

# Configuration
mongoStoreConnectionArgs = ->
  { dbname: db.connections[0].db.databaseName, host: db.connections[0].db.serverConfig.host, port: db.connections[0].db.serverConfig.port }

app.configure ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.cookieParser()
  app.use express.session
    store: mongoStore(mongoStoreConnectionArgs())
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

#------------------------
#### Routes ####
#------------------------

RESTfulRouter = (controller, req, res) ->
  switch req.method
    when 'POST' then controller.create req, res
    when 'PUT' then controller.update req, res
    when 'GET'
      if req.params.id or req.url == '/sessions'
        controller.read req, res
      else
        controller.list req, res
    when 'DELETE' then controller.del req, res

# Handle restful routing
RESTfulRouting = (controller, req, res) ->
  # if this is a session request, pass it on through
  if req.url == '/sessions' or (req.url == '/users' and req.method = 'POST')
    RESTfulRouter controller, req, res
    return
  
  # otherwise try to log the user in
  # 1. check to see if the user has a cookie
  if req.headers['x-csrf-token'] and (JSON.parse req.headers['x-csrf-token']).id  
    # 2. extract the session id from the cookie
    sessionID = (JSON.parse req.headers['x-csrf-token']).id
    
    # 3. Match the sessionID to a session in the datastore
    Session.findById sessionID, (err, session) ->
      if session      
        User.findOne { email: session.email }, (err, user) ->
          req.currentSession = session
          req.currentUser = user
          RESTfulRouter controller, req, res
      else
        res.send 'That\'s classified information', 401
        return
  else
    res.send null

# Index (the only route that sends html to the client)
app.get '/', (req, res) ->
  res.render 'index'

# Sessions routes
app.all '/sessions', (req, res) ->
  RESTfulRouting sessions, req, res
  
app.all '/sessions/:id', (req, res) ->
  RESTfulRouting sessions, req, res
  
# Users routes
app.all '/users', (req, res) ->
  RESTfulRouting users, req, res
  
app.all '/users/:id', (req, res) ->
  RESTfulRouting users, req, res

app.get '/404', (req, res) ->
  options.locals.title = 'Not Found! | Coffee Pot'
  res.render '404', options

app.listen 3000
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env