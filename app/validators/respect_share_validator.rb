class RespectShareValidator < ActiveModel::Validator
	def validate(record)
		#Required to ensure that the presence validation spec for share_id doesn't trigger this validation to throw a nil error.
		return if record.share_id.nil?

		#This simply calls the record's owning share and then passes the record to it.
		if record.share.respect_share?(record) == false
			record.errors.add(:share_users, 'The share has reached its user limit, please contact your CEO or Tech Admin about this issue.')
		end
	end
end