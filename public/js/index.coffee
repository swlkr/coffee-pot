$ ->
  socket = io.connect 'http://localhost:3100'
  socket.on 'news', (data) ->
    console.log data
    socket.emit 'my other event', { my: 'data' }
    
  socket.on 'emit response', (data) ->
    console.log data
    
  $('#emit').click ->
    socket.emit 'emit click', {}
  