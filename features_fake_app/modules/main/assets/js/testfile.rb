class User
	attr_accessor :name

	def initialize(name)
		@name = name
	end

	def admin?
		@name == 'Admin'
	end
end

user = User.new('Bob')
puts user
puts user.admin?