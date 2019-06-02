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
  end
end
