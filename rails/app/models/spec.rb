class Spec < ApplicationRecord
  has_many :packs, dependent: :destroy
end
