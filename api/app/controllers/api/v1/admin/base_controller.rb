module Api
  module V1
    module Admin
      class BaseController < Api::V1::BaseController
        before_action :authenticate_admin!

        private

        def authenticate_admin!
          token = request.headers["Authorization"]&.split(" ")&.last
          return render_unauthorized unless token

          decoded = JwtService.decode(token)
          return render_unauthorized unless decoded

          @current_admin = AdminUser.find_by(id: decoded[:admin_id])
          render_unauthorized unless @current_admin
        end

        def render_unauthorized
          render json: { error: "Unauthorized" }, status: :unauthorized
        end

        attr_reader :current_admin
      end
    end
  end
end
