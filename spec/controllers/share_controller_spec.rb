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
      xhr :get, :name_available, :share_name => "NameTest"
      response.body.should match "true"
    end

    it "should return false if the name 'TakenName' is not available" do
      xhr :get, :name_available, :share_name => "TakenName"
      response.body.should match "false"
    end
  end

  describe "POST 'create'" do
    it "returns http success" do
      sign_in user
      xhr :post, :create, :share_name => "Available", :plan => "basic"
      response.should be_success
    end
    
    it "should create a new group" do
      sign_in user
      expect{
        xhr :post, :create, :share_name => "Available", :plan => "basic"
      }.to change(Share, :count).by(+1)
    end

    it "should create a new group with the name 'Available'" do
      sign_in user
      xhr :post, :create, :share_name => "Available", :plan => "basic"
      Share.where("name = ?", "Available")[0].nil?.should be false
    end

    it "should return the ID of the new share when successfully created" do
      sign_in user
      xhr :post, :create, :share_name => "Available", :plan => "basic"
      share_id = Share.where("name = ?", "Available")[0].id
      response.body.should match "#{share_id}"
    end

    it "should return false if the share is not successfully created" do
      sign_in user
      xhr :post, :create, :plan => "basic"
      response.body.should match "false"
    end

    it "should assign a variable new_join_link to act as the public join link" do
      sign_in user
      xhr :post, :create, :plan => "basic", :share_name => "test_share"
      expect(Share.last.join_link).not_to be_nil
    end
  end

  describe "GET 'destroy'" do
    let!(:share) {FactoryGirl.create(:basic_share)}

    it "returns http success" do
      delete 'destroy', :id => share.id
      response.should be_success
    end
  end

  describe "GET 'show'" do
    let!(:share) {FactoryGirl.create(:basic_share)}

    it "returns http success" do
      sign_in user
      get 'show', :id => share.id
      response.should be_success
    end

    it "should retrieve the share from the database and make it available in the 'share' variable" do
      sign_in user
      get 'show', :id => share.id
      DBshare = Share.where("id = ?", share.id)[0]
      expect(assigns(:share)).to eq(share)
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

  describe "GET 'join' > " do
    let!(:share) {FactoryGirl.create(:basic_share, join_link: "abcdefg")}

    it "should return http 404 if the join_id is not valid" do
      sign_in user
      get 'join', :join_id => "123123"
      response.status.should be 404
    end

    it "should retrieve the specified share from the database" do
      sign_in user
      get 'join', :join_id => share.join_link
      expect(assigns(:share)).to eq share
    end

    describe "existing user > " do
      let!(:share2) {FactoryGirl.create(:share, join_link: "thgrfe")}
      let!(:user2) {FactoryGirl.create(:user)}
      let!(:share_user) {FactoryGirl.create(:share_user, user_id: user2.id, share_id: share2.id)}

      it "should not create a new share_user if the user already has one" do
        sign_in user2
        expect{
          get 'join', :join_id => share2.join_link
        }.to_not change(ShareUser, :count)
      end

      it "should redirect the user to the share's page if the user is already a member of the share" do
        sign_in user2
        get 'join', :join_id => share2.join_link
        expect(response).to redirect_to share_path(id: share2.id)
      end
    end

    describe "new user > " do
      it "should return http success if the join_id is valid" do
        sign_in user
        get 'join', :join_id => share.join_link
        response.should be_redirect
      end

      it "should create a new share_user if the user does not have one with the share" do
        sign_in user
        expect{
          get 'join', :join_id => share.join_link
        }.to change(ShareUser, :count).by(+1)
      end

      it "should redirect to the new api page if the user is not already a member of the share" do
        sign_in user
        get 'join', :join_id => share.join_link
        expect(response).to be_redirect
        expect(response).not_to redirect_to share_path(id: share.id)
      end
    end
        
  end
end
