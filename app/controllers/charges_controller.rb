class ChargesController < ApplicationController
  before_action :set_order
  before_action :set_payment, only: :refund
  before_action :set_description, only: :create

  def new; end

  def create
    customer = Stripe::Customer.create(
      email:  params[:stripeEmail],
      source: params[:stripeToken]
    )

    charge = Stripe::Charge.create(
      customer:    customer.id,
      amount:      @order.total.to_i * 100,
      description: description,
      currency:    'usd'
    )

    payment = Payment.create(
      token: charge['id'],
      order_id: order.id
    )

    order.update(state: 'completed')

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_charge_path
  end

  def refund
    refund_money = Stripe::Refund.create(
      charge: payment.token
    )

    order.update(state: 'refunded')

    redirect_to orders_path

  rescue Stripe::InvalidRequestError => e
    flash[:error] = e.message
    redirect_to orders_path
  end

  private

  attr_reader :order, :payment, :description

  def set_order
    @order = Order.find(params[:order_id])
  end

  def set_payment
    @payment = Payment.find_by(order_id: params[:order_id])
  end

  def set_description
    @description = Rails.application.config.stripe_description
  end
end
