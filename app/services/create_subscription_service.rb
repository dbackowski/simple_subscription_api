require 'ostruct'

class CreateSubscriptionService
  include Service

  def initialize(params = {}, billing_gateway_service_class: BillingGatewayService)
    @params = params.with_indifferent_access.slice(:credit_card_number, :name, :address, :country)
    @billing_gateway_service_class = billing_gateway_service_class
  end

  def call
    return response_struct(false, nil, subscription.errors.full_messages) unless subscription.valid?
    return response_struct(false, nil, billing_service.errors) unless billing_service.success?
    response_struct(subscription.save, subscription, nil)
  end

  private

  def subscription
    @subscription ||= Subscription.new(@params)
  end

  def billing_service
    @billing_service ||= @billing_gateway_service_class.new(@params[:credit_card_number], 100).call
  end
end
