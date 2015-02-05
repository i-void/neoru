class Auth::Models::IdentityQuery < Neo::Database::ModelQuery

  def by_username(username)
    self.add_where([%w[username = {username}]]).add_parameters username: username
  end

  def by_password(password)
    self.add_where([%w[password = {password}]]).add_parameters password: password
  end

  def by_email(email)
    self.add_where([%w[email = {email}]]).add_parameters email: email
  end

  def identity_of_member(member)
    self.add_match('member','Member',{id: member.id}, '-[r:HasIdentity]->n')
  end
end
