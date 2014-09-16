# encoding: utf-8

require 'pp'

class Neo::Commands::Test < Neo::Command
  def run(test)
    test_arr = test.split '::'

    if test.start_with? 'Neo'
      path = Neo.dir + '/tests/' + test_arr[1..-1].map{|i| i.underscore}.join('/') + '.rb'
    elsif test.start_with? 'App'
      path = Neo.app_dir + '/tests/' + test_arr[1..-1].map{|i| i.underscore}.join('/') + '.rb'
    else
      path = Neo.app_dir + '/modules/' + test_arr[0].underscore + '/tests/' + test_arr[1..-1].map{|i| i.underscore}.join('/') + '.rb'
    end

    require 'rspec'

    config = RSpec.configuration

    # optionally set the console output to colourful
    # equivalent to set --color in .rspec file
    config.color = true
    config.add_formatter('json')

    # using the output to create a formatter
    # documentation formatter is one of the default rspec formatter options
    json_formatter = RSpec::Core::Formatters::JsonFormatter.new(config.output)

    # set up the reporter with this formatter
    reporter =  RSpec::Core::Reporter.new(json_formatter)
    config.instance_variable_set(:@reporter, reporter)

    # run the test with rspec runner
    # 'my_spec.rb' is the location of the spec file
    RSpec::Core::Runner.run([path])

    results =  json_formatter.output_hash

    puts ''
    puts ''

    results[:examples].each do |result|
      puts result[:full_description] + ': ' + result[:status]
      puts "File: #{result[:file_path]}:#{result[:line_number]}"
      puts result[:exception][:message] if result[:status] == 'failed'
      puts result[:exception][:backtrace] if result[:status] == 'failed'
      puts '-----------------------------------------------------'
    end
    puts results[:summary_line]
    puts ''
    puts ''
  end
end