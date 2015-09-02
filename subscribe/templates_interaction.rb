class Subscribe::TemplatesInteraction
  def initialize params
    @user = params[:user]
    @type = set_type(params)
    @country = params[:country]
  end

  def as_json options={}
    subscription_templates.as_json(options)
  end

  private
  def subscription_templates
    templates = SubscriptionTemplate.select(subscriptions_params)
    templates.reject! {|t| t.is_trial} unless available_for_trial?
    templates
  end

  def available_for_trial?
    return false unless @user.present?
    return false if eventim_user?
    @user.subscriptions.count == 0 || @user.subscriptions.where(type: @type).count == 0
  end

  def eventim_user?
    @user.partner =~ /eventim/
  end

  def set_type params
    return params[:type] if params[:type].present?
    return nil unless @user.present?
    return nil unless @user.subscriptions.any?
    @user.subscriptions.last.type
  end

  def subscriptions_params
    h = {}
    h[:country] = @country
    h[:user] = @user
    h[:type] = @type
    h
  end
end
