# frozen_string_literal: true

require 'faraday'
require 'stoplight'
require 'api_base/service'
require 'api_base/connection'
require 'api_base/concerns/traceable'
require 'api_base/concerns/filterer'
require 'api_base/errors/api_error'
require 'api_base/errors/processing_error'

module ApiBase
  class Endpoint
    include ActiveSupport::Rescuable
    include Concerns::Traceable
    include Concerns::Filterer
    include ApiBase::Service
    include ApiBase::Connection

    rescue_from Stoplight::Error::RedLight do
      Rails.logger.warn "#{identifier} api circuit is closed"
      raise ApiBase::Errors::ApiError, 'Circuit broken'
    end

    rescue_from Faraday::TimeoutError do
      Rails.logger.warn "#{identifier} api timed-out"
      raise ApiBase::Errors::ApiError, 'Request timed-out'
    end

    def identifier
      "#{service_name}:#{connection_name}"
    end

    protected

    def execute(&block)
      light = Stoplight(identifier) do
        block.call
      end

      light.with_error_handler do |error, handler|
        # We don't want processing errors to affect our circuit breakers
        # They are our api equivalent of runtime errors.
        raise error if error.is_a?(ApiBase::Errors::ProcessingError)

        handler.call(error)
      end

      light.run
    rescue StandardError => e
      trace_active_error(e)
      rescue_with_handler(e) || raise
    end

    def validate_status_code(response)
      return if success_status_codes.include?(response.status)

      raise ApiBase::Errors::ProcessingError, "Request failed with status: #{response.status}"
    end

    def filterer
      @filterer ||= ActiveSupport::ParameterFilter.new sensitive_keys
    end
  end
end
