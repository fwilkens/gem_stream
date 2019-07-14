module GemStream
  class Configuration
    attr_accessor :api_call_interval, :on_version, :on_synced

    DEFAULT_API_CALL_INTERVAL = 1.0
    def api_call_interval
      @api_call_interval || DEFAULT_API_CALL_INTERVAL
    end

    # https://guides.rubygems.org/rubygems-org-api/#rate-limits
    MIN_RUBYGEMS_API_INTERVAL_SECONDS = 0.1
    def api_call_interval=(interval)
      if interval >= MIN_RUBYGEMS_API_INTERVAL_SECONDS
        @api_call_interval = interval
      else
        raise ArgumentError, "The API call interval must not exceed #{MIN_RUBYGEMS_API_INTERVAL_SECONDS} seconds"
      end
    end

    def on_version=(proc)
      if proc.is_a?(Proc)
        @on_version = proc
      else
        raise ArgumentError, "Please specify a Proc for the on_version proc"
      end
    end

    def on_synced=(proc)
      if proc.is_a?(Proc)
        @on_synced = proc
      else
        raise ArgumentError, "Please specify a Proc for the on_synced proc"
      end
    end
  end
end
