class Api::V1::Merchants::InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show, :update, :apply_coupon, :remove_coupon]
  
  def index
    merchant = Merchant.find(params[:merchant_id])

    if params[:status].present?
      invoices = merchant.invoices_filtered_by_status(params[:status])
    else
      invoices = merchant.invoices
    end
    render json: InvoiceSerializer.new(invoices)
  end


  def show
    if @invoice
      render_serialized(@invoice)
    else
      render json: { errors: "Invoice not found" }, status: :not_found
    end
  end


  def update 
    if @invoice.update(invoice_params)
      render_serialized(@invoice)
    else
      render json: { errors: @invoice.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def apply_coupon
    if params[:coupon_id].nil?
      render json: { errors: ["Coupon can't be blank"] }, status: :unprocessable_entity
    elsif @invoice.update(coupon_id: params[:coupon_id])
      render_serialized(@invoice)
    end
  end

  def remove_coupon
    if @invoice.coupon_id.nil?
      render json: { errors: ["No coupon to remove"] }, status: :unprocessable_entity
    elsif @invoice.update(coupon_id: nil)
      render_serialized(@invoice)
    end
  end

  private

  def invoice_params
    params.require(:invoice).permit(:amount, :merchant_id, :status, :coupon_id)
  end

  def set_invoice
    @invoice = Invoice.find_by(id: params[:id], merchant_id: params[:merchant_id])
  end

  def render_serialized(invoice, status = :ok)
    render json: InvoiceSerializer.new(invoice), status: status
  end
end

