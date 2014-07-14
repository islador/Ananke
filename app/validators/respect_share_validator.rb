class RespectShareValidator < ActiveModel::Validator
	def validate(record)
		#Required to ensure that the presence validation spec for share_id doesn't trigger this validation to throw a nil error.
		return if record.share_id.nil?
		#This simply calls the record's owning share and then passes the record to it.
		if record.share.respect_share?(record) == false
			record.errors.add(:share_users, "There are no more available slots. #{record.main_char_name} has been notified of your attempt to join and the problem. Your account will be approved when the problem is fixed.")
			ShareMailer.delay.user_limit_exceeded(record)
		end
	end
end