require "active_record/tasks/database_tasks"

module MultiHandler
  module DatabaseTasks
    def create_current_shards(environment = env)
      MultiHandler.configurations[environment].each_value do |spec|
        create(spec)
      end
    end

    def drop_current_shards(environment = env)
      MultiHandler.configurations[environment].each_value do |spec|
        drop(spec)
      end
    end
  end
end

ActiveRecord::Tasks::DatabaseTasks.extend(MultiHandler::DatabaseTasks)
