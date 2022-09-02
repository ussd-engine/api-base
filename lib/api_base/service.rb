# frozen_string_literal: true

module ApiBase
  module Service
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
