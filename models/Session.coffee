#/**
#    * Model: Session
#    *
#    * Used for session persistence.
#    */

mongoose = require 'mongoose'
db = mongoose.connect 'mongodb://localhost/coffee-pot'

Schema = mongoose.Schema
ObjectId = Schema.ObjectId

Session = new Schema
  email  : { type: String, index: true }
  series : { type: String, index: true }
  token  : { type: String, index: true }


Session.method 'randomToken', -> 
  return Math.round (new Date().valueOf() * Math.random()) + ''

Session.pre 'save', (next) ->
  # Automatically create the tokens
  this.token = this.randomToken()

  if this.isNew
    this.series = this.randomToken()

  next()

Session.virtual('id').get -> 
  return this._id.toHexString()

Session.virtual('cookieValue').get -> 
  return JSON.stringify { email: this.email, token: this.token, series: this.series }
  
mongoose.model 'Session', Session

module.exports = mongoose.model 'Session'