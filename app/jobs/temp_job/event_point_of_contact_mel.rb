module TempJob
  class EventPointOfContactMel
    def perform
			mel_user_id = 2046
			Event.where.not(point_of_contact_id: mel_user_id).find_each(batch_size: 100) do |e|
				e.point_of_contact_id = mel_user_id
				e.save!
			end
    end
  end
end