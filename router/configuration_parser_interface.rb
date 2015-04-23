module Neo::Router::ConfigurationParserInterface
	extend Interface

	abstract :initialize, [:conf, :route_class, :action_class]
	abstract :generate_routes
end