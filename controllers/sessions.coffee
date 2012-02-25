# Sessions Controller. Now with more REST!

Session = require '../models/Session'
User = require '../models/User'

# POST a new session
exports.create = (req, res) ->
  if not req.body.email and not req.body.password
    res.send 'Come on now, there\'s no email or password!', 401
  else
    User.findOne { email: req.body.email }, (err, user) ->
      if not user
        res.send 'There\'s a glitch in the matrix: you don\'t exist.\nThere\'s a glitch in the matrix: you don\'t exist.', 401
        return
      
      if not user.authenticate req.body.password
        res.send 'Access denied. Your password is incorrect.', 401
        return
        
      # clear any old sessions
      # Session.remove { email: user.email }, ->
      session = new Session { email: user.email }
      session.save ->
        #res.cookie 'session', session.cookieValue, { expires: (new Date Date.now() + 2 * 604800000), path: '/' }
        res.send { id: session.id }

# GET a session
exports.read = (req, res) ->
  if req.currentSession
    res.send { id: req.currentSession.id }
    return
  
  if not req.headers['x-csrf-token']
    res.send null
    return
  
  sessionID = (JSON.parse req.headers['x-csrf-token']).id
  
  if not sessionID
    res.send null
    return
    
  Session.findById sessionID, (err, session) ->
    res.send { id: session.id }

# DELete a session
exports.del = (req, res) ->
  Session.remove { _id: req.currentSession.id }, ->
    res.clearCookie 'session'
    req.session.destroy ->
      res.send null