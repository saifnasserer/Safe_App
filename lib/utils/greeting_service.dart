import 'dart:math';

class GreetingService {
  static final Random _random = Random();

  static const List<String> _morningMessages = [
    "صباح الخير ي قمر",
  ];

  static const List<String> _afternoonMessages = [
    "ازيك ي قمر",
  ];

  static const List<String> _eveningMessages = [
    "وَرِزْقُكُمْ فِي السَّمَاءِ وَمَا تُوعَدُونَ",
    ".رزقك لن يأخذه غيرك، فاطمئن",
    "مساء الخير يا قمر",
  ];

  static String getGreeting(String userName) {
    final hour = DateTime.now().hour;
    List<String> messages;

    if (hour >= 5 && hour < 12) {
      messages = _morningMessages;
    } else if (hour >= 12 && hour < 17) {
      messages = _afternoonMessages;
    } else {
      messages = _eveningMessages;
    }

    final message = messages[_random.nextInt(messages.length)];
    return message.replaceAll('{name}', userName);
  }
}
