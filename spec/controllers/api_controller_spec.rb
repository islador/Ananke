require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

describe ApiController do
  # http://stackoverflow.com/questions/8819343/rails-rspec-devise-undefined-method-authenticate-user
  before { controller.stub(:authenticate_user!).and_return true }
  let!(:user) {FactoryGirl.create(:user)}

  describe "CREATE 'create'" do
    it "should enroll a new API" do
      sign_in user
      expect{
        VCR.use_cassette('workers/api_key_info/characterAPI') do
          xhr :post, :create, user_id: user.id, key_id: "3255235", v_code: "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x", main_api: false
        end
      }.to change(Api, :count).by(+1)
    end

    it "should return the API's ID" do
      #This test could be better. Namely sort out how to access the API itself and compare it's ID against the response.
      sign_in user
      VCR.use_cassette('workers/api_key_info/characterAPI') do
        xhr :post, :create, user_id: user.id, key_id: "3255235", v_code: "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x", main_api: false
      end
      expect{
        response
      }.not_to be 0
    end
  end

  describe "DELETE 'destroy'" do
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
        xhr :delete, :destroy, user_id: user.id, id: api.id}.to change(Api, :count).by(-1)
    end

    it "should not destroy the api if it is a main API" do
      expect{
        xhr :delete, :destroy, user_id: user.id, id: main_api.id}.not_to change(Api, :count).by(-1)
      end
  end

  describe "GET 'new'" do
    it "returns http success" do
      sign_in user
      get 'new', :user_id => user.id
      response.should be_success
    end

    it "should build an object containing the count of all the current user's enrolled APIs" do
      sign_in user
      get 'new', :user_id => user.id
      expect(assigns(:count)).to be 0
    end
  end

  describe "GET 'index'" do
    it "returns http success" do
      sign_in user
      get 'index', :user_id => user.id
      response.should be_success
    end

    let!(:api1) {
      VCR.use_cassette('workers/api_key_info/characterAPI') do
        FactoryGirl.create(:api, user: user)
      end
    }
    it "should build an object containing all of the current user's enrolled APIs" do
      sign_in user
      get 'index', :user_id => user.id
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
      get 'show', :user_id => user.id, :id => api1.id
      response.should be_success
    end
  end

  describe "GET 'character_list'" do
    let!(:api1) {
      VCR.use_cassette('workers/api_key_info/characterAPI') do
        FactoryGirl.create(:api, user: user)
      end
    }
    let!(:character1){FactoryGirl.create(:character, api: api1)}
    let!(:character2){FactoryGirl.create(:character, api: api1)}
    #The current API used in the factory is returning a single character. Thus to get the three max characters we need only build one.
    #let!(:character3){FactoryGirl.create(:character, api: api1)}

    it "should return http success" do
      xhr :get, :character_list, :user_id => user.id, :api_id => api1.id
      response.should be_success
    end

    it "should create an object containing all of the API's characters" do
      sign_in user

      xhr :get, :character_list, user_id: user.id, api_id: api1.id
      
      expect(assigns(:cl).count).to be 3
    end

    xit "should render the _character_list partial" do
      sign_in user

      xhr :get, :character_list, user_id: user.id, api_id: api1.id

      #Testing for rendering of partials: http://stackoverflow.com/a/9947815
      #expect(response).to render_template(:partial => 'character_list')
      #response.body.should have_selector("div#Fuck")

      #assert_template partial: 'character_list', count: 1
      
      #response.should render_template(:partial => 'character_list.js')
    end
  end

  describe "PUT 'set_main'" do
    let!(:api2) {
      VCR.use_cassette('workers/api_key_info/characterAPI') do
        FactoryGirl.create(:api, user: user)
      end
    }
    let!(:character1){FactoryGirl.create(:character, api: api2)}
    let!(:character2){FactoryGirl.create(:character, api: api2)}
    let!(:character3){FactoryGirl.create(:character, api: api2)}
    
    it "should return http success" do
      sign_in user
      xhr :put, :set_main, :user_id => user.id, :api_id => api2.id, :character_id => character1.id
      response.should be_success
    end

    let!(:api3) {
      VCR.use_cassette('workers/api_key_info/characterAPI') do
        FactoryGirl.create(:api, user: user, main: true)
      end
    }
    let!(:character4){FactoryGirl.create(:character, api: api3, main: true)}
    it "should set the previous main API to not be the main api" do
      sign_in user
      expect(Api.where("id = ?", api3.id)[0].main).to be_true
      expect(Character.where("id = ?", character4.id)[0].main).to be_true

      xhr :put, :set_main, :user_id => user.id, :api_id => api2.id, :character_id => character1.id
      
      expect(Api.where("id = ?", api3.id)[0].main).not_to be_true
      expect(Character.where("id = ?", character4.id)[0].main).not_to be_true
    end

    it "should retrieve the API from the database as 'api'" do
      sign_in user
      xhr :put, :set_main, :user_id => user.id, :api_id => api2.id, :character_id => character1.id
      
      expect(assigns(:api)).not_to be_nil
    end

    it "should retrieve the character from the database as 'api'" do
      sign_in user
      xhr :put, :set_main, :user_id => user.id, :api_id => api2.id, :character_id => character1.id
      
      expect(assigns(:character)).not_to be_nil
    end

    it "should set an API as the main API" do
      sign_in user
      xhr :put, :set_main, :user_id => user.id, :api_id => api2.id, :character_id => character1.id

      expect(assigns(:api).main).to be true
      expect(Api.where("id = ?", api2.id)[0].main).to be_true
    end

    it "should set the character on the API to be the main" do
      sign_in user
      xhr :put, :set_main, :user_id => user.id, :api_id => api2.id, :character_id => character1.id

      expect(assigns(:character).main).to be true
      expect(Character.where("id = ?", character1.id)[0].main).to be_true
    end

    it "should set the main_entity_name of a general API to the main character's name" do
      sign_in user
      xhr :put, :set_main, :user_id => user.id, :api_id => api2.id, :character_id => character1.id

      expect(Api.where("id = ?", api2.id)[0].main_entity_name).to match character1.name
    end

    let!(:corporation_api) {
      VCR.use_cassette('workers/api_key_info/corpAPI') do
        FactoryGirl.create(:corp_api, user: user)
      end
    }
    let!(:corporation_character) {FactoryGirl.create(:character, api: corporation_api)}
    it "should set the main_entity_name of a corporation API to the main character's name + the corporation's name" do
      sign_in user
      xhr :put, :set_main, :user_id => user.id, :api_id => corporation_api.id, :character_id => corporation_character.id

      expect(Api.where("id = ?", corporation_api.id)[0].main_entity_name).to match "#{corporation_character.name} - Alaskan Fish"
    end

    it "should set the user's main_char_name to the new main character's name" do
      sign_in user
      xhr :put, :set_main, :user_id => user.id, :api_id => corporation_api.id, :character_id => corporation_character.id

      userDB = User.where("id = ?", user.id)[0]
      userDB.main_char_name.should match "#{corporation_character.name}"
    end
  end

  describe "PUT 'begin_whitelist_api_pull'" do
    let!(:corp_api) {
      VCR.use_cassette('workers/api_key_info/corpAPI') do
        FactoryGirl.create(:corp_api, user: user)
      end
    }

    it "should return http success" do
      VCR.use_cassette('workers/corpContactList_standingsSpread') do
        xhr :put, :begin_whitelist_api_pull, user_id: user.id, api_id: corp_api.id
      end
      response.should be_success
    end

    it "should call ApiCorpContactPullWorker with corp_api.id" do
      VCR.use_cassette('workers/corpContactList_standingsSpread') do
        xhr :put, :begin_whitelist_api_pull, user_id: user.id, api_id: corp_api.id
      end
      response.body.should match "API queued for contact processing"
    end
  end

  describe "PUT 'cancel_whitelist_api_pull'" do
    let!(:corp_api) {
      VCR.use_cassette('workers/api_key_info/corpAPI') do
        FactoryGirl.create(:corp_api, user: user)
      end
    }
    let!(:whitelist) {FactoryGirl.create(:whitelist)}
    let!(:whitelist_api_connection) {FactoryGirl.create(:whitelist_api_connection, api_id: corp_api.id, whitelist_id: whitelist.id)}

    it "should return http success" do
      VCR.use_cassette('workers/corpContactList_standingsSpread') do
        xhr :put, :cancel_whitelist_api_pull, user_id: user.id, api_id: corp_api.id
      end
      response.should be_success
    end

    it "should return json 'API removed from contact processing' for a successful request" do
      VCR.use_cassette('workers/corpContactList_standingsSpread') do
        xhr :put, :cancel_whitelist_api_pull, user_id: user.id, api_id: corp_api.id
      end
      response.should be_success
      response.body.should match "API removed from contact processing"
    end

    it "should return json 'Invalid API or API is not a pulling API'" do
      VCR.use_cassette('workers/corpContactList_standingsSpread') do
        xhr :put, :cancel_whitelist_api_pull, user_id: user.id, api_id: 3000
      end
      response.body.should match "Invalid API or API is not a pulling API"
    end

    it "should remove the api from the pull schedule" do
      pending "I have no pull schedule method. Heroku scheduler to trigger like whenever, then query DB like in market monitor?"
    end
  end
end
