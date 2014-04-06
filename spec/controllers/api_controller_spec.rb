require 'spec_helper'

describe ApiController do
  # http://stackoverflow.com/questions/8819343/rails-rspec-devise-undefined-method-authenticate-user
  before { controller.stub(:authenticate_user!).and_return true }
  let!(:user) {FactoryGirl.create(:user)}

  describe "CREATE 'create'" do
    it "should enroll a new API" do
      sign_in user
      expect{
        xhr :post, :create, user_id: user.id, key_id: "1234789", v_code: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", main_api: false
      }.to change(Api, :count).by(+1)
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
      get 'index', :user_id => user.id
      response.should be_success
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
      get 'character_list', :user_id => user.id, :api_id => api1.id
      response.should be_success
    end

    it "should create an object containing all of the API's characters" do
      sign_in user

      xhr :get, :character_list, user_id: user.id, api_id: api1.id
      
      expect(assigns(:cl).count).to be 3
    end
  end
end
