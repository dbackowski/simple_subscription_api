class Api::V1::SubscriptionsController < ApplicationController
  def index
    render json: Subscription.all
  end

  def create
    result = CreateSubscriptionService.call(subscription_params)

    if result.success?
      render json: result.response
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
    end
  end

  private

  def subscription_params
    params.fetch(:data, {}).permit(:credit_card_number, :name, :address, :country)
  end
end
