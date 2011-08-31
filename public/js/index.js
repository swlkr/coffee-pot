(function() {
  $(function() {
    var socket;
    socket = io.connect('http://localhost:3100');
    socket.on('news', function(data) {
      console.log(data);
      return socket.emit('my other event', {
        my: 'data'
      });
    });
    socket.on('emit response', function(data) {
      return console.log(data);
    });
    return $('#emit').click(function() {
      return socket.emit('emit click', {});
    });
  });
}).call(this);
