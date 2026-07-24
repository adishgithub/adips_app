class GreetingHelper {
  static String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return "Good Morning 👋";
    } else if (hour >= 12 && hour < 15) {
      return "Had Lunch? 🍱";
    } else if (hour >= 15 && hour < 17) {
      return "Good Afternoon ☀️";
    } else if (hour >= 17 && hour < 20) {
      return "Good Evening 🌇";
    } else if (hour >= 20 && hour < 23) {
      return "Have a Nice Day 🌙";
    } else {
      return "Good Night 😴";
    }
  }
}