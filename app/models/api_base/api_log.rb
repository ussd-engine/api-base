# frozen_string_literal: true

# == Schema Information
#
# Table name: api_logs
#
#  id               :bigint           not null, primary key
#  api              :text             not null
#  duration         :float
#  endpoint         :text             not null
#  exception        :jsonb
#  method           :text             not null
#  origin           :text             not null
#  request_body     :jsonb
#  request_headers  :jsonb
#  response_body    :jsonb
#  response_headers :jsonb
#  source           :text             not null
#  status_code      :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
require 'English'

module ApiBase
  class ApiLog < ApplicationRecord
    attribute :sanitized, :boolean, default: false

    validate :nothing_changed, unless: :new_record?
    validate :data_sanitized

    validates_presence_of :api, :origin, :source, :endpoint

    validates :source, presence: true, inclusion: { in: %w[outgoing_request incoming_webhook] }
    validates :method, presence: true, inclusion: { in: %w[GET POST DELETE PUT] }

    def self.start_outgoing_request(origin, method, endpoint, payload)
      ApiLog.new api: origin.identifier, origin: origin.class.to_s, source: 'outgoing_request',
                 endpoint: "#{origin.connection.url_prefix}#{endpoint}", method:,
                 request_headers: origin.connection.headers, request_body: payload
    end

    def complete_outgoing_request(response, duration)
      # Ensure we are recording the actual headers that were sent on the request.
      # The ones set from the connection might not be the final headers.
      self.request_headers = response.env.request_headers
      # Set the rest of the response attributes.
      assign_attributes status_code: response.status, duration:,
                        response_body: response.body, response_headers: response.headers
    end

    def self.start_weekhook_request(origin, request)
      ApiLog.new api: origin, origin: origin.class.to_s, source: 'incoming_webhook',
                 endpoint: request.fullpath, method: request.method,
                 request_headers: request.headers.env.reject { |key|
                   key.to_s.include?('.')
                 }, request_body: request.params
    end

    def complete_webhook_request(response, duration)
      # Set the rest of the response attributes.
      assign_attributes status_code: response.status, duration:,
                        response_body: response.body, response_headers: response.headers
    end

    def filter_sensitive_data
      parse_json_fields

      %i[request_headers request_body response_headers response_body exception].each do |prop|
        self[prop] = yield(self[prop]) if self[prop].is_a?(Hash)
      end

      self.sanitized = true
    end

    private

    def nothing_changed
      errors.add(:base, 'Record is read-only') if changed?
    end

    def data_sanitized
      errors.add(:base, 'Data must be sanitized') unless sanitized?
    end

    def parse_json_fields
      %i[request_headers request_body response_headers response_body exception].each do |prop|
        self[prop] = safely_parse_json(self[prop])
      end
    end

    def safely_parse_json(value)
      case value
      when nil, Hash
        value
      when String
        JSON.parse value
      when StandardError
        [e.message, *e.backtrace].join($INPUT_RECORD_SEPARATOR).to_json
      else
        value.to_s.to_json
      end
    rescue StandardError
      # Something we can't encode. Let's preserve it as a string.
      value.to_s.to_json
    end
  end
end
