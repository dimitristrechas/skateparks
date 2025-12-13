module Admin
  class DashboardController < ApplicationController
    http_basic_authenticate_with name: Rails.application.credentials.dig(:admin, :username),
                                 password: Rails.application.credentials.dig(:admin, :password),
                                 unless: -> { Rails.env.development? }

    def index
    end
  end
end
