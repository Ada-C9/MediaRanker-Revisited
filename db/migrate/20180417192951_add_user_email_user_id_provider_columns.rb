class AddUserEmailUserIdProviderColumns < ActiveRecord::Migration[5.0]
  def change
    # add_column :products, :part_number, :string
    add_column :users, :email, :string
    add_column :users, :uid, :integer
    add_column :users, :provider, :string
  end
end
