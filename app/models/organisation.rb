class Organisation < ApplicationRecord
  has_many :pros, dependent: :destroy
  has_many :lieux, dependent: :destroy
  has_many :services, dependent: :destroy
  has_many :motifs, dependent: :destroy

  validates :name, presence: true
end
