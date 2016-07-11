# usage:
#   at the start of update
#     update_log = UpdateLog.create(action_name: "Fetch data", comments: "#{all_patients.size} patients")
#   upon successful completion of update
#     update_log.mark_as_complete
#   to see updates
#     /update_logs

class UpdateLog
  include Mongoid::Document
  field :action_name, type: String
  field :started_at, type: Time
  field :ended_at, type: Time
  field :comments, type: String
  
  before_save :fill_in_started_at
  
  def fill_in_started_at
    self.started_at ||= Time.now
  end
  
  def mark_as_complete
    self.update_attribute :ended_at, Time.now
  end
  
end