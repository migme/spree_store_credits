module Spree
  Order.class_eval do
    attr_accessible :store_credit_amount, :apply_credit
    attr_accessor :store_credit_amount, :apply_credit

    # the check for user? below is to ensure we don't break the
    # admin app when creating a new order from the admin console
    # In that case, we create an order before assigning a user
    #  Apply only when user selects the checkbox

    before_save :process_store_credit, :if => "self.user.present? and  !@apply_credit.nil?"
    after_save :ensure_sufficient_credit, :if => "self.user.present? && !self.completed?"
    after_save :ensure_credits_used_for_shop, :if => "self.user.present? && !self.completed?"

    validates_with StoreCreditMinimumValidator

    def store_credit_amount
      adjustments.store_credits.sum(:amount).abs
    end

    # Credits are applicable only to store
    def store_total
      line_items.where("buyable_type ='Spree::Variant'").map(&:amount).sum
      # ((line_items.where("buyable_type ='Spree::Variant'").map(&:amount).sum * 30).to_d/100).round(2)
    end


    # override core process payments to force payment present
    # in case store credits were destroyed by ensure_sufficient_credit
    def process_payments!
      if self.payment_required? && payment.nil?
        false
      else
        ret = payments.each(&:process!)
      end
    end

    def thirty_percent_store_total
      ((store_total * 30).to_d / 100).round(2)
    end

    private

    # credit or update store credit adjustment to correct value if amount specified
    #
    def process_store_credit
      @store_credit_amount ||= self.user.store_credits_total if @apply_credit
      @store_credit_amount = BigDecimal.new(@store_credit_amount.to_s).round(2)

      # store credit can't be greater than order total (not including existing credit), or the user's available credit

      @store_credit_amount = [@store_credit_amount, user.store_credits_total, (thirty_percent_store_total + store_credit_amount.abs)].min

      # destroy all shop promotions if not available
      self.adjustments.promotion.destroy_all
      self.update_column(:promo_code,nil)
      if @store_credit_amount <= 0
        adjustments.store_credits.destroy_all
      else
        if sca = adjustments.store_credits.first
          sca.update_attributes({:amount => -(@store_credit_amount)})
        else
          # create adjustment off association to prevent reload
          sca = adjustments.store_credits.create(:label => I18n.t(:store_credit) , :amount => -(@store_credit_amount))
        end
      end

      # recalc totals and ensure payment is set to new amount
      update_totals
      payment.amount = total if payment
    end

    def consume_users_credit
      return unless completed?
      credit_used = self.store_credit_amount

      user.store_credits.each do |store_credit|
        break if credit_used == 0
        if store_credit.remaining_amount > 0
          if store_credit.remaining_amount > credit_used
            store_credit.remaining_amount -= credit_used
            store_credit.save
            credit_used = 0
          else
            credit_used -= store_credit.remaining_amount
            store_credit.update_attribute(:remaining_amount, 0)
          end
        end
      end

    end

    # ensure that user has sufficient credits to cover adjustments
    #
    def ensure_sufficient_credit
      if user.store_credits_total < store_credit_amount
        # user's credit does not cover all adjustments.
        adjustments.store_credits.destroy_all

        update!
      end
    end

    def ensure_credits_used_for_shop
      if store_credit_amount > thirty_percent_store_total
        adjustments.store_credits.destroy_all
        update!
      end
    end
  end
end
