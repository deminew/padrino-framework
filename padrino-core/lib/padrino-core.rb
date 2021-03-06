require 'sinatra/base'

Dir[File.dirname(__FILE__) + '/padrino-core/application/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/padrino-core/*.rb'].each {|file| require file }

# Defines our PADRINO_ENV
PADRINO_ENV = ENV["PADRINO_ENV"] ||= ENV["RACK_ENV"] ||= "development" unless defined?(PADRINO_ENV)

module Padrino
  class ApplicationLoadError < RuntimeError #:nodoc:
  end

  class << self
    ##
    # Helper method for file references.
    #
    # ==== Examples
    #
    #   # Referencing a file in config called settings.yml
    #   Padrino.root("config", "settings.yml")
    #   # returns PADRINO_ROOT + "/config/setting.yml"
    #
    def root(*args)
      File.expand_path(File.join(PADRINO_ROOT, *args))
    end

    ##
    # Helper method that return PADRINO_ENV
    #
    def env
      PADRINO_ENV.to_s.downcase.to_sym
    end

    ##
    # Returns the resulting rack builder mapping each 'mounted' application
    #
    def application
      raise ApplicationLoadError.new("At least one app must be mounted!") unless self.mounted_apps && self.mounted_apps.any?
      builder = Rack::Builder.new
      self.mounted_apps.each { |app| app.map_onto(builder) }
      builder
    end

    ##
    # Default encoding to UTF8 if it has not already been set to something else.
    #
    def set_encoding
      unless RUBY_VERSION >= '1.9'
        $KCODE = 'U' if $KCODE == 'NONE' || $KCODE.blank?
      end
      nil
    end

    ##
    # Returns the used $LOAD_PATHS from padrino
    #
    def load_paths
      %w(
        lib
        models
        shared
      ).map { |dir| root(dir) }
    end

    ##
    # Return bundle status :+:locked+ if .bundle/environment.rb exist :+:unlocked if Gemfile exist
    # otherwise return nil
    #
    def bundle
      return :locked   if File.exist?(root('.bundle/environment.rb'))
      return :unlocked if File.exist?(root("Gemfile"))
    end
  end # self
end # Padrino