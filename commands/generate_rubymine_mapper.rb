class Neo::Commands::GenerateRubymineMapper < Neo::Command
	def run
		dirs = [Neo.app_dir, Neo.dir]
		$mapper = true
		File.open("#{Neo.app_dir}/rubymine_mapper.rb", 'w') {|f| f.write ''}
		dirs.each do |dir|
			Dir["#{dir}/**/*.rb"].each do |file|
				unless file.include? 'assets'
					begin
						require "#{File.dirname file}/#{File.basename(file, '.rb')}"
						puts "#{file} required"
					rescue Exception
						puts "#{file} fail to require"
					end
				end
			end
		end
	end
end