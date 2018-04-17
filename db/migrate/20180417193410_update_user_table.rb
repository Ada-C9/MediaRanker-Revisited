class UpdateUserTable < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :username

    add_column :users, :name, :string
    add_column :users, :email, :string
    add_column :users, :uid, :integer
    add_column :users, :provider, :string
  end
end
