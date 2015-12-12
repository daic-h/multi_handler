require "rails/railtie"

module MultiHandler
  class Railtie < Rails::Railtie
    rake_tasks do
      Dir[File.join(File.dirname(__FILE__), "railties/*.rake")].each { |ext| load ext }

      require "multi_handler/database_tasks"
    end

    initializer "multi_handler.initialize_database" do
      MultiHandler.establish_connections(Rails.env)
    end
  end
end
