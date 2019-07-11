module Follow
  class Configuration
    attr_accessor :api_call_interval, :on_version, :on_synced

    DEFAULT_API_CALL_INTERVAL = 1
    def api_call_interval
      @api_call_interval || DEFAULT_API_CALL_INTERVAL
    end

    # https://guides.rubygems.org/rubygems-org-api/#rate-limits
    MIN_RUBYGEMS_API_INTERVAL_SECONDS = 0.1
    def api_call_interval=(interval)
      return if interval >= MIN_RUBYGEMS_API_INTERVAL_SECONDS

      raise ArgumentError, "The API call interval must not exceed #{MIN_RUBYGEMS_API_INTERVAL_SECONDS} seconds"
    end
  end
end
