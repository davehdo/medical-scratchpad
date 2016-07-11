class Patient  
  include Mongoid::Document
  field :fname, type: String
  field :lname, type: String
  field :location, type: String

  
  field :body, type: Hash

  field :orders, type: Array
  field :vitals, type: Array
  field :labs, type: Array
  field :predictions, type: Array

  field :service_names, type: Array
  
  # last time an order, vital, or lab was updated
  field :data_updated_at, type: Time
  # last time there was a successful extraction of params from the data
  field :extracted_at, type: Time
  
  field :visit_id, type: String
  
  field :patient_id, type: String
  
  field :active, type: Boolean, default: true
  
  field :searchable_tokens, type: Array
  
  # has_and_belongs_to_many :cohorts, index: true
  
  validates_uniqueness_of :visit_id
  validates_presence_of :patient_id, :visit_id
  has_many :docs
  
  index({ active: 1 }, { name: "active_index" })
  index({ visit_id: 1 }, {  name: "visit_id_index" })
  index({ patient_id: 1}, {})
  index({ searchable_tokens: 1}, {})
  index({ service_names: 1}, {})
  
  # there should only be a single patient_task per task_id
  # however i cannot define task_id as the primary key
  # so the next best thing is to add an id to each entry whose
  # task_id matches an existing one

  before_save :generate_searchable_tokens
  
  def generate_searchable_tokens
    self.searchable_tokens ||= "#{self.name} #{(self.service_names || []).join(" ")}".split(/[\s\,]+/).uniq
  end
  
  def get( param_name )
    if body
      body[param_name]
    else
      nil
    end
  end
  
  def name
    "#{lname}, #{fname}"
  end
  
  # this is one of the few areas where the app references a piece of data by
  # its name. would prefer to avoid this
  def admitted_at
    if get("ADM_DATE")
      Time.parse get("ADM_DATE")
    else
      nil
    end
  end
  
  def find_or_build_task(task_id)
    self.patient_tasks.where(task_id: task_id).first || self.patient_tasks.build(task_id: task_id)
  end
  
  def build_tasks
    tasks = ActiveSupport::JSON.decode File.read(Rails.root.join('public/tasks.json'))

    tasks.each do |task|
      patient_task = self.find_or_build_task( task["_id"] )
      patient_task.task_name ||= task["name"]
      patient_task.task_snooze_hours ||= task["snooze_hours"]
    end
  end
end
