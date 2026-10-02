enum QuizType {
  singleChoice, // Pilihan A, B, C, D
  multipleChoice, // Pilihan lebih dari 1 (Checkbox)
  textInput, // Kolom isian bebas tanpa pilihan
}

class Question {
  final String id;
  final String questionText;
  final QuizType type;
  final List<String>? options; // Null jika textInput
  final dynamic correctAnswer; // String untuk single/text, List<int> untuk multipleChoice

  Question({
    required this.id,
    required this.questionText,
    required this.type,
    this.options,
    required this.correctAnswer,
  });
}

class Category {
  final String id;
  final String name;
  final List<String>? subCategories; // Jurusan (SMK), Fakultas/Prodi (Kuliah), Sub-topik

  Category({
    required this.id,
    required this.name,
    this.subCategories,
  });
}
