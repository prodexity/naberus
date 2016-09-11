# Load the backend proxy as Rack middleware
Rails.application.config.middleware.use BackendProxy
