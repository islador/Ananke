require 'spec_helper'

describe WhitelistController do
  # http://stackoverflow.com/questions/8819343/rails-rspec-devise-undefined-method-authenticate-user
  before { controller.stub(:authenticate_user!).and_return true }

  describe "GET 'white_list'" do
    it "returns http success" do
      get 'white_list'
      response.should be_success
    end
  end

  describe "GET 'white_list_log'" do
    it "returns http success" do
      get 'white_list_log'
      response.should be_success
    end
  end

  #describe "DELETE 'delete'"

  describe "DELETE 'destroy'" do
    let!(:whitelist) {FactoryGirl.create(:whitelist)}

    it "should destroy the whitelist identified" do
      expect{
        xhr :delete, :destroy, id: whitelist.id}.to change(Whitelist, :count).by(-1)
    end
  end
end
