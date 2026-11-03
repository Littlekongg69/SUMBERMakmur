import '../../core/utils/sql_sandbox_engine.dart';
import 'app_models.dart';

class SeedData {
  SeedData._();

  static const SandboxTable usersTable = SandboxTable(
    name: 'users',
    columns: ['id', 'name', 'age', 'role', 'city'],
    rows: [
      [1, 'John', 20, 'student', 'Jakarta'],
      [2, 'Kevin', 22, 'engineer', 'Bandung'],
      [3, 'Alex', 19, 'student', 'Surabaya'],
      [4, 'Rani', 21, 'analyst', 'Jakarta'],
      [5, 'Dimas', 24, 'engineer', 'Yogyakarta'],
    ],
  );

  static const SandboxTable recipesTable = SandboxTable(
    name: 'recipes',
    columns: ['id', 'dish_name', 'category', 'prep_minutes', 'calories'],
    rows: [
      [1, 'Nasi Goreng Spesial', 'Main', 20, 520],
      [2, 'Soto Ayam Lamongan', 'Soup', 35, 380],
      [3, 'Gado-Gado Siram', 'Salad', 15, 310],
      [4, 'Rendang Padang', 'Main', 120, 650],
      [5, 'Es Cendol Durian', 'Dessert', 10, 290],
    ],
  );

  static const SandboxTable ordersTable = SandboxTable(
    name: 'orders',
    columns: ['id', 'user_id', 'total_amount', 'status', 'order_date'],
    rows: [
      [101, 1, 150000, 'completed', '2026-10-01'],
      [102, 2, 275000, 'completed', '2026-10-02'],
      [103, 3, 85000, 'pending', '2026-10-03'],
      [104, 2, 420000, 'completed', '2026-10-05'],
      [105, 4, 190000, 'cancelled', '2026-10-06'],
    ],
  );

  static const SandboxTable employeesTable = SandboxTable(
    name: 'employees',
    columns: ['id', 'name', 'department', 'salary', 'hire_year'],
    rows: [
      [1, 'Sari', 'Engineering', 12000000, 2023],
      [2, 'Budi', 'Data', 15000000, 2022],
      [3, 'Citra', 'Engineering', 14500000, 2021],
      [4, 'Dedi', 'Product', 11000000, 2024],
      [5, 'Eka', 'Data', 16500000, 2020],
    ],
  );

  /// Bagian 37: >= 12 Lesson pada SQL Beginner (penuh) & SQL Intermediate (sebagian) + SQL Advanced
  static List<LearningPathModel> buildInitialPaths() {
    return [
      LearningPathModel(
        id: 'path-beginner',
        title: 'SQL Beginner',
        description:
            'Kuasai fondasi database relasional dan query PostgreSQL dari nol hingga mahir menyaring data.',
        difficulty: 'Beginner',
        estimatedMinutes: 180,
        xpReward: 300,
        unlockedByOnboarding: true,
        modules: [
          ModuleModel(
            id: 'mod-1',
            pathId: 'path-beginner',
            position: 1,
            title: 'Introduction to Database',
            description: 'Konsep tabel, baris, kolom, dan kunci utama di PostgreSQL.',
            estimatedMinutes: 25,
            lessons: [
              LessonModel(
                id: 'les-1',
                moduleId: 'mod-1',
                pathId: 'path-beginner',
                position: 1,
                title: 'Apa Itu Database Relasional?',
                description: 'Memahami struktur tabel, kolom (atribut), dan baris (record).',
                contentMarkdown: '''
### Mengenal Database Relasional (PostgreSQL)

Database relasional menyimpan data dalam bentuk **tabel** yang terdiri dari:
- **Kolom (Column)**: mendefinisikan atribut dan tipe data (contoh: `id`, `name`, `age`).
- **Baris (Row / Record)**: satu entitas data utuh di dalam tabel.
- **Primary Key**: pengenal unik untuk setiap baris (contoh: `id`).

Di SQLQuest, seluruh query dijalankan langsung di **PostgreSQL Sandbox** terisolasi sehingga kamu bebas bereksperimen dengan aman!
''',
                codeExamples: const [
                  'SELECT * FROM users;',
                  'SELECT name, city FROM users;',
                ],
                difficulty: 'Beginner',
                estimatedMinutes: 10,
                xpReward: 20,
                practicePrompt: 'Tampilkan seluruh kolom dan baris dari tabel users.',
                starterQuery: 'SELECT * FROM users;',
                referenceQuery: 'SELECT * FROM users;',
                sandboxTables: const [usersTable],
                expectedColumns: usersTable.columns,
                expectedRows: usersTable.rows,
                status: 'completed',
                hasExecutedQuery: true,
                hasPassedQuiz: true,
                quizQuestions: const [
                  QuizQuestionModel(
                    id: 'q-1',
                    question: 'Perintah SQL manakah yang digunakan untuk mengambil seluruh kolom dari tabel users?',
                    options: [
                      'SELECT * FROM users;',
                      'GET ALL FROM users;',
                      'FETCH users ALL;',
                      'EXTRACT * FROM users;',
                    ],
                    correctOptionIndex: 0,
                    explanation: 'Tanda bintang (*) pada SELECT * berarti memilih seluruh kolom dari tabel.',
                  ),
                ],
              ),
              LessonModel(
                id: 'les-2',
                moduleId: 'mod-1',
                pathId: 'path-beginner',
                position: 2,
                title: 'Tipe Data & Skema Tabel',
                description: 'Mengenal INTEGER, TEXT/VARCHAR, BOOLEAN, dan DATE di PostgreSQL.',
                contentMarkdown: '''
### Tipe Data Utama di PostgreSQL

Setiap kolom pada tabel PostgreSQL memiliki tipe data yang ketat:
1. `INTEGER` / `BIGINT`: angka bulat tanpa desimal (mis. `id`, `age`).
2. `TEXT` / `VARCHAR(n)`: teks atau string karakter (mis. `'Jakarta'`).
3. `NUMERIC` / `DECIMAL`: angka presisi tinggi.
4. `TIMESTAMPTZ` / `DATE`: tanggal dan waktu UTC.
''',
                codeExamples: const [
                  'SELECT id, name FROM users;',
                ],
                difficulty: 'Beginner',
                estimatedMinutes: 15,
                xpReward: 20,
                practicePrompt: 'Tampilkan hanya kolom id dan name dari tabel users.',
                starterQuery: 'SELECT id, name FROM users;',
                referenceQuery: 'SELECT id, name FROM users;',
                sandboxTables: const [usersTable],
                expectedColumns: const ['id', 'name'],
                expectedRows: const [
                  [1, 'John'],
                  [2, 'Kevin'],
                  [3, 'Alex'],
                  [4, 'Rani'],
                  [5, 'Dimas'],
                ],
                status: 'completed',
                hasExecutedQuery: true,
                hasPassedQuiz: true,
                quizQuestions: const [
                  QuizQuestionModel(
                    id: 'q-2',
                    question: 'Tipe data PostgreSQL untuk menyimpan angka bulat tanpa desimal adalah...',
                    options: ['INTEGER', 'VARCHAR', 'BOOLEAN', 'TEXT'],
                    correctOptionIndex: 0,
                    explanation: 'INTEGER digunakan untuk menyimpan bilangan bulat.',
                  ),
                ],
              ),
            ],
          ),
          ModuleModel(
            id: 'mod-2',
            pathId: 'path-beginner',
            position: 2,
            title: 'SQL Basics & SELECT',
            description: 'Memilih kolom spesifik, alias AS, dan DISTINCT.',
            estimatedMinutes: 30,
            prerequisiteModuleTitle: 'Introduction to Database',
            lessons: [
              LessonModel(
                id: 'les-3',
                moduleId: 'mod-2',
                pathId: 'path-beginner',
                position: 1,
                title: 'Memilih Kolom dengan SELECT',
                description: 'Mengambil kolom tertentu dari tabel menggunakan SELECT.',
                contentMarkdown: '''
### Klausa SELECT Spesifik

Daripada mengambil semua kolom dengan `*`, praktik terbaik di produksi adalah menyebutkan kolom yang dibutuhkan:
- Menghemat bandwidth jaringan dan memori.
- Membuat hasil query lebih jelas.

Contoh: `SELECT name, role FROM users;`
''',
                codeExamples: const [
                  'SELECT name, role FROM users;',
                  'SELECT dish_name, calories FROM recipes;',
                ],
                difficulty: 'Beginner',
                estimatedMinutes: 15,
                xpReward: 20,
                practicePrompt: 'Tampilkan kolom name dan role dari tabel users.',
                starterQuery: 'SELECT name, role FROM users;',
                referenceQuery: 'SELECT name, role FROM users;',
                sandboxTables: const [usersTable],
                expectedColumns: const ['name', 'role'],
                expectedRows: const [
                  ['John', 'student'],
                  ['Kevin', 'engineer'],
                  ['Alex', 'student'],
                  ['Rani', 'analyst'],
                  ['Dimas', 'engineer'],
                ],
                status: 'completed',
                hasExecutedQuery: true,
                hasPassedQuiz: true,
                quizQuestions: const [
                  QuizQuestionModel(
                    id: 'q-3',
                    question: 'Bagaimana cara memilih kolom name dan city saja dari tabel users?',
                    options: [
                      'SELECT name, city FROM users;',
                      'SELECT (name, city) IN users;',
                      'FROM users SELECT *;',
                      'PICK name, city FROM users;',
                    ],
                    correctOptionIndex: 0,
                    explanation: 'Pisahkan nama kolom dengan tanda koma setelah kata kunci SELECT.',
                  ),
                ],
              ),
              LessonModel(
                id: 'les-4',
                moduleId: 'mod-2',
                pathId: 'path-beginner',
                position: 2,
                title: 'Menghapus Duplikat dengan DISTINCT',
                description: 'Menampilkan nilai unik menggunakan SELECT DISTINCT.',
                contentMarkdown: '''
### SELECT DISTINCT

Sering kali sebuah kolom memiliki nilai yang berulang (misalnya beberapa pengguna tinggal di kota yang sama). Gunakan `SELECT DISTINCT` untuk mengambil nilai unik saja.
''',
                codeExamples: const [
                  'SELECT DISTINCT city FROM users;',
                  'SELECT DISTINCT role FROM users;',
                ],
                difficulty: 'Beginner',
                estimatedMinutes: 15,
                xpReward: 25,
                practicePrompt: 'Tampilkan daftar role yang unik (tanpa duplikat) dari tabel users.',
                starterQuery: 'SELECT DISTINCT role FROM users;',
                referenceQuery: 'SELECT DISTINCT role FROM users;',
                sandboxTables: const [usersTable],
                expectedColumns: const ['role'],
                expectedRows: const [
                  ['student'],
                  ['engineer'],
                  ['analyst'],
                ],
                status: 'completed',
                hasExecutedQuery: true,
                hasPassedQuiz: true,
                quizQuestions: const [
                  QuizQuestionModel(
                    id: 'q-4',
                    question: 'Kata kunci apa yang menghilangkan baris duplikat pada hasil SELECT?',
                    options: ['DISTINCT', 'UNIQUE', 'SINGLE', 'DIFFERENT'],
                    correctOptionIndex: 0,
                    explanation: 'SELECT DISTINCT mengembalikan hanya baris-baris yang unik.',
                  ),
                ],
              ),
            ],
          ),
          ModuleModel(
            id: 'mod-3',
            pathId: 'path-beginner',
            position: 3,
            title: 'Filtering dengan WHERE',
            description: 'Menyaring baris dengan operator perbandingan, AND, OR, dan LIKE.',
            estimatedMinutes: 35,
            prerequisiteModuleTitle: 'SQL Basics & SELECT',
            lessons: [
              LessonModel(
                id: 'les-5',
                moduleId: 'mod-3',
                pathId: 'path-beginner',
                position: 1,
                title: 'Operator Perbandingan di WHERE',
                description: 'Menyaring baris menggunakan =, >, <, >=, <=, dan !=.',
                contentMarkdown: '''
### Klausa WHERE

Klausa `WHERE` diletakkan setelah `FROM` untuk menyaring baris yang memenuhi kondisi tertentu:
- `=` : sama dengan
- `>` / `<` : lebih dari / kurang dari
- `>=` / `<=` : lebih dari atau sama dengan / kurang dari atau sama dengan
- `!=` atau `<>` : tidak sama dengan
''',
                codeExamples: const [
                  'SELECT * FROM users WHERE age > 20;',
                  "SELECT name, city FROM users WHERE city = 'Jakarta';",
                ],
                difficulty: 'Beginner',
                estimatedMinutes: 15,
                xpReward: 25,
                practicePrompt:
                    'Tampilkan seluruh kolom dari tabel users yang berusia lebih dari 20 tahun (age > 20).',
                starterQuery: 'SELECT * FROM users WHERE age > 20;',
                referenceQuery: 'SELECT * FROM users WHERE age > 20;',
                sandboxTables: const [usersTable],
                expectedColumns: usersTable.columns,
                expectedRows: const [
                  [2, 'Kevin', 22, 'engineer', 'Bandung'],
                  [4, 'Rani', 21, 'analyst', 'Jakarta'],
                  [5, 'Dimas', 24, 'engineer', 'Yogyakarta'],
                ],
                status: 'in_progress',
                hasExecutedQuery: false,
                hasPassedQuiz: false,
                quizQuestions: const [
                  QuizQuestionModel(
                    id: 'q-5',
                    question: 'Manakah query yang benar untuk mencari user dari kota Jakarta?',
                    options: [
                      "SELECT * FROM users WHERE city = 'Jakarta';",
                      'SELECT * FROM users WHERE city == Jakarta;',
                      "SELECT WHERE city = 'Jakarta' FROM users;",
                      "FILTER users BY city = 'Jakarta';",
                    ],
                    correctOptionIndex: 0,
                    explanation: 'String di SQL diapit tanda kutip tunggal dan dievaluasi dengan operator =.',
                  ),
                ],
              ),
              LessonModel(
                id: 'les-6',
                moduleId: 'mod-3',
                pathId: 'path-beginner',
                position: 2,
                title: 'Kombinasi Kondisi AND & OR',
                description: 'Menggabungkan beberapa syarat menggunakan logika AND dan OR.',
                contentMarkdown: '''
### Menggabungkan Kondisi dengan AND & OR

- **AND**: semua kondisi harus bernilai benar.
- **OR**: minimal satu kondisi bernilai benar.

Contoh:
`SELECT * FROM users WHERE role = 'engineer' AND age > 21;`
''',
                codeExamples: const [
                  "SELECT * FROM users WHERE role = 'engineer' AND age > 21;",
                ],
                difficulty: 'Beginner',
                estimatedMinutes: 20,
                xpReward: 25,
                practicePrompt:
                    "Tampilkan seluruh kolom dari tabel users dengan role = 'student' AND city = 'Jakarta'.",
                starterQuery:
                    "SELECT * FROM users WHERE role = 'student' AND city = 'Jakarta';",
                referenceQuery:
                    "SELECT * FROM users WHERE role = 'student' AND city = 'Jakarta';",
                sandboxTables: const [usersTable],
                expectedColumns: usersTable.columns,
                expectedRows: const [
                  [1, 'John', 20, 'student', 'Jakarta'],
                ],
                status: 'locked',
                quizQuestions: const [
                  QuizQuestionModel(
                    id: 'q-6',
                    question: 'Operator manakah yang mengharuskan KEDUA kondisi bernilai benar?',
                    options: ['AND', 'OR', 'NOT', 'BOTH'],
                    correctOptionIndex: 0,
                    explanation: 'Operator AND hanya mengembalikan baris jika semua kondisi terpenuhi.',
                  ),
                ],
              ),
            ],
          ),
          ModuleModel(
            id: 'mod-4',
            pathId: 'path-beginner',
            position: 4,
            title: 'Sorting & Limiting (ORDER BY, LIMIT)',
            description: 'Mengurutkan hasil query ASC/DESC dan membatasi jumlah baris.',
            estimatedMinutes: 30,
            prerequisiteModuleTitle: 'Filtering dengan WHERE',
            lessons: [
              LessonModel(
                id: 'les-7',
                moduleId: 'mod-4',
                pathId: 'path-beginner',
                position: 1,
                title: 'Mengurutkan Baris dengan ORDER BY',
                description: 'Mengurutkan data dari terkecil (ASC) atau terbesar (DESC).',
                contentMarkdown: '''
### ORDER BY (ASC & DESC)

Gunakan `ORDER BY nama_kolom [ASC|DESC]` untuk mengurutkan hasil query:
- `ASC` (default): urut naik (A-Z atau kecil ke besar).
- `DESC`: urut turun (Z-A atau besar ke kecil).
''',
                codeExamples: const [
                  'SELECT name, age FROM users ORDER BY age DESC;',
                ],
                difficulty: 'Beginner',
                estimatedMinutes: 15,
                xpReward: 25,
                practicePrompt:
                    'Tampilkan name dan age dari tabel users diurutkan berdasarkan age dari yang tertua (DESC).',
                starterQuery: 'SELECT name, age FROM users ORDER BY age DESC;',
                referenceQuery: 'SELECT name, age FROM users ORDER BY age DESC;',
                sandboxTables: const [usersTable],
                expectedColumns: const ['name', 'age'],
                expectedRows: const [
                  ['Dimas', 24],
                  ['Kevin', 22],
                  ['Rani', 21],
                  ['John', 20],
                  ['Alex', 19],
                ],
                status: 'locked',
                quizQuestions: const [
                  QuizQuestionModel(
                    id: 'q-7',
                    question: 'Kata kunci untuk mengurutkan hasil dari nilai terbesar ke terkecil adalah...',
                    options: ['DESC', 'ASC', 'TOP', 'DOWN'],
                    correctOptionIndex: 0,
                    explanation: 'DESC (Descending) mengurutkan nilai dari terbesar ke terkecil.',
                  ),
                ],
              ),
              LessonModel(
                id: 'les-8',
                moduleId: 'mod-4',
                pathId: 'path-beginner',
                position: 2,
                title: 'Membatasi Hasil dengan LIMIT',
                description: 'Mengambil N baris teratas menggunakan klausa LIMIT.',
                contentMarkdown: '''
### Klausa LIMIT

Saat tabel memiliki jutaan baris, gunakan `LIMIT n` di akhir query untuk mengambil hanya `n` baris pertama.
Sangat berguna jika dipadukan dengan `ORDER BY` untuk mencari Top-N!
''',
                codeExamples: const [
                  'SELECT name, age FROM users ORDER BY age DESC LIMIT 3;',
                ],
                difficulty: 'Beginner',
                estimatedMinutes: 15,
                xpReward: 30,
                practicePrompt:
                    'Tampilkan 3 baris pertama (seluruh kolom) dari tabel users menggunakan LIMIT 3.',
                starterQuery: 'SELECT * FROM users LIMIT 3;',
                referenceQuery: 'SELECT * FROM users LIMIT 3;',
                sandboxTables: const [usersTable],
                expectedColumns: usersTable.columns,
                expectedRows: const [
                  [1, 'John', 20, 'student', 'Jakarta'],
                  [2, 'Kevin', 22, 'engineer', 'Bandung'],
                  [3, 'Alex', 19, 'student', 'Surabaya'],
                ],
                status: 'locked',
                quizQuestions: const [
                  QuizQuestionModel(
                    id: 'q-8',
                    question: 'Dimanakah klausa LIMIT diletakkan pada query SELECT?',
                    options: [
                      'Di akhir query setelah ORDER BY',
                      'Sebelum kata kunci FROM',
                      'Di dalam klausa WHERE',
                      'Sebelum kata kunci SELECT',
                    ],
                    correctOptionIndex: 0,
                    explanation: 'Urutan standar SQL adalah SELECT -> FROM -> WHERE -> ORDER BY -> LIMIT.',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      LearningPathModel(
        id: 'path-intermediate',
        title: 'SQL Intermediate',
        description:
            'Kuasai agregasi COUNT/SUM/AVG, GROUP BY, HAVING, relasi antar tabel dengan JOIN, serta Subquery.',
        difficulty: 'Intermediate',
        estimatedMinutes: 240,
        xpReward: 450,
        prerequisitePathId: 'path-beginner',
        prerequisiteTitle: 'SQL Beginner',
        unlockedByOnboarding: false,
        modules: [
          ModuleModel(
            id: 'mod-5',
            pathId: 'path-intermediate',
            position: 1,
            title: 'Agregasi & GROUP BY',
            description: 'Menghitung ringkasan data dengan COUNT, SUM, AVG, dan GROUP BY.',
            estimatedMinutes: 45,
            lessons: [
              LessonModel(
                id: 'les-9',
                moduleId: 'mod-5',
                pathId: 'path-intermediate',
                position: 1,
                title: 'Fungsi Agregat COUNT',
                description: 'Menghitung total baris menggunakan fungsi COUNT(*).',
                contentMarkdown: '''
### Fungsi Agregat di PostgreSQL

Fungsi agregat merangkum banyak baris menjadi satu nilai:
- `COUNT(*)` : menghitung jumlah total baris
- `SUM(kolom)` : menjumlahkan nilai numerik
- `AVG(kolom)` : menghitung rata-rata
- `MIN(kolom)` / `MAX(kolom)` : mencari nilai terkecil / terbesar
''',
                codeExamples: const [
                  'SELECT COUNT(*) FROM users;',
                  "SELECT COUNT(*) FROM orders WHERE status = 'completed';",
                ],
                difficulty: 'Intermediate',
                estimatedMinutes: 20,
                xpReward: 25,
                practicePrompt: 'Hitung jumlah total baris di tabel users menggunakan COUNT(*).',
                starterQuery: 'SELECT COUNT(*) FROM users;',
                referenceQuery: 'SELECT COUNT(*) FROM users;',
                sandboxTables: const [usersTable],
                expectedColumns: const ['count'],
                expectedRows: const [
                  [5],
                ],
                status: 'available',
                quizQuestions: const [
                  QuizQuestionModel(
                    id: 'q-9',
                    question: 'Fungsi agregat manakah yang menghitung jumlah baris dalam tabel?',
                    options: ['COUNT(*)', 'TOTAL(*)', 'NUMBER(*)', 'LEN(*)'],
                    correctOptionIndex: 0,
                    explanation: 'COUNT(*) menghitung seluruh baris hasil query.',
                  ),
                ],
              ),
              LessonModel(
                id: 'les-10',
                moduleId: 'mod-5',
                pathId: 'path-intermediate',
                position: 2,
                title: 'Mengelompokkan Data & Filter HAVING',
                description: 'Menggunakan GROUP BY dan menyaring agregasi dengan HAVING.',
                contentMarkdown: '''
### GROUP BY & HAVING

- `GROUP BY` mengelompokkan baris yang memiliki nilai kolom yang sama.
- `HAVING` menyaring hasil setelah pengelompokan (berbeda dengan `WHERE` yang menyaring sebelum dikelompokkan).
''',
                codeExamples: const [
                  'SELECT department, salary FROM employees WHERE salary > 13000000;',
                ],
                difficulty: 'Intermediate',
                estimatedMinutes: 25,
                xpReward: 30,
                practicePrompt:
                    'Tampilkan name dan salary dari tabel employees yang memiliki salary > 13000000.',
                starterQuery:
                    'SELECT name, salary FROM employees WHERE salary > 13000000;',
                referenceQuery:
                    'SELECT name, salary FROM employees WHERE salary > 13000000;',
                sandboxTables: const [employeesTable],
                expectedColumns: const ['name', 'salary'],
                expectedRows: const [
                  ['Budi', 15000000],
                  ['Citra', 14500000],
                  ['Eka', 16500000],
                ],
                status: 'locked',
                quizQuestions: const [
                  QuizQuestionModel(
                    id: 'q-10',
                    question: 'Klausa apa yang digunakan untuk memfilter hasil fungsi agregat setelah GROUP BY?',
                    options: ['HAVING', 'WHERE', 'FILTER', 'GROUP FILTER'],
                    correctOptionIndex: 0,
                    explanation: 'HAVING memfilter kelompok hasil GROUP BY.',
                  ),
                ],
              ),
            ],
          ),
          ModuleModel(
            id: 'mod-6',
            pathId: 'path-intermediate',
            position: 2,
            title: 'JOIN & Relasi Tabel',
            description: 'Menggabungkan tabel menggunakan INNER JOIN dan LEFT JOIN.',
            estimatedMinutes: 45,
            prerequisiteModuleTitle: 'Agregasi & GROUP BY',
            lessons: [
              LessonModel(
                id: 'les-11',
                moduleId: 'mod-6',
                pathId: 'path-intermediate',
                position: 1,
                title: 'Menggabungkan Tabel & Foreign Key',
                description: 'Memahami relasi user_id pada tabel orders.',
                contentMarkdown: '''
### Relasi Foreign Key & INNER JOIN

Dalam database relasional, tabel `orders` menyimpan `user_id` yang merujuk ke `users.id`.
Dengan `INNER JOIN`, kita dapat menyandingkan pesanan dengan nama pemiliknya.
''',
                codeExamples: const [
                  "SELECT id, total_amount FROM orders WHERE status = 'completed';",
                ],
                difficulty: 'Intermediate',
                estimatedMinutes: 20,
                xpReward: 30,
                practicePrompt:
                    "Tampilkan id dan total_amount dari tabel orders yang berstatus 'completed'.",
                starterQuery:
                    "SELECT id, total_amount FROM orders WHERE status = 'completed';",
                referenceQuery:
                    "SELECT id, total_amount FROM orders WHERE status = 'completed';",
                sandboxTables: const [ordersTable],
                expectedColumns: const ['id', 'total_amount'],
                expectedRows: const [
                  [101, 150000],
                  [102, 275000],
                  [104, 420000],
                ],
                status: 'locked',
                quizQuestions: const [
                  QuizQuestionModel(
                    id: 'q-11',
                    question: 'Jenis JOIN yang hanya mengembalikan baris yang cocok di kedua tabel adalah...',
                    options: ['INNER JOIN', 'LEFT JOIN', 'FULL JOIN', 'CROSS JOIN'],
                    correctOptionIndex: 0,
                    explanation: 'INNER JOIN mengembalikan irisan baris yang cocok pada kedua tabel.',
                  ),
                ],
              ),
              LessonModel(
                id: 'les-12',
                moduleId: 'mod-6',
                pathId: 'path-intermediate',
                position: 2,
                title: 'Subquery & Analisis Lanjutan',
                description: 'Menulis query di dalam query untuk filter dinamis.',
                contentMarkdown: '''
### Subquery di PostgreSQL

Subquery adalah query `SELECT` yang disisipkan di dalam klausa `WHERE`, `FROM`, atau `SELECT` lainnya untuk evaluasi bertingkat.
''',
                codeExamples: const [
                  'SELECT * FROM orders WHERE total_amount > 200000;',
                ],
                difficulty: 'Intermediate',
                estimatedMinutes: 25,
                xpReward: 30,
                practicePrompt:
                    'Tampilkan seluruh kolom dari tabel orders dengan total_amount > 200000.',
                starterQuery:
                    'SELECT * FROM orders WHERE total_amount > 200000;',
                referenceQuery:
                    'SELECT * FROM orders WHERE total_amount > 200000;',
                sandboxTables: const [ordersTable],
                expectedColumns: ordersTable.columns,
                expectedRows: const [
                  [102, 2, 275000, 'completed', '2026-10-02'],
                  [104, 2, 420000, 'completed', '2026-10-05'],
                ],
                status: 'locked',
                quizQuestions: const [
                  QuizQuestionModel(
                    id: 'q-12',
                    question: 'Tanda kurung apa yang wajib membungkus sebuah subquery di SQL?',
                    options: ['( ... )', '{ ... }', '[ ... ]', '< ... >'],
                    correctOptionIndex: 0,
                    explanation: 'Subquery selalu ditulis di dalam tanda kurung biasa ( ).',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      LearningPathModel(
        id: 'path-advanced',
        title: 'SQL Advanced',
        description:
            'Kuasai CTE (WITH), Window Function (ROW_NUMBER, RANK), Transaction, Index, dan Query Optimization.',
        difficulty: 'Advanced',
        estimatedMinutes: 300,
        xpReward: 600,
        prerequisitePathId: 'path-intermediate',
        prerequisiteTitle: 'SQL Intermediate',
        unlockedByOnboarding: false,
        modules: [
          ModuleModel(
            id: 'mod-7',
            pathId: 'path-advanced',
            position: 1,
            title: 'CTE & Window Functions',
            description: 'Menulis query modular dengan WITH dan analisis ranking.',
            estimatedMinutes: 60,
            lessons: [
              LessonModel(
                id: 'les-13',
                moduleId: 'mod-7',
                pathId: 'path-advanced',
                position: 1,
                title: 'Common Table Expressions (WITH)',
                description: 'Menyederhanakan query kompleks menggunakan klausa WITH.',
                contentMarkdown: '''
### Common Table Expressions (CTE)

CTE memungkinkan kamu mendefinisikan tabel sementara bernama menggunakan klausa `WITH` sebelum `SELECT` utama.
''',
                codeExamples: const [
                  'WITH senior_emp AS (SELECT * FROM employees WHERE hire_year <= 2022) SELECT name, salary FROM employees WHERE hire_year <= 2022;',
                ],
                difficulty: 'Advanced',
                estimatedMinutes: 30,
                xpReward: 30,
                practicePrompt:
                    'Tampilkan name dan salary dari tabel employees yang direkrut pada atau sebelum tahun 2022 (hire_year <= 2022).',
                starterQuery:
                    'SELECT name, salary FROM employees WHERE hire_year <= 2022;',
                referenceQuery:
                    'SELECT name, salary FROM employees WHERE hire_year <= 2022;',
                sandboxTables: const [employeesTable],
                expectedColumns: const ['name', 'salary'],
                expectedRows: const [
                  ['Budi', 15000000],
                  ['Citra', 14500000],
                  ['Eka', 16500000],
                ],
                status: 'locked',
                quizQuestions: const [
                  QuizQuestionModel(
                    id: 'q-13',
                    question: 'Kata kunci untuk mengawali Common Table Expression (CTE) adalah...',
                    options: ['WITH', 'LET', 'TEMP', 'DEFINE'],
                    correctOptionIndex: 0,
                    explanation: 'Klausa WITH digunakan untuk mendeklarasikan CTE.',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ];
  }

  /// Bagian 37 & Bagian 14: >= 20 SQL Challenges mencakup Easy (Mode Blok "SQL Cooking Quest" & Both), Medium, Hard, Expert
  static List<SqlChallengeModel> buildInitialChallenges() {
    return [
      // 1. Easy - SQL Cooking Quest (Mode Blok sesuai Mockup Bagian 14)
      SqlChallengeModel(
        id: 'chal-1',
        title: 'Resep Cepat Saji Dapur Nusantara',
        description:
            'Bantu Chef Rani menemukan hidangan yang cepat dimasak di bawah 25 menit!',
        storyTheme: 'SQL Cooking Quest',
        questContext: 'SQL Cooking Quest · Misi #1 · Modul SELECT & WHERE',
        objective:
            'Susun query untuk menampilkan seluruh kolom (*) dari tabel recipes yang memiliki prep_minutes < 25.',
        difficulty: 'Easy',
        inputMode: 'both',
        xpReward: 20,
        maxAttempts: null, // Easy: tak terbatas (visual 5 hati)
        tables: const [recipesTable],
        schemaDdl:
            'CREATE TABLE recipes (id INT PRIMARY KEY, dish_name TEXT, category TEXT, prep_minutes INT, calories INT);',
        referenceQuery: 'SELECT * FROM recipes WHERE prep_minutes < 25;',
        expectedColumns: recipesTable.columns,
        expectedRows: const [
          [1, 'Nasi Goreng Spesial', 'Main', 20, 520],
          [3, 'Gado-Gado Siram', 'Salad', 15, 310],
          [5, 'Es Cendol Durian', 'Dessert', 10, 290],
        ],
        hints: const [
          'Awali query dengan SELECT * FROM diikuti nama tabel recipes.',
          'Gunakan klausa WHERE untuk menyaring kolom prep_minutes.',
          'Gunakan operator < 25 dan akhiri dengan tanda titik koma (;).',
        ],
        explanation:
            'SELECT * FROM recipes WHERE prep_minutes < 25; menyaring baris pada tabel recipes yang waktu persiapannya kurang dari 25 menit.',
        targetSlotCount: 8,
        blockSet: const [
          SqlBlockItem(id: 'b1', text: 'SELECT', type: SqlBlockType.keyword),
          SqlBlockItem(id: 'b2', text: '*', type: SqlBlockType.column),
          SqlBlockItem(id: 'b3', text: 'FROM', type: SqlBlockType.keyword),
          SqlBlockItem(id: 'b4', text: 'recipes', type: SqlBlockType.table),
          SqlBlockItem(id: 'b5', text: 'WHERE', type: SqlBlockType.keyword),
          SqlBlockItem(id: 'b6', text: 'prep_minutes', type: SqlBlockType.column),
          SqlBlockItem(id: 'b7', text: '< 25', type: SqlBlockType.operatorType),
          SqlBlockItem(id: 'b8', text: ';', type: SqlBlockType.closing),
          SqlBlockItem(
            id: 'b9',
            text: 'calories',
            type: SqlBlockType.column,
            isDistractor: true,
          ),
          SqlBlockItem(
            id: 'b10',
            text: '> 100',
            type: SqlBlockType.operatorType,
            isDistractor: true,
          ),
        ],
      ),

      // 2. Easy - Contoh PRD Bagian 19 (users WHERE age > 20)
      SqlChallengeModel(
        id: 'chal-2',
        title: 'Filter Pengguna di Atas 20 Tahun',
        description:
            'Tampilkan seluruh pengguna yang berusia lebih dari 20 tahun.',
        storyTheme: 'SQL Cooking Quest',
        questContext: 'SQL Quest · Misi #2 · Modul WHERE',
        objective:
            'Tampilkan seluruh kolom (*) dari tabel users yang berusia lebih dari 20 tahun (age > 20).',
        difficulty: 'Easy',
        inputMode: 'both',
        xpReward: 20,
        maxAttempts: null,
        tables: const [usersTable],
        schemaDdl:
            'CREATE TABLE users (id INT PRIMARY KEY, name TEXT, age INT, role TEXT, city TEXT);',
        referenceQuery: 'SELECT * FROM users WHERE age > 20;',
        expectedColumns: usersTable.columns,
        expectedRows: const [
          [2, 'Kevin', 22, 'engineer', 'Bandung'],
          [4, 'Rani', 21, 'analyst', 'Jakarta'],
          [5, 'Dimas', 24, 'engineer', 'Yogyakarta'],
        ],
        hints: const [
          'Gunakan SELECT * FROM users untuk memilih semua kolom.',
          'Tambahkan klausa WHERE age > 20.',
          'Query lengkap: SELECT * FROM users WHERE age > 20;',
        ],
        explanation:
            'Klausa WHERE age > 20 menyaring hanya baris dengan nilai kolom age di atas 20.',
        targetSlotCount: 8,
        blockSet: const [
          SqlBlockItem(id: 'u1', text: 'SELECT', type: SqlBlockType.keyword),
          SqlBlockItem(id: 'u2', text: '*', type: SqlBlockType.column),
          SqlBlockItem(id: 'u3', text: 'FROM', type: SqlBlockType.keyword),
          SqlBlockItem(id: 'u4', text: 'users', type: SqlBlockType.table),
          SqlBlockItem(id: 'u5', text: 'WHERE', type: SqlBlockType.keyword),
          SqlBlockItem(id: 'u6', text: 'age', type: SqlBlockType.column),
          SqlBlockItem(id: 'u7', text: '> 20', type: SqlBlockType.operatorType),
          SqlBlockItem(id: 'u8', text: ';', type: SqlBlockType.closing),
          SqlBlockItem(
            id: 'u9',
            text: '< 20',
            type: SqlBlockType.operatorType,
            isDistractor: true,
          ),
          SqlBlockItem(
            id: 'u10',
            text: 'orders',
            type: SqlBlockType.table,
            isDistractor: true,
          ),
        ],
        isCompleted: true,
      ),

      // 3. Easy - SQL Cooking Quest #2
      SqlChallengeModel(
        id: 'chal-3',
        title: 'Daftar Nama Hidangan & Kalori',
        description: 'Chef ingin mencetak buku menu berisi nama masakan dan kalorinya saja.',
        storyTheme: 'SQL Cooking Quest',
        questContext: 'SQL Cooking Quest · Misi #3 · Modul SELECT',
        objective: 'Tampilkan kolom dish_name dan calories dari tabel recipes.',
        difficulty: 'Easy',
        inputMode: 'both',
        xpReward: 20,
        tables: const [recipesTable],
        schemaDdl:
            'CREATE TABLE recipes (id INT PRIMARY KEY, dish_name TEXT, category TEXT, prep_minutes INT, calories INT);',
        referenceQuery: 'SELECT dish_name, calories FROM recipes;',
        expectedColumns: const ['dish_name', 'calories'],
        expectedRows: const [
          ['Nasi Goreng Spesial', 520],
          ['Soto Ayam Lamongan', 380],
          ['Gado-Gado Siram', 310],
          ['Rendang Padang', 650],
          ['Es Cendol Durian', 290],
        ],
        hints: const [
          'Sebutkan kedua kolom dipisahkan koma setelah SELECT.',
          'Gunakan FROM recipes di akhir klausa.',
        ],
        explanation: 'SELECT dish_name, calories FROM recipes; memilih hanya dua kolom yang diminta.',
        targetSlotCount: 5,
        blockSet: const [
          SqlBlockItem(id: 'c3_1', text: 'SELECT', type: SqlBlockType.keyword),
          SqlBlockItem(id: 'c3_2', text: 'dish_name, calories', type: SqlBlockType.column),
          SqlBlockItem(id: 'c3_3', text: 'FROM', type: SqlBlockType.keyword),
          SqlBlockItem(id: 'c3_4', text: 'recipes', type: SqlBlockType.table),
          SqlBlockItem(id: 'c3_5', text: ';', type: SqlBlockType.closing),
          SqlBlockItem(id: 'c3_6', text: '*', type: SqlBlockType.column, isDistractor: true),
        ],
      ),

      // 4. Easy - Filter Kota Jakarta
      SqlChallengeModel(
        id: 'chal-4',
        title: 'Komunitas Pembelajar Jakarta',
        description: 'Temukan semua anggota komunitas yang berdomisili di Jakarta.',
        storyTheme: 'Community Quest',
        questContext: 'Misi #4 · Modul WHERE',
        objective: "Tampilkan seluruh kolom (*) dari tabel users yang memiliki city = 'Jakarta'.",
        difficulty: 'Easy',
        inputMode: 'both',
        xpReward: 20,
        tables: const [usersTable],
        schemaDdl: 'CREATE TABLE users (id INT, name TEXT, age INT, role TEXT, city TEXT);',
        referenceQuery: "SELECT * FROM users WHERE city = 'Jakarta';",
        expectedColumns: usersTable.columns,
        expectedRows: const [
          [1, 'John', 20, 'student', 'Jakarta'],
          [4, 'Rani', 21, 'analyst', 'Jakarta'],
        ],
        hints: const [
          "Gunakan tanda kutip tunggal untuk teks 'Jakarta'.",
          "Tulis WHERE city = 'Jakarta'.",
        ],
        explanation: "String literal pada PostgreSQL wajib memakai kutip tunggal ('Jakarta').",
        targetSlotCount: 8,
        blockSet: const [
          SqlBlockItem(id: 'c4_1', text: 'SELECT', type: SqlBlockType.keyword),
          SqlBlockItem(id: 'c4_2', text: '*', type: SqlBlockType.column),
          SqlBlockItem(id: 'c4_3', text: 'FROM', type: SqlBlockType.keyword),
          SqlBlockItem(id: 'c4_4', text: 'users', type: SqlBlockType.table),
          SqlBlockItem(id: 'c4_5', text: 'WHERE', type: SqlBlockType.keyword),
          SqlBlockItem(id: 'c4_6', text: 'city', type: SqlBlockType.column),
          SqlBlockItem(id: 'c4_7', text: "= 'Jakarta'", type: SqlBlockType.operatorType),
          SqlBlockItem(id: 'c4_8', text: ';', type: SqlBlockType.closing),
          SqlBlockItem(id: 'c4_9', text: "= 'Bandung'", type: SqlBlockType.operatorType, isDistractor: true),
        ],
      ),

      // 5. Easy - Menu Rendah Kalori
      SqlChallengeModel(
        id: 'chal-5',
        title: 'Menu Sehat Rendah Kalori',
        description: 'Saring menu di tabel recipes yang kalorinya tidak lebih dari 400.',
        storyTheme: 'SQL Cooking Quest',
        questContext: 'SQL Cooking Quest · Misi #5 · Modul WHERE',
        objective: 'Tampilkan seluruh kolom (*) dari tabel recipes dengan calories <= 400.',
        difficulty: 'Easy',
        inputMode: 'both',
        xpReward: 20,
        tables: const [recipesTable],
        schemaDdl: 'CREATE TABLE recipes (id INT, dish_name TEXT, category TEXT, prep_minutes INT, calories INT);',
        referenceQuery: 'SELECT * FROM recipes WHERE calories <= 400;',
        expectedColumns: recipesTable.columns,
        expectedRows: const [
          [2, 'Soto Ayam Lamongan', 'Soup', 35, 380],
          [3, 'Gado-Gado Siram', 'Salad', 15, 310],
          [5, 'Es Cendol Durian', 'Dessert', 10, 290],
        ],
        hints: const ['Gunakan operator <= 400 pada kolom calories.'],
        explanation: 'Operator <= menyertakan nilai batas 400 dan semua nilai di bawahnya.',
        targetSlotCount: 8,
        blockSet: const [
          SqlBlockItem(id: 'c5_1', text: 'SELECT', type: SqlBlockType.keyword),
          SqlBlockItem(id: 'c5_2', text: '*', type: SqlBlockType.column),
          SqlBlockItem(id: 'c5_3', text: 'FROM', type: SqlBlockType.keyword),
          SqlBlockItem(id: 'c5_4', text: 'recipes', type: SqlBlockType.table),
          SqlBlockItem(id: 'c5_5', text: 'WHERE', type: SqlBlockType.keyword),
          SqlBlockItem(id: 'c5_6', text: 'calories', type: SqlBlockType.column),
          SqlBlockItem(id: 'c5_7', text: '<= 400', type: SqlBlockType.operatorType),
          SqlBlockItem(id: 'c5_8', text: ';', type: SqlBlockType.closing),
        ],
      ),

      // 6. Easy - Kota Unik Pengguna
      SqlChallengeModel(
        id: 'chal-6',
        title: 'Daftar Kota Unik',
        description: 'Tampilkan daftar nama kota tempat tinggal user tanpa duplikasi.',
        storyTheme: 'Community Quest',
        questContext: 'Misi #6 · Modul DISTINCT',
        objective: 'Tampilkan kolom city secara unik (DISTINCT) dari tabel users.',
        difficulty: 'Easy',
        inputMode: 'both',
        xpReward: 20,
        tables: const [usersTable],
        schemaDdl: 'CREATE TABLE users (id INT, name TEXT, age INT, role TEXT, city TEXT);',
        referenceQuery: 'SELECT DISTINCT city FROM users;',
        expectedColumns: const ['city'],
        expectedRows: const [
          ['Jakarta'],
          ['Bandung'],
          ['Surabaya'],
          ['Yogyakarta'],
        ],
        hints: const ['Gunakan SELECT DISTINCT city FROM users;'],
        explanation: 'DISTINCT mengeliminasi duplikat kota Jakarta sehingga tampil satu kali.',
        targetSlotCount: 6,
        blockSet: const [
          SqlBlockItem(id: 'c6_1', text: 'SELECT', type: SqlBlockType.keyword),
          SqlBlockItem(id: 'c6_2', text: 'DISTINCT', type: SqlBlockType.keyword),
          SqlBlockItem(id: 'c6_3', text: 'city', type: SqlBlockType.column),
          SqlBlockItem(id: 'c6_4', text: 'FROM', type: SqlBlockType.keyword),
          SqlBlockItem(id: 'c6_5', text: 'users', type: SqlBlockType.table),
          SqlBlockItem(id: 'c6_6', text: ';', type: SqlBlockType.closing),
        ],
      ),

      // 7. Easy - Hitung Total Resep
      SqlChallengeModel(
        id: 'chal-7',
        title: 'Total Koleksi Resep Nusantara',
        description: 'Hitung ada berapa resep yang tersimpan di tabel recipes.',
        storyTheme: 'SQL Cooking Quest',
        questContext: 'SQL Cooking Quest · Misi #7 · Modul COUNT',
        objective: 'Hitung jumlah total baris pada tabel recipes menggunakan COUNT(*).',
        difficulty: 'Easy',
        inputMode: 'both',
        xpReward: 20,
        tables: const [recipesTable],
        schemaDdl: 'CREATE TABLE recipes (id INT, dish_name TEXT, category TEXT, prep_minutes INT, calories INT);',
        referenceQuery: 'SELECT COUNT(*) FROM recipes;',
        expectedColumns: const ['count'],
        expectedRows: const [
          [5],
        ],
        hints: const ['Gunakan SELECT COUNT(*) FROM recipes;'],
        explanation: 'COUNT(*) menghitung seluruh baris yang ada di tabel recipes.',
        targetSlotCount: 5,
        blockSet: const [
          SqlBlockItem(id: 'c7_1', text: 'SELECT', type: SqlBlockType.keyword),
          SqlBlockItem(id: 'c7_2', text: 'COUNT(*)', type: SqlBlockType.column),
          SqlBlockItem(id: 'c7_3', text: 'FROM', type: SqlBlockType.keyword),
          SqlBlockItem(id: 'c7_4', text: 'recipes', type: SqlBlockType.table),
          SqlBlockItem(id: 'c7_5', text: ';', type: SqlBlockType.closing),
        ],
      ),

      // 8. Medium - Urutan Gaji Tertinggi
      SqlChallengeModel(
        id: 'chal-8',
        title: 'Daftar Gaji Karyawan Tertinggi',
        description: 'Urutkan seluruh karyawan dari gaji terbesar ke terkecil.',
        storyTheme: 'Enterprise Data Quest',
        questContext: 'Misi #8 · Modul ORDER BY',
        objective: 'Tampilkan name, department, dan salary dari tabel employees diurutkan berdasarkan salary DESC.',
        difficulty: 'Medium',
        inputMode: 'text',
        xpReward: 40,
        maxAttempts: 10,
        ordered: true,
        tables: const [employeesTable],
        schemaDdl: 'CREATE TABLE employees (id INT, name TEXT, department TEXT, salary INT, hire_year INT);',
        referenceQuery: 'SELECT name, department, salary FROM employees ORDER BY salary DESC;',
        expectedColumns: const ['name', 'department', 'salary'],
        expectedRows: const [
          ['Eka', 'Data', 16500000],
          ['Budi', 'Data', 15000000],
          ['Citra', 'Engineering', 14500000],
          ['Sari', 'Engineering', 12000000],
          ['Dedi', 'Product', 11000000],
        ],
        hints: const [
          'Pilih kolom name, department, salary dari employees.',
          'Tambahkan ORDER BY salary DESC di akhir query.',
        ],
        explanation: 'ORDER BY salary DESC mengurutkan karyawan dari gaji tertinggi ke terendah.',
      ),

      // 9. Medium - Top 3 Pesanan Terbesar
      SqlChallengeModel(
        id: 'chal-9',
        title: 'Top 3 Transaksi Pesanan Terbesar',
        description: 'Temukan 3 pesanan dengan nominal total_amount tertinggi.',
        storyTheme: 'E-Commerce Quest',
        questContext: 'Misi #9 · Modul ORDER BY & LIMIT',
        objective: 'Tampilkan id dan total_amount dari tabel orders diurutkan berdasarkan total_amount DESC dan dibatasi 3 baris (LIMIT 3).',
        difficulty: 'Medium',
        inputMode: 'text',
        xpReward: 40,
        maxAttempts: 10,
        ordered: true,
        tables: const [ordersTable],
        schemaDdl: 'CREATE TABLE orders (id INT, user_id INT, total_amount INT, status TEXT, order_date TEXT);',
        referenceQuery: 'SELECT id, total_amount FROM orders ORDER BY total_amount DESC LIMIT 3;',
        expectedColumns: const ['id', 'total_amount'],
        expectedRows: const [
          [104, 420000],
          [102, 275000],
          [105, 190000],
        ],
        hints: const [
          'Urutkan dengan ORDER BY total_amount DESC.',
          'Batasi hasil menjadi 3 baris dengan LIMIT 3.',
        ],
        explanation: 'Kombinasi ORDER BY ... DESC LIMIT 3 adalah pola standar untuk mencari Top-3.',
      ),

      // 10. Medium - Filter Karyawan Engineering
      SqlChallengeModel(
        id: 'chal-10',
        title: 'Tim Engineering Senior',
        description: 'Cari anggota tim Engineering dengan gaji di atas 13 juta.',
        storyTheme: 'Enterprise Data Quest',
        questContext: 'Misi #10 · Modul WHERE AND',
        objective: "Tampilkan seluruh kolom (*) dari tabel employees dengan department = 'Engineering' AND salary > 13000000.",
        difficulty: 'Medium',
        inputMode: 'text',
        xpReward: 40,
        maxAttempts: 10,
        tables: const [employeesTable],
        schemaDdl: 'CREATE TABLE employees (id INT, name TEXT, department TEXT, salary INT, hire_year INT);',
        referenceQuery: "SELECT * FROM employees WHERE department = 'Engineering' AND salary > 13000000;",
        expectedColumns: employeesTable.columns,
        expectedRows: const [
          [3, 'Citra', 'Engineering', 14500000, 2021],
        ],
        hints: const [
          "Gunakan WHERE department = 'Engineering' AND salary > 13000000.",
        ],
        explanation: 'Operator AND memastikan kedua syarat departemen dan gaji terpenuhi.',
      ),

      // 11. Medium - Pesanan Selesai di Atas 200 Ribu
      SqlChallengeModel(
        id: 'chal-11',
        title: 'Audit Pesanan Completed Bernilai Tinggi',
        description: 'Tim keuangan membutuhkan daftar pesanan completed di atas Rp200.000.',
        storyTheme: 'E-Commerce Quest',
        questContext: 'Misi #11 · Modul WHERE',
        objective: "Tampilkan id, user_id, dan total_amount dari tabel orders yang berstatus 'completed' AND total_amount > 200000.",
        difficulty: 'Medium',
        inputMode: 'text',
        xpReward: 40,
        maxAttempts: 10,
        tables: const [ordersTable],
        schemaDdl: 'CREATE TABLE orders (id INT, user_id INT, total_amount INT, status TEXT, order_date TEXT);',
        referenceQuery: "SELECT id, user_id, total_amount FROM orders WHERE status = 'completed' AND total_amount > 200000;",
        expectedColumns: const ['id', 'user_id', 'total_amount'],
        expectedRows: const [
          [102, 2, 275000],
          [104, 2, 420000],
        ],
        hints: const [
          "Pilih kolom id, user_id, total_amount dari tabel orders.",
          "Saring dengan WHERE status = 'completed' AND total_amount > 200000.",
        ],
        explanation: 'Menyaring pesanan yang sudah selesai sekaligus bernilai di atas 200.000.',
      ),

      // 12. Medium - Pencarian Pola LIKE
      SqlChallengeModel(
        id: 'chal-12',
        title: 'Pencarian Menu Nasi dengan LIKE',
        description: 'Cari semua hidangan di tabel recipes yang diawali kata Nasi.',
        storyTheme: 'SQL Cooking Quest',
        questContext: 'Misi #12 · Modul LIKE',
        objective: "Tampilkan seluruh kolom (*) dari tabel recipes yang dish_name LIKE 'Nasi%'.",
        difficulty: 'Medium',
        inputMode: 'text',
        xpReward: 40,
        maxAttempts: 10,
        tables: const [recipesTable],
        schemaDdl: 'CREATE TABLE recipes (id INT, dish_name TEXT, category TEXT, prep_minutes INT, calories INT);',
        referenceQuery: "SELECT * FROM recipes WHERE dish_name LIKE 'Nasi%';",
        expectedColumns: recipesTable.columns,
        expectedRows: const [
          [1, 'Nasi Goreng Spesial', 'Main', 20, 520],
        ],
        hints: const [
          "Gunakan operator LIKE 'Nasi%' pada kolom dish_name.",
        ],
        explanation: "Wildcard % pada 'Nasi%' mencocokkan teks apa pun setelah kata Nasi.",
      ),

      // 13. Medium - Urutan Masakan Tercepat
      SqlChallengeModel(
        id: 'chal-13',
        title: 'Urutan Masakan Tercepat ke Terlama',
        description: 'Urutkan hidangan berdasarkan waktu persiapan paling singkat.',
        storyTheme: 'SQL Cooking Quest',
        questContext: 'Misi #13 · Modul ORDER BY ASC',
        objective: 'Tampilkan dish_name dan prep_minutes dari tabel recipes diurutkan berdasarkan prep_minutes ASC.',
        difficulty: 'Medium',
        inputMode: 'text',
        xpReward: 40,
        maxAttempts: 10,
        ordered: true,
        tables: const [recipesTable],
        schemaDdl: 'CREATE TABLE recipes (id INT, dish_name TEXT, category TEXT, prep_minutes INT, calories INT);',
        referenceQuery: 'SELECT dish_name, prep_minutes FROM recipes ORDER BY prep_minutes ASC;',
        expectedColumns: const ['dish_name', 'prep_minutes'],
        expectedRows: const [
          ['Es Cendol Durian', 10],
          ['Gado-Gado Siram', 15],
          ['Nasi Goreng Spesial', 20],
          ['Soto Ayam Lamongan', 35],
          ['Rendang Padang', 120],
        ],
        hints: const ['Gunakan ORDER BY prep_minutes ASC.'],
        explanation: 'ORDER BY prep_minutes ASC mengurutkan dari nilai terkecil ke terbesar.',
      ),

      // 14. Medium - Hitung Pesanan Completed
      SqlChallengeModel(
        id: 'chal-14',
        title: 'Jumlah Transaksi Sukses',
        description: 'Hitung berapa banyak pesanan yang berstatus completed.',
        storyTheme: 'E-Commerce Quest',
        questContext: 'Misi #14 · Modul COUNT & WHERE',
        objective: "Hitung jumlah baris dengan COUNT(*) dari tabel orders yang memiliki status = 'completed'.",
        difficulty: 'Medium',
        inputMode: 'text',
        xpReward: 40,
        maxAttempts: 10,
        tables: const [ordersTable],
        schemaDdl: 'CREATE TABLE orders (id INT, user_id INT, total_amount INT, status TEXT, order_date TEXT);',
        referenceQuery: "SELECT COUNT(*) FROM orders WHERE status = 'completed';",
        expectedColumns: const ['count'],
        expectedRows: const [
          [3],
        ],
        hints: const ["Gunakan SELECT COUNT(*) FROM orders WHERE status = 'completed';"],
        explanation: 'Klausa WHERE dijalankan terlebih dahulu sebelum fungsi agregat COUNT(*).',
      ),

      // 15. Hard - Karyawan Senior Data & Engineering
      SqlChallengeModel(
        id: 'chal-15',
        title: 'Filter Karyawan Senior Lintas Tahun',
        description: 'Temukan karyawan yang direkrut sebelum 2023 dan urutkan gajinya.',
        storyTheme: 'Enterprise Data Quest',
        questContext: 'Misi #15 · Hard Challenge',
        objective: 'Tampilkan name, department, salary dari tabel employees dengan hire_year < 2023 diurutkan berdasarkan salary DESC.',
        difficulty: 'Hard',
        inputMode: 'text',
        xpReward: 80,
        maxAttempts: 8,
        timeLimitSeconds: 900, // 15 menit (Bagian 19)
        ordered: true,
        tables: const [employeesTable],
        schemaDdl: 'CREATE TABLE employees (id INT, name TEXT, department TEXT, salary INT, hire_year INT);',
        referenceQuery: 'SELECT name, department, salary FROM employees WHERE hire_year < 2023 ORDER BY salary DESC;',
        expectedColumns: const ['name', 'department', 'salary'],
        expectedRows: const [
          ['Eka', 'Data', 16500000],
          ['Budi', 'Data', 15000000],
          ['Citra', 'Engineering', 14500000],
        ],
        hints: const [
          'Saring baris dengan WHERE hire_year < 2023.',
          'Urutkan hasil menggunakan ORDER BY salary DESC.',
        ],
        explanation: 'Menggabungkan filter tahun rekrutmen dengan pengurutan gaji menurun.',
      ),

      // 16. Hard - Hidangan Utama Kalori Tinggi
      SqlChallengeModel(
        id: 'chal-16',
        title: 'Hidangan Utama Berenergi Tinggi',
        description: 'Cari hidangan kategori Main dengan kalori di atas 500.',
        storyTheme: 'SQL Cooking Quest',
        questContext: 'Misi #16 · Hard Challenge',
        objective: "Tampilkan dish_name, prep_minutes, calories dari tabel recipes dengan category = 'Main' AND calories > 500 diurutkan berdasarkan calories DESC.",
        difficulty: 'Hard',
        inputMode: 'text',
        xpReward: 80,
        maxAttempts: 8,
        timeLimitSeconds: 900,
        ordered: true,
        tables: const [recipesTable],
        schemaDdl: 'CREATE TABLE recipes (id INT, dish_name TEXT, category TEXT, prep_minutes INT, calories INT);',
        referenceQuery: "SELECT dish_name, prep_minutes, calories FROM recipes WHERE category = 'Main' AND calories > 500 ORDER BY calories DESC;",
        expectedColumns: const ['dish_name', 'prep_minutes', 'calories'],
        expectedRows: const [
          ['Rendang Padang', 120, 650],
          ['Nasi Goreng Spesial', 20, 520],
        ],
        hints: const [
          "Gunakan WHERE category = 'Main' AND calories > 500.",
          'Tambahkan ORDER BY calories DESC.',
        ],
        explanation: 'Menyaring kategori Main dan kalori > 500 lalu mengurutkannya dari tertinggi.',
      ),

      // 17. Hard - Audit Pesanan Non-Cancelled
      SqlChallengeModel(
        id: 'chal-17',
        title: 'Daftar Pesanan Aktif & Selesai',
        description: 'Tampilkan seluruh pesanan yang tidak dibatalkan (status != cancelled).',
        storyTheme: 'E-Commerce Quest',
        questContext: 'Misi #17 · Hard Challenge',
        objective: "Tampilkan id, user_id, total_amount, status dari tabel orders dengan status != 'cancelled' diurutkan berdasarkan id ASC.",
        difficulty: 'Hard',
        inputMode: 'text',
        xpReward: 80,
        maxAttempts: 8,
        timeLimitSeconds: 900,
        ordered: true,
        tables: const [ordersTable],
        schemaDdl: 'CREATE TABLE orders (id INT, user_id INT, total_amount INT, status TEXT, order_date TEXT);',
        referenceQuery: "SELECT id, user_id, total_amount, status FROM orders WHERE status != 'cancelled' ORDER BY id ASC;",
        expectedColumns: const ['id', 'user_id', 'total_amount', 'status'],
        expectedRows: const [
          [101, 1, 150000, 'completed'],
          [102, 2, 275000, 'completed'],
          [103, 3, 85000, 'pending'],
          [104, 2, 420000, 'completed'],
        ],
        hints: const [
          "Gunakan operator != 'cancelled' atau <> 'cancelled'.",
          'Urutkan dengan ORDER BY id ASC.',
        ],
        explanation: 'Operator != mengecualikan baris pesanan yang berstatus cancelled.',
      ),

      // 18. Hard - Top 2 Engineer Termuda
      SqlChallengeModel(
        id: 'chal-18',
        title: 'Engineer Muda Berbakat',
        description: 'Cari engineer di tabel users dan urutkan dari usia termuda.',
        storyTheme: 'Community Quest',
        questContext: 'Misi #18 · Hard Challenge',
        objective: "Tampilkan name, age, city dari tabel users dengan role = 'engineer' diurutkan berdasarkan age ASC.",
        difficulty: 'Hard',
        inputMode: 'text',
        xpReward: 80,
        maxAttempts: 8,
        timeLimitSeconds: 900,
        ordered: true,
        tables: const [usersTable],
        schemaDdl: 'CREATE TABLE users (id INT, name TEXT, age INT, role TEXT, city TEXT);',
        referenceQuery: "SELECT name, age, city FROM users WHERE role = 'engineer' ORDER BY age ASC;",
        expectedColumns: const ['name', 'age', 'city'],
        expectedRows: const [
          ['Kevin', 22, 'Bandung'],
          ['Dimas', 24, 'Yogyakarta'],
        ],
        hints: const ["Gunakan WHERE role = 'engineer' ORDER BY age ASC."],
        explanation: 'Menyaring role engineer dan mengurutkan berdasarkan usia termuda.',
      ),

      // 19. Expert - Analisis Divisi Data Eksekutif
      SqlChallengeModel(
        id: 'chal-19',
        title: 'Analisis Kompensasi Divisi Data',
        description: 'Identifikasi spesialis divisi Data dengan kompensasi tertinggi.',
        storyTheme: 'Enterprise Data Quest',
        questContext: 'Misi #19 · Expert Challenge',
        objective: "Tampilkan id, name, salary, hire_year dari tabel employees dengan department = 'Data' diurutkan berdasarkan salary DESC.",
        difficulty: 'Expert',
        inputMode: 'text',
        xpReward: 150,
        maxAttempts: 5,
        timeLimitSeconds: 1200, // 20 menit (Bagian 19)
        ordered: true,
        strictColumns: true,
        tables: const [employeesTable],
        schemaDdl: 'CREATE TABLE employees (id INT, name TEXT, department TEXT, salary INT, hire_year INT);',
        referenceQuery: "SELECT id, name, salary, hire_year FROM employees WHERE department = 'Data' ORDER BY salary DESC;",
        expectedColumns: const ['id', 'name', 'salary', 'hire_year'],
        expectedRows: const [
          [5, 'Eka', 16500000, 2020],
          [2, 'Budi', 15000000, 2022],
        ],
        hints: const [
          'Perhatikan urutan dan nama kolom karena strict_columns aktif.',
          "Gunakan WHERE department = 'Data' ORDER BY salary DESC.",
        ],
        explanation: 'Pada mode Expert dengan strict_columns, nama dan urutan kolom wajib persis.',
      ),

      // 20. Expert - Optimasi Query Pelanggan Prioritas
      SqlChallengeModel(
        id: 'chal-20',
        title: 'Filter Transaksi Pelanggan VIP #2',
        description: 'Temukan seluruh riwayat pesanan milik user_id = 2 diurutkan dari nominal tertinggi.',
        storyTheme: 'E-Commerce Quest',
        questContext: 'Misi #20 · Expert Challenge',
        objective: 'Tampilkan id, total_amount, order_date dari tabel orders dengan user_id = 2 diurutkan berdasarkan total_amount DESC.',
        difficulty: 'Expert',
        inputMode: 'text',
        xpReward: 150,
        maxAttempts: 5,
        timeLimitSeconds: 1200,
        ordered: true,
        strictColumns: true,
        tables: const [ordersTable],
        schemaDdl: 'CREATE TABLE orders (id INT, user_id INT, total_amount INT, status TEXT, order_date TEXT);',
        referenceQuery: 'SELECT id, total_amount, order_date FROM orders WHERE user_id = 2 ORDER BY total_amount DESC;',
        expectedColumns: const ['id', 'total_amount', 'order_date'],
        expectedRows: const [
          [104, 420000, '2026-10-05'],
          [102, 275000, '2026-10-02'],
        ],
        hints: const [
          'Pilih kolom id, total_amount, order_date dari tabel orders.',
          'Gunakan WHERE user_id = 2 ORDER BY total_amount DESC.',
        ],
        explanation: 'Menyaring pesanan pelanggan VIP user_id = 2 secara terurut menurun.',
      ),
    ];
  }

  /// Bagian 20: 3 Misi Harian per pengguna (1 Mudah, 1 Sedang, 1 Bebas)
  static List<DailyMissionModel> buildInitialMissions() {
    final now = DateTime.now();
    final midnightNext = DateTime(now.year, now.month, now.day + 1);
    return [
      DailyMissionModel(
        id: 'mis-1',
        title: 'Selesaikan 1 Lesson SQL',
        description: 'Baca materi, jalankan latihan query, dan lulus kuis pada 1 lesson.',
        requirementType: 'lesson_completed',
        target: 1,
        progress: 0,
        xpReward: 30,
        difficulty: 'Mudah',
        status: 'available',
        expiresAt: midnightNext,
      ),
      DailyMissionModel(
        id: 'mis-2',
        title: 'Menangkan 2 SQL Challenge',
        description: 'Kirim jawaban benar pada 2 tantangan di SQL Game.',
        requirementType: 'challenges_completed',
        target: 2,
        progress: 1,
        xpReward: 50,
        difficulty: 'Sedang',
        status: 'in_progress',
        expiresAt: midnightNext,
      ),
      DailyMissionModel(
        id: 'mis-3',
        title: 'Kumpulkan 100 XP Hari Ini',
        description: 'Raih minimal 100 XP dari lesson, kuis, atau challenge.',
        requirementType: 'xp_earned',
        target: 100,
        progress: 60,
        xpReward: 40,
        difficulty: 'Bebas',
        status: 'in_progress',
        expiresAt: midnightNext,
      ),
    ];
  }

  /// Bagian 23 & 37: 3 Achievement MVP (First Lesson, First SQL Query, First Game) + daftar lengkap
  static List<AchievementModel> buildInitialAchievements() {
    return [
      AchievementModel(
        id: 'ach-1',
        code: 'first_lesson',
        name: 'First Lesson',
        description: 'Menyelesaikan 1 lesson pertama di Learning Path.',
        iconName: 'menu_book',
        xpReward: 10,
        isUnlocked: true,
        unlockedAt: DateTime(2026, 10, 25),
        isMvp: true,
      ),
      AchievementModel(
        id: 'ach-2',
        code: 'first_sql_query',
        name: 'First SQL Query',
        description: 'Menjalankan 1 eksekusi query berhasil di SQL Sandbox.',
        iconName: 'terminal',
        xpReward: 10,
        isUnlocked: true,
        unlockedAt: DateTime(2026, 10, 25),
        isMvp: true,
      ),
      AchievementModel(
        id: 'ach-3',
        code: 'first_game',
        name: 'First Game',
        description: 'Menyelesaikan 1 SQL Challenge dengan hasil benar.',
        iconName: 'sports_esports',
        xpReward: 20,
        isUnlocked: true,
        unlockedAt: DateTime(2026, 10, 26),
        isMvp: true,
      ),
      const AchievementModel(
        id: 'ach-4',
        code: 'sql_beginner',
        name: 'SQL Beginner',
        description: 'Menamatkan seluruh modul pada Path SQL Beginner.',
        iconName: 'workspace_premium',
        xpReward: 100,
        isUnlocked: false,
        isMvp: false,
      ),
      const AchievementModel(
        id: 'ach-5',
        code: 'streak_7',
        name: '7 Day Streak',
        description: 'Belajar konsisten selama 7 hari berturut-turut.',
        iconName: 'local_fire_department',
        xpReward: 50,
        isUnlocked: false,
        isMvp: false,
      ),
      const AchievementModel(
        id: 'ach-6',
        code: 'perfect_score',
        name: 'Perfect Score',
        description: 'Menyelesaikan Challenge Hard/Expert pada percobaan pertama tanpa hint.',
        iconName: 'military_tech',
        xpReward: 50,
        isUnlocked: false,
        isMvp: false,
      ),
      const AchievementModel(
        id: 'ach-7',
        code: 'sql_master',
        name: 'SQL Master',
        description: 'Mencapai Level 10 (SQL Master).',
        iconName: 'emoji_events',
        xpReward: 500,
        isUnlocked: false,
        isMvp: false,
      ),
    ];
  }

  /// Bagian 24 & AC-13: Leaderboard Top 50 + posisi pengguna
  static List<LeaderboardEntryModel> buildLeaderboard({
    required UserProfileModel currentUser,
    required String periodType, // global, weekly, monthly
  }) {
    final factor = periodType == 'weekly'
        ? 0.25
        : periodType == 'monthly'
            ? 0.6
            : 1.0;

    final names = [
      ('dimas_se', 'Dimas Pratama', 2450, 2),
      ('budi_data', 'Budi Santoso', 2180, 1),
      ('sari_dev', 'Sari Kusuma', 1940, -1),
      ('nadia_sql', 'Nadia Putri', 1760, 3),
      ('farhan_pg', 'Farhan Akbar', 1620, 0),
      ('citra_db', 'Citra Lestari', 1490, 2),
      ('reza_query', 'Reza Mahendra', 1350, -2),
      ('putri_analytics', 'Putri Maharani', 1210, 1),
      ('andi_backend', 'Andi Wijaya', 1100, 0),
      ('bagas_code', 'Bagas Saputra', 980, 4),
      ('tiara_tech', 'Tiara Anindya', 910, -1),
    ];

    final entries = <LeaderboardEntryModel>[];
    for (int i = 0; i < 50; i++) {
      if (i < names.length) {
        final item = names[i];
        final xp = (item.$3 * factor).round();
        entries.add(
          LeaderboardEntryModel(
            rank: i + 1,
            userId: 'user_${i + 1}',
            username: item.$1,
            fullName: item.$2,
            level: (xp ~/ 250).clamp(1, 10),
            xp: xp,
            rankChange: item.$4,
          ),
        );
      } else {
        final rawXp = (890 - (i - names.length) * 18).clamp(40, 900);
        final xp = (rawXp * factor).round();
        entries.add(
          LeaderboardEntryModel(
            rank: i + 1,
            userId: 'user_${i + 1}',
            username: 'learner_${i + 1}',
            fullName: 'SQL Learner #${i + 1}',
            level: (xp ~/ 250).clamp(1, 10),
            xp: xp,
            rankChange: (i % 3) - 1,
          ),
        );
      }
    }

    // Insert or replace current user based on XP
    final myXp = (currentUser.totalXp * factor).round();
    entries.removeWhere((e) => e.username == currentUser.username);
    entries.add(
      LeaderboardEntryModel(
        rank: 0,
        userId: currentUser.id,
        username: currentUser.username,
        fullName: currentUser.fullName,
        level: currentUser.level,
        xp: myXp,
        rankChange: 2,
        isCurrentUser: true,
      ),
    );

    entries.sort((a, b) => b.xp.compareTo(a.xp));
    return List.generate(entries.length, ( idx) {
      final e = entries[idx];
      return LeaderboardEntryModel(
        rank: idx + 1,
        userId: e.userId,
        username: e.username,
        fullName: e.fullName,
        level: e.level,
        xp: e.xp,
        rankChange: e.rankChange,
        isCurrentUser: e.isCurrentUser,
      );
    });
  }

  static List<AppNotificationModel> buildInitialNotifications() {
    final now = DateTime.now();
    return [
      AppNotificationModel(
        id: 'notif-1',
        type: 'achievement_unlocked',
        title: 'Achievement Terbuka: First Game!',
        body: 'Selamat! Kamu berhasil menyelesaikan SQL Challenge pertamamu (+20 XP).',
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: false,
        deepLink: '/achievements',
      ),
      AppNotificationModel(
        id: 'notif-2',
        type: 'level_up',
        title: 'Naik ke Level 4 — SQL Practitioner!',
        body: 'Total XP kamu menembus 600 XP. Terus pertahankan streak belajarmu!',
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: false,
        deepLink: '/profile',
      ),
      AppNotificationModel(
        id: 'notif-3',
        type: 'daily_mission',
        title: '3 Misi Harian Baru Tersedia',
        body: 'Selesaikan ketiga misi hari ini untuk klaim bonus ekstra +30 XP.',
        createdAt: now.subtract(const Duration(hours: 5)),
        isRead: true,
        deepLink: '/missions',
      ),
    ];
  }
}

