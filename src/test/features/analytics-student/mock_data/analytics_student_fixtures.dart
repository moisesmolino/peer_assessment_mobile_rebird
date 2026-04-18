class StudentScoreFixture {
  final String label;
  final double value;

  const StudentScoreFixture(this.label, this.value);
}

const studentScores = <StudentScoreFixture>[
  StudentScoreFixture('Punctuality', 4.2),
  StudentScoreFixture('Contributions', 3.7),
  StudentScoreFixture('Commitment', 4.0),
  StudentScoreFixture('Attitude', 4.5),
];
