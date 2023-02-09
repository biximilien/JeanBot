class ModerationStrategy
  def initialize(bot)
    @bot = bot
  end

  def condition(event)
    false
  end

  def execute(event)
    nil
  end
end

class RemoveMessageStrategy < ModerationStrategy
  def condition(event)
    case analysed = sentiment_analysis(event.message.content)
    when /Positive/i
      $logger.info("Sentiment Analysis: Positive")
      false
    when /Negative/i
      $logger.info("Sentiment Analysis: Negative")
      true
    else
      $logger.info("Sentiment Analysis: Neutral")
      false
    end
  end

  def execute(event)
    reason = "Moderation (removing message)"
    event.message.delete(reason)
  end
end

class WatchListStrategy < ModerationStrategy
  def condition(event)
    # watched users loop
    if @bot.get_watch_list_users(event.server.id.to_i).include?(event.user.id.to_i)
      case analysed = sentiment_analysis(event.message.content)
      when /Positive/i
        $logger.info("Sentiment Analysis: Positive")
        false
      when /Negative/i
        $logger.info("Sentiment Analysis: Negative")
        true
      else
        $logger.info("Sentiment Analysis: Neutral")
        false
      end
    end
  end

  def execute(event)
    edited = moderation_rewrite(event.message.content)
    $logger.info(edited)
    reason = "Moderation (rewriting due to negative sentiment)"
    event.message.delete(reason)
    event.respond("~~<@#{event.user.id}>: #{event.message.content}~~" + "\n" + edited)
  end
end
