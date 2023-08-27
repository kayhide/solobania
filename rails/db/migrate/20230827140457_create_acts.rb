class CreateActs < ActiveRecord::Migration[7.0]
  def change
    create_table :acts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :actable, polymorphic: true
      t.string :mark

      t.timestamps
    end
  end
end
