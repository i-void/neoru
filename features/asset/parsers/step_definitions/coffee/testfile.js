
/**
Multiline Documentation
 */

(function() {
  var foo, foobar;

  foobar = function(callback) {
    setTimeout((function() {
      callback();
    }), 1000);
  };

  foo = {
    key: {
      nestedKey: "value"
    },
    array: [1],
    nestedArray: [1, 2, ["2a", ["2a-I"]]]
  };

  foobar(function() {
    alert(foo.array);
  });

}).call(this);
