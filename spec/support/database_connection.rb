ActiveRecord::Base.configurations = YAML.load_file(File.join(File.dirname(__FILE__), "../config/database.yml"))
ActiveRecord::Base.establish_connection(:test)
MultiHandler.establish_connections(:test)
