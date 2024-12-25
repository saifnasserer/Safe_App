enum GoalType {
  goal,
  monthlyCommitment
}

class GoalTypeHelper {
  static String getName(GoalType type) {
    switch (type) {
      case GoalType.goal:
        return 'هدف';
      case GoalType.monthlyCommitment:
        return 'التزام شهري';
    }
  }
}
