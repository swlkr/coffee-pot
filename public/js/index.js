(function() {
  _.templateSettings = {
    interpolate: /\{\{(.+?)\}\}/g,
    evaluate: /\<\%(.+?)\%\>/g
  };
  $(function() {});
}).call(this);
