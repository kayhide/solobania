class CreateSpecs < ActiveRecord::Migration[7.0]
  def change
    create_table :specs do |t|
      t.string :key, null: false, index: { unique: true }
      t.string :name, null: false
      t.json :body

      t.timestamps
    end
  end
end
