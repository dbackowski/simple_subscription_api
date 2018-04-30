require 'ostruct'

class BillingGatewayService
  include HTTParty
  include Service

  ON_ERROR_RETRIES = 1

  attr_accessor :credit_card_number, :amount

  base_uri 'http://fake-billing-gateway.com/'
  default_timeout 2

  def initialize(credit_card_number, amount)
    self.credit_card_number = credit_card_number
    self.amount = amount
  end

  def call
    handle_exceptions do
      response = self.class.get("/?credit_card_number=#{credit_card_number}&amount=#{amount}")

      if response.success?
        result = JSON.parse(response.parsed_response, object_class: OpenStruct)
        response_struct(result.paid, result, result.failure_message)
      else
        raise 'Billing gateway API Error'
      end
    end
  end

  private

  def handle_exceptions
    retry_count = 0

    begin
      yield
    rescue => e
      retry_count += 1
      retry if retry_count <= ON_ERROR_RETRIES
      response_struct(false, nil, e.message)
    end
  end
end
