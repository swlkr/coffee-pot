# change the default underscore.js template bindings to mustache.js style
# but keep the evaluation ones (the ones that don't print anything to the screen)
# looking this: <% do_something_in_code_here %>
_.templateSettings =
  interpolate : /\{\{(.+?)\}\}/g
  evaluate: /\<\%(.+?)\%\>/g

$ ->
  
  # put some coffeescript here