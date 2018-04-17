class User < ApplicationRecord
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true

  def self.add_user(user_data)
    @user = User.new(
    name: user_data['info']['name'],
    email: user_data['info']['email'],
    uid: user_data[:uid],
    provider: user_data[:provider])

  end

end
