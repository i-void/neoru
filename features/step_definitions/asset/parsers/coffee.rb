Given(/^Prepare test file for parsing$/) do
	dir = File.dirname __FILE__
	@path = "#{dir}/testfile.coffee"
end

Then(/^Parse$/) do
	parsed_content = Neo::Asset::Parsers::Coffee.parse(@path)
	expected_content = "
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
      nestedKey: \"value\"
    },
    array: [1],
    nestedArray: [1, 2, [\"2a\", [\"2a-I\"]]]
  };

  foobar(function() {
    alert(foo.array);
  });

}).call(this);
"
	expected = {content: expected_content, extension: '.js'}
	expect(parsed_content).to eq(expected)
end