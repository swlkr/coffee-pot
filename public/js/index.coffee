# change the default underscore templates
_.templateSettings =
  interpolate : /\{\{(.+?)\}\}/g
  evaluate: /\{\%(.+?)\%\}/g
        
$ ->
  
  # Modify backbone sync to support sessions
  Backbone.old_sync = Backbone.sync
  Backbone.sync = (method, model, options) ->
    new_options = _.extend
      beforeSend: (xhr) ->
        cookie = $.cookie 'session'
        if cookie
          xhr.setRequestHeader 'X-CSRF-Token', cookie
      options
    Backbone.old_sync method, model, new_options
  
  # Models
  class window.User extends Backbone.Model
    urlRoot: '/users'
    defaults: ->
      username: ''
      email: ''
      password: ''
      admin : true
      created: new Date()
    create: ->
      this.save { username: $('#signup-view input[name="username"]').val(), email: $('#signup-view input[name="email"]').val(), password: $('#signup-view input[name="password"]').val() }
        success: (model, res) ->
          $('.signedin-view').show()
          $('.signedout-view').hide()
  
  window.user = new User

  class window.Session extends Backbone.Model
    urlRoot: '/sessions'
    defaults: ->
      username: ''
      password: ''
    remove: ->
      this.destroy
        success: (model, res) ->
          if not res
            $.cookie 'session', null
            window.session = new Session
            $('.signedin-view').hide()
            $('.signedout-view').show()
            $('#signup-view').hide()
        error: (model, res) ->

  window.session = new Session
  
  class window.AppView extends Backbone.View
    el: $('body')
    
    events:
      'click #signin'           : 'signin'
      'click #signup'           : 'signup'
      'click #signout'          : 'signout'
      'keypress #signin-view input[name="password"]' : 'signinOnEnter'
      'keypress #signin-view input[name="email"]' : 'signinOnEnter'
      'click #show-signin-view' : 'showSigninView'
      'click #show-signup-view' : 'showSignupView'
    
    initialize: ->
            
      sessionCookie = $.cookie 'session'
      if sessionCookie
        sessionCookie = JSON.parse sessionCookie
        session.set
          id: sessionCookie.id
        
      session.fetch
        success: (model, res) ->
          if res
            $('.signedin-view').show()
          else
            $('#signin-view, #show-signin-view, #show-signup-view').show()
        error: (model, res) ->
  
    showSigninView: ->
      $('#signin-view').show()
      $('#signup-view').hide()
    
    showSignupView: ->
      $('#signup-view').show()
      $('#signin-view').hide()
  
    signin: ->
      # create a new session
      $('.notifications').html('')
      session.save { email: $('#signin-view input[name="email"]').val(), password: $('#signin-view input[name="password"]').val() }
        success: (model, res) ->
          $.cookie 'session', JSON.stringify { id: res.id }, { expires: 30, path: '/' }
          $('.signedout-view').hide()
          $('.signedin-view').show()
        error: (model, res) ->
          $('.notifications').addClass('error').html res.responseText
          
    signinOnEnter: (e) ->
      if e.keyCode == 13
        this.signin()
        
    signup: ->
      # create a new user        
      user.create()
  
    signout: ->
      if session
        session.remove()
          
  window.App = new AppView