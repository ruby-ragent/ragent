# frozen_string_literal: true
module Ragent
  module Plugin
    def self.included(klass)
      klass.send(:include, Ragent::Logging)
      klass.send(:include, Celluloid)
      klass.send(:include, Celluloid::Notifications)
      klass.send(:finalizer, :stop)
      klass.send(:extend, Ragent::CommandHelpers)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      def plugin_name(name = nil)
        if name
          @name = name
        else
          @name
        end
      end
    end

    attr_reader :plugin_name
    def initialize(ragent, plugin_name:)
      @plugin_name=plugin_name
      @ragent = ragent
      @logger = ragent.logger
      self.class.prepared_commands.each do |cmd|
        @ragent.commands.add(cmd = Ragent::Command.new(cmd.merge(recipient: self)))
      end
    end

    def configure(*args, &block); end

    def start; end

    def stop; end

    def agent(type:, as:, args: [])
      @ragent.supervisor.supervise(
        type: type,
        as: as,
        args: args
      )
    end

    def agents(name)
      Celluloid::Actor[name]
    end
  end
end
