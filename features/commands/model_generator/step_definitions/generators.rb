Given(/^Clear the fake model directory$/) do
	@structure_dir = "#{Neo.app_dir}/structure"
	Dir["#{@structure_dir}/**"].each do |path|
		File.delete path unless path.end_with? 'structure.yml'
	end
	expect(Dir["#{@structure_dir}/**"]).to eq(["#{@structure_dir}/structure.yml"])
end

Given(/^Create a fake model file into model directory$/) do
	pending
end

Given(/^Read the (.*)$/) do |structure_file|
	pending
end

When(/^Model files generated$/) do
	pending
end

Then(/^The fake model file must be deleted$/) do
	pending
end

Then(/^Module directories must be created$/) do
	pending
end

Then(/^Model files must be created$/) do
	pending
end

Then(/^Model files must be same with prepared content$/) do
	pending
end