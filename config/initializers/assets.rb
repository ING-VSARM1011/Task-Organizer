# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

# Windows can deny replacing cache files while another thread has them open.
# Keep Sprockets' intermediate cache in memory on this platform.
if Gem.win_platform?
  Rails.application.config.assets.configure do |environment|
    environment.cache = Sprockets::Cache::MemoryStore.new
  end
end
