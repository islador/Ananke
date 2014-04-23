require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

describe WhitelistController do
  # http://stackoverflow.com/questions/8819343/rails-rspec-devise-undefined-method-authenticate-user
  before { controller.stub(:authenticate_user!).and_return true }
  let!(:user) {FactoryGirl.create(:user)}

  describe "GET 'white_list'" do
    let!(:pulled_corp_api) {
      VCR.use_cassette('workers/api_key_info/corpAPI') do
        FactoryGirl.create(:corp_api, user: user)
      end
    }
    let!(:valid_corp_api) {
      VCR.use_cassette('workers/api_key_info/corpAPI') do
        FactoryGirl.create(:corp_api, user: user)
      end
    }
    let!(:inactive_corp_api) {
      VCR.use_cassette('workers/api_key_info/corpAPI') do
        FactoryGirl.create(:corp_api, user: user, active: false)
      end
    }
    let!(:whitelist) {FactoryGirl.create(:whitelist)}
    let!(:whitelist_api_connection) {FactoryGirl.create(:whitelist_api_connection, api_id: pulled_corp_api.id, whitelist_id: whitelist.id)}
    

    it "returns http success" do
      sign_in user
      get 'white_list'
      response.should be_success
    end

    it "should build an @wl object containing all whitelists" do
      sign_in user
      get 'white_list'
      expect(assigns(:wl)).to include(whitelist)
    end

    it "should build an @corp_apis object containing all of the user's valid corp APIs" do
      sign_in user
      get 'white_list'
      expect(assigns(:corp_apis)).to include(valid_corp_api)
    end

    it "should build an @active_pull_apis object containing all of the APIs currently being pulled from" do
      sign_in user
      get 'white_list'
      expect(assigns(:active_pull_apis)).to include(pulled_corp_api)
      expect(assigns(:active_pull_apis)).to_not include(valid_corp_api)
      expect(assigns(:active_pull_apis)).to_not include(inactive_corp_api)
    end

    it "should build an @user_char_names object containing all of the API's currently being pulled from user's main_char_names" do
      sign_in user
      get 'white_list'
      expect(assigns(:user_char_names)[0]).to match "#{user.main_char_name}"
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
    it "should create a new whitelist entity" do
      sign_in user
      expect{
        xhr :post, :create, entity_name: "Fido", entity_type: 4
      }.to change(Whitelist, :count).by(+1)
    end
  end
end
