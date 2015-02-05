class Auth::Models::RoleQuery < Neo::Database::ModelQuery

  def by_name(name)
    self.add_where([%w[name = {name}]]).add_parameters name: name
  end

  def role_of_member(member)
    self.add_match('member','Member',{id: member.id}, '-[r:HasRole]->n')
  end
end
