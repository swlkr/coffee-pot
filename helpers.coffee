exports.helpers =
  appName: 'Coffee Pot',
  version: '1.0',
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