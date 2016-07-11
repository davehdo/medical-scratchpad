json.array!(@patients) do |patient|
	json.partial! patient
end
