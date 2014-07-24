require 'spec_helper'


describe ApiController do
  # http://stackoverflow.com/questions/8819343/rails-rspec-devise-undefined-method-authenticate-user
  before {
    controller.stub(:authenticate_user!).and_return true
    controller.stub(:require_share_user).and_return true
  }

  let(:user) {FactoryGirl.create(:user)}
  let(:share) {FactoryGirl.create(:share, user_limit: 2)}
  let!(:share_user) {FactoryGirl.create(:share_user, share_id: share.id, user_id: user.id, approved: true)}

  describe "CREATE 'create'" do
    it "should return http success" do
      sign_in user
      VCR.use_cassette('workers/api_key_info/dynamicCharacterAPI', erb: {:charName => "#{Rails.configuration.charCount+1}", :charID => Rails.configuration.charCount += 1, :corpID => 12345, :corpName => "VCRCorp", :allianceID => 54321, :allianceName => "VCRAlliance", :factionID=>98765, :factionName=>"VCRFaction"}) do
        xhr :post, :create, share_user_id: share_user.id, key_id: "3255235", v_code: "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x", main_api: false
      end
      response.should be_success
    end

    it "should enroll a new API" do
      sign_in user
      expect{
        VCR.use_cassette('workers/api_key_info/dynamicCharacterAPI', erb: {:charName => "#{Rails.configuration.charCount+1}", :charID => Rails.configuration.charCount+=1, :corpID => 12345, :corpName => "VCRCorp", :allianceID => 54321, :allianceName => "VCRAlliance", :factionID=>98765, :factionName=>"VCRFaction"}) do
          xhr :post, :create, share_user_id: share_user.id, key_id: "3255235", v_code: "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x", main_api: false
        end
      }.to change(Api, :count).by(+1)
    end

    it "should return the API's ID" do
      #This test could be better. Namely sort out how to access the API itself and compare it's ID against the response.
      sign_in user
      VCR.use_cassette('workers/api_key_info/dynamicCharacterAPI', erb: {:charName => "#{Rails.configuration.charCount+1}", :charID => Rails.configuration.charCount += 1, :corpID => 12345, :corpName => "VCRCorp", :allianceID => 54321, :allianceName => "VCRAlliance", :factionID=>98765, :factionName=>"VCRFaction"}) do
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
        FactoryGirl.create(:character_api_skip_determine_type)
    }
    let!(:main_api) {
        FactoryGirl.create(:character_api_skip_determine_type, main: true)
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
      FactoryGirl.create(:character_api_skip_determine_type, share_user: share_user)
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
      FactoryGirl.create(:character_api_skip_determine_type)
    }
    let!(:character1){FactoryGirl.create(:character, api: api1, share_id: share.id, ccp_character_id: Rails.configuration.charCount+=1)}
    let!(:character2){FactoryGirl.create(:character, api: api1, share_id: share.id, ccp_character_id: Rails.configuration.charCount+=1)}
    let!(:character3){FactoryGirl.create(:character, api: api1, share_id: share.id, ccp_character_id: Rails.configuration.charCount+=1)}

    it "returns http success" do
      get 'show', :share_user_id => share_user.id, :id => api1.id
      response.should be_success
    end

    it "should retrieve the API from the database" do
      get 'show', share_user_id: share_user.id, id: api1.id
      expect(assigns(:api).id).to be api1.id
    end

    it "should collect all of the api's characters" do
      get 'show', share_user_id: share_user.id, id: api1.id
      expect(assigns(:cl)).to match_array([character2,character3,character1])
    end
  end

  describe "GET 'character_list'" do
    let!(:corp_api) {
      FactoryGirl.create(:corp_api_skip_determine_type, share_user: share_user)
    }
    let!(:api1) {
      FactoryGirl.create(:character_api_skip_determine_type, share_user: share_user)
    }
    let!(:character1){FactoryGirl.create(:character, api: api1, share_id: share.id, ccp_character_id: Rails.configuration.charCount+=1)}
    let!(:character2){FactoryGirl.create(:character, api: api1, share_id: share.id, ccp_character_id: Rails.configuration.charCount+=1)}
    let!(:character3){FactoryGirl.create(:character, api: api1, share_id: share.id, ccp_character_id: Rails.configuration.charCount+=1)}

    it "should return http success" do
      xhr :get, :character_list, :share_user_id => share_user.id, :api_id => api1.id
      response.should be_success
    end

    it "should create an object containing all of the API's characters" do
      sign_in user

      xhr :get, :character_list, share_user_id: share_user.id, api_id: api1.id
      
      expect(assigns(:cl)).to match_array([character2,character3,character1])
    end

    it "should return 'false' when called on a corp api" do
      sign_in user
      xhr :get, :character_list, share_user_id: share_user.id, api_id: corp_api.id
      response.body.should match "false"
    end
  end

  describe "PUT 'set_main'" do
    let!(:api2) {
      FactoryGirl.create(:character_api_skip_determine_type, share_user: share_user, active: true)
    }
    let!(:character1){FactoryGirl.create(:character, api: api2, share_id: share.id, ccp_character_id: Rails.configuration.charCount+=1)}
    let!(:character2){FactoryGirl.create(:character, api: api2, share_id: share.id, ccp_character_id: Rails.configuration.charCount+=1)}
    let!(:character3){FactoryGirl.create(:character, api: api2, share_id: share.id, ccp_character_id: Rails.configuration.charCount+=1)}

    let!(:api3) {
      FactoryGirl.create(:character_api_skip_determine_type, share_user: share_user, main: true)
    }
    let!(:character4){FactoryGirl.create(:character, api: api3, main: true, share_id: share.id, ccp_character_id: Rails.configuration.charCount+=1)}

    let!(:inactive_api) {
      FactoryGirl.create(:character_api_skip_determine_type, share_user: share_user)
    }
    let!(:character5){FactoryGirl.create(:character, api: inactive_api, share_id: share.id, ccp_character_id: Rails.configuration.charCount+=1)}

    it "should return http 400 for inactive APIs" do
      sign_in user
      xhr :put, :set_main, :share_user_id => share_user.id, :api_id => inactive_api.id, :character_id => character5.id
      response.status.should be 400
    end

    it "should return http success" do
      sign_in user
      xhr :put, :set_main, :share_user_id => share_user.id, :api_id => api2.id, :character_id => character1.id
      response.should be_success
    end

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

    it "should retrieve the character from the database as 'character'" do
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

    it "should trigger approval of the share user via the main character" do
      sign_in user
      xhr :put, :set_main, :share_user_id => share_user.id, :api_id => api2.id, :character_id => character1.id

      expect(ShareUser.find(share_user.id).approved).to be false
    end

    it "should set the main_entity_name of a general API to the main character's name" do
      sign_in user
      xhr :put, :set_main, :share_user_id => share_user.id, :api_id => api2.id, :character_id => character1.id

      expect(Api.where("id = ?", api2.id)[0].main_entity_name).to match character1.name
    end

    it "should set the share_user's main_char_name to the main character's name" do
      sign_in user
      xhr :put, :set_main, share_user_id: share_user.id, api_id: api2.id, character_id: character1.id
      expect(ShareUser.where("id = ?", share_user.id)[0].main_char_name).to match character1.name
    end

    describe " share_user invalid with a :share_users error" do
      let!(:user_2) {FactoryGirl.create(:user)}
      let!(:share_user_2) {FactoryGirl.create(:share_user, share_id: share.id, user_id: user_2.id, approved: false)}
      let!(:su2_api) {FactoryGirl.create(:character_api_skip_determine_type, share_user: share_user_2, active: true)}
      let!(:su2_character) {FactoryGirl.create(:character, api: su2_api, main: false, share_id: share.id, ccp_character_id: Rails.configuration.charCount+=1)}

      let!(:whitelist) {FactoryGirl.create(:whitelist, share_id: share.id, name: su2_character.name)}
      
      it "if the share_user is invalid with a :share_users error it should return an error array." do
        expected = ["This uses regexp matching, not string comparison matching. Cute"].to_json

        sign_in user_2
        xhr :put, :set_main, share_user_id: share_user_2.id, api_id: su2_api.id, character_id: su2_character.id
        expect(response.body).to match expected
      end

      it "if the share_user is invalid with a :share_users error, it should still set the share_user's main_char_name to the new main character's name" do
        sign_in user_2
        xhr :put, :set_main, share_user_id: share_user_2.id, api_id: su2_api.id, character_id: su2_character.id
        expect(ShareUser.where("id = ?", share_user_2.id)[0].main_char_name).to match su2_character.name
      end
    end

    describe "with Corp APIs > " do
      #Corporation APIs may not be used to set mains. This helps avoid character name collisions.
      let!(:corporation_api) {
        FactoryGirl.create(:corp_api_skip_determine_type, share_user: share_user, active: true)
      }

      it "should return false if a corporation API is used" do
        sign_in user
        xhr :put, :set_main, :share_user_id => share_user.id, :api_id => corporation_api.id#, :character_id => corporation_character.id
        response.status.should be 400
        #response.body.should match "false"
      end
    end
  end

  describe "PUT 'begin_whitelist_api_pull' > " do
    let!(:corp_api_2) {
      FactoryGirl.create(:corp_api_skip_determine_type, share_user: share_user, active: true)
    }

    it "should return http success" do
      VCR.use_cassette('workers/api_corp_contact/alliance_standingsSpread') do
        xhr :put, :begin_whitelist_api_pull, share_user_id: share_user.id, api_id: corp_api_2.id
      end
      response.should be_success
    end

    it "should call ApiCorpContactPullWorker with corp_api.id" do
      VCR.use_cassette('workers/api_corp_contact/alliance_standingsSpread') do
        xhr :put, :begin_whitelist_api_pull, share_user_id: share_user.id, api_id: corp_api_2.id
      end
      response.should be_success
    end

    it "should create a whitelist log indicating a new API Pull has been started" do
      VCR.use_cassette('workers/api_corp_contact/alliance_standingsSpread') do
        xhr :put, :begin_whitelist_api_pull, share_user_id: share_user.id, api_id: corp_api_2.id
      end
      WhitelistLog.where("entity_type = 5 AND addition = true")[0].should_not be_nil
    end

    describe "Invalid APIs > " do
      let!(:inactive_corp_api) {
        FactoryGirl.create(:corp_api_skip_determine_type, share_user: share_user)
      }
      let!(:character_api) {
        FactoryGirl.create(:character_api_skip_determine_type, share_user: share_user, active: true)
      }

      it "should respond with a 304 if the API is inactive" do
        VCR.use_cassette('workers/api_corp_contact/alliance_standingsSpread') do
          xhr :put, :begin_whitelist_api_pull, share_user_id: share_user.id, api_id: inactive_corp_api.id
        end
        response.status.should be 304
      end

      it "should respond with a 304 if the API is the incorrect type" do
        VCR.use_cassette('workers/api_corp_contact/alliance_standingsSpread') do
          xhr :put, :begin_whitelist_api_pull, share_user_id: share_user.id, api_id: character_api.id
        end
        response.status.should be 304
      end
    end
  end

  describe "PUT 'cancel_whitelist_api_pull'" do
    let!(:corp_api_3) {
      FactoryGirl.create(:corp_api_skip_determine_type, share_user: share_user)
    }
    let!(:whitelist) {FactoryGirl.create(:whitelist)}
    let!(:whitelist_api_connection) {FactoryGirl.create(:whitelist_api_connection, api_id: corp_api_3.id, whitelist_id: whitelist.id)}

    it "should return http success" do
      xhr :put, :cancel_whitelist_api_pull, share_user_id: share_user.id, api_id: corp_api_3.id
      response.should be_success
    end

    it "should return http 200 for a successful request" do
      xhr :put, :cancel_whitelist_api_pull, share_user_id: share_user.id, api_id: corp_api_3.id
      response.should be_success
      #response.body.should match "API removed from contact processing"
    end

    it "should return http 400 for an invalid api" do
      xhr :put, :cancel_whitelist_api_pull, share_user_id: share_user.id, api_id: 3000
      response.status.should be 400
    end

    it "should remove the api from the pull schedule" do
      #The pull schedule is defined in scheduling.rake as any API that has a whitelist api connection.
      #So delete the connection to remove it from the pull schedule.
      xhr :put, :cancel_whitelist_api_pull, share_user_id: share_user.id, api_id: corp_api_3.id
      WhitelistApiConnection.where("id = ?", whitelist_api_connection.id).count.should be 0
    end

    it "should create a whitelist log indicating the API Pull has been cancelled" do
      xhr :put, :cancel_whitelist_api_pull, share_user_id: share_user.id, api_id: corp_api_3.id
      WhitelistLog.where("entity_type = 5 AND addition = false")[0].should_not be_nil
    end
  end

  describe "PUT 'update_api_whitelist_standing'" do
    let!(:corp_api_4) {
      FactoryGirl.create(:corp_api_skip_determine_type, share_user: share_user, active: true)
    }
    it "should return http success" do
      xhr :put, :update_api_whitelist_standing, share_user_id: share_user.id, api_id: corp_api_4.id, standing: 2
      response.should be_success
    end

    it "should return http 200 if the API was updated" do
      xhr :put, :update_api_whitelist_standing, share_user_id: share_user.id, api_id: corp_api_4.id, standing: 2
      response.status.should be 200
      #response.body.should match "true"
    end

    it "should set the API's whitelist_standings to the value sent it" do
      xhr :put, :update_api_whitelist_standing, share_user_id: share_user.id, api_id: corp_api_4.id, standing: 2
      Api.where("id = ?", corp_api_4.id)[0].whitelist_standings.should be 2
    end

    describe "Error Handling > " do
      let!(:inactive_api) {
        FactoryGirl.create(:corp_api_skip_determine_type, share_user: share_user)
      }
      let!(:general_api) {
        FactoryGirl.create(:character_api_skip_determine_type, share_user: share_user)
      }

      it "should throw an argument error if the API is not active." do
        expect{
          xhr :put, :update_api_whitelist_standing, share_user_id: share_user.id, api_id: general_api.id, standing: 2
        }.to raise_error ArgumentError
        response.status.should be 304
        #response.body.should match "API must be a corporation API"
      end

      it "should throw an argument error if the API is not a corp API" do
        expect{
          xhr :put, :update_api_whitelist_standing, share_user_id: share_user.id, api_id: inactive_api.id, standing: 2
        }.to raise_error ArgumentError
        response.status.should be 304
        #response.body.should match "API must be active"
      end
    end
  end

  describe "PUT 'update_api_black_list_standings'" do
    let!(:corp_api_4) {
      FactoryGirl.create(:corp_api_skip_determine_type, share_user: share_user, active: true)
    }
    it "should return http success" do
      xhr :put, :update_api_black_list_standings, share_user_id: share_user.id, api_id: corp_api_4.id, standing: 2
      response.should be_success
    end

    it "should return http 200 if the API was updated" do
      xhr :put, :update_api_black_list_standings, share_user_id: share_user.id, api_id: corp_api_4.id, standing: 2
      response.status.should be 200
      expect(response.body).to eq ["Api Black List Standing set to: #{2}"].to_s
    end

    it "should set the API's black_list_standings to the value sent it" do
      xhr :put, :update_api_black_list_standings, share_user_id: share_user.id, api_id: corp_api_4.id, standing: 2
      expect(Api.where("id = ?", corp_api_4.id)[0].black_list_standings).to be 2
    end

    describe "Error Handling > " do
      let!(:inactive_api) {
        FactoryGirl.create(:corp_api_skip_determine_type, share_user: share_user)
      }
      let!(:general_api) {
        FactoryGirl.create(:character_api_skip_determine_type, share_user: share_user)
      }

      it "should throw an argument error if the API is not active." do
        expect{
          xhr :put, :update_api_black_list_standings, share_user_id: share_user.id, api_id: general_api.id, standing: 2
        }.to raise_error ArgumentError
        response.status.should be 400
      end

      it "should throw an argument error if the API is not a corp API" do
        expect{
          xhr :put, :update_api_black_list_standings, share_user_id: share_user.id, api_id: inactive_api.id, standing: 2
        }.to raise_error ArgumentError
        response.status.should be 400
      end
    end
  end

  describe "PUT 'begin_black_list_api_pull' > " do
    let!(:corp_api_2) {FactoryGirl.create(:corp_api_skip_determine_type, share_user: share_user, active: true)}

    it "should return http success" do
      VCR.use_cassette('workers/black_list_corp_contact/alliance_standingsSpread') do
        xhr :put, :begin_black_list_api_pull, share_user_id: share_user.id, api_id: corp_api_2.id
      end
      response.should be_success
    end

    xit "should call BlackListCorpContactPullWorker with corp_api.id" do
      VCR.use_cassette('workers/black_list_corp_contact/alliance_standingsSpread') do
        xhr :put, :begin_black_list_api_pull, share_user_id: share_user.id, api_id: corp_api_2.id
      end
      response.should be_success
      expect(response.body).to eq ["Populating Black List using API #{corp_api_2.name}. All contacts with standing #{corp_api_2.black_list_standings} and down will be black listed."].to_s
    end

    it "should create a whitelist log indicating a new API Pull has been started" do
      VCR.use_cassette('workers/api_corp_contact/alliance_standingsSpread') do
        xhr :put, :begin_black_list_api_pull, share_user_id: share_user.id, api_id: corp_api_2.id
      end
      expect(BlackListEntityLog.where("entity_type = 5 AND addition = true")[0]).to_not be_nil
    end

    describe "Invalid APIs > " do
      let!(:inactive_corp_api) {FactoryGirl.create(:corp_api_skip_determine_type, share_user: share_user)}
      let!(:character_api) {FactoryGirl.create(:character_api_skip_determine_type, share_user: share_user, active: true)}

      it "should respond with a 400 if the API is inactive" do
        expect{
          xhr :put, :begin_black_list_api_pull, share_user_id: share_user.id, api_id: inactive_corp_api.id
          }.to raise_error ArgumentError
        response.status.should be 400
      end

      it "should respond with a 400 if the API is the incorrect type" do
        expect{
          xhr :put, :begin_black_list_api_pull, share_user_id: share_user.id, api_id: character_api.id
          }.to raise_error ArgumentError
        response.status.should be 400
      end
    end
  end

  describe "PUT 'cancel_black_list_api_pull' > " do
    let(:corp_api) {FactoryGirl.create(:corp_api_skip_determine_type, share_user: share_user)}
    let(:black_list_entity) {FactoryGirl.create(:black_list_entity)}
    let!(:black_list_entity_api_connection) {FactoryGirl.create(:black_list_entity_api_connection, api_id: corp_api.id, black_list_entity_id: black_list_entity.id, share_id: share.id)}

    it "should return http success" do
      xhr :put, :cancel_black_list_api_pull, share_user_id: share_user.id, api_id: corp_api.id
      expect(response).to be_success
    end

    it "should return http 400 for an invalid api" do
      xhr :put, :cancel_black_list_api_pull, share_user_id: share_user.id, api_id: 99999
      expect(response.status).to be 400
    end

    it "should remove the api from the pull schedule" do
      xhr :put, :cancel_black_list_api_pull, share_user_id: share_user.id, api_id: corp_api.id
      expect(BlackListEntityApiConnection.where("id = ?", black_list_entity_api_connection.id).count).to be 0
    end

    it "should create a black list log indicating the API Pull has been cancelled" do
      xhr :put, :cancel_black_list_api_pull, share_user_id: share_user.id, api_id: corp_api.id
      expect(BlackListEntityLog.where("entity_type = 5 AND addition = false")[0]).should_not be_nil
    end
  end
end
