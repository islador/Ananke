# == Schema Information
#
# Table name: black_list_entity_logs
#
#  id                   :integer          not null, primary key
#  entity_name          :string(255)
#  source_share_user_id :integer
#  source_type          :integer
#  addition             :boolean
#  entity_type          :integer
#  date                 :date
#  time                 :datetime
#  share_id             :integer
#  created_at           :datetime
#  updated_at           :datetime
#

require 'spec_helper'

describe BlackListEntityLog do
	let!(:log) {FactoryGirl.create(:black_list_entity_log)}
	subject{log}

	it {should respond_to(:entity_name)}
	it {should respond_to(:source_share_user_id)}
	it {should respond_to(:source_type)}
	it {should respond_to(:addition)}
	it {should respond_to(:entity_type)}
	it {should respond_to(:date)}
	it {should respond_to(:time)}
	it {should respond_to(:share_id)}

	it {should be_valid}
end
