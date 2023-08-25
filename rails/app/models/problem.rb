class Problem < ApplicationRecord
  belongs_to :sheet

  def self.generate spec
    spec = spec.symbolize_keys
    klass = (spec[:type].to_s.classify + "Problem").constantize
    klass.generate spec[:spec]
  end
end
