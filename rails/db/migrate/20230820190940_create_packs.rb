class CreatePacks < ActiveRecord::Migration[7.0]
  def change
    create_table :packs do |t|
      t.string :category, null: false
      t.string :name, null: false
      t.integer :grade
      t.string :grade_unit

      t.timestamps
    end
  end
end
