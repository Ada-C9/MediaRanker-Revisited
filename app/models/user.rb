class User < ApplicationRecord
  has_many :votes, dependent: :destroy 
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true

  def self.get_user_info(auth_hash)
      @user = User.new(
        username: auth_hash['info']['name'],
        email: auth_hash['info']['email'],
        uid: auth_hash['uid'],
        provider: auth_hash['provider'])
        # raise
        return @user
  end
end
