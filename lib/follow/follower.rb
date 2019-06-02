require 'json'
require 'net/http'
require 'time'

module Follow
  class Follower
    SYNCED_IF_WITHIN_SECONDS_OF_PRESENT = 10
    ONE_DAY = 86400
    DEFAULT_RUBYGEMS_API_INTERVAL = 1
    RUBYGEMS_ENDPOINT = 'https://rubygems.org/api/v1/timeframe_versions.json'.freeze
    MAX_RUBY_GEMS_QUERY_RANGE_IN_SECONDS = 6 * ONE_DAY # It's actually 7 days, but use 6 to be safe

    def self.follow_from(start_time)
      self.new(start_time).follow
    end

    private

    def initialize(synced_up_to_time)
      @synced_up_to_time = synced_up_to_time
    end

    def follow
      query_rubygems

      if synced?
        synced
      else
        increment_query_window && follow
      end
    end

    def synced?
      (Time.now - @synced_up_to_time) <= SYNCED_IF_WITHIN_SECONDS_OF_PRESENT
    end

    def synced
      Follow.configuration.on_synced.call()
    end

    def query_rubygems(page: 1)
      params = {
        from: @synced_up_to_time.iso8601,
        to: (@synced_up_to_time + MAX_RUBY_GEMS_QUERY_RANGE_IN_SECONDS).iso8601,
        page: page
      }

      uri = URI(RUBYGEMS_ENDPOINT)
      uri.query = URI.encode_www_form(params)
      response = Net:HTTP.get_response(RUBYGEMS_ENDPOINT, options)

      # TODO: something smarter here
      # Allow config option for handling api errors?
      if response.code != '200'
        puts "Got status #{response.code} from rubygems for #{RUBYGEMS_ENDPOINT} with options: #{params.inspect}"
        return
      end

      versions = JSON.parse(response.body)

      return if versions.size == 0

      versions.each do |version|
        Follow.configuration.on_version.call(version)
      end

      sleep Follow.configuration.api_call_interval || DEFAULT_RUBYGEMS_API_INTERVAL
      get_latest_from_rubygems_for_current_period(page: page + 1)
    end

    def increment_query_window
      @synced_up_to_time = [
        (@synced_up_to_time + MAX_RUBY_GEMS_QUERY_RANGE_IN_SECONDS),
        Time.now
      ].min
    end
  end
end
