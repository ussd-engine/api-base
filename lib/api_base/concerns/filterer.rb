# frozen_string_literal: true

module ApiBase
  module Concerns
    module Filterer
      protected

      def filterer
        @filterer ||= ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
      end

      def filter_object(obj)
        return if obj.nil?

        case obj
        when Array then filter_array(obj)
        when Hash then filter_hash(obj)
        else obj
        end
      end

      def filter_array(array)
        return if array.nil?

        array.map do |item|
          case item
          when Array then filter_array(item)
          when Hash then filter_hash(item)
          else item
          end
        end
      end

      def filter_hash(hash)
        return if hash.nil?

        hash.each do |key, value|
          case value
          when Array then hash[key] = filter_array(value)
          when Hash then hash[key] = filter_hash(value)
          end
        end
        filterer.filter (hash.try(:permit!) || hash).to_hash
      end
    end
  end
end
