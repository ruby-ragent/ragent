module Ragent
  class Plugins
    include Ragent::Logging

    def self.search(ragent)
      new(ragent).search
    end

    def initialize(ragent)
      @ragent=ragent
      @logger=ragent.logger
      @plugins={}
    end

    def search
      # find plugins
      plugins_dir=@ragent.workdir.join("plugins").expand_path
      plugins_dir.
        each_child(false) do |plugin_dir|
        require plugins_dir.join(plugin_dir,'ragent.rb').to_s
        plugin=ActiveSupport::Inflector.
                constantize(
                  ActiveSupport::Inflector.camelize(
                  plugin_dir)).new(@ragent)
        @plugins[plugin_dir]=plugin
        info "Found: #{plugin.name}"
      end
      self
    end

    def configure
      @plugins.values.each do |plugin|
        info "Configure: #{plugin.name}"
        plugin.configure
      end
      self
    end

    def start
      @plugins.values.each do |plugin|
        info "Starting: #{plugin.name}"

        plugin.start
      end
    end

  end
end
