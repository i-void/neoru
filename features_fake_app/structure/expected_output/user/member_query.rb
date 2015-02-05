class User::Models::MemberQuery < Neo::Database::ModelQuery

  def by_last_visit(last_visit)
    self.add_where([%w[last_visit = {last_visit}]]).add_parameters last_visit: last_visit
  end

  def by_ip(ip)
    self.add_where([%w[ip = {ip}]]).add_parameters ip: ip
  end

  def friend_of_member(member)
    self.add_match('member','Member',{id: member.id}, '-[r:HasFriend]->n')
  end
end
