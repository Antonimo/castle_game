import 'dart:math';

List<int> getTwoRandomDistinctNumbers({int min = 1, int max = 10}) {
  // Create a new Random object
  final random = Random();

  // Create a Set to store the numbers
  final numbers = <int>{};

  // Generate two random numbers and add them to the Set
  while (numbers.length < 2) {
    final number = random.nextInt(max - min) + min;
    if (!numbers.contains(number)) {
      numbers.add(number);
    }
  }

  // Return the numbers as a List
  return numbers.toList();
}
