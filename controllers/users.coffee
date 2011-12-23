# Users Controller

User = require '../models/User'
Session = require '../models/Session'

exports.create = (req, res) ->
  # create a new session (log in)
  if not req.body.user
    res.send 'Your json object needs to look like this: user : { email: "email", username: "username", password: "password" }'
    return
  
  user = new User req.body.user
  user.save (response) ->
    if not response
      req.session.userID = user.id
      session = new Session { email: user.email }
      session.save ->
        res.cookie 'session', session.cookieValue, { expires: (new Date Date.now() + 2 * 604800000), path: '/' }
        res.send ''
        return

    if response
      message = ''
      if response.errors and response.errors.email
        message += 'Something is up with that email address'

      if response.errors and response.errors.username
        message += 'Something is also up with that username'

      # Handle invalid password
      if response.message == 'Invalid password'
        message += 'What is up with that password? Could be too weak try one with more than 6 characters.'

      # Handle duplicate username/email
      if response.message and response.message.contains 'duplicate'
        property = if response.message.contains 'email' then 'email address' else 'username'
        message += 'Sorry but that ' + property + ' is taken.'
  
      res.send
        notification:
          type: 'Error'
          message: message

exports.delete = (req, res) ->
  Session.remove { email: req.currentUser.email }, ->
    res.clearCookie 'session'
    req.session.destroy ->
      User.remove { email: req.currentUser.email }, ->
        res.send ''