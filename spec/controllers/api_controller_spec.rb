require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

describe ApiController do
  # http://stackoverflow.com/questions/8819343/rails-rspec-devise-undefined-method-authenticate-user
  before {
    controller.stub(:authenticate_user!).and_return true
    controller.stub(:require_share_user).and_return true
  }
  let!(:user) {FactoryGirl.create(:user)}
  let!(:share_user) {FactoryGirl.create(:share_user, user_id: user.id)}

  describe "CREATE 'create'" do
    it "should return http success" do
      sign_in user
      VCR.use_cassette('workers/api_key_info/characterAPI') do
        xhr :post, :create, share_user_id: share_user.id, key_id: "3255235", v_code: "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x", main_api: false
      end
      response.should be_success
    end

    it "should enroll a new API" do
      sign_in user
      expect{
        VCR.use_cassette('workers/api_key_info/characterAPI') do
          xhr :post, :create, share_user_id: share_user.id, key_id: "3255235", v_code: "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x", main_api: false
        end
      }.to change(Api, :count).by(+1)
    end

    it "should return the API's ID" do
      #This test could be better. Namely sort out how to access the API itself and compare it's ID against the response.
      sign_in user
      VCR.use_cassette('workers/api_key_info/characterAPI') do
        xhr :post, :create, share_user_id: share_user.id, key_id: "3255235", v_code: "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x", main_api: false
      end
      expect{
        response
      }.not_to be 0
    end
  end

  describe "DELETE 'destroy'" do
    #These tests indicate that the user may destroy APIs not owned by him. This needs to be fixed
    let!(:api) {
      VCR.use_cassette('workers/api_key_info/characterAPI') do
        FactoryGirl.create(:api)
      end
    }
    let!(:main_api) {
      VCR.use_cassette('workers/api_key_info/characterAPI') do
        FactoryGirl.create(:api, main: true)
      end
    }

    it "should destroy the api identified" do
      expect{
        xhr :delete, :destroy, share_user_id: share_user.id, id: api.id}.to change(Api, :count).by(-1)
    end

    it "should not destroy the api if it is a main API" do
      expect{
        xhr :delete, :destroy, share_user_id: share_user.id, id: main_api.id}.not_to change(Api, :count).by(-1)
      end
  end

  describe "GET 'new'" do
    it "returns http success" do
      sign_in user
      get 'new', :share_user_id => share_user.id
      response.should be_success
    end

    it "should build an object containing the count of all the current user's enrolled APIs" do
      sign_in user
      get 'new', :share_user_id => share_user.id
      expect(assigns(:count)).to be 0
    end
  end

  describe "GET 'index'" do
    it "returns http success" do
      sign_in user
      get 'index', :share_user_id => share_user.id
      response.should be_success
    end

    let!(:api1) {
      VCR.use_cassette('workers/api_key_info/characterAPI') do
        FactoryGirl.create(:api, share_user: share_user)
      end
    }
    it "should build an object containing all of the current user's enrolled APIs" do
      sign_in user
      get 'index', :share_user_id => share_user.id
      expect(assigns(:apis)).not_to be_nil
      expect(assigns(:apis)).to include api1
    end
  end

  describe "GET 'show'" do
    let!(:api1) {
      VCR.use_cassette('workers/api_key_info/characterAPI') do
        FactoryGirl.create(:api)
      end
    }
    it "returns http success" do
      get 'show', :share_user_id => share_user.id, :id => api1.id
      response.should be_success
    end
  end

  describe "GET 'character_list'" do
    let!(:corp_api) {
      VCR.use_cassette('workers/api_key_info/corpAPI') do
        FactoryGirl.create(:corp_api, share_user: share_user)
      end
    }
    let!(:api1) {
      VCR.use_cassette('workers/api_key_info/characterAPI') do
        FactoryGirl.create(:api, share_user: share_user)
      end
    }
    let!(:character1){FactoryGirl.create(:character, api: api1)}
    let!(:character2){FactoryGirl.create(:character, api: api1)}
    #The current API used in the factory is returning a single character. Thus to get the three max characters we need only build two.
    #let!(:character3){FactoryGirl.create(:character, api: api1)}

    it "should return http success" do
      xhr :get, :character_list, :share_user_id => share_user.id, :api_id => api1.id
      response.should be_success
    end

    it "should create an object containing all of the API's characters" do
      sign_in user

      xhr :get, :character_list, share_user_id: share_user.id, api_id: api1.id
      
      expect(assigns(:cl).count).to be 3
    end

    it "should return 'false' when called on a corp api" do
      sign_in user
      xhr :get, :character_list, share_user_id: share_user.id, api_id: corp_api.id
      response.body.should match "false"
    end
  end

  describe "PUT 'set_main'" do
    let!(:api2) {
      VCR.use_cassette('workers/api_key_info/characterAPI') do
        FactoryGirl.create(:api, share_user: share_user)
      end
    }
    let!(:character1){FactoryGirl.create(:character, api: api2)}
    let!(:character2){FactoryGirl.create(:character, api: api2)}
    let!(:character3){FactoryGirl.create(:character, api: api2)}
    
    it "should return http success" do
      sign_in user
      xhr :put, :set_main, :share_user_id => share_user.id, :api_id => api2.id, :character_id => character1.id
      response.should be_success
    end

    let!(:api3) {
      VCR.use_cassette('workers/api_key_info/characterAPI') do
        FactoryGirl.create(:api, share_user: share_user, main: true)
      end
    }
    let!(:character4){FactoryGirl.create(:character, api: api3, main: true)}
    it "should set the previous main API to not be the main api" do
      sign_in user
      expect(Api.where("id = ?", api3.id)[0].main).to be_true
      expect(Character.where("id = ?", character4.id)[0].main).to be_true

      xhr :put, :set_main, :share_user_id => share_user.id, :api_id => api2.id, :character_id => character1.id
      
      expect(Api.where("id = ?", api3.id)[0].main).not_to be_true
      expect(Character.where("id = ?", character4.id)[0].main).not_to be_true
    end

    it "should retrieve the API from the database as 'api'" do
      sign_in user
      xhr :put, :set_main, :share_user_id => share_user.id, :api_id => api2.id, :character_id => character1.id
      
      expect(assigns(:api)).not_to be_nil
    end

    it "should retrieve the character from the database as 'api'" do
      sign_in user
      xhr :put, :set_main, :share_user_id => share_user.id, :api_id => api2.id, :character_id => character1.id
      
      expect(assigns(:character)).not_to be_nil
    end

    it "should set an API as the main API" do
      sign_in user
      xhr :put, :set_main, :share_user_id => share_user.id, :api_id => api2.id, :character_id => character1.id

      expect(assigns(:api).main).to be true
      expect(Api.where("id = ?", api2.id)[0].main).to be_true
    end

    it "should set the character on the API to be the main" do
      sign_in user
      xhr :put, :set_main, :share_user_id => share_user.id, :api_id => api2.id, :character_id => character1.id

      expect(assigns(:character).main).to be true
      expect(Character.where("id = ?", character1.id)[0].main).to be_true
    end

    it "should set the main_entity_name of a general API to the main character's name" do
      sign_in user
      xhr :put, :set_main, :share_user_id => share_user.id, :api_id => api2.id, :character_id => character1.id

      expect(Api.where("id = ?", api2.id)[0].main_entity_name).to match character1.name
    end

    let!(:corporation_api) {
      VCR.use_cassette('workers/api_key_info/corpAPI') do
        FactoryGirl.create(:corp_api, share_user: share_user)
      end
    }
    let!(:corporation_character) {FactoryGirl.create(:character, api: corporation_api)}
    it "should set the main_entity_name of a corporation API to the main character's name + the corporation's name" do
      sign_in user
      xhr :put, :set_main, :share_user_id => share_user.id, :api_id => corporation_api.id, :character_id => corporation_character.id

      expect(Api.where("id = ?", corporation_api.id)[0].main_entity_name).to match "#{corporation_character.name} - Alaskan Fish"
    end

    it "should set the user's main_char_name to the new main character's name" do
      sign_in user
      xhr :put, :set_main, :share_user_id => share_user.id, :api_id => corporation_api.id, :character_id => corporation_character.id

      shareUserDB = ShareUser.where("id = ?", share_user.id)[0]
      shareUserDB.main_char_name.should match "#{corporation_character.name}"
    end
  end

  describe "PUT 'begin_whitelist_api_pull'" do
    let!(:corp_api) {
      VCR.use_cassette('workers/api_key_info/corpAPI') do
        FactoryGirl.create(:corp_api, share_user: share_user)
      end
    }

    it "should return http success" do
      VCR.use_cassette('workers/corpContactList_standingsSpread') do
        xhr :put, :begin_whitelist_api_pull, share_user_id: share_user.id, api_id: corp_api.id
      end
      response.should be_success
    end

    it "should call ApiCorpContactPullWorker with corp_api.id" do
      VCR.use_cassette('workers/corpContactList_standingsSpread') do
        xhr :put, :begin_whitelist_api_pull, share_user_id: share_user.id, api_id: corp_api.id
      end
      response.body.should match "API queued for contact processing"
    end

    it "should create a whitelist log indicating a new API Pull has been started" do
      VCR.use_cassette('workers/corpContactList_standingsSpread') do
        xhr :put, :begin_whitelist_api_pull, share_user_id: share_user.id, api_id: corp_api.id
      end
      WhitelistLog.where("entity_type = 5 AND addition = true")[0].should_not be_nil
    end
  end

  describe "PUT 'cancel_whitelist_api_pull'" do
    let!(:corp_api) {
      VCR.use_cassette('workers/api_key_info/corpAPI') do
        FactoryGirl.create(:corp_api, share_user: share_user)
      end
    }
    let!(:whitelist) {FactoryGirl.create(:whitelist)}
    let!(:whitelist_api_connection) {FactoryGirl.create(:whitelist_api_connection, api_id: corp_api.id, whitelist_id: whitelist.id)}

    it "should return http success" do
      VCR.use_cassette('workers/corpContactList_standingsSpread') do
        xhr :put, :cancel_whitelist_api_pull, share_user_id: share_user.id, api_id: corp_api.id
      end
      response.should be_success
    end

    it "should return json 'API removed from contact processing' for a successful request" do
      VCR.use_cassette('workers/corpContactList_standingsSpread') do
        xhr :put, :cancel_whitelist_api_pull, share_user_id: share_user.id, api_id: corp_api.id
      end
      response.should be_success
      response.body.should match "API removed from contact processing"
    end

    it "should return json 'Invalid API or API is not a pulling API'" do
      VCR.use_cassette('workers/corpContactList_standingsSpread') do
        xhr :put, :cancel_whitelist_api_pull, share_user_id: share_user.id, api_id: 3000
      end
      response.body.should match "Invalid API or API is not a pulling API"
    end

    it "should remove the api from the pull schedule" do
      #The pull schedule is defined in scheduling.rake as any API that has a whitelist api connection.
      #So delete the connection to remove it from the pull schedule.
      xhr :put, :cancel_whitelist_api_pull, share_user_id: share_user.id, api_id: corp_api.id
      WhitelistApiConnection.where("id = ?", whitelist_api_connection.id).count.should be 0
    end

    it "should create a whitelist log indicating the API Pull has been cancelled" do
      xhr :put, :cancel_whitelist_api_pull, share_user_id: share_user.id, api_id: corp_api.id
      WhitelistLog.where("entity_type = 5 AND addition = false")[0].should_not be_nil
    end
  end

  describe "PUT 'update_api_whitelist_standing'" do
    let!(:corp_api) {
      VCR.use_cassette('workers/api_key_info/corpAPI') do
        FactoryGirl.create(:corp_api, share_user: share_user)
      end
    }
    it "should return http success" do
      #VCR.use_cassette('workers/corpContactList_standingsSpread') do
        xhr :put, :update_api_whitelist_standing, share_user_id: share_user.id, api_id: corp_api.id, standing: 2
      #end
      response.should be_success
    end

    describe "Error Handling > " do
      let!(:inactive_api) {
        VCR.use_cassette('workers/api_key_info/corpAPI') do
          FactoryGirl.create(:corp_api, share_user: share_user, active: false)
        end
      }
      let!(:general_api) {
        VCR.use_cassette('workers/api_key_info/characterAPI') do
          FactoryGirl.create(:api, share_user: share_user)
        end
      }

      it "should throw an argument error if the API is not active." do
        expect{
          xhr :put, :update_api_whitelist_standing, share_user_id: share_user.id, api_id: general_api.id, standing: 2
        }.to raise_error ArgumentError
        response.body.should match "API must be a corporation API"
      end

      it "should throw an argument error if the API is not a corp API" do
        expect{
          xhr :put, :update_api_whitelist_standing, share_user_id: share_user.id, api_id: inactive_api.id, standing: 2
        }.to raise_error ArgumentError
        response.body.should match "API must be active"
      end
    end

    it "should output json confirming the API was updated" do
      xhr :put, :update_api_whitelist_standing, share_user_id: share_user.id, api_id: corp_api.id, standing: 2
      response.body.should match "true"
    end

    it "should set the API's whitelist_standings to the value sent it" do
      xhr :put, :update_api_whitelist_standing, share_user_id: share_user.id, api_id: corp_api.id, standing: 2
      Api.where("id = ?", corp_api.id)[0].whitelist_standings.should be 2
    end
  end
end
