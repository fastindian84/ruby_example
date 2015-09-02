load 'support/subscribe_shared/subscribe_interactions_spec.rb'

RSpec.describe Subscribe::SubscribeInteraction do
  it_behaves_like 'subscribe_interaction'
  include_context "subscribe interaction context"

  let!(:subscription_interaction) {Subscribe::SubscribeInteraction.new(@params)}

  describe "paypal cooperation", skip: true do
    it "return correct return_url" do
      expect(subscription_interaction.redirect_url).to include('https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=')
    end
  end
end
