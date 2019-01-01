class OrganizerPositionPolicy < ApplicationPolicy
	def delete?
		user.admin?
	end
end