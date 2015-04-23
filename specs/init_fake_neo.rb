require 'minitest/autorun'
require 'mocha/mini_test'
require 'pp'
module Neo
	def self.app_dir; './fake'	end
	def self.log(*args); args end
	def self.dir; '..' end
	def self.trn(phrase, lang:'EnEn', replace:{})
		translated_phrase = Neo::I18N.translate(phrase,lang)
		replace.reduce(translated_phrase) {|memo, (key, value)|	memo.gsub key, value }
	end
	class Config
		def self.[](val)
			'test' if val == :env
		end
	end
end

require '../module_extend'
Dir['../helpers/*'].each { |f| require f }