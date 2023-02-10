require "json"
require "net/http"
require "uri"
require "opentelemetry/sdk"
OpenAITracer = OpenTelemetry.tracer_provider.tracer("openai", "1.0")

module OpenAI
  def query(url, params)
    OpenAITracer.in_span(url, attributes: {
                                "http.url" => url,
                                "http.body" => params.to_json,
                                "http.method" => "POST",
                              }) do |span|
      begin
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri.request_uri)
        request["Content-Type"] = "application/json"
        request["Authorization"] = "Bearer #{OPENAI_API_KEY}"
        request.body = params.to_json
        $logger.debug(request.body)
        span.add_event("OpenAI API call")

        response = http.request(request)
        $logger.debug(response.body)
        span.add_event("OpenAI API response")

        ret = JSON.parse(response.body)
        if ret.include?("error")
          ret["error"]
        else
          val = ret["choices"][0]["text"].strip
          span.set_attribute("openai.completions", val)
          val
        end
      rescue Net::ReadTimeout
        span.add_event("OpenAI API timeout")
        "Timeout"
      end
    end
  end

  # query OpenAI completions API for sentiment analysis
  def sentiment_analysis(text)
    query("https://api.openai.com/v1/completions", {
      model: "text-davinci-003",
      prompt: "Do you feel like the statement : \"#{text}\" is positive, negative or neutral?",
      temperature: 0.7,
      max_tokens: 256,
      top_p: 1,
      frequency_penalty: 0,
      presence_penalty: 0,
    })
  end

  def qualify_toxicity(text)
    query("https://api.openai.com/v1/completions", {
      model: "text-davinci-003",
      prompt: "Is the statement : \"#{text}\" is toxic or non-toxic?",
      temperature: 0.7,
      max_tokens: 256,
      top_p: 1,
      frequency_penalty: 0,
      presence_penalty: 0,
    })
  end

  # moderation request
  def moderation_rewrite(text)
    query("https://api.openai.com/v1/completions", {
      model: "text-davinci-003",
      prompt: "Rewrite the following statement in a positive manner : \"#{text}\"",
      temperature: 0.7,
      max_tokens: 256,
      top_p: 1,
      frequency_penalty: 0,
      presence_penalty: 0,
    })
  end
end
