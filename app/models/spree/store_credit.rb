module Spree
  class StoreCredit < ActiveRecord::Base

    DEFAULT_VALID_PERIOD = 30.days.from_now
    attr_accessible :user_id, :amount, :reason, :remaining_amount

    validates :amount, :presence => true, :numericality => true
    validates :reason, :presence => true
    validates :user, :presence => true
    validates :valid_to, :presence => true

    scope :expired, :conditions => ["state <> 'expired' AND valid_to < ?", Time.zone.now.to_date]

    belongs_to :user

    after_initialize :set_default_valid_to

    after_save :update_user

    state_machine :initial => :valid, :namespace => :credits do
      event :expire do
        transition :from => :valid, :to => :expired, :if => lambda {|cp| cp.valid_to < Time.zone.now.to_date}
      end
    end

    def update_user
      self.user.update_credit
    end

    def set_default_valid_to
      self.valid_to ||= DEFAULT_VALID_PERIOD
    end

    def self.expire
      self.expired.each do  |c|
        begin
          c.expire_credits!
        rescue
          Rails.logger.info "Cannot expire credits -  #{c.id}"
        end
      end
    end
  end
end
