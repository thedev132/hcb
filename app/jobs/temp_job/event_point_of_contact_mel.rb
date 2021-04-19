module TempJob
  class EventPointOfContactMel
    def perform
			mel_user_id = 2046
			Event.where.not(point_of_contact_id: mel_user_id).find_each(batch_size: 100) do |e|
				e.update_column(:point_of_contact_id, mel_user_id)
			end
    end
  end
end