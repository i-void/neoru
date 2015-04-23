class Main::Controllers::Main < Neo::Controller

	def index_action
		'Main Page'
	end

	def about_action(who)
		"Hello #{who}"
	end

end