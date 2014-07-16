# == Schema Information
#
# Table name: black_list_entity_api_connections
#
#  id                   :integer          not null, primary key
#  api_id               :integer
#  black_list_entity_id :integer
#  share_id             :integer
#  created_at           :datetime
#  updated_at           :datetime
#

require 'spec_helper'

describe BlackListEntityApiConnection do
	let!(:black_list_entity_api_connection) {FactoryGirl.create(:black_list_entity_api_connection)}

	subject {black_list_entity_api_connection}

	it {should respond_to(:api_id)}
	it {should respond_to(:black_list_entity_id)}
	it {should respond_to(:share_id)}
end
