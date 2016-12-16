class CreateHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :histories do |t|
      t.string :trynogometry_string
      t.integer :user_id

      t.timestamps
    end
  end
end
