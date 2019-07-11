require 'follow/version'
require 'follow/follower'
require 'follow/configuration'

module Follow
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
    if !configuration.on_version.is_a?(Proc)
      raise ArgumentError, "Please specify a Proc for the on_version hook"
    end

    if !configuration.on_synced.is_a?(Proc)
      raise ArgumentError, "Please specify a Proc for the on_synced hook"
    end
  end
end
