# frozen_string_literal: true

module ApiBase
  class Engine < ::Rails::Engine
    isolate_namespace ApiBase
  end
end
