require "active_record"
require "active_support/core_ext/class"

require "multi_handler/log_subscriber"
require "multi_handler/migration"
require "multi_handler/model"
require "multi_handler/proxy"
require "multi_handler/railtie" if defined?(Rails)
require "multi_handler/version"

module MultiHandler
  def self.configurations
    @config ||= begin
      conf = HashWithIndifferentAccess.new
      ActiveRecord::Base.configurations.each do |shard, spec|
        conf[shard] = spec["connections"] || {}
      end
      conf
    end
  end

  def self.establish_connections(env)
    configurations[env].each do |shard, spec|
      ActiveRecord::Base.connection_manager.establish_connection(shard, spec)
    end
  end
end
