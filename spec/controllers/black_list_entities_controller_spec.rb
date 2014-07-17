require 'spec_helper'

describe BlackListEntitiesController do
  # http://stackoverflow.com/questions/8819343/rails-rspec-devise-undefined-method-authenticate-user
  before {
    controller.stub(:authenticate_user!).and_return true
    controller.stub(:require_share_user).and_return true
  }

  let!(:user) {FactoryGirl.create(:user)}
  let(:share) {FactoryGirl.create(:share)}
  let!(:share_user) {FactoryGirl.create(:share_user, share_id: share.id, user_id: user.id)}
  let!(:blacklist) {FactoryGirl.create(:black_list_entity, share_id: share.id, source_share_user_id: share_user.id)}

  let(:share2) {FactoryGirl.create(:share)}
  let(:user2) {FactoryGirl.create(:user)}
  let!(:share_user2) {FactoryGirl.create(:share_user, share_id: share2.id, user_id: user2.id)}
  let!(:blacklist2) {FactoryGirl.create(:black_list_entity, share_id: share2.id, source_share_user_id: share_user2.id)}

  describe "GET 'create'" do
    before(:each){
      sign_in user
    }
    it "returns http success" do
      get 'create', share_user_id: share_user.id
      response.should be_success
    end
  end

  describe "GET 'destroy'" do
    before(:each){
      sign_in user
    }
    it "returns http success" do
      get 'destroy', share_user_id: share_user.id, id: blacklist.id
      response.should be_success
    end
  end

  describe "GET 'index'" do
    before(:each){
      sign_in user
    }
    it "returns http success" do
      get 'index', share_user_id: share_user.id
      response.should be_success
    end
  end

  describe "GET 'show'" do
    before(:each){
      sign_in user
    }
    it "returns http success" do
      get 'show', share_user_id: share_user.id, id: blacklist.id
      response.should be_success
    end
  end

  describe "GET 'logs'" do
    before(:each){
      sign_in user
    }
    it "returns http success" do
      get 'logs', share_user_id: share_user.id
      response.should be_success
    end

    let!(:black_list_entity_log) {FactoryGirl.create(:black_list_entity_log, share_id: share.id)}
    let!(:black_list_entity_log2) {FactoryGirl.create(:black_list_entity_log, share_id: share2.id)}
    it "should build an @bll object containing all whitelists in the current share" do
      get 'logs', share_user_id: share_user.id
      expect(assigns(:bll)).to include(black_list_entity_log)
      expect(assigns(:bll)).to_not include(black_list_entity_log2)
    end

    it "should build an @user_char_names object containing all of the source_share_user_id's main_char_names" do
      get 'logs', share_user_id: share_user.id
      expect(assigns(:user_char_names)[0]).to match "#{share_user.main_char_name}"
      expect(assigns(:user_char_names)).to_not include("#{share_user2.main_char_name}")
    end
  end

  describe "GET 'retrieve_pullable_apis'" do
    before(:each){
      sign_in user
    }
    it "returns http success" do
      get 'retrieve_pullable_apis', share_user_id: share_user.id
      response.should be_success
    end
  end

end
