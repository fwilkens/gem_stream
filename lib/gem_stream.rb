require 'gem_stream/version'
require 'gem_stream/follower'
require 'gem_stream/configuration'

module GemStream
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
