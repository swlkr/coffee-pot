# Module dependencies.
express = require 'express'
User = require './models/User'
LoginToken = require './models/LoginToken'
mongoose = require 'mongoose'
db = mongoose.connect 'mongodb://localhost/coffeepot'
connect = require 'connect'
mongoStore = require 'connect-mongodb'

app = module.exports = express.createServer()

# Configuration

helpers = require './helpers.coffee'
app.helpers helpers.helpers
app.dynamicHelpers helpers.dynamicHelpers

mongoStoreConnectionArgs = ->
  { dbname: db.connections[0].db.databaseName, host: db.connections[0].db.serverConfig.host, port: db.connections[0].db.serverConfig.port }

app.configure = ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.cookieParser()
  tmpStore = mongoStore mongoStoreConnectionArgs()
  tmp = { store: tmpStore, secret: 'Coffee Pot' }
  app.use express.session tmp
  app.use express.methodOverride()
  stylus = require 'stylus'
  app.use stylus.middleware { src: __dirname + '/public' }
  app.use app.router
  app.use express.static __dirname + '/public'
  app.use express.favicon __dirname + '/public/img/favicon.ico'
  
app.configure 'development', ->
  app.use express.errorHandler { dumpExceptions: true, showStack: true }
  
app.configure 'production', -> 
  app.use express.errorHandler()

# Global variables
options = {
  locals : {
    username: null,
    scripts : []
  },
  layout : 'layout'
}

# Authenticates from a cookie
# req - request
# res - response
# next is a holder variable for moving on to the next callback in the chain
authenticateFromLoginToken = (req, res, next) ->
  cookie = JSON.parse req.cookies.logintoken 
  json = { email: cookie.email, series: cookie.series, token: cookie.token }
  LoginToken.findOne json, (err, loginToken) ->
    if not loginToken
      res.redirect '/login'
      return

    User.findOne { email: loginToken.email }, (err, user) ->
      if not user
        res.redirect '/login'
        return
    
      if user
        req.session.user_id = user.id
        req.session.username = user.username
        req.currentUser = user
        loginToken.token = loginToken.randomToken()
        loginToken.save ->
          res.cookie 'logintoken', loginToken.cookieValue, { expires: (new Date Date.now() + 2 * 604800000), path: '/' }
          next()

# Middleware for user authentication
# req - request
# res - response
# next is a holder variable for moving on to the next callback in the chain
userRequired = (req, res, next) ->
  if req.session and req.session.user_id
    User.findById req.session.user_id, (err, user) ->
      if user
        req.currentUser = user
        res.locals options 
        next()
      else
        res.locals options
        res.redirect '/login'
  else if req.cookies and req.cookies.logintoken
    authenticateFromLoginToken req, res, next
  else
    res.locals options
    res.redirect '/login'
    
######------------------
##### Routes
#####-------------------

# Index
# The starting point for the application
app.get '/', userRequired, (req, res) ->
  # render the app
  options.locals.scripts[0] = 'application.js'
  res.render 'index', options 
    
# Sign Up
app.get '/signup', (req, res) ->
  if req.currentUser
    res.redirect '/'
    return

  res.render 'signup', options

app.post '/signup', (req, res) ->
  if not req.body.user
    res.render '/signup'

  user = new User req.body.user
  user.save (response) ->
    if not response
      req.session.user_id = user.id
      loginToken = new LoginToken { email: user.email }
      loginToken.save ->
        res.cookie 'logintoken', loginToken.cookieValue, { expires: (new Date Date.now() + 2 * 604800000), path: '/' }
        res.redirect '/'
      return

    if response
      if response.errors and response.errors.email
        req.flash 'error', 'Something is up with that email address'

      if response.errors and response.errors.username
        req.flash 'error', 'Something is also up with that username'

      # Handle invalid password
      if response.message == 'Invalid password'
        req.flash 'error', 'What\'s up with that password? Could be too weak try one with more than 6 characters.'

      # Handle duplicate username/email
      if response.message and response.message.contains 'duplicate'
        property = if response.message.contains 'email' then 'email address' else 'username'
        req.flash 'error', 'Sorry but that ' + property + ' is taken.'

      res.redirect 'signup'

# Login
app.get '/login', (req, res) ->
  if req.currentUser
    res.redirect '/'
    return
    
  res.render 'login', options

app.post '/login', (req, res) ->
  if not req.body.user
    res.redirect '/login'
  else
    # find the user and set the currentUser session variable
    User.findOne { email: req.body.user.email }, (err, user) ->
      if user and user.authenticate req.body.user.password
        req.session.user_id = user.id
        loginToken = new LoginToken { email: user.email }
        loginToken.save ->
          res.cookie 'logintoken', loginToken.cookieValue, { expires: (new Date Date.now() + 2 * 604800000), path: '/' }
          res.redirect '/'
      else
        req.flash 'error', 'Your username or password is incorrect.'
        res.redirect '/login'

# Logout
app.get '/logout', userRequired, (req, res) ->
  if req.session
    LoginToken.remove { email: req.currentUser.email }, ->
    res.clearCookie 'logintoken'
    req.session.destroy ->
    options.locals.username = null

  res.redirect '/'
    
app.get '/404', (req, res) ->
  res.render '404', options
    
process.on 'uncaughtException', (err) ->
  console.log 'Caught exception: ' + err

app.listen 3000
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
