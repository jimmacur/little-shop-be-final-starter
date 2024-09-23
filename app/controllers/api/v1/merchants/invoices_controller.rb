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
end

private

def invoice_params
  params.require(:invoice).permit(:amount, :merchant_id, :status, :coupon_id)
end

#   def create
#     merchant = Merchant.find(params[:merchant_id])
#     invoice = merchant.invoices.new(invoice_params)
#     if invoice.save
#       render json: InvoiceSerializer.new(invoice), status: :created
#     else
#       render json: { errors: invoice.errors.full_messages }, status: :unprocessable_entity
#     end
#   end
  
#   def update 
#     invoice = Invoice.find(params[:id])

#     if invoice.update(invoice_params)
#       render json: InvoiceSerializer.new(invoice)
#     else
#       render_error(invoice)
#     end
#   end



#   def render_error(invoice)
#     render json: { errors: invoice.errors.full_messages }, status: :unprocessable_entity
#   end
# end