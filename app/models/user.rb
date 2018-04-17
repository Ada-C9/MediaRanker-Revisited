class User < ApplicationRecord
  has_many :votes, dependent: :destroy
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true

  def login(auth_hash)
    if auth_hash['uid']
      @user = self.find_by(uid: auth_hash[:uid], provider: 'github')
      if @user.nil?
        @user = self.new(
          username: auth_hash['info']['name'],
          email: auth_hash['info']['email'],
          uid: auth_hash[:uid],
          provider: ['github'])
      end
    end
    return @user
  end

end
