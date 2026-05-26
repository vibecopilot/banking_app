# redis_conn = proc {
#   Redis.new # do anything you want here
# }
# Sidekiq.configure_client do |config|
#   config.redis = ConnectionPool.new(size: 5, &redis_conn)
# end
# Sidekiq.configure_server do |config|
#   config.redis = ConnectionPool.new(size: 25, &redis_conn)
# end

Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6379/0'}
  config.on(:startup) do
    Rails.application.eager_load!
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379/0'}
end


