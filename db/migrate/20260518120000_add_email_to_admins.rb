class AddEmailToAdmins < ActiveRecord::Migration[8.1]
  def change
    add_column :admins, :email, :string, null: false, default: ""
    add_index :admins, :email, unique: true

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE admins SET email = 'admin@bidesk.local' WHERE email = '' OR email IS NULL
        SQL
      end
    end
  end
end
