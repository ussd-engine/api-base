# frozen_string_literal: true

module ApiBase
  module Behaviours
    # Shared concern that adds the ability to post json to an endpoint
    module PostJson
      include Shared

      alias post_json behaviour_delegate

      protected

      def execute_request(endpoint, payload)
        execute do
          connection.post(endpoint, payload) do |req|
            req.body = payload.to_json
            req.headers["Content-Type"] = "application/json"
          end
        end
      end

      def method
        "POST"
      end
    end
  end
end
