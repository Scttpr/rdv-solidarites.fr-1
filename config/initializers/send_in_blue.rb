SibApiV3Sdk.configure do |config|
  # Configure API key authorization: api-key
  config.api_key["api-key"] = ENV["SENDINBLUE_API_KEY"]
end