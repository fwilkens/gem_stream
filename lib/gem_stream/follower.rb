require 'json'

module GemStream
  class Follower
    SYNCED_IF_WITHIN_SECONDS_OF_PRESENT = 10
    RUBYGEMS_ENDPOINT = 'https://rubygems.org/api/v1/timeframe_versions.json'.freeze
    MAX_RUBY_GEMS_QUERY_RANGE_IN_SECONDS = 6 * 86400 # It's actually 7 days, but use 6 to be safe

    def self.follow_from(start_time)
      self.new(start_time).follow
    end

    def initialize(synced_up_to_time)
      @synced_up_to_time = synced_up_to_time
    end

    def follow
      query_rubygems

      if synced?
        synced
      else
        increment_query_window && query_rubygems
      end
    end

    private

    def synced?
      (Time.now - @synced_up_to_time) <= SYNCED_IF_WITHIN_SECONDS_OF_PRESENT
    end

    def synced
      GemStream.configuration.on_synced.call()
    end

    def query_rubygems(page: 1)
      params = {
        from: @synced_up_to_time.iso8601,
        to: (@synced_up_to_time + MAX_RUBY_GEMS_QUERY_RANGE_IN_SECONDS).iso8601,
        page: page
      }

      uri = URI(RUBYGEMS_ENDPOINT)
      uri.query = URI.encode_www_form(params)
      response = Net::HTTP.get_response(uri)

      if response.code != '200'
        puts "Got status #{response.code} from rubygems for #{RUBYGEMS_ENDPOINT} with options: #{params.inspect}"
        return
      end

      versions = JSON.parse(response.body)

      return if versions.size == 0

      versions.each do |version|
        GemStream.configuration.on_version.call(version)
      end

      sleep GemStream.configuration.api_call_interval
      query_rubygems(page: page + 1)
    end

    def increment_query_window
      @synced_up_to_time = [
        (@synced_up_to_time + MAX_RUBY_GEMS_QUERY_RANGE_IN_SECONDS),
        Time.now
      ].min
    end
  end
end
