class PaymentsController < ApplicationController

  layout 'authorize_net'
  helper :authorize_net
  protect_from_forgery :except => :relay_response

  # GET
  # Displays a payment form.
  def payment
    @amount = 10.00
    @sim_transaction = AuthorizeNet::SIM::Transaction.new(AUTHORIZE_NET_CONFIG['api_login_id'], AUTHORIZE_NET_CONFIG['api_transaction_key'], @amount, :relay_url => payments_relay_response_url(:only_path => false))
  end

  # POST
  # Returns relay response when Authorize.Net POSTs to us.
  def relay_response
    sim_response = AuthorizeNet::SIM::Response.new(params)
    if sim_response.success?(AUTHORIZE_NET_CONFIG['api_login_id'], AUTHORIZE_NET_CONFIG['merchant_hash_value'])
      render :text => sim_response.direct_post_reply(payments_receipt_url(:only_path => false), :include => true)
    else
      render
    end
  end
  
  # GET
  # Displays a receipt.
  def receipt
    @auth_code = params[:x_auth_code]
  end

  # POST
  def aim_test
    transaction = AuthorizeNet::AIM::Transaction.new(AUTHORIZE_NET_CONFIG['api_login_id'], AUTHORIZE_NET_CONFIG['api_transaction_key'], :gateway => :sandbox)
    credit_card = AuthorizeNet::CreditCard.new(params[:card][:number], params[:card][:expiration])
    response = transaction.purchase(params[:mount].to_f, credit_card)
    if response.success?
      redirect_to paymentspayment_path
    else
      raise "No anda nada" + AUTHORIZE_NET_CONFIG['api_login_id']
    end
  end
end
