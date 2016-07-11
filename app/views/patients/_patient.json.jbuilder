json.extract! patient, :name, :fname, :lname, :location, :body, :service_names # name is just lname, fname
json.doc_ids patient.docs.collect {|e| e.to_param}
json.id patient.to_param