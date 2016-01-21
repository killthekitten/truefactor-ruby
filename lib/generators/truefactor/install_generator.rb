require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record'
module Truefactor
  class InstallGenerator < Rails::Generators::NamedBase
    include Rails::Generators::Migration

    def self.next_migration_number(dirname)
      ActiveRecord::Generators::Base.next_migration_number(dirname)
    end

    source_root File.expand_path("../../templates", __FILE__)

    desc "Adds a route, generates a migration, truefactorizes an application_controller and a model with the given NAME"

    def add_truefactor_route
      route "get '/truefactor', to: 'application#truefactor'"
    end

    def add_truefactor_migration
      migration_template "migration.rb", "db/migrate/add_truefactor_to_#{table_name}.rb"
    end

    def truefactorize_model
      content = "  truefactorize\n"
      class_path =
        if namespaced?
          class_name.to_s.split("::")
        else
          [class_name]
        end

      model_path = File.join("app", "models", "#{file_path}.rb")
      inject_into_class(model_path, class_path.last, content)
    end

    def truefactorize_controller
      content = "  truefactorize\n"
      controller_path = File.join("app", "controllers", "application_controller.rb")
      inject_into_class(controller_path, 'ApplicationController', content)
    end

    def copy_initializer
      template "truefactor.rb", "config/initializers/truefactor.rb"
    end
  end
end
