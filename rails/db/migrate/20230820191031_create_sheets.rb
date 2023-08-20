class CreateSheets < ActiveRecord::Migration[7.0]
  def change
    create_table :sheets do |t|
      t.references :pack, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :timelimit, null: false

      t.timestamps
    end
  end
end
