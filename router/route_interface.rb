module Neo::Router::RouteInterface
	extend Interface

	abstract :initialize, [:name, :path, :parameters_url, :action, :subdomain, :methods]
	abstract :match?, [:request]
	abstract :execute_action
end