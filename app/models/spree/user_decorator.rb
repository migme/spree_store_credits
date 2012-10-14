module Spree
  User.class_eval do
    has_many :store_credits, :conditions => ["state = 'valid' and valid_to >= ?",Time.zone.now.to_date],:order => "valid_to", :dependent => :destroy

    def has_store_credit?
      store_credits.present?
    end

    def store_credits_total
      store_credits.sum(:remaining_amount)
    end

    def update_credit
      self.update_attribute(:credit, store_credits.sum(:remaining_amount))
    end
  end
end
