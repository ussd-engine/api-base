# frozen_string_literal: true

require 'faraday'
require 'stoplight'
require 'api_base/concerns/traceable'
require 'api_base/concerns/filterer'

module ApiBase
  class Base
    include ActiveSupport::Rescuable
    include Concerns::Traceable
    include Concerns::Filterer

    def identifier
      raise NotImplementedError, 'identifier is not implemented'
    end

    def connection
      raise NotImplementedError, 'connection is not implemented'
    end

    def sensitive_data_keys
      raise NotImplementedError, 'sensitive_data_keys is not implemented'
    end

    rescue_from Stoplight::Error::RedLight do
      Rails.logger.warn "#{identifier} api circuit is closed"
      raise ApiBase::Error::ApiError, 'Circuit broken'
    end

    rescue_from Faraday::TimeoutError do
      Rails.logger.warn "#{identifier} api timed-out"
      raise ApiBase::Error::ApiError, 'Request timed-out'
    end

    protected

    def execute(&block)
      light = Stoplight(identifier) do
        block.call
      end

      light.with_error_handler do |error, handler|
        # We don't want processing errors to affect our circuit breakers
        # They are our api equivalent of runtime errors.
        raise error if error.is_a?(ApiBase::Error::ProcessingError)

        handler.call(error)
      end

      light.run
    rescue StandardError => e
      trace_active_error(e)
      rescue_with_handler(e) || raise
    end

    def validate_status_code(response)
      return if success_status_codes.include?(response.status)

      raise ApiBase::Error::ProcessingError, "Request failed with status: #{response.status}"
    end

    def success_status_codes
      [200, 201]
    end

    def filterer
      @filterer ||= ActiveSupport::ParameterFilter.new sensitive_data_keys
    end
  end
end
