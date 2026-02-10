module Api
  module V1
    class BaseController < ApplicationController
      private

      def paginate(scope)
        scope.page(params[:page]).per(params[:per_page] || 12)
      end

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count,
          per_page: collection.limit_value
        }
      end
    end
  end
end
