require "rails_helper"

RSpec.describe "Merchant invoices endpoints" do
  before :each do
    @merchant1 = create(:merchant)
    @merchant2 = create(:merchant)

    @customer1 = create(:customer)
    @customer2 = create(:customer)

    @coupon = create(:coupon, merchant: @merchant1)

    @invoice1 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "packaged", coupon_id: @coupon.id)
    create_list(:invoice, 3, merchant_id: @merchant1.id, customer_id: @customer1.id)
    @invoice2 = Invoice.create!(customer: @customer1, merchant: @merchant2, status: "shipped")
  end

  describe "GET /api/v1/merchants/:merchant_id/invoices without params" do
    it "should return all invoices for merchant if no params" do
      get "/api/v1/merchants/#{@merchant1.id}/invoices"

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(json[:data].count).to eq(4)
    end
  end

  describe "GET /api/v1/merchants/:merchant_id/invoices with status param" do
    it "should return all invoices for a given merchant based on status param" do
      get "/api/v1/merchants/#{@merchant1.id}/invoices?status=packaged"

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(json[:data].count).to eq(1)
      expect(json[:data][0][:id]).to eq(@invoice1.id.to_s)
      expect(json[:data][0][:type]).to eq("invoice")
      expect(json[:data][0][:attributes][:customer_id]).to eq(@customer1.id)
      expect(json[:data][0][:attributes][:merchant_id]).to eq(@merchant1.id)
      expect(json[:data][0][:attributes][:status]).to eq("packaged")
    end
  
    it "should get multiple invoices if they exist for a given merchant and status param" do
      get "/api/v1/merchants/#{@merchant1.id}/invoices?status=shipped"

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(json[:data].count).to eq(3)
    end
  end

  describe "GET /api/v1/merchants/:merchant_id/invoices for a specific merchant" do
    it "should only get invoices for merchant given" do
      get "/api/v1/merchants/#{@merchant2.id}/invoices?status=shipped"

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(json[:data].count).to eq(1)
      expect(json[:data][0][:id]).to eq(@invoice2.id.to_s)
    end
  end

  describe "GET /api/v1/merchants/invalid_merchant_id" do
    it "returns 404 and error message when merchant is not found" do
      get "/api/v1/merchants/100000/customers"

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:not_found)
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to be_a Array
      expect(json[:errors].first).to eq("Couldn't find Merchant with 'id'=100000")
    end
  end

  describe 'GET /api/v1/merchants/:merchant_id/invoices' do
    before :each do
      @merchant1 = create(:merchant)
      @customer1 = create(:customer)
      @coupon = create(:coupon, merchant: @merchant1)
      @invoice_with_coupon = create(:invoice, merchant: @merchant1, customer: @customer1, coupon: @coupon)
      @invoice_without_coupon = create(:invoice, merchant: @merchant1, customer: @customer1, coupon_id: nil)
    end
  
    it 'returns all invoices including the coupon_id' do
      get "/api/v1/merchants/#{@merchant1.id}/invoices"
  
      expect(response).to be_successful
      json_response = JSON.parse(response.body, symbolize_names: true)
      data = json_response[:data]
  
      expect(data.count).to eq(2)
      expect(data[0][:attributes][:coupon_id]).to eq(@coupon.id)
      expect(data[1][:attributes][:coupon_id]).to be_nil
    end

    it 'returns an empty array when there are no invoices for the merchant' do
      empty_merchant = create(:merchant)
  
      get "/api/v1/merchants/#{empty_merchant.id}/invoices"
  
      expect(response).to be_successful
      json_response = JSON.parse(response.body, symbolize_names: true)
      data = json_response[:data]
  
      expect(data).to be_empty
    end
  end

  describe "GET /api/v1/merchants/:merchant_id/invoices/:id" do
    it "returns an invoice with coupon id" do
      coupon = create(:coupon, merchant: @merchant1)
      invoice = create(:invoice, customer: @customer1, merchant: @merchant1, coupon: coupon)
  
      get "/api/v1/merchants/#{@merchant1.id}/invoices/#{invoice.id}"
  
      expect(response).to be_successful
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:data][:attributes][:coupon_id]).to eq(coupon.id)
    end
  
    it "returns an invoice without a coupon id" do
      invoice = create(:invoice, customer: @customer1, merchant: @merchant1)
  
      get "/api/v1/merchants/#{@merchant1.id}/invoices/#{invoice.id}"
  
      expect(response).to be_successful
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:data][:attributes][:coupon_id]).to be_nil
    end
  end

  describe "GET /api/v1/merchants/:merchant_id/invoices/:id" do
    it "returns a 404 error if the invoice is not found" do
  
      get "/api/v1/merchants/#{@merchant1.id}/invoices/9999"
  
      json = JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to have_http_status(:not_found)
      expect(json[:errors]).to eq("Invoice not found")
    end
  end

  describe "PATCH /api/v1/merchants/:merchant_id/invoices/:id/" do
    before :each do
      @merchant = create(:merchant)
      @invoice = create(:invoice, merchant: @merchant, status: "pending")
    end

    it 'updates the invoices with valid parameters' do
      patch "/api/v1/merchants/#{@merchant.id}/invoices/#{@invoice.id}", params: { invoice: { status: "shipped" } }

      expect(response).to be_successful
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:data][:attributes][:status]).to eq("shipped")
      expect(json[:data][:attributes][:merchant_id]).to eq(@merchant.id)
    end

    it 'returns an error when the update fails' do
      patch "/api/v1/merchants/#{@merchant.id}/invoices/#{@invoice.id}", params: { invoice: { status: nil } }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:errors]).to include("Status is not included in the list")
    end

  end

  describe 'PATCH /api/v1/merchants/:merchant_id/invoices/:id/apply_coupon' do
    it 'applies a coupon to the invoice' do
      patch "/api/v1/merchants/#{@merchant1.id}/invoices/#{@invoice1.id}/apply_coupon", params: { coupon_id: @coupon.id }
  
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:data][:attributes][:coupon_id]).to eq(@coupon.id)
    end

    it 'returns an error when applying a coupon to the invoice if coupon_is is invalid' do
      patch "/api/v1/merchants/#{@merchant1.id}/invoices/#{@invoice1.id}/apply_coupon", params: { coupon_id: nil }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:errors]).to include("Coupon can't be blank")
    end
  end

  describe 'PATCH /api/v1/merchants/:merchant_id/invoices/:id/remove_coupon' do
    it 'removes the coupon from the invoice' do
      patch "/api/v1/merchants/#{@merchant1.id}/invoices/#{@invoice1.id}/remove_coupon"
  
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:data][:attributes][:coupon_id]).to be_nil
    end

    it 'returns an error when there is no coupon to remove' do
      invoice_without_coupon = create(:invoice, merchant: @merchant1, coupon_id: nil)
    
      patch "/api/v1/merchants/#{@merchant1.id}/invoices/#{invoice_without_coupon.id}/remove_coupon"
    
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:errors]).to include("No coupon to remove")
    end
  end
end