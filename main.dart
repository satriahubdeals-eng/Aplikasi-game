import 'package:flutter/material.dart';
import 'quiz_models.dart';
import 'ai_quiz_service.dart';

void main() {
  runApp(const InteractiveQuizApp());
}

class InteractiveQuizApp extends StatelessWidget {
  const InteractiveQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interactive Quiz',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const CategorySelectionScreen(),
    );
  }
}

// -------------------------------------------------------------
// SCREEN 1: Kategori & Jenjang
// -------------------------------------------------------------
class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  final List<Category> categories = [
    Category(id: 'sd', name: 'SD (Sekolah Dasar)'),
    Category(id: 'smp', name: 'SMP (Sekolah Menengah Pertama)'),
    Category(id: 'sma', name: 'SMA', subCategories: ['IPA', 'IPS', 'Bahasa']),
    Category(id: 'smk', name: 'SMK', subCategories: [
      'Teknik Komputer & Jaringan',
      'Rekayasa Perangkat Lunak',
      'Akuntansi',
      'Tata Boga',
      'Teknik Otomotif'
    ]),
    Category(id: 'kuliah', name: 'Kuliah / Perguruan Tinggi', subCategories: [
      'Informatika / Teknik Elektro',
      'Ekonomi & Bisnis',
      'Hukum',
      'Kedokteran'
    ]),
    Category(id: 'umum', name: 'Pengetahuan Umum'),
    Category(id: 'agama', name: 'Pengetahuan Keagamaan', subCategories: [
      'Islam',
      'Kristen Protestan',
      'Katolik',
      'Hindu',
      'Buddha',
      'Khonghucu'
    ]),
  ];

  Category? selectedCategory;
  String? selectedSubCategory;
  bool isLoading = false;

  void startQuiz() async {
    if (selectedCategory == null) return;
    if (selectedCategory!.subCategories != null && selectedSubCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jurusan/sub-kategori terlebih dahulu!')),
      );
      return;
    }

    setState(() => isLoading = true);

    AIQuizService aiService = AIQuizService();
    List<Question> questions = await aiService.generateQuiz(
      level: selectedCategory!.name,
      subCategory: selectedSubCategory,
    );

    setState(() => isLoading = false);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          questions: questions,
          categoryName: selectedCategory!.name,
          subCategoryName: selectedSubCategory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Jenjang & Kategori Quiz')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<Category>(
                  decoration: const InputDecoration(labelText: 'Jenjang / Kategori'),
                  value: selectedCategory,
                  items: categories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat.name));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedCategory = val;
                      selectedSubCategory = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (selectedCategory?.subCategories != null) ...[
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Pilih Jurusan / Sub-Kategori'),
                    value: selectedSubCategory,
                    items: selectedCategory!.subCategories!.map((sub) {
                      return DropdownMenuItem(value: sub, child: Text(sub));
                    }).toList(),
                    onChanged: (val) {
                      setState(() => selectedSubCategory = val);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                const Spacer(),
                ElevatedButton(
                  onPressed: isLoading ? null : startQuiz,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Generate Quiz & Mulai', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          const WatermarkWidget(),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// SCREEN 2: Pengerjaan Kuis (Mendukung Multi-Tipe Soal)
// -------------------------------------------------------------
class QuizScreen extends StatefulWidget {
  final List<Question> questions;
  final String categoryName;
  final String? subCategoryName;

  const QuizScreen({
    super.key,
    required this.questions,
    required this.categoryName,
    this.subCategoryName,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentIndex = 0;
  
  // Jawaban User
  int? singleAnswerIndex;
  TextEditingController textController = TextEditingController();
  List<int> multipleAnswerIndices = [];

  void nextQuestion() {
    // Pindah ke soal berikutnya
    if (currentIndex < widget.questions.length - 1) {
      setState(() {
        currentIndex++;
        singleAnswerIndex = null;
        textController.clear();
        multipleAnswerIndices.clear();
      });
    } else {
      // Kuis selesai
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Selesai!'),
          content: const Text('Kamu telah menyelesaikan seluruh kuis.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Kembali ke Menu'),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Question currentQ = widget.questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoryName} ${widget.subCategoryName != null ? "(${widget.subCategoryName})" : ""}'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(
                  value: (currentIndex + 1) / widget.questions.length,
                ),
                const SizedBox(height: 16),
                Text(
                  'Soal ${currentIndex + 1} dari ${widget.questions.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  currentQ.questionText,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),

                // Render Input Berdasarkan Tipe Soal
                Expanded(child: _buildAnswerInput(currentQ)),

                ElevatedButton(
                  onPressed: nextQuestion,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                  child: Text(currentIndex == widget.questions.length - 1 ? 'Selesai' : 'Lanjut'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          const WatermarkWidget(),
        ],
      ),
    );
  }

  Widget _buildAnswerInput(Question question) {
    switch (question.type) {
      case QuizType.singleChoice:
        return ListView.builder(
          itemCount: question.options!.length,
          itemBuilder: (context, index) {
            return RadioListTile<int>(
              title: Text(question.options![index]),
              value: index,
              groupValue: singleAnswerIndex,
              onChanged: (val) {
                setState(() => singleAnswerIndex = val);
              },
            );
          },
        );

      case QuizType.multipleChoice:
        return ListView.builder(
          itemCount: question.options!.length,
          itemBuilder: (context, index) {
            bool isChecked = multipleAnswerIndices.contains(index);
            return CheckboxListTile(
              title: Text(question.options![index]),
              value: isChecked,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    multipleAnswerIndices.add(index);
                  } else {
                    multipleAnswerIndices.remove(index);
                  }
                });
              },
            );
          },
        );

      case QuizType.textInput:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            controller: textController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Ketik jawaban Anda di sini',
            ),
          ),
        );
    }
  }
}

// -------------------------------------------------------------
// WATERMARK COMPONENT
// -------------------------------------------------------------
class WatermarkWidget extends StatelessWidget {
  const WatermarkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 12,
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          '© Create by Satria',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}
