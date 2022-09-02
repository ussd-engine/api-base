# frozen_string_literal: true

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
      raise NotImplementedError, "with_connection is not implemented"
    end
  end
end
