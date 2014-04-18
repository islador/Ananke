require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

describe WhitelistController do
  # http://stackoverflow.com/questions/8819343/rails-rspec-devise-undefined-method-authenticate-user
  before { controller.stub(:authenticate_user!).and_return true }

  describe "GET 'white_list'" do
    let!(:whitelist) {FactoryGirl.create(:whitelist)}

    it "returns http success" do
      get 'white_list'
      response.should be_success
    end

    it "should build an @wl object containing all whitelists" do
      get 'white_list'
      expect(assigns(:wl)).to include(whitelist)
    end

    xit "should build an @corp_apis object containing all " do
    end
  end

  describe "GET 'white_list_log'" do
    it "returns http success" do
      get 'white_list_log'
      response.should be_success
    end

    let!(:whitelistLog) {FactoryGirl.create(:whitelist_log)}
    it "should build an @wll object containing all whitelists" do
      get 'white_list_log'
      expect(assigns(:wll)).to include(whitelistLog)
    end
  end

  describe "DELETE 'destroy'" do
    let!(:whitelist) {FactoryGirl.create(:whitelist)}

    it "should destroy the whitelist identified" do
      expect{
        xhr :delete, :destroy, id: whitelist.id}.to change(Whitelist, :count).by(-1)
    end
  end

  describe "CREATE 'create'" do
    let!(:user) {FactoryGirl.create(:user)}

    it "should create a new whitelist entity" do
      sign_in user
      expect{
        xhr :post, :create, entity_name: "Fido", entity_type: 4
      }.to change(Whitelist, :count).by(+1)
    end
  end

  describe "PUT 'begin_api_pull'" do
    work = ApiCorpContactPullWorker.new
    let!(:user) {FactoryGirl.create(:user)}
    let!(:corp_api) {
      VCR.use_cassette('workers/api_key_info/corpAPI') do
        FactoryGirl.create(:corp_api, user: user)
      end
    }

    it "should return http success" do
      VCR.use_cassette('workers/corpContactList_standingsSpread') do
        xhr :put, :begin_api_pull, api_id: corp_api.id
      end
      response.should be_success
    end

    it "should call ApiCorpContactPullWorker with corp_api.id" do
      VCR.use_cassette('workers/corpContactList_standingsSpread') do
        xhr :put, :begin_api_pull, api_id: corp_api.id
      end
      response.body.should match "API queued for contact processing"
    end
  end
end
