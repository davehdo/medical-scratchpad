# =============================  models module  ===============================
models = angular.module("models")

# defaults methods are get({id: 1}), save, query, remove, delete
models.factory('Patient', ["$resource", "Model", "Doc", ($resource, Model, Doc) ->
	Patient = $.extend($resource('/patients/:id', # url
		{format: "json"}, # param defaults
		{ # custom actions here 
			query: {method: "GET", url: "/patients/", isArray: true}, 
			update: {method: "PATCH", params: {id: '@id'}}
		}
	), Model)
	
	
	Patient.prototype.firstOrCreateDoc = () ->	
		if !@doc
			if @doc_ids and @doc_ids.length > 0
				@doc = Doc.find( @doc_ids[0] )
			else
				@doc = new Doc({one_liner: "New"})
			
	Patient.prototype.getLocation = () ->
		"#{@body["Loc-unit"]} #{@body["Loc_Room_bed"]}"
		
	Patient.prototype.dob = () ->
		if @body then moment(@body["DOB"]) else null

	Patient.prototype.mrn = () ->
		if @body then @body["MRN"] else null

	Patient.prototype.age = () ->
		if @body then @body["AGE"] else null

	Patient.prototype.gender = () ->
		if @body then @body["GENDER"] else null
	
	Patient.prototype.attending = () ->
		if @body then @body["ATTENDING_PROV_NAME"] else null

	Patient.prototype.admittedAt = () ->
		if @body then moment(@body["ADM_DATE"]) else null

	Patient.prototype.service = () ->
		if @body then @body["SERVICE_DESCRIPTION"] else null
		
		
	
	
	
	Patient
])