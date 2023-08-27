class AddOrderToProblems < ActiveRecord::Migration[7.0]
  def change
    add_column :problems, :order, :integer, null: false, default: 0
    reversible do |dir|
      dir.up do
        Sheet.includes(:problems).find_each do |sheet|
          sheet.problems.order(:id).each_with_index do |problem, i|
            problem.update order: i
          end
        end
      end
    end
  end
end
