fs = require 'fs'
jade = require 'jade'

exports.sandwich = (views_dir) ->
  filenames = fs.readdirSync(views_dir)
  html = ''
  for filename in filenames
    do (filename) ->
      file = fs.readFileSync filename, 'utf8'
      template = jade.compile file.toString(), { filename: filename }
      html += template
        'appName': setting['appName']