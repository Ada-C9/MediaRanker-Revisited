class User < ApplicationRecord
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :name, uniqueness: true, presence: true

  def build_from_github(auth_hash)
    return User.new(
      name: auth_hash['info']['name'],
      email: auth_hash['info']['email'],
      uid: auth_hash['uid'],
      provider: auth_hash['provider'])
  end
end
