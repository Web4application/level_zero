HttpResponse<String> response = Unirest.post("https://api.intelbase.is/lookup/email")
  .header("x-api-key", "<in_we8pu42691psGzc9MQF5>"
  .header("Content-Type", "application/json")
  .body("{\n  \"email\": \"<string>\",\n  \"timeout_ms\": 123,\n  \"include_data_breaches\": true,\n  \"exclude_modules\": [\n    \"<string>\"\n  ]\n}")
  .asString();
