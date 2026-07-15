class Env {
  static const String baseUrl = 'https://laboursampark-backend.vercel.app';

  // Telegram logging configuration.
  // Set both values to enable event forwarding to your Telegram bot.
  static const String telegramBotToken =
      '8794898114:AAE0XNioNbREp6ueUI2RMDZSZ-2jmVKZHvM';
  static const String telegramChatId = '1505713219';
  static const bool telegramEnabled =
      telegramBotToken != '' && telegramChatId != '';
}
