class User < ApplicationRecord
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true

  def self.login(auth_hash)

    if auth_hash[:uid]
      @user = User.find_by(uid: auth_hash[:uid], provider: 'github')
      if @user.nil?
        # User doesn't match anything in the DB
        # Attempt to create a new user
        puts "Creating a new user"
        @user = User.new(uid: auth_hash[:uid], provider: auth_hash[:provider], username: auth_hash[:info][:nickname], email: auth_hash[:info][:email])
        if @user.save
          puts "User was created successfully"
          return @user
        else
          puts "Failed to create new user"
          return @user
        end
      else
        return @user
      end
    else
      return nil
    end
  end

end
