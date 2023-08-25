class Sheet < ApplicationRecord
  belongs_to :pack
  has_many :problems, dependent: :destroy

  def self.generate spec
    spec = spec.symbolize_keys
    self.new(spec.slice(*%i(name timelimit))).tap do |sheet|
      problem_type = spec[:problem_type]
      sheet.problems = spec[:problems].to_a.map { |s|
        Problem.generate(type: problem_type, spec: s)
      }
    end
  end
end
