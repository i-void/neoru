Given(/^Clear the fake model directory except (.*)$/) do |structure_file|
	require 'fileutils'
	@structure_dir = "#{Neo.app_dir}/structure"
	Pathname.new(@structure_dir).children.each do |path|
		path.rmtree unless path.to_s.end_with?(structure_file)
	end
	expect(Dir["#{@structure_dir}/**"]).to eq(["#{@structure_dir}/#{structure_file}"])
end

Given(/^Create a fake model file into model directory$/) do
	file_path = "#{@structure_dir}/auth/fake.rb"
	FileUtils.mkpath "#{@structure_dir}/auth"
	File.write file_path, 'fake'
	expect(File.file? file_path).to be true
end

Given(/^Read the (.*)$/) do |structure_file|
	@generator = Neo::Commands::ModelGenerator.new "#{@structure_dir}/#{structure_file}"

end

When(/^Model files generated$/) do
	@generator.generate
end

Then(/^The fake model file must be deleted$/) do
	file_path = "#{@structure_dir}/auth/fake.rb"
	expect(File.file? file_path).to be false
end

Then(/^Module directories must be created$/) do
	@generator.modules.each_key do |_module|
		path = File.join @structure_dir, _module.to_s.underscore
		expect(File.directory? path).to be true
	end
end

Then(/^Model files must be created$/) do
	@generator.modules.each do |_module, models|
		models.each_key do |model|
			path = File.join @structure_dir, _module.to_s.underscore, model.to_s.underscore
			expect(File.file? "#{path}.rb").to be true
		end
	end
end

Then(/^Model files must be same with prepared content$/) do
	pending
end