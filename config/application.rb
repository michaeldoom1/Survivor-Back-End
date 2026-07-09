require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SurvivorBackEnd
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # Devise's sign_in/sign_out calls Warden, which writes to the Rails session
    # even though auth is actually handled by JWTs. API-only mode strips the
    # session middleware entirely, so add a minimal in-memory-cookie session
    # store back just to give Warden somewhere to write.
    config.session_store :cookie_store, key: "_survivor_back_end_session"
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use config.session_store, config.session_options

    # A malformed/garbage Authorization header raises JWT::DecodeError inside
    # warden-jwt_auth's revocation middleware, which sits above the router -
    # map it to 401 instead of letting it surface as an unhandled 500.
    config.action_dispatch.rescue_responses.merge!(
      "JWT::DecodeError" => :unauthorized
    )

    config.generators do |g|
      g.test_framework :rspec, request_specs: true, fixtures: false
    end
  end
end
