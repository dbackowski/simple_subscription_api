require 'rails_helper'

RSpec.describe "Api::V1::Subscriptions", type: :request do
  describe "GET /api/v1/subscriptions" do
    before do
      10.times { FactoryBot.create :subscription }
    end

    it "returns subscriptions" do
      get api_v1_subscriptions_path
      expect(json.size).to eq(10)
      expect(response).to have_http_status(200)
    end
  end

  describe "POST /api/v1/subscriptions" do
    context "with valid data" do
      context "with sufficient funds" do
        it "creates a subscription" do
          expect{
            post api_v1_subscriptions_path, params: {
              data: FactoryBot.attributes_for(:subscription, :visa)
            }
          }.to change(Subscription, :count).by(1)
          expect(response).to have_http_status(200)
        end
      end

      context "with sufficient funds and timeout on billing gateway" do
        it "retries and creates a subscription" do
          expect{
            post api_v1_subscriptions_path, params: {
              data: FactoryBot.attributes_for(:subscription, :mastercard)
            }
          }.to change(Subscription, :count).by(1)
          expect(response).to have_http_status(200)
        end
      end

      context "with sufficient funds and error on billing gateway" do
        it "retries and creates a subscription" do
          expect{
            post api_v1_subscriptions_path, params: {
              data: FactoryBot.attributes_for(:subscription, :amex)
            }
          }.to change(Subscription, :count).by(1)
          expect(response).to have_http_status(200)
        end
      end

      context "with insufficient funds" do
        it "does not create a subscription" do
          expect{
            post api_v1_subscriptions_path, params: {
              data: FactoryBot.attributes_for(:subscription, :maestro)
            }
          }.not_to change(Subscription, :count)
          expect(response).to have_http_status(422)
        end
      end

      context "with timeout more than once" do
        it "does not create a subscription and returns \"execution expired\"" do
          expect{
            post api_v1_subscriptions_path, params: {
              data: FactoryBot.attributes_for(:subscription, :discover)
            }
          }.not_to change(Subscription, :count)
          expect(json['errors']).to eq 'execution expired'
          expect(response).to have_http_status(422)
        end
      end
    end

    context "with invalid card number" do
      it "does not create a subscription" do
        expect {
          post api_v1_subscriptions_path, params: {
            data: FactoryBot.attributes_for(:subscription, :visa).merge!(credit_card_number: "378380400053321")
          }
        }.not_to change(Subscription, :count)
        expect(json["errors"]).to eq ["Credit card number is invalid"]
        expect(response).to have_http_status(422)
      end
    end

    context "with empty name" do
      it "does not create a subscription" do
        expect {
          post api_v1_subscriptions_path, params: {
            data: FactoryBot.attributes_for(:subscription, :visa).merge!(name: nil)
          }
        }.not_to change(Subscription, :count)

        expect(json["errors"]).to eq ["Name can't be blank"]
        expect(response).to have_http_status(422)
      end
    end

    context "with empty address" do
      it "does not create a subscription" do
        expect {
          post api_v1_subscriptions_path, params: {
            data: FactoryBot.attributes_for(:subscription, :visa).merge!(address: nil)
          }
        }.not_to change(Subscription, :count)

        expect(json["errors"]).to eq ["Address can't be blank"]
        expect(response).to have_http_status(422)
      end
    end

    context "with empty country" do
      it "does not create a subscription" do
        expect {
          post api_v1_subscriptions_path, params: {
            data: FactoryBot.attributes_for(:subscription, :visa).merge!(country: nil)
          }
        }.not_to change(Subscription, :count)

        expect(json["errors"]).to eq ["Country can't be blank"]
        expect(response).to have_http_status(422)
      end
    end
  end
end
