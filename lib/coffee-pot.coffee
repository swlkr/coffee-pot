http = require 'http'
fs = require 'fs'
jade = require 'jade'
jelly = require 'sandwich'

# default settings
setting = 
  'models' : './models'
  'controllers' : './controllers'
  'views' : './views'
  'static' : './public'

set = (key, value) ->
  setting[key] = value
  
listen = (port) ->
  app.listen port, 'localhost'

app = createServer = http.createServer (req, res) ->
  
    # There are only ever 4 routes
    # 1. Index returns all of the js template views combined and minified into index.html
    # 2. Resource routes /:controller
    # 3. Resource routes like this /:controller/:id
    # 4. Static files (.js, .css, .png, .jpg)
  
  if req.url == '/'
    # sandwich the jade views together
    jelly.sandwich setting['views']
    jadeFile = fs.readFileSync setting['views'] + '/index.jade', 'utf8'
    jadeTemplate = jade.compile jadeFile.toString(), { filename: setting['views'] + '/index.jade' }
    html = jadeTemplate
      'appName': setting['appName']
    res.writeHead 200,
      'Content-Type' : 'text/html'
    res.end html
  else
    if req.url.indexOf('.js') != -1
      res.writeHead 200,
        'Content-Type': 'text/javascript'
      fs.readFile setting['static'] + req.url, (err, data) ->
        res.end data
    else if req.url.indexOf('.css') != -1
      res.writeHead 200,
        'Content-Type': 'text/css'
      fs.readFile setting['static'] + req.url, (err, data) ->
        res.end data
    else if req.url.indexOf('.png') != -1
      res.writeHead 200,
        'Content-Type' : 'image/png'
      fs.readFile setting['static'] + req.url, (err, data) ->
        res.end data
    else if req.url.indexOf('.jpg') != -1 or req.url.indexOf('.jpeg') != -1
      res.writeHead 200,
        'Content-Type' : 'image/jpeg'
      fs.readFile setting['static'] + req.url, (err, data) ->
        res.end data
    else
      controller = require setting['controllers'] + req.url + '.coffee'
  
      switch req.method
        when 'POST' then controller.create req, res
        when 'GET'
          if req.url.indexOf('s') == req.url.length-1 
            controller.list req, res
          else
            controller.read req, res
        when 'PUT' then controller.update req, res
        when 'DEL' then controller.del req, res

  return
    
exports.listen = listen
exports.startServer = createServer  
exports.set = set
exports.app = app