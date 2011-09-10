exports.helpers =
  appName: 'Coffee Pot',
  version: '0.1',
  nameAndVersion: (name, version) ->
    return name + ' v' + version
  uppify: (str) ->
    if str == null or str.length == 0
      return

    tmp = str.toUpperCase()
    tmp1 = tmp[1..tmp.length].toLowerCase()
    str = tmp[0] + tmp1
    return str
  toShortDateString: (date) ->
    return (date.getMonth() + 1) + "/" + date.getDate() + "/" + date.getFullYear()
  getDateAtMidnight: (date) ->
    return (new Date date.getFullYear(), date.getMonth(), date.getDate(), 0, 0, 0)
  startsWith: (source, compare) ->
    return source.substr(0, str.length) == compare
  contains: (source, compare) ->
    return source.indexOf(compare) not -1
  
class FlashMessage
  constructor: (@type, @messages) ->
  
  toHtml: ->
    if @messages.length > 0
      '<div id="status" class="notification ' + @type  + '"><div>' + exports.helpers.uppify(@type) + '! ' + @messages.join(',') + '</div></div>'  

exports.dynamicHelpers = 
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
    return html