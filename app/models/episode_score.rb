class EpisodeScore < ApplicationRecord
  belongs_to :contestant
  belongs_to :scoring_event
  belongs_to :season

  before_validation :snapshot_points

  validates :episode_number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :scoring_event_id, uniqueness: { scope: [ :contestant_id, :episode_number ] }

  validate :contestant_matches_season

  private

  def snapshot_points
    self.points = scoring_event.points if scoring_event
  end

  def contestant_matches_season
    return if contestant.nil? || season_id.nil?

    if contestant.season_id != season_id
      errors.add(:base, "#{contestant.name} is not in season #{season&.number}")
    end
  end
end
