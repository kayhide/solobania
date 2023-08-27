class Problem < ApplicationRecord
  belongs_to :sheet
  delegate :pack, to: :sheet
  has_many :acts, as: :actable, dependent: :destroy

  def self.generate spec
    spec = spec.symbolize_keys
    klass = (spec[:type].to_s.classify + "Problem").constantize
    klass.generate spec[:spec]
  end

  def self.rand_digit_number r, d0, d1, min: nil, max: nil
    d = d1 && r.rand(d0..d1) || d0
    bottom = 10 ** (d - 1)
    bottom = min ? [bottom, min].max : bottom
    top = 10 ** d - 1
    top = max ? [top, max].min : top
    r.rand(bottom...top) if bottom < top
  end

  def display_name
    "#{sheet.display_name} #{order + 1}"
  end
end
