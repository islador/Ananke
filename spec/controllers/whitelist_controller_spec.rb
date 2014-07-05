require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

describe WhitelistController do
  # http://stackoverflow.com/questions/8819343/rails-rspec-devise-undefined-method-authenticate-user
  before {
    controller.stub(:authenticate_user!).and_return true
    controller.stub(:require_share_user).and_return true
  }
  let!(:user) {FactoryGirl.create(:user)}
  let(:share) {FactoryGirl.create(:share)}
  let!(:share_user) {FactoryGirl.create(:share_user, share_id: share.id, user_id: user.id)}

  let(:share2) {FactoryGirl.create(:share)}
  let(:user2) {FactoryGirl.create(:user)}
  let!(:share_user2) {FactoryGirl.create(:share_user, share_id: share2.id, user_id: user2.id)}

  describe "GET 'white_list' > " do
    let!(:pulled_corp_api) {
      FactoryGirl.create(:corp_api_skip_determine_type, share_user: share_user, active: true)
    }
    let!(:valid_corp_api) {
      FactoryGirl.create(:corp_api_skip_determine_type, share_user: share_user, active: true)
    }
    let!(:inactive_corp_api) {
      FactoryGirl.create(:corp_api_skip_determine_type, share_user: share_user, active: false)
    }
    #Share 1
    let!(:whitelist) {FactoryGirl.create(:whitelist, share_id: share.id)}
    let!(:whitelist_api_connection) {FactoryGirl.create(:whitelist_api_connection, api_id: pulled_corp_api.id, whitelist_id: whitelist.id, share_id: share.id)}
    #Share 2
    let!(:pulled_corp_api2) {
      FactoryGirl.create(:corp_api_skip_determine_type, share_user: share_user2, active: true)
    }
    let!(:whitelist2) {FactoryGirl.create(:whitelist, share_id: share2.id)}
    let!(:whitelist_api_connection2) {FactoryGirl.create(:whitelist_api_connection, api_id: pulled_corp_api2.id, whitelist_id: whitelist2.id)}
    

    it "returns http success" do
      sign_in user
      get 'white_list', share_user_id: share_user.id
      response.should be_success
    end

    it "should build an @wl object containing all whitelists of the given share" do
      sign_in user
      get 'white_list', share_user_id: share_user.id
      expect(assigns(:wl)).to include(whitelist)
      expect(assigns(:wl)).to_not include(whitelist2)
    end

    it "should build an @active_pull_apis object containing all of the APIs currently being pulled from on the given share" do
      sign_in user
      get 'white_list', share_user_id: share_user.id
      expect(assigns(:active_pull_apis)).to include(pulled_corp_api)
      expect(assigns(:active_pull_apis)).to_not include(valid_corp_api)
      expect(assigns(:active_pull_apis)).to_not include(inactive_corp_api)
      expect(assigns(:active_pull_apis)).to_not include(pulled_corp_api2)
    end

    it "should build an @user_char_names object containing all of the API's currently being pulled from the given share's share_user's main_char_names" do
      sign_in user
      get 'white_list', share_user_id: share_user.id
      expect(assigns(:user_char_names)[0]).to match "#{share_user.main_char_name}"
      expect(assigns(:user_char_names)).to_not include("#{share_user2.main_char_name}")
    end
  end

  describe "GET 'white_list_log'" do
    it "returns http success" do
      get 'white_list_log', share_user_id: share_user.id
      response.should be_success
    end

    let!(:whitelistLog) {FactoryGirl.create(:whitelist_log, share_id: share.id)}
    let!(:whitelistLog2) {FactoryGirl.create(:whitelist_log, share_id: share2.id)}
    it "should build an @wll object containing all whitelists in the current share" do
      get 'white_list_log', share_user_id: share_user.id
      expect(assigns(:wll)).to include(whitelistLog)
      expect(assigns(:wll)).to_not include(whitelistLog2)
    end
  end

  describe "DELETE 'destroy'" do
    let!(:whitelist) {FactoryGirl.create(:whitelist, share_id: share.id)}

    it "should destroy the whitelist identified" do
      expect{
        xhr :delete, :destroy, share_user_id: share_user.id, id: whitelist.id}.to change(Whitelist, :count).by(-1)
    end
  end

  describe "CREATE 'create'" do
    it "should create a new whitelist entity" do
      sign_in user
      expect{
        xhr :post, :create, share_user_id: share_user.id, entity_name: "Fido", entity_type: 4
      }.to change(Whitelist, :count).by(+1)
    end
  end

  describe "GET 'retrieve_pullable_apis'" do
    let!(:pulled_corp_api) {
      FactoryGirl.create(:corp_api_skip_determine_type, share_user: share_user, active: true)
    }
    let!(:valid_corp_api) {
      FactoryGirl.create(:corp_api_skip_determine_type, share_user: share_user, active: true)
    }
    let!(:inactive_corp_api) {
      FactoryGirl.create(:corp_api_skip_determine_type, share_user: share_user, active: false)
    }
    let!(:whitelist) {FactoryGirl.create(:whitelist, share_id: share.id)}
    let!(:whitelist_api_connection) {FactoryGirl.create(:whitelist_api_connection, api_id: pulled_corp_api.id, whitelist_id: whitelist.id, share_id: share.id)}

    #Share 2
    let!(:valid_corp_api2) {
      FactoryGirl.create(:corp_api, share_user: share_user2, active: true)
    }
    let!(:pulled_corp_api2) {
      FactoryGirl.create(:corp_api, share_user: share_user2, active: true)
    }
    let!(:whitelist2) {FactoryGirl.create(:whitelist, share_id: share2.id)}
    let!(:whitelist_api_connection2) {FactoryGirl.create(:whitelist_api_connection, api_id: pulled_corp_api2.id, whitelist_id: whitelist.id, share_id: share2.id)}
    
    it "should build an @corp_apis object containing all of the share_user's valid corp APIs" do
      sign_in user
      xhr :get, :retrieve_pullable_apis, share_user_id: share_user.id
      expect(assigns(:valid_corp_apis)).to include(valid_corp_api)
      expect(assigns(:valid_corp_apis)).to_not include(valid_corp_api2)
    end

    it "should build an @corp_apis object that does not contain APIs currently being pulled from" do
      sign_in user
      xhr :get, :retrieve_pullable_apis, share_user_id: share_user.id
      expect(assigns(:valid_corp_apis)).to_not include(pulled_corp_api)
      expect(assigns(:valid_corp_apis)).to_not include(pulled_corp_api2)
    end
  end
end
