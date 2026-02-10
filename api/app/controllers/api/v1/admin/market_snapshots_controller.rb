module Api
  module V1
    module Admin
      class MarketSnapshotsController < BaseController
        def generate
          MarketSnapshotService.generate
          render json: { message: "Market snapshots generated successfully" }
        end
      end
    end
  end
end
