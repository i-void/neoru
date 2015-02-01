class Auth::Models::Identity < Neo::Database::Model
  IdentityQuery = Auth::Models::IdentityQuery

  attr_accessor :username, :password, :email

  def initialize
    @labels = 'Identity'
  end

end
