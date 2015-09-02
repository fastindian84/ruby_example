load 'support/subscribe_shared/subscribe_interactions_spec.rb'

RSpec.describe Subscribe::SubscribeConfirmInteraction do

  it_behaves_like 'subscribe_interaction'
  include_context "subscribe interaction context"

  before do
    @params[:paypal_token] = "PAYPAL_RECCURING_TOKEN"
    @interaction = Subscribe::SubscribeConfirmInteraction.new(@params)
    allow(@interaction).to receive(:setup_profile) {"paypal_profile_id"}
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  describe 'valid behavior' do
    it 'initialize valid subscription if paypal response correct' do
      subscription = @interaction.init_subscription(@interaction.setup_profile)
      expect(subscription).to be_instance_of(Persistence::Subscription)
      expect(subscription.save).to be_truthy
    end

    it 'execute block after saving subscription' do
      expect{ |probe| @interaction.process_subscription!(&probe).to yield_control }
    end

    it 'sends an email after subscription processing' do
      expect do
          @interaction.process_subscription!
      end.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(ActionMailer::Base.deliveries.first.subject).to eq "Confirmation of your tunehog radio subscription"
    end
  end

  describe 'exceptions' do
    it 'raise exception if no paypal token' do
      @params[:paypal_token] = nil
      expect{ Subscribe::SubscribeConfirmInteraction.new(@params) }.to raise_exception(StandardError)
    end

    it 'raise exception if no paypal profile gained' do
      allow(@interaction).to receive(:setup_profile) { nil }
      expect{ @interaction.process_subscription! }.to raise_exception(InteractionErrors::RedirectingError, 'Paypal payment profile was not created')
    end
  end
end
