module Spree
  CheckoutController.class_eval do
    #append_before_filter :remove_payments_attributes_if_total_is_zero

    private
    def remove_payments_attributes_if_total_is_zero
      load_order

      return unless params[:order]

      store_credit_amount =  current_user.store_credits_total
      if store_credit_amount >= (current_order.total + @order.store_credit_amount)
        params[:order].delete(:source_attributes)
        params.delete(:payment_source)
        params[:order].delete(:payments_attributes)
      end
    end
  end
end
