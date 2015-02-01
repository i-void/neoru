class Auth::Models::Role < Neo::Database::Model
  RoleQuery = Auth::Models::RoleQuery

  attr_accessor :name

  def initialize
    @labels = 'Role'
  end

end
