load 'support/subscribe_shared/subscribe_interactions_spec.rb'

RSpec.describe Subscribe::InitialInteraction do
  it_behaves_like 'subscribe_interaction'
  include_context "subscribe interaction context"

  it "have subscriptions params builded" do
    interaction = Subscribe::InitialInteraction.new(@params)
    expect(interaction.subscription_params[:id]).to eq @params[:id]
    expect(interaction.subscription_params[:user_country]).to eq @params[:user_country]
    expect(interaction.subscription_params[:th_token]).to eq @params[:token]
    expect(interaction.subscription_params[:department_code]).to eq @params[:department_code]
    expect(interaction.subscription_params[:success_url]).to eq "http://restapi.tunehog.com/api/subscriptions/result_success"
    expect(interaction.subscription_params[:error_url]).to eq "http://restapi.tunehog.com/api/subscriptions/result_error"
    expect(interaction.subscription_params[:cancel_url]).to eq "http://restapi.tunehog.com/api/subscriptions/result_cancel"
  end
end
