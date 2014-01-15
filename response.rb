module Neo
	class Response
		class << self
			def error404
				conf = Neo::Config.main[:errors][:e404]
				view = Neo::View.new(conf[0])
				return view.render(conf[1])
			end
			def error500
				conf = Neo::Config.main[:errors][:e500]
				view = Neo::View.new(conf[0])
				return view.render(conf[1])
			end
		end
	end
end