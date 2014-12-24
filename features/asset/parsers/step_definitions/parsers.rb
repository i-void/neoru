Given(/^Prepare (.*) for parsing$/) do |test_file|
  @dir = File.dirname __FILE__
  @test_file_path = "#{@dir}/#{test_file}"
end

Then(/^Parse$/) do
	parsed_content = Neo::Asset::Parsers::Coffee.parse(@path)
	expected_content = ''
	expected = {content: expected_content, extension: '.js'}
	expect(parsed_content).to eq(expected)
end

Then(/^Parse with (.*)$/) do |parser_class|
  parser_class = Neo::Asset::Parsers.const_get parser_class
  @parsed_content = parser_class.parse(@test_file_path)
end

Then(/^Expect (.*) content same as parsed content$/) do |result_file|
  @result_file_path = "#{@dir}/#{result_file}"
  file = File.open @result_file_path
  extension = File.extname(@result_file_path)
  expected_content = file.read
  expected = {content: expected_content, extension: extension}
  expect(@parsed_content).to eq(expected)
end