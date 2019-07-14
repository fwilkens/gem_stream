require 'json'
require 'time'
require 'net/http'

module GemStream
  class Follower
    RUBYGEMS_ENDPOINT = 'https://rubygems.org/api/v1/timeframe_versions.json'.freeze
    MAX_RUBY_GEMS_QUERY_RANGE_IN_SECONDS = 6 * 86400 # It's actually 7 days, but use 6 to be safe

    def self.follow_from(start_time)
      self.new(start_time).follow
    end

    def initialize(start_time)
      @synced_up_to_time = start_time
      @on_version = GemStream.configuration.on_version.dup
      @on_synced = GemStream.configuration.on_synced.dup
      @api_call_interval = GemStream.configuration.api_call_interval.dup
      @keep_streaming = true
    end

    def follow
      while keep_streaming?
        query_rubygems
        increment_query_window
      end

      synced
    end

    private

    def keep_streaming?
      @keep_streaming
    end

    def synced
      @on_synced.call()
    end

    def query_rubygems(page: 1)
      uri = URI(RUBYGEMS_ENDPOINT)
      params = query_params(page)
      uri.query = URI.encode_www_form(params)
      response = Net::HTTP.get_response(uri)

      if response.code != '200'
        puts "Got status #{response.code} from rubygems for #{RUBYGEMS_ENDPOINT} with options: #{params.inspect}"
        return
      end

      versions = JSON.parse(response.body)

      if versions.size == 0
        @keep_streaming = page == 1
        return
      end

      versions.each do |version|
        @on_version.call(version)
      end

      sleep @api_call_interval
      query_rubygems(page: page + 1)
    end

    def increment_query_window
      @synced_up_to_time = [
        (@synced_up_to_time + MAX_RUBY_GEMS_QUERY_RANGE_IN_SECONDS),
        Time.now
      ].min
    end

    def query_params(page)
      {
        from: @synced_up_to_time.iso8601,
        to: (@synced_up_to_time + MAX_RUBY_GEMS_QUERY_RANGE_IN_SECONDS).iso8601,
        page: page,
      }
    end
  end
end
