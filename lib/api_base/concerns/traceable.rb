# frozen_string_literal: true

module ApiBase
  module Concerns
    module Traceable
      protected

      def trace_root_tag(name, value)
        Rails.logger.debug "trace_root_tag -> #{name} | #{value}"
      end

      def trace_root_error(error)
        Rails.logger.debug "trace_root_error -> #{error}"
      end

      def trace_active_tag(name, value)
        Rails.logger.debug "trace_active_tag -> #{name} | #{value}"
      end

      def trace_active_error(error)
        Rails.logger.debug "trace_active_error -> #{error}"
      end
    end
  end
end
