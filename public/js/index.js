(function() {
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  _.templateSettings = {
    interpolate: /\{\{(.+?)\}\}/g,
    evaluate: /\<\%(.+?)\%\>/g
  };
  $(function() {
    var getCookie, getUrl, urlError;
    getUrl = function(object) {
      if (!object && !object.url) {
        return null;
      }
      if (_.isFunction(object.url)) {
        return object.url();
      } else {
        return object.url;
      }
    };
    urlError = function() {
      throw new Error('A "url" property or function must be specified');
    };
    getCookie = function(key) {
      var dict, str, _fn, _i, _len, _ref;
      dict = {};
      _ref = document.cookie.split('%2C');
      _fn = function(str) {
        str = str.replace(/%22/gi, '').replace(/%7B/gi, '').replace(/%7D/gi, '').replace('session=', '').replace(/%40/gi, '@');
        return dict[str.split('%3A')[0]] = str.split('%3A')[1];
      };
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        str = _ref[_i];
        _fn(str);
      }
      return dict[key];
    };
    Backbone.old_sync = Backbone.sync;
    Backbone.sync = function(method, model, options) {
      var new_options;
      new_options = _.extend({
        beforeSend: function(xhr) {
          var email, series, sessionID;
          sessionID = window.session.get('token');
          email = window.session.get('email');
          series = window.session.get('series');
          if (token) {
            return xhr.setRequestHeader('X-CSRF-Token', token);
          }
        }
      }, options);
      return Backbone.old_sync(method, model, options);
    };
    window.User = (function() {
      __extends(User, Backbone.Model);
      function User() {
        User.__super__.constructor.apply(this, arguments);
      }
      User.prototype.url = '/users';
      User.prototype.defaults = function() {
        return {
          username: '',
          email: '',
          password: '',
          created: new Date()
        };
      };
      return User;
    })();
    window.user = new User;
    window.Session = (function() {
      __extends(Session, Backbone.Model);
      function Session() {
        Session.__super__.constructor.apply(this, arguments);
      }
      Session.prototype.url = '/sessions';
      Session.prototype.defaults = function() {
        return {
          token: '',
          userID: '',
          series: '',
          username: '',
          email: '',
          password: ''
        };
      };
      return Session;
    })();
    window.session = new Session;
    window.AppView = (function() {
      __extends(AppView, Backbone.View);
      function AppView() {
        AppView.__super__.constructor.apply(this, arguments);
      }
      AppView.prototype.el = $('#app');
      AppView.prototype.events = {
        'click #signin': 'signin',
        'click #signup': 'signup',
        'click #signout': 'signout'
      };
      AppView.prototype.initialize = function() {
        if (document.cookie) {
          window.session.set({
            token: getCookie('token'),
            email: getCookie('email'),
            series: getCookie('series'),
            password: '',
            username: '',
            userID: ''
          });
          window.session.save({
            succes: function(model, response) {
              $('.signed-in-view').show();
              return $('.signed-out-view').hide();
            },
            error: function(model, response) {
              return console.log('error');
            }
          });
        }
        $('#signup-view').hide();
        return $('.signed-in-view').hide();
      };
      AppView.prototype.signin = function() {
        window.session.set({
          username: '',
          email: $('#signin-view input[name="user[email]"]').val(),
          password: $('#signin-view input[name="user[password]"]').val(),
          token: '',
          userID: ''
        });
        return window.session.save({
          success: function(model, response) {
            $('.signed-in-view').show();
            return $('.signed-out-view').hide();
          },
          error: function(model, response) {
            return console.log('error');
          }
        });
      };
      AppView.prototype.signup = function() {};
      AppView.prototype.signout = function() {};
      return AppView;
    })();
    return window.App = new AppView;
  });
}).call(this);
