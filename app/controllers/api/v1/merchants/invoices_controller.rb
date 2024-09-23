class Api::V1::Merchants::InvoicesController < ApplicationController
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
    invoice = Invoice.find_by(id: params[:id], merchant_id: params[:merchant_id])
    if invoice
      render json: InvoiceSerializer.new(invoice)
    else
      render json: { errors: "Invoice not found" }, status: :not_found
    end
  end


  def update 
    invoice = Invoice.find_by(id: params[:id], merchant_id: params[:merchant_id])

    if invoice.update(invoice_params)
      render json: InvoiceSerializer.new(invoice), status: :ok
    else
      render json: { errors: invoice.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def apply_coupon
    invoice = Invoice.find(params[:id])
  
    if params[:coupon_id].nil?
      render json: { errors: ["Coupon can't be blank"] }, status: :unprocessable_entity
    elsif invoice.update(coupon_id: params[:coupon_id])
      render json: InvoiceSerializer.new(invoice), status: :ok
    end
  end

  def remove_coupon
    invoice = Invoice.find(params[:id])
    if invoice.coupon_id.nil?
      render json: { errors: ["No coupon to remove"] }, status: :unprocessable_entity
    elsif invoice.update(coupon_id: nil)
      render json: InvoiceSerializer.new(invoice), status: :ok
    end
  end

  private

  def invoice_params
    params.require(:invoice).permit(:amount, :merchant_id, :status, :coupon_id)
  end
end

