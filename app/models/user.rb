class User < ApplicationRecord
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true

  def self.get_from_github(auth_hash)
    user = User.new(
      username: auth_hash['info']['name'],
      uid: auth_hash['uid'],
      email: auth_hash['info']['email'],
      provider: auth_hash['provider'])

      if user.save
        flash[:status] = :success
        flash[:result_text] = "#{user.username}Logged in successfully"

      else
        flash.now[:status] = :failure
        flash.now[:result_text] = "Could not log in"
        flash.now[:messages] = user.errors.messages
      end

      return user

    end
  end
