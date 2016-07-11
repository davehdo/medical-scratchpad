class Doc
  include Mongoid::Document
  field :checklist, type: String
  field :one_liner, type: String
  field :interval_events, type: String
  field :history_of_present_illness, type: String
  field :past_medical_history, type: String 
  field :medications, type: String 
  field :family_history, type: String 
  field :social_history, type: String 
  field :emergency_contact, type: String 
  field :exam, type: String 
  field :data, type: String 
  field :assessment_and_plan, type: String
  field :plan_archive, type: String
  field :event_archive, type: String
  
  belongs_to :patient
end
