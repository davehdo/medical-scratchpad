# autosave 
# when typing then autosave every few seconds (without sync to avoid disrupting the typing)
# then when field changed then do an immediate save (with sync)

controllers = angular.module("controllers")

controllers.directive('autosavePatient', ["flash", (flash) -> 
	restrict: "A"
	scope: 
		patient: "=autosavePatient"

	link: (scope, elem, attr) ->
		# change does not happen until blur event
		elem.on("change", ->
			# run an immediate save
			scope.save( scope.patient )
		)

		elem.on("keyup", ->
			# autocomplete every few seconds while typing
			scope.saveWithoutSync( scope.patient, 8000)
		)

		elem.on("focus", ->
			# console.log "focus"
			# in the future, if object is older than 5 minutes, 
			# focus should trigger a refresh in case fields
			# have been edited by other users
		)

		
		
		# ==============  a series of methods for updating field class  =============
		# e.g. for contextual color change
		
		attributeName = _.last(elem.attr("ng-model").split("."))
		
		scope.contextualClass = ""
		
		updateContextualClass = ->
			if scope.patient and scope.patient.doc 
			
				if scope.patient.doc.errors and scope.patient.doc.errors[attributeName]
					newClass = "has-error"
				else if scope.patient.doc.prior_values and (scope.patient.doc[attributeName] != scope.patient.doc.prior_values[attributeName])
					newClass = "has-warning"
				else # if there are no errors nor unsaved changes
					newClass = ""
				
				# if the class changed then update the DOM	
				if newClass != scope.contextualClass
					elem.closest(".form-group")
						.removeClass("has-warning has-error").addClass(newClass)
					scope.contextualClass = newClass
				
		scope.$watch("patient.doc.#{attributeName}", updateContextualClass)
		scope.$watch("patient.doc.prior_values.#{attributeName}", updateContextualClass)
		scope.$watch("patient.doc.errors.#{attributeName}", updateContextualClass)


		# ==================================  save  =================================
		scope.saveTimeout = false
		
		# saves the current document and assign it to the patient if not already done
		scope.save = (patient) ->
			clearTimeout(scope.saveTimeout) if scope.saveTimeout
			
			if patient.doc.changed()
				# console.log "Immediate save with sync"
				patient.doc.saveAndReinitialize( (doc) ->
					# assign the document to the patient if not yet assigned 
					patient.assignDoc doc
				, (err) ->
					patient.doc.errors = err.data
					msg = _.map(err.data, (v,k) -> "#{k} #{v}" ).join(" and ")			
					flash.currentMessage "error: #{msg}"
				)
			# set to false so we know theres no active timer
			scope.saveTimeout = false


		# if a user is actively typing and it autosaves, need to 
		# in the future it may be useful to have a "save with selective sync"
		# to sync only fields that are not actively being typed in
		# use saveWithoutSync in order to prevent skipping 
		scope.saveWithoutSync = (patient, timeout) ->
			timeout ||= 0
		
			if !(scope.saveTimeout and timeout != 0)
				clearTimeout(scope.saveTimeout) if scope.saveTimeout
				
				scope.saveTimeout = setTimeout( ->
					if patient.doc.changed()
						# console.log "Saving without sync"
						patient.doc.saveWithoutSync( (doc) ->
							# assign the document to the patient if not yet assigned 
							patient.assignDoc doc
						, (err) ->
							patient.doc.errors = err.data
							msg = _.map(err.data, (v,k) -> "#{k} #{v}" ).join(" and ")			
							flash.currentMessage "Error: #{msg}"
						)
					# set to false so we know theres no active timer
					scope.saveTimeout = false
				, timeout)
				
				
		
])