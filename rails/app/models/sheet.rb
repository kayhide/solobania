class Sheet < ApplicationRecord
  belongs_to :pack
  has_many :problems, dependent: :destroy
  has_many :acts, as: :actable, dependent: :destroy

  def self.generate spec
    spec = spec.symbolize_keys
    self.new(spec.slice(*%i(name timelimit))).tap do |sheet|
      problem_type = spec[:problem_type]
      sheet.problems = spec[:problems].to_a.map { |s|
        Problem.generate(type: problem_type, spec: s)
      }
    end
  end

  def display_name
    "#{pack.display_name} #{name}"
  end
end
