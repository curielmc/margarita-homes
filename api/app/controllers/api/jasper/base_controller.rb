# frozen_string_literal: true

module Api
  module Jasper
    class BaseController < ApplicationController
      before_action :authenticate_jasper!

      private

      def authenticate_jasper!
        token = request.headers["Authorization"]&.split(" ")&.last
        api_token = Rails.application.credentials.dig(:jasper, :api_token)

        unless api_token.present? && ActiveSupport::SecurityUtils.secure_compare(token.to_s, api_token)
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      end

      def render_success(data, status: :ok)
        render json: { success: true, data: data }, status: status
      end

      def render_error(message, status: :unprocessable_entity, errors: nil)
        response = { success: false, error: message }
        response[:errors] = errors if errors.present?
        render json: response, status: status
      end
    end
  end
end
