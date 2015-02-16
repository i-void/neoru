class Neo::Params
	class << self
		attr_accessor :module,:controller,:action, :env
	end

	module Hashable
		def [](var)
			@hash_store[var]
		end
		def []=(var, value)
			@hash_store[var] = value
		end
	end

	class Session
		extend Hashable
		@hash_store = Neo.req.session
  rescue
    @hash_store = nil
	end

	class Post
		extend Hashable
		@hash_store = Neo.req.POST
  rescue
    @hash_store = nil
	end

	class Get
		extend Hashable
		@hash_store = Neo.req.GET
  rescue
    @hash_store = nil
	end
	
	# class File
	# 	extend Hashable
	# 	@hash_store = Neo.req::Multipart::UploadedFile
	# end
end