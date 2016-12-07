class CreateCalculates < ActiveRecord::Migration[5.0]
  def change
    create_table :calculates do |t|

      t.timestamps
    end
  end
end
