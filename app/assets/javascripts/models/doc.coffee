# =============================  models module  ===============================
models = angular.module("models")

# defaults methods are get({id: 1}), save, query, remove, delete
models.factory('Doc', ["$resource", "Model", ($resource, Model) ->
	$.extend($resource('/docs/:id', # url
		{format: "json"}, # param defaults
		{ # custom actions here 
			query: {method: "GET", url: "/docs/", isArray: true}, 
			update: {method: "PATCH", params: {id: '@id'}}
		}
	), Model)
])