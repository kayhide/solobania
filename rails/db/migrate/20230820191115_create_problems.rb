class CreateProblems < ActiveRecord::Migration[7.0]
  def change
    create_table :problems do |t|
      t.references :sheet, null: false, foreign_key: true
      t.string :type
      t.integer :count, null: false
      t.json :body
      t.json :spec

      t.timestamps
    end
  end
end
