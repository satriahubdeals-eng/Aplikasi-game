import 'dart:async';
import 'quiz_models.dart';

class AIQuizService {
  // Integrasikan endpoint OpenAI / Gemini API Anda di fungsi ini
  Future<List<Question>> generateQuiz({
    required String level,
    String? subCategory,
    int totalQuestions = 5,
  }) async {
    // Simulasi delay request AI
    await Future.delayed(const Duration(seconds: 2));

    String context = subCategory != null ? "$level ($subCategory)" : level;

    // Contoh dataset yang dihasilkan AI secara dinamis
    return [
      // 1. Tipe Single Choice (ABC)
      Question(
        id: '1',
        questionText: 'Soal $context [Pilihan Ganda]: Apa elemen dasar utama dalam materi ini?',
        type: QuizType.singleChoice,
        options: ['Jawaban A', 'Jawaban B', 'Jawaban C', 'Jawaban D'],
        correctAnswer: 0,
      ),
      // 2. Tipe Text Input (Isian Bebas)
      Question(
        id: '2',
        questionText: 'Soal $context [Isian]: Tuliskan istilah kunci dari pembahasan bab ini!',
        type: QuizType.textInput,
        correctAnswer: 'inovasi',
      ),
      // 3. Tipe Multiple Choice (Pilih lebih dari 1)
      Question(
        id: '3',
        questionText: 'Soal $context [Multi-Pilih]: Manakah dari opsi berikut yang bernilai benar? (Pilih lebih dari satu)',
        type: QuizType.multipleChoice,
        options: ['Opsi 1 (Benar)', 'Opsi 2 (Salah)', 'Opsi 3 (Benar)', 'Opsi 4 (Salah)'],
        correctAnswer: [0, 2],
      ),
    ];
  }
}
