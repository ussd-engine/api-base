# frozen_string_literal: true

require 'test_helper'

class ApiBaseTest < ActiveSupport::TestCase
  test 'it has a version number' do
    assert ApiBase::VERSION
  end
end
