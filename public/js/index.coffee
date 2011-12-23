# change the default underscore.js template bindings to mustache.js style
# but keep the evaluation ones (the ones that don't print anything to the screen)
# looking this: <% do_something_in_code_here %>
_.templateSettings =
  interpolate : /\{\{(.+?)\}\}/g
  evaluate: /\{\%(.+?)\%\}/g

$ ->
  
  getCookie = (key) ->
    dict = {}
    for str in document.cookie.split('%2C')
      do (str) ->
        str = str.replace(/%22/gi, '').replace(/%7B/gi, '').replace(/%7D/gi, '').replace('session=', '').replace(/%40/gi, '@')
        dict[str.split('%3A')[0]] = str.split('%3A')[1]
    return dict[key]
      
  Backbone.old_sync = Backbone.sync
  Backbone.sync = (method, model, options) ->
    new_options = _.extend
      beforeSend: (xhr) ->
        sessionID = window.session.get('token')
        email = window.session.get('email')
        series = window.session.get('series')
        if token
          xhr.setRequestHeader('X-CSRF-Token', token)
      options
    Backbone.old_sync method, model, options
      
  
  class window.User extends Backbone.Model
    url: '/users'
    defaults: ->
      username: ''
      email: ''
      password: ''
      created: new Date()
    
  window.user = new User
  
  class window.Session extends Backbone.Model
    url: '/sessions'
    defaults: ->
      token: ''
      userID: ''
      series: ''
      username: ''
      email: ''
      password: ''
    
  window.session = new Session
  
  class window.AppView extends Backbone.View
    el: $('#app')
    
    events:
      'click #signin'  : 'signin'
      'click #signup'  : 'signup'
      'click #signout' : 'signout'
      'click #show-signin-view'
    
    initialize: ->
      # try to sign user in with cookie
      if document.cookie
        window.session.set
          token: getCookie 'token'
          email: getCookie 'email'
          series: getCookie 'series'
          password: ''
          username: ''
          userID: ''
        window.session.save
          success: (model, response) ->
            $('.signed-in-view').show()
            $('.signed-out-view').hide()
            #window.session.set('sessionID', data.sessionID)
            #window.session.set('userID', data.userID)
            #window.session.set('username', data.username)
          error: (model, response) ->
            console.log 'error'
          
      # hide the signup view
      $('#signup-view').hide()
      $('.signed-in-view').hide()
    
    signin: ->
      # create a new session and send it to the server
      window.session.set
        username: ''
        email: $('#signin-view input[name="user[email]"]').val()
        password: $('#signin-view input[name="user[password]"]').val()
        token: ''
        userID: ''
      window.session.save 
        success: (model, response) ->
          # success callback
          $('.signed-in-view').show()
          $('.signed-out-view').hide()
          #window.session.set('sessionID', data.sessionID)
          #window.session.set('userID', data.userID)
          #window.session.set('username', data.username)
        error: (model, response) ->
          console.log 'error'
        
    signup: ->
      # create a new user and send it to the server
    
    signout: ->
      # get the current user and send it to the server to be destroyed
            
  window.App = new AppView
  