# User model

bcrypt = require 'bcrypt'
mongoose = require 'mongoose'
db = mongoose.connect 'mongodb://localhost/coffeepot'

Schema = mongoose.Schema
ObjectId = Schema.ObjectId

# Validators
validatePresenceOf = (value) ->
  value and value.length
  
validateUsernameLength = (value) ->
  value.length > 0 and value.length <= 20
  
toLower = (v) ->
  v.toLowerCase()

isValidEmail = (v) ->
  filter  = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/
  filter.test(v)
  
encryptPassword = (pw) ->
  salt = bcrypt.gen_salt_sync 10
  [bcrypt.encrypt_sync(pw, salt), salt]

User = new Schema
  owner           : ObjectId
  email           : { type: String, required: true, set: toLower, validate: [isValidEmail, 'Invalid email'], unique: true } 
  username        : { type: String, required: true, unique: true }
  hashed_password : { type: String, required: true }
  salt            : { type: String, required: true }
  created         : { type: Date }
  updated         : { type: Date, default: Date.now }

User.virtual('id').get ->
  return this._id.toHexString()

User.virtual('password').set (password) ->
  this._password = password
  arr = encryptPassword password
  this.salt = arr[1]
  this.hashed_password = arr[0]
    
User.virtual('password').get -> 
  return this._password

User.method 'authenticate', (plainText) ->
  return bcrypt.compare_sync plainText, this.hashed_password

User.pre 'save', (next) ->
  if not validatePresenceOf this.password 
    next new Error('Invalid password')
  else if not validatePresenceOf this.username or not validateUsernameLength this.username 
    next new Error('You need something in your username')
    
  if this.created == undefined
    this.created = new Date()
      
  next()

mongoose.model 'User', User

module.exports = mongoose.model 'User'
