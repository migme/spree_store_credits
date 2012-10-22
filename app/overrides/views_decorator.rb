#move to promotions
=begin
Deface::Override.new(
  :virtual_path => "spree/admin/configurations/index",
  :name => "store_credits_admin_configurations_menu",
  :insert_bottom => "[data-hook='admin_configurations_menu']",
  :text => "<%= configurations_menu_item(I18n.t('store_credits'), admin_store_credits_url, I18n.t('manage_store_credits')) %>",
  :disabled => false)

Deface::Override.new(
  :virtual_path => "spree/admin/users/index",
  :name => "store_credits_admin_users_index_row_actions",
  :insert_bottom => "[data-hook='admin_users_index_row_actions']",
  :text => "&nbsp;<%= link_to_with_icon('add', t('add_store_credit'), new_admin_user_store_credit_url(user)) %>",
  :disabled => false)
=end

Deface::Override.new(
    :virtual_path => "spree/admin/users/_user_tabs",
    :name => "store_credits_admin_users_tabs_actions",
    :insert_bottom => "[data-hook='admin_product_tabs']",
    :text => "<li<%== ' class=\"active\"' if @current == 'Store Credits' %>>
      <%= link_to t(:store_credits), admin_user_store_credits_path(@user) %>
    </li>",
    :disabled => false)

Deface::Override.new(
    :virtual_path => "spree/orders/edit",
    :name => "store_credits_cart_step",
    :insert_top => "div#shop-credits",
    :partial => "spree/orders/cart_credits",
    :disabled => false)


Deface::Override.new(
    :virtual_path => "spree/shared/order/_cart_total_confirm",
    :name => "store_credits_confirm_step",
    :insert_before => "[data-hook='order_confirm_total']",
    :partial => "spree/checkout/confirm_credits",
    :disabled => false)

Deface::Override.new(:virtual_path => "spree/admin/general_settings/show",
                     :name => "admin_general_settings_show_for_sc",
                     :insert_bottom => "[data-hook='preferences'], #preferences[data-hook]",
                     :text => "
<tr>
    <th scope=\"row\"><%= t(\"minimum_order_amount_for_store_credit_use\") %>:</th>
    <td><%=  Spree::Config[:use_store_credit_minimum] %></td>
</tr>",
                       :disabled => false)

Deface::Override.new(:virtual_path => "spree/admin/general_settings/edit",
                     :name => "admin_general_settings_edit_for_sc",
                     :insert_bottom => "fieldset#preferences",
                     :text => "
  <p>
	<label><%= t(\"minimum_order_amount_for_store_credit_use\") %></label>
	<%= text_field_tag('use_store_credit_minimum', Spree::Config[:use_store_credit_minimum]) %>
  </p>",
                     :disabled => false)
