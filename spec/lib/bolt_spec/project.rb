# frozen_string_literal: true

require 'bolt/project'

module BoltSpec
  module Project
    # Creates the project directory structure with config and inventory
    # files. Yields the path to the project.
    #
    def with_project_directory(name = 'project', config: nil, inventory: nil, boltdir: false)
      Dir.mktmpdir(nil, Dir.pwd) do |tmpdir|
        # Build project paths
        tmpdir         = Pathname.new(tmpdir).expand_path
        project_path   = boltdir ? (tmpdir + name + 'Boltdir') : (tmpdir + name)
        config_path    = project_path + 'bolt-project.yaml'
        inventory_path = project_path + 'inventory.yaml'

        # Set default config and inventory if not provided
        config    ||= { 'name' => name }
        inventory ||= {}

        # Create project directory and files
        FileUtils.mkdir_p(project_path)
        File.write(config_path, config.to_yaml)
        File.write(inventory_path, inventory.to_yaml)

        yield(project_path)
      end
    end

    # Creates a project directory structure and yields a Bolt::Project
    # instance.
    #
    def with_project(name = 'project', **kwargs)
      with_project_directory(name, kwargs) do |project_path|
        project = Bolt::Project.create_project(project_path)
        yield(project)
      end
    end

    # Creates a project directory structure and changes the current
    # working directory to the project. Yields a Bolt::Project instance.
    #
    def in_project(name = 'project', **kwargs)
      with_project(name, kwargs) do |project|
        Dir.chdir(project.path) do
          yield(project)
        end
      end
    end

    # Creates a Bolt::Project instance.
    #
    def make_project(project_path)
      Bolt::Project.make_project(project_path)
    end
  end
end
