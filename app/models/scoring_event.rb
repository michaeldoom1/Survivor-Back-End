class ScoringEvent < ApplicationRecord
  has_many :episode_scores, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :points, presence: true, numericality: { only_integer: true }
end
