class MultipleRolesForUser < ActiveRecord::Migration[7.0]
  def up
    add_column :users, :roles, :string, array: true, default: [], null: false
    execute "UPDATE users SET roles[0] = role;"
    remove_column :users, :role
  end

  def down
    add_column :users, :role, :string, null: false, default: ""
    execute "UPDATE users SET role = roles[0];"
    remove_column :users, :roles
  end
end
