class Subscribe::SubscribeInteraction < Subscribe::InitialInteraction
  def redirect_url
    build_auth_redirect_url(return_url, cancel_url)
  end

  private
  def return_url
    subscribe_confirm_subscriptions_url(host.merge(params: subscription_params))
  end
end
