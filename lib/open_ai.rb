require "json"
require "net/http"
require "uri"
require "opentelemetry/sdk"
OpenAITracer = OpenTelemetry.tracer_provider.tracer("openai", "1.0")

module OpenAI
  def query(url, params, user = nil)
    OpenAITracer.in_span(url, attributes: {
                                "http.url" => url,
                                "http.body" => params.to_json,
                                "http.scheme" => "https",
                                "http.target" => URI.parse(url).request_uri,
                                "http.method" => "POST",
                                "net.peer.name" => URI.parse(url).host,
                                "net.peer.port" => URI.parse(url).port,
                                "discord.user.id" => user&.id,
                                "discord.user.name" => user&.name,
                                "discord.user.username" => user&.username,
                                "discord.user.discriminator" => user&.discriminator,
                                "discord.user.status" => user&.status.to_s,
                                "discord.user.avatar_id" => user&.avatar_id,
                                "discord.user.bot_account" => user&.bot_account,
                                "discord.user.current_bot?" => user&.current_bot?,
                                "discord.user.dnd?" => user&.dnd?,
                                "discord.user.idle?" => user&.idle?,
                                "discord.user.offline?" => user&.offline?,
                                "discord.user.online?" => user&.online?,
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
        span.set_attribute("http.status_code", response.code)
        $logger.debug(response.body)
        span.add_event("OpenAI API response")

        ret = JSON.parse(response.body)
        if ret.include?("error")
          ret["error"]
        else
          choices = ret["choices"]
          usage = ret["usage"]
          text = choices[0]["text"].strip
          span.set_attribute("openai.completions.choices.text", text)
          span.set_attribute("openai.completions.choices", choices.length)
          span.set_attribute("openai.completions.choices.index", choices[0]["index"])
          span.set_attribute("openai.completions.choices.logprobs", choices[0]["logprobs"] || [])
          span.set_attribute("openai.completions.choices.finish_reason", choices[0]["finish_reason"])
          span.set_attribute("openai.completions.model", ret["model"])
          span.set_attribute("openai.completions.id", ret["id"])
          span.set_attribute("openai.completions.object", ret["object"])
          span.set_attribute("openai.completions.created", ret["created"])
          span.set_attribute("openai.completions.usage", usage.length)
          span.set_attribute("openai.completions.usage.prompt_tokens", usage["prompt_tokens"])
          span.set_attribute("openai.completions.usage.completion_tokens", usage["completion_tokens"])
          span.set_attribute("openai.completions.usage.total_tokens", usage["total_tokens"])
          text
        end
      rescue Net::ReadTimeout
        span.add_event("OpenAI API timeout")
        "Timeout"
      end
    end
  end

  # query OpenAI completions API for sentiment analysis
  def sentiment_analysis(text, user = nil)
    query("https://api.openai.com/v1/completions", {
      model: "text-davinci-003",
      prompt: "Do you feel like the statement : \"#{text}\" is positive, negative or neutral?",
      temperature: 0.7,
      max_tokens: 256,
      top_p: 1,
      frequency_penalty: 0,
      presence_penalty: 0,
    }, user)
  end

  def qualify_toxicity(text, user = nil)
    query("https://api.openai.com/v1/completions", {
      model: "text-davinci-003",
      prompt: "Is the statement : \"#{text}\" is toxic or non-toxic?",
      temperature: 0.7,
      max_tokens: 256,
      top_p: 1,
      frequency_penalty: 0,
      presence_penalty: 0,
    }, user)
  end

  # moderation request
  def moderation_rewrite(text, user = nil)
    query("https://api.openai.com/v1/completions", {
      model: "text-davinci-003",
      prompt: "Rewrite the following statement in a positive manner : \"#{text}\"",
      temperature: 0.7,
      max_tokens: 256,
      top_p: 1,
      frequency_penalty: 0,
      presence_penalty: 0,
    }, user)
  end
end
