class Act < ApplicationRecord
  belongs_to :user
  belongs_to :actable, polymorphic: true

  MARKS = %w(confident hesitant uncertain)
  enum mark: MARKS.map { |x| [x, x] }.to_h
end
