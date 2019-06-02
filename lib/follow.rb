require 'follow/version'
require 'time'
require 'net/http'

module Follow
  class Follower
    SYNCED_IF_WITHIN_SECONDS_OF_PRESENT = 10
    ONE_DAY = 86400
    # In theory, can be .1 (or maybe less since we're processing between reqs)
    # https://guides.rubygems.org/rubygems-org-api/#rate-limits
    DEFAULT_RUBYGEMS_API_INTERVAL = 1
    SLEEP_INTERVAL_WHEN_UP_TO_DATE = ONE_MINUTE * 3
    RUBYGEMS_ENDPOINT = 'https://rubygems.org/api/v1/timeframe_versions.json'.freeze
    MAX_RUBY_GEMS_QUERY_RANGE_IN_SECONDS = 6 * ONE_DAY # It's actually 7 days, but use 6 to be safe

    class_attribute :_on_version
    class_attribute :_on_synced

    def self.on_version=(proc)
      raise ArgumentError if !proc.is_a?(Proc)
      self._on_version = proc
    end

    def self.on_synced=(proc)
      raise ArgumentError if !proc.is_a?(Proc)
      self._on_synced = proc
    end

    def initialize(start_from_time:)
      @synced_up_to_time = start_from_time
    end

    def run
      follow
    end

    private

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
      self.class._on_synced.call()
    end

    def query_rubygems(page: 1)
      params = {
          from: @synced_up_to_time.iso8601,
          to: (@synced_up_to_time + MAX_RUBY_GEMS_QUERY_RANGE_IN_SECONDS).iso8601,
          page: page
        }
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
        self.class._on_version.call(version)
      end

      sleep DEFAULT_RUBYGEMS_API_INTERVAL
      get_latest_from_rubygems_for_current_period(page: page+1)
    end

    def increment_query_window
      @synced_up_to_time = [
        (@synced_up_to_time + MAX_RUBY_GEMS_QUERY_RANGE_IN_SECONDS),
        Time.now
      ].min
    end
  end
end
