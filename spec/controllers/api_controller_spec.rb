require 'spec_helper'

describe ApiController do

  describe "GET 'create'" do
    it "returns http success" do
      get 'create'
      response.should be_success
    end
  end

  describe "GET 'destroy'" do
    it "returns http success" do
      get 'destroy'
      response.should be_success
    end
  end

  describe "GET 'apis'" do
    it "returns http success" do
      get 'apis'
      response.should be_success
    end
  end

end
