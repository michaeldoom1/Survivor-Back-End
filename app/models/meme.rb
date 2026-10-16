class Meme < ApplicationRecord
  X_HOSTS = %w[x.com www.x.com twitter.com www.twitter.com mobile.twitter.com].freeze
  REDDIT_HOSTS = %w[reddit.com www.reddit.com old.reddit.com new.reddit.com].freeze

  belongs_to :episode_post

  validate :has_image_or_embed_url
  validate :image_url_is_valid
  validate :bluesky_url_is_valid
  validate :x_url_is_valid
  validate :reddit_url_is_valid
  validate :source_url_is_valid

  private

  def has_image_or_embed_url
    if [ image_url, bluesky_url, x_url, reddit_url ].all?(&:blank?)
      errors.add(:base, "must have an image URL or a Bluesky, X, or Reddit post URL")
    end
  end

  def image_url_is_valid
    validate_url(:image_url)
  end

  def bluesky_url_is_valid
    validate_url(:bluesky_url)
  end

  def x_url_is_valid
    validate_url(:x_url, hosts: X_HOSTS, path: %r{\A/(?:[^/]+|i/web)/status/\d+})
  end

  def reddit_url_is_valid
    validate_url(:reddit_url, hosts: REDDIT_HOSTS, path: %r{\A/r/[^/]+/comments/[^/]+})
  end

  def source_url_is_valid
    validate_url(:source_url)
  end

  def validate_url(attribute, hosts: nil, path: nil)
    url = read_attribute(attribute)
    return if url.blank?

    uri = URI.parse(url)
    if !(uri.is_a?(URI::HTTP) && uri.host.present?)
      errors.add(attribute, "must be a valid URL")
    elsif (hosts && !hosts.include?(uri.host.downcase)) || (path && !uri.path.to_s.match?(path))
      errors.add(attribute, "must be a link to a post")
    end
  rescue URI::InvalidURIError
    errors.add(attribute, "must be a valid URL")
  end
end
