module Spree
  class StoreCredit < ActiveRecord::Base

    DEFAULT_VALID_PERIOD = 30.days.from_now
    attr_accessible :user_id, :amount, :reason, :remaining_amount, :valid_to

    validates :amount, :presence => true, :numericality => true
    validates :reason, :presence => true
    validates :user, :presence => true
    validates :valid_to, :presence => true

    scope :expired, :conditions => ["state <> 'expired' AND valid_to < ?", Time.zone.now.to_date]

    belongs_to :user

    after_initialize :set_default_valid_to

    before_create :set_values
    after_save :update_user

    state_machine :initial => :valid, :namespace => :credits do
      event :expire do
        transition :from => :valid, :to => :expired, :if => lambda {|cp| cp.valid_to < Time.zone.now.to_date}
      end
    end

    def set_values
      remaining_amount ||= amount
      valid_to ||= DEFAULT_VALID_PERIOD
    end

    def update_user
      self.user.update_credit
    end

    def set_default_valid_to
      self.valid_to ||= DEFAULT_VALID_PERIOD
    end
    class << self
      def expire
        self.expired.each do  |c|
          begin
            c.expire_credits!
          rescue
            Rails.logger.info "Cannot expire credits -  #{c.id}"
          end
        end
      end

      def add_credit(user, amount, reason,valid_to = DEFAULT_VALID_PERIOD)
        credit = new()
        credit.user = user
        credit.amount = amount
        credit.remaining_amount = amount
        credit.reason = reason
        credit.valid_to = valid_to
        credit.save
      end
    end
  end
end
