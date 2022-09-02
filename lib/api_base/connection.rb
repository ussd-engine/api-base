# frozen_string_literal: true

require 'faraday'
require 'stoplight'
require 'api_base/concerns/traceable'
require 'api_base/concerns/filterer'

module ApiBase
  module Connection
    def connection
      @connection_cache ||= {}
      @connection_cache[connection_name] ||= with_connection(connection_name)
    end

    def connection_name
      defined?(@connection_name) ? @connection_name.to_sym : :default
    end

    def with_connection(connection_name)
      @connection_name = connection_name
    end

    protected

    def with_connection(connection_name)
      raise NotImplementedError, 'with_connection is not implemented'
    end
  end
end
