
Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'], size: 12 }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'], size: 2 }
end
