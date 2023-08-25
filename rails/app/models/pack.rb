class Pack < ApplicationRecord
  belongs_to :spec
  has_many :sheets, dependent: :destroy

  CATEGORIES = %w(shuzan anzan)
  enum category: CATEGORIES.map { |x| [x, x] }.to_h

  GRADE_UNITS = %w(kyu dan)
  enum grade_unit: GRADE_UNITS.map { |x| [x, x] }.to_h

  def self.generate spec
    spec = spec.symbolize_keys
    self.new(spec.slice(*%i(category grade grade_unit name))).tap do |pack|
      pack.sheets = spec[:sheets].to_a.map(&Sheet.method(:generate))
    end
  end
end
