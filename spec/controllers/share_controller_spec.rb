require 'spec_helper'

describe ShareController do
  # http://stackoverflow.com/questions/8819343/rails-rspec-devise-undefined-method-authenticate-user
  before { controller.stub(:authenticate_user!).and_return true }
  let!(:user) {FactoryGirl.create(:user)}

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end
  end

  describe "name_available" do
    let!(:share) {FactoryGirl.create(:basic_share, owner_id: user.id, name: "TakenName")}

    it "should return http success" do
      xhr :get, :name_available, :name => "NameTest"
      response.should be_success
    end

    it "should return true if the name 'NameTest' is available" do
      xhr :get, :name_available, :name => "NameTest"
      response.body.should match "true"
    end

    it "should return false if the name 'TakenName' is not available" do
      xhr :get, :name_available, :name => "TakenName"
      response.body.should match "false"
    end
  end

  describe "GET 'create'" do
    it "returns http success" do
      get 'create'
      response.should be_success
    end
  end

  describe "GET 'destroy'" do
    it "returns http success" do
      get 'destroy'
      response.should be_success
    end
  end

  describe "GET 'show'" do
    it "returns http success" do
      get 'show'
      response.should be_success
    end
  end

  describe "GET 'index'" do
    let(:share) {FactoryGirl.create(:basic_share)}
    let!(:share_user) {FactoryGirl.create(:share_user, share_id: share.id, user_id: user.id)}
    
    it "returns http success" do
      sign_in user
      get 'index'
      response.should be_success
    end

    it "should populate 'user_shares' with the user's share_users" do
      sign_in user
      get 'index'
      expect(assigns(:user_shares)).to include share
    end
  end

end
