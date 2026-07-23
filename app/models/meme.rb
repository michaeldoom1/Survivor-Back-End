class Meme < ApplicationRecord
  belongs_to :episode_post

  validate :has_image_or_bluesky_url
  validate :image_url_is_valid
  validate :bluesky_url_is_valid
  validate :source_url_is_valid

  private

  def has_image_or_bluesky_url
    if image_url.blank? && bluesky_url.blank?
      errors.add(:base, "must have either an image URL or a Bluesky post URL")
    end
  end

  def image_url_is_valid
    validate_url(:image_url)
  end

  def bluesky_url_is_valid
    validate_url(:bluesky_url)
  end

  def source_url_is_valid
    validate_url(:source_url)
  end

  def validate_url(attribute)
    url = read_attribute(attribute)
    return if url.blank?

    uri = URI.parse(url)
    unless uri.is_a?(URI::HTTP) && uri.host.present?
      errors.add(attribute, "must be a valid URL")
    end
  rescue URI::InvalidURIError
    errors.add(attribute, "must be a valid URL")
  end
end
