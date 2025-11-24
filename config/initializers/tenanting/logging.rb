ActiveSupport.on_load(:action_controller_base) do
  before_action do
    if Current.account.present?
      logger.try(:struct, account: { queenbee_id: Current.account.external_account_id })
    end
  end
end
