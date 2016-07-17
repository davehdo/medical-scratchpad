# ============================  controllers module  ===========================
controllers = angular.module("controllers")


controllers.controller("PatientsIndexController", ["$scope", "$location", "Patient", "Cohort", "$http", "flash", ($scope, $location, Patient, Cohort, $http, flash) -> 
	# in case there is a flash message, pull it into scope so the view has access to it
	$scope.flash = flash
		
	# just pick the first cohort and forward route there
	$scope.cohorts = Cohort.all( (cohorts) ->
		setTimeout( $location.path( "/cohorts/#{ cohorts[0].id }" ), 10 )
	)
	
])

# /cohorts/show
controllers.controller("CohortsShowController", ["$scope", "$location", "$routeParams", "Patient", "Cohort", "$http", "flash", ($scope, $location, $routeParams, Patient, Cohort, $http, flash) -> 
	# in case there is a flash message, pull it into scope so the view has access to it
	$scope.flash = flash

	# while this looks synchronous, what is returned is a "future", an object
	# that will be filled with data when the XHR response returns
	
	$scope.Patient = Patient
	$scope.Cohort = Cohort
	
	$scope.activate = (patient) -> Patient.active = patient
	$scope.isActive = (patient) ->
	 	Patient.active.id == patient.id
	$scope.activateCohort = (cohort) ->
		$location.path( "/cohorts/#{ cohort.id }" )
	
	$scope.cohorts = Cohort.all( (cohorts) ->
		Cohort.active = Cohort.find( $routeParams.id, (cohort) ->
			$scope.loading = true
			$scope.patients = []
			Patient.query({service_names: cohort.service_names.join("|")}, (patients) ->
				$scope.patients = _.sortBy( patients, (p) -> "#{p.lname}|#{p.fname}")
				$scope.loading = false
				Patient.active ||= patients[0] 
			)
		)

	)
	
	$scope.search = (queryObj) ->
		# run a search if length > 3 and user pauses for minimum time
		if (queryObj || "").length >= 2 
			# start a timer, and if in 500 ms there is no change, initiate the query
			clearTimeout( $scope.searchFunc ) if $scope.searchFunc
			$scope.searchFunc = setTimeout(() =>
				$scope.loading = true
				$scope.patients = Patient.query({q: queryObj}, () ->
					$scope.loading = false
				)			
			, 500)
])


controllers.controller("CohortsCoveringController", ["$scope", "$routeParams", "$location", "Patient", "Doc", "Cohort", "flash", ($scope, $routeParams, $location, Patient, Doc, Cohort, flash) -> 
	# in case there is a flash message, pull it into scope so the view has access to it
	$scope.flash = flash
	
	$scope.Patient = Patient 
	$scope.Cohort = Cohort
	
	$scope.activate = (patient) ->
		Patient.active = patient
	$scope.isActive = (patient) ->
		patient and Patient.active and (Patient.active.id == patient.id)
		
	# while this looks synchronous, what is returned is a "future", an object
	# that will be filled with data when the XHR response returns
	
	$scope.activateCohort = (cohort) ->
		$location.path( "/cohorts/#{ cohort.id }/covering" )
		
	$scope.cohorts = Cohort.all( (cohorts) ->
		Cohort.active = Cohort.find($routeParams.id, (cohort) ->
		
			# while this looks synchronous, what is returned is a "future", an object
			# that will be filled with data when the XHR response returns
			$scope.loading = true
			$scope.patients = Patient.query({service_names: cohort.service_names.join("|")}, (patients) ->
				_.each(patients, (patient) -> patient.firstOrCreateDoc())
				$scope.loading = false
				Patient.active ||= patients[0] 					
			)
		)	
	)
	
	
	# saves the current document and assign it to the patient if not already done
	# if a timeout is listed, means its "okay to wait x ms before saving"
	# any save requests before that time are ignored UNLESS its a save request with timeout of zero
	$scope.save = (patient, timeout) ->
		timeout ||= 0
		
		if !($scope.saveTimeout and timeout != 0)
			clearTimeout($scope.saveTimeout) if $scope.saveTimeout
				
			$scope.saveTimeout = setTimeout( ->
				if patient.doc.changed()
					patient.doc.save( (doc) ->
						# assign the document to the patient if not yet assigned 
						patient.assignDoc doc
						doc.storePriorValues()
					)
				# set to false so we know theres no active timer
				$scope.saveTimeout = false
			, timeout)
			
	$scope.saveIntermittently = (patient) ->
		$scope.save( patient, 5000)
	
	
])

controllers.controller("PatientsAdmittingController", ["$scope", "Patient", "Cohort", "Doc", "$routeParams", "flash", ($scope, Patient, Cohort, Doc, $routeParams, flash) -> 
	# in case there is a flash message, pull it into scope so the view has access to it
	$scope.flash = flash
	
	$scope.Patient = Patient 
	$scope.Cohort = Cohort
	$scope.moment = moment

	
	Patient.active = $scope.patient = Patient.find( $routeParams.id, (patient) ->
		patient.firstOrCreateDoc()
	)		
			
	$scope.cohorts = Cohort.all( (cohorts) ->
		Cohort.active ||= cohorts[0]
	)
	
])


controllers.controller("PatientsProgressingController", ["$scope", "Patient", "Cohort", "Doc", "$routeParams", "flash", ($scope, Patient, Cohort, Doc, $routeParams, flash) -> 
	# in case there is a flash message, pull it into scope so the view has access to it
	$scope.flash = flash
	
	$scope.Patient = Patient 
	$scope.Cohort = Cohort
	
	Patient.active = $scope.patient = Patient.find( $routeParams.id, (patient) ->
		patient.firstOrCreateDoc()
	)		
			
	$scope.cohorts = Cohort.all( (cohorts) ->
		Cohort.active ||= cohorts[0]
	)
	
	
])

controllers.controller("PatientsDischargingController", ["$scope", "Patient", "Cohort", "Doc", "$routeParams", "flash", ($scope, Patient, Cohort, Doc, $routeParams, flash) -> 
	# in case there is a flash message, pull it into scope so the view has access to it
	$scope.flash = flash
	
	$scope.Patient = Patient 
	$scope.Cohort = Cohort
	
	Patient.active = $scope.patient = Patient.find( $routeParams.id, (patient) ->
		patient.firstOrCreateDoc()
	)		
			
	$scope.cohorts = Cohort.all( (cohorts) ->
		Cohort.active ||= cohorts[0]
	)
		
	
	
])


controllers.controller("PatientsShowController", ["$scope", "$routeParams", "$location", "Patient", "flash", ($scope, $routeParams, $location, Patient, flash) -> 
# in case there is a flash message, pull it into scope so the view has access to it
	$scope.flash = flash

	$scope.patient = Patient.get({ id: $routeParams.id})
])


controllers.controller("PatientsNewController", ["$scope", "$location", "Patient", "Cohort", "flash", ($scope, $location, Patient, Cohort, flash) -> 
	# in case there is a flash message, pull it into scope so the view has access to it
	$scope.flash = flash

	$scope.patient = new Patient
	
	$scope.cohorts = Cohort.all( (cohorts) ->
		Cohort.active ||= cohorts[0]
		$scope.patient.service_names = Cohort.active.service_names
	)
	
	
	$scope.submitForm = () ->
		$scope.patient.$save(null, () -> # parameters, success, error
			flash.setMessage "Successfully created"
			$location.path( "/patients/#{ $scope.patient.id }/admitting" )
		, (err) ->
			flash.currentMessage _.map(err.data, (v,k) -> "#{k} #{v}" ).join(" and ")			
		) 
])


controllers.controller("PatientsEditController", ["$scope", "$routeParams", "$location", "Patient", "Cohort", "flash", ($scope, $routeParams, $location, Patient, Cohort, flash) -> 
	# in case there is a flash message, pull it into scope so the view has access to it
	$scope.flash = flash

	$scope.patient = Patient.get({ id: $routeParams.id})

	$scope.cohorts = Cohort.all( (cohorts) ->
		Cohort.active ||= cohorts[0]
		$scope.patient.service_names = Cohort.active.service_names
	)
			
	$scope.submitForm = () ->
		$scope.patient.$update(null, () -> # parameters, success, error
			flash.setMessage "Successfully saved"
			$location.path( "/patients/#{ $scope.patient.id }/admitting" )
		, (err) ->
			flash.currentMessage _.map(err.data, (v,k) -> "#{k} #{v}" ).join(" and ")
		)
		
	$scope.destroy = () ->
		if confirm("Are you sure you want to delete?")
			$scope.patient.$delete({id: $scope.patient._id}, () ->
				flash.setMessage "Deleted"
				$location.path( "/patients/")
			)
])
