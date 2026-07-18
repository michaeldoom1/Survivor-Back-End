class Person < ApplicationRecord
  has_many :contestants, dependent: :restrict_with_error
  has_many :seasons, through: :contestants

  validates :name, presence: true
  validates :gender, presence: true

  def total_points
    contestants.sum(&:total_points)
  end
end
