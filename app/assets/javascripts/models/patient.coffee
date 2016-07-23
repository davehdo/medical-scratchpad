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
	
	Patient.prototype.assignDoc = (doc) ->
		# assign the document to the patient if not yet assigned 
		@doc = doc # temporarily set the active doc, however this is overwritten by update anyway
		
		@doc_ids ||= []

		if _.indexOf( @doc_ids, doc.id ) == -1
			@doc_ids.push( doc.id )
			@$update( (patient ) ->
				patient.firstOrCreateDoc()
			)
	
	
	Patient.prototype.firstOrCreateDoc = (onSuccess, onError) ->	
		if !@doc # if no active document assigned:
			if @doc_ids and @doc_ids.length > 0
				# use get instead of find here because we want the most up-to-date
				@doc = Doc.get({id: @doc_ids[0]}, (d) -> 
					d.initialize() 
					onSuccess(d) if onSuccess
				, onError) 
			else
				@doc = new Doc({one_liner: "New"})
				@doc.initialize()
				onSuccess(@doc) if onSuccess
				
			
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