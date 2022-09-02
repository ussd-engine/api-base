# frozen_string_literal: true

require 'faraday'
require 'stoplight'
require 'api_base/concerns/traceable'
require 'api_base/concerns/filterer'

module ApiBase
  module Service
    include Concerns::Traceable
    include Concerns::Filterer

    def service_name
      raise NotImplementedError, 'service_name is not implemented'
    end

    def sensitive_keys
      raise NotImplementedError, 'sensitive_keys is not implemented'
    end

    def success_status_codes
      [200, 201]
    end
  end
end
