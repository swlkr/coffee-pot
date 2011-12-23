# Users Controller

User = require '../models/User'
Session = require '../models/Session'

# save a new user to the database
saveUser = (user, req, res) ->
  user.save (response) ->
    if response
      if response.errors and response.errors.email
        res.send { error: 'Something is up with that email address' }, 401
        return
  
      if response.errors and response.errors.username
        res.send { error: 'Something is also up with that username' }, 401
        return

      # Handle invalid password
      if response.message == 'Invalid password'
        res.send { error: 'What\'s up with that password? Could be too weak try one with more than 6 characters.' }, 401
        return

      # Handle duplicate username/email
      if response.message and response.message.indexOf 'duplicate' != -1
        property = if response.message.indexOf 'email' != -1 then 'email address' else 'username'
        res.send { error: 'Sorry but that ' + property + ' is taken.' }, 401
        return
        
    session = new Session { email: user.email }
    session.save ->
      res.cookie 'session', JSON.stringify { id: session.id } , { expires: (new Date Date.now() + 2 * 604800000), path: '/' }
      res.send { email: user.email, username: user.username, password: '' }
      return
  

# POST a new user
exports.create = (req, res) ->
  if not req.body.email or not req.body.username or not req.body.password
    res.send 'Come on now. I need an email, username and password to do this thing!'
    return
  
  user = new User req.body
  
  # check for uniqueness
  User.find { username: user.username, email: user.email }, (err, users) ->  
    if users.length != 0
      res.send { error: 'That username or email is already taken.' }
      return
      
    saveUser user, req, res

# List users
exports.list = (req, res) ->
  User.find { companyId: req.currentUser.companyId }, (err, users) ->
    res.send users

# Update users
exports.update = (req, res) ->
  
# Delete a user
exports.del = (req, res) ->
  User.findById req.params.id, (err, user) ->
    if user.admin == true
      res.send 'Cannot delete an admin user'
      return
      
    user.remove ->
      res.send null