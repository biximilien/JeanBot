require "json"
require "net/http"
require "uri"

module OpenAI
  def query(url, params)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{OPENAI_API_KEY}"
    request.body = params.to_json
    $logger.debug(request.body)

    response = http.request(request)
    $logger.debug(response.body)

    ret = JSON.parse(response.body)
    if ret.include?("error")
      ret["error"]
    else
      ret["choices"][0]["text"].strip
    end
  rescue Net::ReadTimeout
    "Timeout"
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
