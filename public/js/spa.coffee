# change the default underscore.js template bindings to mustache.js style
# but keep the evaluation ones (the ones that don't print anything to the screen)
# looking this: <% do_something_in_code_here %>
_.templateSettings =
  interpolate : /\{\{(.+?)\}\}/g
  evaluate: /\<\%(.+?)\%\>/g

$ ->
  
  # first things first, try to login with a cookie
  $.post(
    '/signin'
    (response) ->
      if response.notification
        if response.notification.type == 'Success'
          showTemplate 'index-template'
        else if response.notification.type == 'Error'
          showTemplate 'signin-template'            
    'json'
  )
  
  # wire up sign in, sign up and logout events
  $('#signup').live 'click', ->
    $.post(
      '/signup'
      user:
        username: $('#signup-form .username').val()
        email: $('#signup-form .email').val()
        password: $('#signup-form .password').val()
      (response) ->
        if response.notification
          showNotification response.notification
          if response.notification.type == 'Success'
            showTemplate 'index-template'
      'json'
    )
  
  $('#signin').live 'click', ->
    $.post(
      '/signin'
      user:
        email: $('#signin-form .email').val()
        password: $('#signin-form .password').val()
      (response) ->
        if response.notification
          showNotification response.notification
          if response.notification.type == 'Success'
            showTemplate 'index-template'            
      'json'
    )
  
  $('#logout').live 'click', ->
    $.get(
      '/logout'
      (response) ->
        if response.notification
          showNotification response.notification
          if response.notification.type == 'Success'
            showTemplate 'signin-template'
      'json'
    )
    
  $('#show-signup-template, #show-signin-template').live 'click', ->
    template = $(this).attr('id').replace('show-', '')
    showTemplate template

showTemplate = (template) ->
  $('#content').fadeOut 'medium', 
    -> 
      $('#content').html $('#' + template).html()
      $('#content').fadeIn 'medium'
      clearNotifications()
      
showNotification = (notification) ->
  notifications = _.template $('#notification-template').html(), notification
  $('.notifications').html(notifications).fadeIn 'medium'

clearNotifications = ->
  $('.notifications').html('')
  