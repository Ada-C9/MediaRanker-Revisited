class User < ApplicationRecord
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true

  def self.build_from_github(auth_hash)
    user = self.new(
      username: auth_hash['info']['name'],
      email: auth_hash['info']['email'],
      provider: auth_hash['provider'],
      uid: auth_hash['uid'])

    return user
  end
end
