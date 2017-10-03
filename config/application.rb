require File.expand_path('../boot', __FILE__)

require 'rails/all'
require_relative '../lib/rack_x_robots_tag'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SfDahliaWeb
  # setting up config for application
  class Application < Rails::Application
    config.assets.paths << Rails.root.join('lib', 'assets', 'bower_components')
    config.assets.paths << Rails.root.join('app', 'assets', 'json', 'translations')

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # http://guides.rubyonrails.org/action_mailer_basics.html#previewing-emails
    config.action_mailer.preview_path = "#{Rails.root}/lib/mailer_previews"

    config.time_zone = 'Pacific Time (US & Canada)'

    # set up ActiveJob to use Sidekiq
    # if ENV['SIDEKIQ'] is not specified, will use default inline processor
    config.active_job.queue_adapter = :sidekiq if ENV['SIDEKIQ']

    if ENV['PRERENDER_TOKEN'].present?
      config.middleware.use Rack::Prerender, prerender_token: ENV['PRERENDER_TOKEN']
    elsif ENV['PRERENDER_SERVICE_URL'].present?
      config.middleware.use Rack::Prerender, prerender_service_url: ENV['PRERENDER_SERVICE_URL']
    end

    ENV['GEOCODING_SERVICE_URL'] ||= 'https://sfgis-svc.sfgov.org/arcgis/rest/services/dt/NRHP_Composite/GeocodeServer/findAddressCandidates'
    ENV['NEIGHBORHOOD_BOUNDARY_SERVICE_URL'] ||= 'https://sfgis-svc.sfgov.org/arcgis/rest/services/dt/NRHP_pref/MapServer/0/query'

    config.middleware.use Rack::XRobotsTag
    # write cached robots.txt into public dir
    config.action_controller.page_cache_directory = "#{Rails.root}/public"

    # for serving gzipped assets
    config.middleware.use Rack::Deflater

    # remove trailing slashes
    # https://stackoverflow.com/a/3570233/260495
    config.middleware.insert_before(Rack::Lock, Rack::Rewrite) do
      r301 %r{(.+)/$}, '$1'
    end
  end
end
