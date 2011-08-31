exports.helpers = {
  appName: 'Coffee Pot',
  version: '0.1',
  nameAndVersion: (name, version) ->
    return name + ' v' + version
}

Date::toShortDateString = ->
  (this.getMonth() + 1) + "/" + this.getDate() + "/" + this.getFullYear()

Date::getDateAtMidnight = ->
  (new Date this.getFullYear(), this.getMonth(), this.getDate(), 0, 0, 0)

String::startsWith = (str) ->
  this.substr(0, str.length) == str

String::contains = (str) ->
  this.indexOf(str) not -1

String::uppify = (str) ->
  if str == null or str.length == 0
    return
  
  tmp = str.toUpperCase()
  tmp1 = tmp[1..tmp.length].toLowerCase()
  str = tmp[0] + tmp1
  return str
  
class FlashMessage
  constructor: (@type, @messages) ->
  
  toHtml: ->
    if @messages.length > 0
      '<div id="status" class="notification ' + @type  + '"><div>' + Uppify(@type) + '! ' + @messages.join(',') + '</div></div>'  

exports.dynamicHelpers = {
  flashMessages: (req, res) ->
    html = ''
    type = 'error'
    msg = new FlashMessage(type, req.flash type).toHtml()
    if msg != undefined
      html += msg
    type = 'info'
    msg = new FlashMessage(type, req.flash type).toHtml()
    if msg != undefined
      html += msg
    #html = ( ( flashMessage = new FlashMessage(type, req.flash type).toHTML() ) unless (req.flash type).length == 0 for type in ['error', 'info'] )
    return html
};