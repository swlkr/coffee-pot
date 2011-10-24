# Sessions Controller

Session = require '../models/Session'
User = require '../models/User'

exports.name = 'sessions'  

exports.create = (req, res) ->
  if not req.body.email and not req.body.password
    res.send 'Your json object needs to look like this: { email: "email", password: "password" }'
  else
    User.findOne { email: req.body.email }, (err, user) ->
      if user and user.authenticate req.body.password
        req.currentUser = user
        session = new Session { email: user.email }
        session.save ->
          res.cookie 'session', session.cookieValue, { expires: (new Date Date.now() + 2 * 604800000), path: '/' }
          res.send
            sessionID: session.id
            userID: user.id
            username: user.username
            password: ''
          return
      else
        res.send
          notification:
            type: 'Error'
            message: 'Could not find that user in the datastore'
        return

exports.read = (req, res) ->
  Session.findById req.params.id, (err, session) ->
    res.send session

exports.del = (req, res) ->
  Session.remove { email: req.currentUser.email }, ->
    res.clearCookie 'session'
    req.session.destroy ->
      res.send ''