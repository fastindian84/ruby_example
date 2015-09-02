require 'rails_helper'

RSpec.shared_context "subscribe interaction context" do
  let!(:user) {create(:persistence_user)}

  before do
    test_gateway    = instance_double("ActiveMerchant::Billing::PaypalExpressGateway")
    paypal_response = instance_double(ActiveMerchant::Billing::PaypalExpressResponse, params: {})
    allow(test_gateway).to receive(:status_recurring).and_return(paypal_response)
    allow(Persistence::Subscription).to receive(:paypal_gateway).and_return(test_gateway)
  end

  before(:each)do
    @params = {}
    @params[:template_id] = 1
    @params[:user] = user
    @params[:user_country] = 'us'
    @params[:agent] = 'WEBRADIO'
    @params[:department_code] = 012
    @params[:token] = user.authentication_tokens.first.value
  end
end

RSpec.shared_examples 'subscribe_interaction' do
  include_context "subscribe interaction context"

  describe "Initialization" do
    it "set necessary params for subscription" do
      s = Subscribe::InitialInteraction.new(@params)
      [:user, :template_id, :agent, :department_code,
       :cancel_url, :success_url, :error_url,
       :country, :authentication_token].each do |f|
        expect(s.send(f)).to_not be_nil
      end
    end

    it 'raise exeptions if token nil' do
      @params[:token] = nil
      expect{ Subscribe::InitialInteraction.new(@params)}.to raise_exception(StandardError)
    end

    it 'raise exeptions if user nil' do
      @params[:user] = nil
      expect{ Subscribe::InitialInteraction.new(@params)}.to raise_exception(StandardError)
    end

    it 'raise exeptions if department_code nil' do
      @params[:department_code] = nil
      expect{ Subscribe::InitialInteraction.new(@params)}.to raise_exception(StandardError)
    end

    it 'raise exeptions if user_country nil' do
      @params[:user_country] = nil
      expect{ Subscribe::InitialInteraction.new(@params)}.to raise_exception(StandardError)
    end

    it 'raise exeptions if agent nil' do
      @params[:agent] = nil
      expect{ Subscribe::InitialInteraction.new(@params)}.to raise_exception(StandardError)
    end
  end
end
