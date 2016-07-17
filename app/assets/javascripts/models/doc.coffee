# =============================  models module  ===============================
models = angular.module("models")

# defaults methods are get({id: 1}), save, query, remove, delete
models.factory('Doc', ["$resource", "Model", ($resource, Model) ->
	Doc = $resource('/docs/:id', # url
		{format: "json"}, # param defaults
		{ # custom actions here 
			query: {method: "GET", url: "/docs/", isArray: true}, 
			update: {method: "PATCH", params: {id: '@id'}}
		}
	)
	
	Doc.prototype.save = (onSuccess, onErr) ->
		if @id # if the document is not brand new, update it
			@$update(null, onSuccess, onErr)
		else # if the document is brand new, create it
			@$save(null, onSuccess, onErr)

	# in the future it may be useful to have a "save with selective sync"
	# to sync only fields that are not actively being typed in
	Doc.prototype.saveWithoutSync = (onSuccess, onErr) ->
		docOriginal = this
		docCopy = _.clone(this)
	
		docCopy.save( (docReturned) ->
			onSuccess(docOriginal) if onSuccess
		, onErr)
	
		# Immediately after sending the save request, should
		# copy values to prior_values (since obj won't be overwritten by a sync).
		# The first iteration of this waited for the latest object, docReturned,
		# and then stored its values as prior_values, but that was flawed
		# because it allowed risk of overwriting whats on the server in other fields
		# that were simultaneously being edited
		docOriginal.prior_values = docOriginal.attributes()
	
	Doc.prototype.storePriorValues = () ->
		@prior_values = this.attributes()
	
	Doc.prototype.attributes = () ->
		JSON.parse(JSON.stringify(_.omit(this, ["prior_values"])))
		
	Doc.prototype.changed = () ->
		JSON.stringify(@prior_values || {}) != JSON.stringify(_.omit(this, ["prior_values"]))
		
		
	Doc
])