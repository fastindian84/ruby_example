class Subscribe::SubscribeConfirmInteraction < Subscribe::InitialInteraction
  include SubscriptionUtils::Confirming
  attr_reader :paypal_token

  def process_subscription!
    profile_id = setup_profile
    if profile_id.nil?
      raise InteractionErrors::RedirectingError.new error_url, "Paypal payment profile was not created"
    end
    subscription = init_subscription(profile_id)
    if subscription.save
      notify_user(subscription)
      yield if block_given?
    else
      logger.error "Purchased subscription was not saved"
      raise InteractionErrors::RedirectingError.new error_url, subscription.errors.full_messages.join(" ")
    end
  end

  def additional_params_to_validate
   [:paypal_token]
  end

  def additional_assign_from(params)
    @paypal_token = params[:paypal_token]
  end

  protected
  def notify_user(subscription)
    SubscriptionMailService.send_confirmation_notification(subscription)
  end
end
