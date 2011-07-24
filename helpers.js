exports.helpers = {
  appName: 'Coffee Base',
  version: '0.1',

  nameAndVersion: function(name, version) {
    return name + ' v' + version;
  }
};

Date.prototype.toShortDateString = function(){
  return (this.getMonth() + 1) + "/" + this.getDate() + "/" + this.getFullYear();
};

Date.prototype.getDateAtMidnight = function() {
  return new Date(this.getFullYear(), this.getMonth(), this.getDate(), 0, 0, 0);
};

String.prototype.startsWith = function(str) {
  return this.substr(0, str.length) === str
}

String.prototype.contains = function(str) {
  return this.indexOf(str) != -1
}

function uppify(str) {
  if(str == null || str == '')
    return '';
    
  returnStr = ''
  
  for(i = 0; i != str.length; i++) {
    if(i == 0)
      returnStr += str[i].toUpperCase();
    else
      returnStr += str[i];
  }
  
  return returnStr;
}

function FlashMessage(type, messages) {
  this.type = type;
  this.messages = typeof messages === 'string' ? [messages] : messages;
}

FlashMessage.prototype = {
  toHTML: function() {
    return '<div id="status" class="notification png_bg ' + this.type  + '"><div>' + uppify(this.type) + '! ' + 
    this.messages.join(',') + '</div></div>';
  }
};

exports.dynamicHelpers = {
  flashMessages: function(req, res) {
    var html = '';
    ['error', 'information'].forEach(function(type) {
      var messages = req.flash(type);
      if (messages.length > 0) {
        html += new FlashMessage(type, messages).toHTML();
      }
    });
    return html;
  }
};