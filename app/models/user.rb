class User < ApplicationRecord
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true

  def self.build_from_github(auth_hash)
    user = User.new(
      username: auth_hash["info"]["name"],
      email: auth_hash["info"]["email"],
      uid: auth_hash["uid"],
      provider: auth_hash["provider"]
    )

    if user.save
      flash[:status] = :success
      flash[:result_text] = "#{user.username} logged in successfully"
    else
      flash.now[:status] = :failure
      flash.now[:result_text] = "Could not log in"
      flash.now[:messages] = user.errors.messages
    end
    return user  
  end
end
