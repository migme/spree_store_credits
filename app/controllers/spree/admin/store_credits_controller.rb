module Spree
  class Admin::StoreCreditsController < Admin::ResourceController
    before_filter :check_amounts, :only => [:edit, :update]
    prepend_before_filter :set_remaining_amount, :only => [:create, :update]
    #for user's store credits display
    prepend_before_filter :set_up_user
    prepend_before_filter :add_flash, :only => [:create, :update]


    private
    def check_amounts
      if (@store_credit.remaining_amount < @store_credit.amount)
        flash[:error] = I18n.t(:cannot_edit_used)
        redirect_to admin_store_credits_path
      end
    end

    def set_remaining_amount
      params[:store_credit][:remaining_amount] = params[:store_credit][:amount]
    end

    def collection
      if params[:user_id].nil?
        @q = super.search(params[:q])
        @q.result.page(params[:page])
      else #for store credits in admin user page
        @q = super.where(:user_id => params[:user_id].to_i).search(params[:q])
        @q.result.page(params[:page])
      end
    end

    def collection_url
      if flash[:user_id].nil?
        super
      else
        @user ||= Spree::User.find(flash[:user_id])
        spree.polymorphic_url([:admin, @user, "store_credits"])
      end
    end

    def set_up_user
      user_id = params[:user_id] || flash[:user_id]
      if !user_id.nil?
        @user = Spree::User.find(user_id)
        @current = "Store Credits"
      end
    end

    def add_flash
      flash[:user_id] = params[:user_id]
    end


  end
end
