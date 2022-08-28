# frozen_string_literal: true

module ApiBase
  module Behaviours
    # Shared module that adds common methods to api behaviours
    module Shared
      def behaviour_delegate(endpoint, payload = {})
        api_log = ApiBase::ApiLog.start_outgoing_request(self, method, endpoint, payload)
        response, duration = make_request(endpoint, payload)
        api_log.complete_outgoing_request response, duration

        response
      rescue StandardError => e
        api_log.exception = e if api_log.present?
        raise
      ensure
        if api_log.present?
          api_log.filter_sensitive_data { |data| filter_object(data) }
          api_log.save!
        end

        validate_status_code response if response.present?
      end

      protected

      def make_request(endpoint, payload)
        trace_active_tag('request.endpoint', endpoint)
        trace_active_tag('request.payload', filter_object(payload))

        start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        response = execute_request(endpoint, payload)
        duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start

        trace_active_tag('response.status', response.status)
        trace_active_tag('response.body', filter_object(response.body))
        trace_active_tag('response.duration', duration)

        [response, duration]
      end

      def method
        raise NotImplementedError, 'method is not implemented'
      end

      def execute_request
        raise NotImplementedError, 'execute_request is not implemented'
      end
    end
  end
end
