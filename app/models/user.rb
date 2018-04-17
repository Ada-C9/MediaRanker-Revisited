require 'pry'
class User < ApplicationRecord
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true

def self.build_from_github(auth_hash)
auth_hash["info"]["name"] ? name = auth_hash["info"]["name"] : name = auth_hash["info"]["email"]

user_data = {
  uid: auth_hash[:uid],
  username: name,
  email: auth_hash["info"]["email"],
  provider: auth_hash[:provider]
}

  user = self.new(user_data)
  if user.save
    return user
  else
    return false
  end
end

end
