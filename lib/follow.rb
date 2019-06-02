require 'follow/version'
require 'time'
require 'net/http'

module Follow
  class Follower
    ONE_MINUTE = 60
    ONE_DAY = 86400
    SLEEP_INTERVAL = 3
    SLEEP_INTERVAL_WHEN_UP_TO_DATE = ONE_MINUTE * 3
    RUBYGEMS_ENDPOINT = 'https://rubygems.org/api/v1/timeframe_versions.json'.freeze
    MAX_RUBY_GEMS_QUERY_RANGE_IN_SECONDS = 6 * ONE_DAY # It's actually 7 days, but use 6 to be safe

    def initialize(start_from_time:)
      @start_from_time = start_from_time
    end

    def run
      @synced_up_to_time = @start_from_time || last_published_at_in_code_recon

      poll_rubygems_api
    end

    def poll_rubygems_api
      puts 'getting latest from rubygems...'
      get_latest_from_rubygems_for_current_period

      poll_rubygems_api
    end

    def get_latest_from_rubygems_for_current_period(page: 1)
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
      if response.code != '200'
        puts "Got status #{response.code} from rubygems for #{RUBYGEMS_ENDPOINT} with options: #{params.inspect}"
        return
      end

      versions = JSON.parse(response.body)

      return increment_period_or_up_to_date if versions.size == 0

      versions.each do |version|
        # TODO -- call the specified on_version hook
      end

      sleep SLEEP_INTERVAL # don't spam rubygems
      get_latest_from_rubygems_for_current_period(page: page+1)
    end

    def increment_period_or_up_to_date
      if @synced_up_to_time >= one_minute_ago # TODO: do something better
        up_to_date
      else
        increment_current_period
        get_latest_from_rubygems_for_current_period
      end
    end

    def up_to_date
      print 'up to date, sleeping...'
      @synced_up_to_time = Time.now - ONE_MINUTE

      sleep SLEEP_INTERVAL_WHEN_UP_TO_DATE
    end

    def increment_current_period
      @synced_up_to_time = [
        (@synced_up_to_time + MAX_RUBY_GEMS_QUERY_RANGE_IN_SECONDS),
        Time.now
      ].min
    end

    def one_minute_ago
      Time.now - (1 * ONE_MINUTE)
    end
  end
end
