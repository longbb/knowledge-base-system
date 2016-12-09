class CreateTrigonometries < ActiveRecord::Migration[5.0]
  def change
    create_table :trigonometries do |t|

      t.timestamps
    end
  end
end
