# == Schema Information
#
# Table name: whitelist_logs
#
#  id                :integer          not null, primary key
#  entity_name       :string(255)
#  source_share_user :integer
#  source_type       :integer
#  addition          :boolean
#  entity_type       :integer
#  date              :date
#  created_at        :datetime
#  updated_at        :datetime
#  time              :datetime
#

require 'spec_helper'

describe WhitelistLog do
  let(:log) {FactoryGirl.create(:whitelist_log)}

  subject{log}

  it {should respond_to(:entity_name)}
  it {should respond_to(:source_share_user)}
  it {should respond_to(:source_type)}
  it {should respond_to(:addition)}
  it {should respond_to(:entity_type)}
  it {should respond_to(:date)}
  it {should respond_to(:time)}

  it {should be_valid}

  describe "Validations > " do
		describe "should validate presence of entity_name" do
			before {log.entity_name = nil}
			it {should_not be_valid}
		end

		describe "should validate presence of source_user" do
			before {log.source_share_user = nil}
			it {should_not be_valid}
		end

		describe "should validate presence of source_type" do
			before {log.source_type = nil}
			it {should_not be_valid}
		end

		describe "should validate presence of entity_type" do
			before {log.entity_type = nil}
			it {should_not be_valid}
		end

		describe "should validate presence of date" do
			before {log.date = nil}
			it {should_not be_valid}
		end

		describe "should validate presence of time" do
			before {log.time = nil}
			it {should_not be_valid}
		end
	end
end
