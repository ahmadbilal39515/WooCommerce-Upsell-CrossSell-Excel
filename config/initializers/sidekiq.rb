# Sidekiq.configure_server do |config|
#   config.redis = { url: Rails.application.config_for(:redis)['url'] }
# end

# Sidekiq.configure_client do |config|
#   config.redis = { url: Rails.application.config_for(:redis)['url'] }
# end

Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6390/0' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6390/0' }
end
