require 'rails_helper'

RSpec.describe Subscribe::TemplatesInteraction do
  let(:params) {
    params = {}
    params[:user] = create(:persistence_user)
    params[:type] = 'radio'
    params[:country] = 'us'
    params
  }

  before do
    test_gateway    = instance_double("ActiveMerchant::Billing::PaypalExpressGateway")
    paypal_response = instance_double(ActiveMerchant::Billing::PaypalExpressResponse, params: {})
    allow(test_gateway).to receive(:status_recurring).and_return(paypal_response)
    allow(Persistence::Subscription).to receive(:paypal_gateway).and_return(test_gateway)
  end

  describe 'subscriptions templates with trial' do
    subject {Subscribe::TemplatesInteraction.new(params).as_json}
    it { expect(subject.count).to eq 4 }
    it 'has only radio subscriptions' do
      expect(subject.map { |s| s[:type] }.uniq ).to eq(['radio'])
    end
    it 'include trial template' do
      expect(subject.select { |v| v[:is_trial] }.count).to be > 0
    end
  end

  describe 'subscriptions templates without trial' do
    it 'has no trial for eventim user' do
      params[:user] = create(:persistence_user, :eventim)
      interaction_json = Subscribe::TemplatesInteraction.new(params).as_json
      expect(interaction_json.select { |v| v[:is_trial] }.count).to eq 0
    end

    it 'has not trial if user already have subscription for certain type' do
      user = create(:persistence_user)
      user.subscriptions << create(:subscription, user_uri: user.uri)
      params[:user] = user
      interaction_json = Subscribe::TemplatesInteraction.new(params).as_json
      expect(interaction_json.select { |v| v[:is_trial] }.count).to eq 0
    end
  end
end
