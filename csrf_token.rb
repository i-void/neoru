class Neo::CsrfToken
	def self.generate
		Neo::Params::Session['csrf_token'] = 24.random_char
	end

	def self.to_s
		Neo::Params::Session['csrf_token'] || generate
	end
end