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
    merhant = merchant.find(params[:mercahnt_id])
    invoice = merchant.invoice.finnd(params[:id])

    render json: InvoiceSerializer.new(invoice)
  end
end