class Pick < ApplicationRecord
  belongs_to :user
  belongs_to :season
  belongs_to :male_contestant, class_name: "Contestant"
  belongs_to :female_contestant, class_name: "Contestant"
  belongs_to :golden_goose_contestant, class_name: "Contestant"

  validates :season_id, uniqueness: { scope: :user_id }

  validate :male_contestant_is_male
  validate :female_contestant_is_female
  validate :contestants_match_season
  validate :golden_goose_is_not_male_or_female_pick

  private

  def male_contestant_is_male
    return if male_contestant.nil?

    unless male_contestant.gender == "Male"
      errors.add(:male_contestant, "must be male")
    end
  end

  def female_contestant_is_female
    return if female_contestant.nil?

    unless female_contestant.gender == "Female"
      errors.add(:female_contestant, "must be female")
    end
  end

  def contestants_match_season
    [ male_contestant, female_contestant, golden_goose_contestant ].compact.each do |contestant|
      if contestant.season_id != season_id
        errors.add(:base, "#{contestant.name} is not in season #{season&.number}")
      end
    end
  end

  def golden_goose_is_not_male_or_female_pick
    return if golden_goose_contestant_id.blank?

    if golden_goose_contestant_id == male_contestant_id
      errors.add(:golden_goose_contestant, "can't also be your male pick")
    elsif golden_goose_contestant_id == female_contestant_id
      errors.add(:golden_goose_contestant, "can't also be your female pick")
    end
  end
end
