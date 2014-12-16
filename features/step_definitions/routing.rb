Given(/^add route as \/test with parameters will tested by (.*)$/) do |regexp|
  Neo::Config[:routes][:test] = ['/test', "#{regexp}", 'main:main:index', 'get']
  Neo.server_vars['REQUEST_METHOD'] = 'get'
end

Then(/^(.*) must pass$/) do |true_url|
  Neo.server_vars['REQUEST_PATH'] = true_url
  expect(Neo::Router.check_from_config).to eq('main:main:index')
end


Then(/^(.*) must give error$/) do |false_url|
  Neo.server_vars['REQUEST_PATH'] = false_url
  expect(Neo::Router.check_from_config).to eq(nil)
end