require 'json'
module Neo
	module Response
		extend self

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

		# reads the file
		# get its mimetype
		# and returns content as mimetype
		def static(file)
			mime = MIME::Types.type_for(file).first.to_s
			if mime == 'application/x-ruby'
				return error404
			end
			file = File.open(file, 'rb')
			contents = file.read
			file.close
			return ['200', {'Content-Type' => mime}, [contents]]
		end

		#returns simple html format
		def html(content)
			return [200, {'Content-Type' => 'text/html'}, [content]]
		end

		def redirect(url)
			return [302, {'Content-Type' => 'text', 'Location' => url}, ['302 found'] ]
		end

		#returns content json encoded
		def json(content)
			return [200, {'Content-Type' => 'application/json'}, [content.to_json]]
		end
	end
end