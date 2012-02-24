(function() {
  var __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  _.templateSettings = {
    interpolate: /\{\{(.+?)\}\}/g,
    evaluate: /\{\%(.+?)\%\}/g
  };

  $(function() {
    Backbone.old_sync = Backbone.sync;
    Backbone.sync = function(method, model, options) {
      var new_options;
      new_options = _.extend({
        beforeSend: function(xhr) {
          var cookie;
          cookie = $.cookie('session');
          if (cookie) return xhr.setRequestHeader('X-CSRF-Token', cookie);
        }
      }, options);
      return Backbone.old_sync(method, model, new_options);
    };
    window.User = (function(_super) {

      __extends(User, _super);

      function User() {
        User.__super__.constructor.apply(this, arguments);
      }

      User.prototype.urlRoot = '/users';

      User.prototype.defaults = function() {
        return {
          username: '',
          email: '',
          password: '',
          admin: true,
          created: new Date()
        };
      };

      User.prototype.create = function() {
        return this.save({
          username: $('#signup-view input[name="username"]').val(),
          email: $('#signup-view input[name="email"]').val(),
          password: $('#signup-view input[name="password"]').val()
        }, {
          success: function(model, res) {
            $('.signedin-view').show();
            return $('.signedout-view').hide();
          }
        });
      };

      return User;

    })(Backbone.Model);
    window.user = new User;
    window.Session = (function(_super) {

      __extends(Session, _super);

      function Session() {
        Session.__super__.constructor.apply(this, arguments);
      }

      Session.prototype.urlRoot = '/sessions';

      Session.prototype.defaults = function() {
        return {
          username: '',
          password: ''
        };
      };

      Session.prototype.remove = function() {
        return this.destroy({
          success: function(model, res) {
            if (!res) {
              $.cookie('session', null);
              window.session = new Session;
              $('.signedin-view').hide();
              $('.signedout-view').show();
              return $('#signup-view').hide();
            }
          },
          error: function(model, res) {}
        });
      };

      return Session;

    })(Backbone.Model);
    window.session = new Session;
    window.AppView = (function(_super) {

      __extends(AppView, _super);

      function AppView() {
        AppView.__super__.constructor.apply(this, arguments);
      }

      AppView.prototype.el = $('body');

      AppView.prototype.events = {
        'click #signin': 'signin',
        'click #signup': 'signup',
        'click #signout': 'signout',
        'keypress #signin-view input[name="password"]': 'signinOnEnter',
        'keypress #signin-view input[name="email"]': 'signinOnEnter',
        'click #show-signin-view': 'showSigninView',
        'click #show-signup-view': 'showSignupView'
      };

      AppView.prototype.initialize = function() {
        var sessionCookie;
        sessionCookie = $.cookie('session');
        if (sessionCookie) {
          sessionCookie = JSON.parse(sessionCookie);
          session.set({
            id: sessionCookie.id
          });
        }
        return session.fetch({
          success: function(model, res) {
            if (res) {
              return $('.signedin-view').show();
            } else {
              return $('#signin-view, #show-signin-view, #show-signup-view').show();
            }
          },
          error: function(model, res) {}
        });
      };

      AppView.prototype.showSigninView = function() {
        $('#signin-view').show();
        return $('#signup-view').hide();
      };

      AppView.prototype.showSignupView = function() {
        $('#signup-view').show();
        return $('#signin-view').hide();
      };

      AppView.prototype.signin = function() {
        $('.notifications').html('');
        return session.save({
          email: $('#signin-view input[name="email"]').val(),
          password: $('#signin-view input[name="password"]').val()
        }, {
          success: function(model, res) {
            $.cookie('session', JSON.stringify({
              id: res.id
            }, {
              expires: 30,
              path: '/'
            }));
            $('.signedout-view').hide();
            return $('.signedin-view').show();
          },
          error: function(model, res) {
            return $('.notifications').addClass('error').html(res.responseText);
          }
        });
      };

      AppView.prototype.signinOnEnter = function(e) {
        if (e.keyCode === 13) return this.signin();
      };

      AppView.prototype.signup = function() {
        return user.create();
      };

      AppView.prototype.signout = function() {
        if (session) return session.remove();
      };

      return AppView;

    })(Backbone.View);
    return window.App = new AppView;
  });

}).call(this);
