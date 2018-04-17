class User < ApplicationRecord
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true

def build_from_github(auth_hash)
user_data = {
  uid: auth_hash[:uid],
  name: auth_hash["info"]["name"],
  email: auth_hash["info"]["email"],
  provider: auth_hash[:provider]
}

  user = self.New(user_data)
  return user if user.save
end

end
