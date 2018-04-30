class UpdateColumnsforUsersTable < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :username, :name
    add_column :users, :uid, :integer, null: false
    add_column :users, :provider, :string, null: false
    add_column :users, :email, :string
  end
end
