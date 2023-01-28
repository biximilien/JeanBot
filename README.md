# ModerationGPT

This bot provides automated text moderation for Discord text channels. It uses OpenAI API text completions GPT-3 to rewrite any negative messages from users in text channels into a positive message.

## How it works

The bot monitors all messages in a text channel. If a message contains a negative word, the bot will rewrite the message using GPT-3. The bot will then delete the original message and replace it with the rewritten message.

## How to use

1. Create a Discord bot and invite it to your server. See [this guide](https://discordpy.readthedocs.io/en/latest/discord.html) for more information.

2. Create an OpenAI API key. See [this guide](https://beta.openai.com/docs/developer-quickstart/1-creating-an-api-key) for more information.

3. Clone this repository and install the dependencies.

```bash
git clone
cd ModerationGPT
bundle install
```

4. Create a file called `.env` in the root directory of the repository. Add the following lines to the file, replacing the values with your own.

```bash
# .env
OPENAI_API_KEY=my_openai_secret
DISCORD_BOT_TOKEN=my_discord_secret
REDIS_URL=redis://localhost:6379/0
```

Use direnv or source .env the file manually.

5. Run the bot.

```bash
bundle exec ruby bot.rb
```

## Contributing

Contributions are welcome! Please open an issue or pull request if you would like to contribute.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [OpenAI](https://openai.com/) for providing the GPT-3 API
- [Discordrb]() for providing the Discord API wrapper
