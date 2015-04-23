module Neo::Router::ActionInterface
	extend Interface

	abstract :initialize, [:address]
	abstract :execute
	abstract :valid?
end