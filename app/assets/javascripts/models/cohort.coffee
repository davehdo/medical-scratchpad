# =============================  models module  ===============================
models = angular.module("models")

# defaults methods are get({id: 1}), save, query, remove, delete
models.factory('Cohort', ["$resource", "Model", ($resource, Model) ->
	$.extend($resource('/cohorts.json', # url
		{format: "json"}, # param defaults
		{ # custom actions here 
			query: {method: "GET", url: "/cohorts.json", isArray: true}
		}
	), Model)
])