json.array!(@elements) do |element|
  json.extract! element, 
  json.url element_url(element, format: :json)
end
