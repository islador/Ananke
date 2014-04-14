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
        xhr :post, :create, user_id: user.id, key_id: "3255235", v_code: "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x", main_api: false
      }.to change(Api, :count).by(+1)
    end

    it "should return the API's ID" do
      #This test could be better. Namely sort out how to access the API itself and compare it's ID against the response.
      sign_in user
      xhr :post, :create, user_id: user.id, key_id: "3255235", v_code: "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x", main_api: false
      expect{
        response
      }.should_not be 0
    end
  end

  describe "DELETE 'destroy'" do
    let!(:api) {FactoryGirl.create(:api)}

    it "should destroy the api identified" do
      expect{
        xhr :delete, :destroy, user_id: user.id, id: api.id}.to change(Api, :count).by(-1)
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

    let!(:api1) {FactoryGirl.create(:api, user: user)}
    it "should build an object containing all of the current user's enrolled APIs" do
      sign_in user
      get 'index', :user_id => user.id
      expect(assigns(:apis)).not_to be_nil
      expect(assigns(:apis)).to include api1
    end
  end

  describe "GET 'show'" do
    let!(:api1) {FactoryGirl.create(:api)}
    it "returns http success" do
      get 'show', :user_id => user.id, :id => api1.id
      response.should be_success
    end
  end

  describe "GET 'character_list'" do
    let!(:api1) {FactoryGirl.create(:api, user: user)}
    let!(:character1){FactoryGirl.create(:character, api: api1)}
    let!(:character2){FactoryGirl.create(:character, api: api1)}
    let!(:character3){FactoryGirl.create(:character, api: api1)}

    it "should return http success" do
      xhr :get, :character_list, :user_id => user.id, :api_id => api1.id
      response.should be_success
    end

    it "should create an object containing all of the API's characters" do
      sign_in user

      xhr :get, :character_list, user_id: user.id, api_id: api1.id
      
      expect(assigns(:cl).count).to be 3
    end

    it "should render the _character_list partial" do
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
    let!(:api1) {FactoryGirl.create(:api, user: user)}
    let!(:character1){FactoryGirl.create(:character, api: api1)}
    let!(:character2){FactoryGirl.create(:character, api: api1)}
    let!(:character3){FactoryGirl.create(:character, api: api1)}
    
    it "should return http success" do
      xhr :put, :set_main, :user_id => user.id, :api_id => api1.id, :character_id => character1.id
      response.should be_success
    end

    it "should retrieve the API from the database as 'api'" do
      xhr :put, :set_main, :user_id => user.id, :api_id => api1.id, :character_id => character1.id
      
      expect(assigns(:api)).not_to be_nil
    end

    it "should set an API as the main API" do
      xhr :put, :set_main, :user_id => user.id, :api_id => api1.id, :character_id => character1.id

      expect(assigns(:api).main).to be true
    end

    it "should set the character on the API to be the main" do
      xhr :put, :set_main, :user_id => user.id, :api_id => api1.id, :character_id => character1.id

      expect(assigns(:character).main).to be true
    end
  end
end
