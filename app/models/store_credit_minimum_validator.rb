class StoreCreditMinimumValidator < ActiveModel::Validator
  def validate(record)
    if Spree::Config[:use_store_credit_minimum] and record.item_total < Spree::Config[:use_store_credit_minimum].to_f and record.store_credit_amount > 0
      record.errors[:base] <<  "The total order amount is less than RM30. A minimum of RM#{Spree::Config[:use_store_credit_minimum].to_f} order amount is required to redeem your free shop credits."
    end
  end
end
