class CreateRules < ActiveRecord::Migration[5.0]
  def change
    create_table :rules do |t|
      t.string :before
      t.string :after
      t.string :status

      t.timestamps
    end
  end
end
