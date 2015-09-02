class Subscribe::InitialInteraction
  include SubscriptionUtils::Initiating
  include Rails.application.routes.url_helpers

  attr_reader :user, :template_id, :agent, :department_code,
              :cancel_url, :success_url, :error_url,
              :country, :mobile, :authentication_token
  alias_method :user_country, :country

  def initialize(params)
    ad_hoc_kavalski_missing_id_fix(params) {|id| params[:id] = id }
    validate_params(params)
    @user = params[:user]
    @authentication_token = params[:token]
    @template_id = params[:id]
    @success_url = params.fetch(:success_url) { result_success_subscriptions_url(host) }
    @cancel_url = params.fetch(:cancel_url) { result_cancel_subscriptions_url(host) }
    @error_url = params.fetch(:error_url) { result_error_subscriptions_url(host) }
    @department_code = params[:department_code]
    @agent = params[:agent]
    @country = params[:user_country]
    @mobile = params[:mobile]
    additional_assign_from params
  end

  def additional_params_to_validate
    []
  end

  def additional_assign_from(params)
  #   If you need more params add them here
  end

  private
  def host
    @host ||= {host: Settings.domain}
  end

  def validate_params(params)
    params_to_validate.each do |attr|
      raise InteractionErrors::WrongArgument.new "Missed #{attr}! in params" if params[attr].blank?
    end
  end

  def ad_hoc_kavalski_missing_id_fix params
    id = params[:id]
    if id.blank?
      h = {}
      h[:type] = params[:type]
      h[:repeat_period] = params[:repeat_period]
      h[:repeat_frequency] = params[:repeat_frequency]
      h[:country] = params[:user_country]
      id = SubscriptionTemplate.select(h).reject(&:is_trial).first.id
    end
    yield id
  end

  def params_to_validate
    unless additional_params_to_validate.is_a? Array
      raise StandardError, '#additional_params_to_validate should be an array'
    end
    %w(user id user_country agent department_code token).map(&:to_sym) + additional_params_to_validate.map(&:to_sym)
  end

  def mobile?
    mobile.present?
  end

  def subscription_template
    _subscription = SubscriptionTemplate.find(template_id) or raise InteractionErrors::NotFound.new template_id
    # This staff needed for QA testing purposes
    if user.developer?
      _subscription.repeat_period = 'day'
      _subscription.trial_frequency = 1 if _subscription.is_trial
    end
    _subscription
  end
end
