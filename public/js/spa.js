(function() {
  var clearNotifications, showNotification, showTemplate;
  _.templateSettings = {
    interpolate: /\{\{(.+?)\}\}/g,
    evaluate: /\<\%(.+?)\%\>/g
  };
  $(function() {
    $.post('/signin', function(response) {
      if (response.notification) {
        if (response.notification.type === 'Success') {
          return showTemplate('index-template');
        } else if (response.notification.type === 'Error') {
          return showTemplate('signin-template');
        }
      }
    }, 'json');
    $('#signup').live('click', function() {
      return $.post('/signup', {
        user: {
          username: $('#signup-form .username').val(),
          email: $('#signup-form .email').val(),
          password: $('#signup-form .password').val()
        }
      }, function(response) {
        if (response.notification) {
          showNotification(response.notification);
          if (response.notification.type === 'Success') {
            return showTemplate('index-template');
          }
        }
      }, 'json');
    });
    $('#signin').live('click', function() {
      return $.post('/signin', {
        user: {
          email: $('#signin-form .email').val(),
          password: $('#signin-form .password').val()
        }
      }, function(response) {
        if (response.notification) {
          showNotification(response.notification);
          if (response.notification.type === 'Success') {
            return showTemplate('index-template');
          }
        }
      }, 'json');
    });
    $('#logout').live('click', function() {
      return $.get('/logout', function(response) {
        if (response.notification) {
          showNotification(response.notification);
          if (response.notification.type === 'Success') {
            return showTemplate('signin-template');
          }
        }
      }, 'json');
    });
    return $('#show-signup-template, #show-signin-template').live('click', function() {
      var template;
      template = $(this).attr('id').replace('show-', '');
      return showTemplate(template);
    });
  });
  showTemplate = function(template) {
    return $('#content').fadeOut('medium', function() {
      $('#content').html($('#' + template).html());
      $('#content').fadeIn('medium');
      return clearNotifications();
    });
  };
  showNotification = function(notification) {
    var notifications;
    notifications = _.template($('#notification-template').html(), notification);
    return $('.notifications').html(notifications).fadeIn('medium');
  };
  clearNotifications = function() {
    return $('.notifications').html('');
  };
}).call(this);
