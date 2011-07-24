/**
  * Model: User
  */
var bcrypt = require('bcrypt')
var mongoose = require('mongoose')
var db = mongoose.connect('mongodb://localhost/db');
  
var Schema = mongoose.Schema, ObjectId = Schema.ObjectId;

// Validators
function validatePresenceOf(value) {
  return value && value.length;
}

function validateUsernameLength(value) {
  return value.length > 0 && value.length <= 20;
}

function toLower (v) {
  return v.toLowerCase();
}

function isValidEmail (v) {
  var filter  = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
  return filter.test(v);
}

function encryptPassword (pw) {
  var salt = bcrypt.gen_salt_sync(10);
  return [bcrypt.encrypt_sync(pw, salt), salt];
}

var User = new Schema({
    owner           : ObjectId
  , email           : { type: String, required: true, index: { unique: true }, set: toLower, validate: [isValidEmail, 'Invalid email'] } 
  , username        : { type: String, required: true, index: { unique: true },  }
  , hashed_password : { type: String, required: true  }
  , salt            : { type: String, required: true  }
  , created         : { type: Date }
  , updated         : { type: Date, default: Date.now }
});

User.virtual('id')
.get(function() {
  return this._id.toHexString();
});

User.virtual('password')
  .set(function(password) {
    this._password = password;
    var arr = encryptPassword(password);
    this.salt = arr[1];
    this.hashed_password = arr[0];
  })
.get(function() { return this._password; });

User.method('authenticate', function(plainText) {
  return bcrypt.compare_sync(plainText, this.hashed_password); 
});

User.pre('save', function(next) {
    if (!validatePresenceOf(this.password)) {
      next(new Error('Invalid password'));
    } else {
      if(!validatePresenceOf(this.username) || !validateUsernameLength(this.username)) {
        next(new Error('You need something in your username'))
      }
      next();
    }
  });

mongoose.model('User', User);

module.exports = mongoose.model('User');