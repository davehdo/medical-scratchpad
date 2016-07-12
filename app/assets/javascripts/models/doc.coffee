# =============================  models module  ===============================
models = angular.module("models")

# defaults methods are get({id: 1}), save, query, remove, delete
models.factory('Doc', ["$resource", "Model", ($resource, Model) ->
	Doc = $.extend($resource('/docs/:id', # url
		{format: "json"}, # param defaults
		{ # custom actions here 
			query: {method: "GET", url: "/docs/", isArray: true}, 
			update: {method: "PATCH", params: {id: '@id'}}
		}
	), Model)
	
	Doc.prototype.save = (callback) ->
		if @id # if the document is not brand new, update it
			@$update(null, callback)
		else # if the document is brand new, create it
			@$save(null, callback)

	Doc
])