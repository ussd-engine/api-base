# frozen_string_literal: true

module ApiBase
  module Behaviours
    # Shared concern that adds the ability to get json from an endpoint
    module GetJson
      include Shared

      alias get_json behaviour_delegate

      protected

      def execute_request(endpoint, _payload)
        execute do
          connection.get(endpoint) do |req|
            req.headers['Content-Type'] = 'application/json'
          end
        end
      end

      def method
        'GET'
      end
    end
  end
end
