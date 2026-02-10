module Api
  module V1
    module Admin
      class SessionsController < Api::V1::BaseController
        def create
          admin = AdminUser.find_by(email: params[:email])

          if admin&.authenticate(params[:password])
            token = JwtService.encode(admin_id: admin.id)
            render json: { token: token, admin: { id: admin.id, email: admin.email, name: admin.name } }
          else
            render json: { error: "Invalid email or password" }, status: :unauthorized
          end
        end

        def destroy
          render json: { message: "Logged out" }
        end
      end
    end
  end
end
