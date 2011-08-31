#/**
#    * Model: LoginToken
#    *
#    * Used for session persistence.
#    */

mongoose = require 'mongoose'
db = mongoose.connect 'mongodb://localhost/coffeepot'

Schema = mongoose.Schema
ObjectId = Schema.ObjectId

LoginToken = new Schema
  email  : { type: String, index: true }
  series : { type: String, index: true }
  token  : { type: String, index: true }


LoginToken.method 'randomToken', -> 
  return Math.round (new Date().valueOf() * Math.random()) + ''

LoginToken.pre 'save', (next) ->
  # Automatically create the tokens
  this.token = this.randomToken()

  if this.isNew
    this.series = this.randomToken()

  next()

LoginToken.virtual('id').get -> 
  return this._id.toHexString()

LoginToken.virtual('cookieValue').get -> 
  return JSON.stringify { email: this.email, token: this.token, series: this.series }
  
mongoose.model 'LoginToken', LoginToken

module.exports = mongoose.model 'LoginToken'