# encoding: utf-8
require 'yaml'
module Neo
	class Fixture
		attr_accessor :data,:path
		def initialize(path)
			@path = path
		end

		def parse_data
			@data = YAML.load(File.read(@path, encoding: 'UTF-8'))
		end

		def tr_sorter(subject,case_insentive=true)
			point = 0.0
			arr = %w(a  b  c  ç  d  e  f  g  ğ  h  ı  i  j  k  l  m  n  o  ö  p  q  r  s  ş  t  u  ü  v  w  x  y  z)
			cap = %w(A  B  C  Ç  D  E  F  G  Ğ  H  I  İ  J  K  L  M  N  O  Ö  P  Q  R  S  Ş  T  U  Ü  V  W  X  Y  Z)
			step = 100000.0
			subject.split('').each do |letter|
				index = arr.find_index(letter)
				point += (index+1)*step unless index.nil?
				index = cap.find_index(letter)
				unless index.nil?
					point += case_insentive ? (index+1)*step : ((index+1)+arr.length)*step
				end
				step = step/arr.length
				step = step/2 unless case_insentive
			end
			return point
		end

		def load(sort_col=nil,case_insentive=true, sorter='tr_sorter')
			parse_data
			@data.each do |model, value|
				obj = eval(model)
				value.each do |params|
					obj_instance = obj.new
					params.each do |key,param|
						obj_instance.instance_variable_set('@'+key,param)
					end
					unless sort_col.nil?
						point = send(sorter,obj_instance.send(sort_col),case_insentive)
						obj_instance.send(sort_col+'_seq=',point)
					end
					obj_instance.save
				end
			end
		end
	end
end