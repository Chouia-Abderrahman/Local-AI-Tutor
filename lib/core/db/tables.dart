import 'package:drift/drift.dart';

// Tables follow DESIGN.md section 13. Text values that hold enums use the
// enum's `name`; JSON payloads are stored as TEXT.

@DataClassName('StudyDocument')
class Documents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get sourcePath => text().nullable()();
  TextColumn get sha256 => text().unique()();
  IntColumn get pageCount => integer().withDefault(const Constant(0))();
  TextColumn get language => text().nullable()();

  /// importing | ready | failed
  TextColumn get status => text().withDefault(const Constant('importing'))();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get settingsJson => text().nullable()();
  DateTimeColumn get importedAt => dateTime().withDefault(currentDateAndTime)();

  /// The model file that generates for this document and answers its new
  /// conversations. Null: the app's default model. (Schema 2.)
  TextColumn get modelPath => text().nullable()();
}

@TableIndex(name: 'idx_sections_document', columns: {#documentId, #ord})
class Sections extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get documentId =>
      integer().references(Documents, #id, onDelete: KeyAction.cascade)();
  IntColumn get parentId => integer().nullable()();
  TextColumn get title => text()();
  IntColumn get level => integer()();
  IntColumn get ord => integer()();
  IntColumn get pageStart => integer()();
  IntColumn get pageEnd => integer()();
}

@TableIndex(name: 'idx_chunks_document', columns: {#documentId, #ord})
@TableIndex(name: 'idx_chunks_section', columns: {#sectionId})
class Chunks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get documentId =>
      integer().references(Documents, #id, onDelete: KeyAction.cascade)();
  IntColumn get sectionId =>
      integer().references(Sections, #id, onDelete: KeyAction.cascade)();
  IntColumn get ord => integer()();
  TextColumn get body => text()();
  TextColumn get headingPath => text()();
  IntColumn get pageStart => integer()();
  IntColumn get pageEnd => integer()();
  IntColumn get tokenEstimate => integer()();

  /// study | toc | bookIndex | refs | front | math (ContentKind.name)
  TextColumn get kind => text().withDefault(const Constant('study'))();
  TextColumn get sha256 => text()();
}

@TableIndex(name: 'idx_facts_document', columns: {#documentId})
@TableIndex(name: 'idx_facts_chunk', columns: {#chunkId})
class Facts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get documentId =>
      integer().references(Documents, #id, onDelete: KeyAction.cascade)();
  IntColumn get chunkId =>
      integer().references(Chunks, #id, onDelete: KeyAction.cascade)();
  IntColumn get sectionId => integer()();
  TextColumn get statement => text()();
  TextColumn get quote => text()();
  IntColumn get quoteStart => integer()();
  IntColumn get quoteEnd => integer()();
  TextColumn get keyTerm => text()();
  IntColumn get importance => integer().withDefault(const Constant(2))();

  /// active | retired | disputed
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@TableIndex(name: 'idx_questions_fact', columns: {#factId})
class Questions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get factId =>
      integer().references(Facts, #id, onDelete: KeyAction.cascade)();

  /// cloze | flashcard | mcq
  TextColumn get type => text()();

  /// recall | understand | apply | analyze
  TextColumn get depth => text()();
  TextColumn get prompt => text()();
  TextColumn get answer => text()();
  TextColumn get distractorsJson => text().nullable()();
  TextColumn get explanation => text().nullable()();

  /// quick | standard | thorough | deep
  TextColumn get quality => text()();
  TextColumn get modelId => text()();
  IntColumn get promptVersion => integer()();
  TextColumn get checksJson => text().nullable()();

  /// active | retired | reported
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Links questions that span several sections (Analyze depth).
class QuestionSections extends Table {
  IntColumn get questionId =>
      integer().references(Questions, #id, onDelete: KeyAction.cascade)();
  IntColumn get sectionId =>
      integer().references(Sections, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {questionId, sectionId};
}

/// Spaced-repetition state, one card per fact.
@TableIndex(name: 'idx_fact_cards_due', columns: {#due})
class FactCards extends Table {
  IntColumn get factId =>
      integer().references(Facts, #id, onDelete: KeyAction.cascade)();
  TextColumn get fsrsJson => text()();
  DateTimeColumn get due => dateTime()();
  RealColumn get stability => real().nullable()();
  RealColumn get difficulty => real().nullable()();

  /// learning | review | relearning
  TextColumn get state => text()();
  DateTimeColumn get lastReview => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {factId};
}

@TableIndex(name: 'idx_reviews_fact', columns: {#factId})
class Reviews extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get factId =>
      integer().references(Facts, #id, onDelete: KeyAction.cascade)();
  IntColumn get questionId => integer().nullable()();

  /// FSRS rating: 1 again, 2 hard, 3 good, 4 easy.
  IntColumn get rating => integer()();
  BoolColumn get correct => boolean().nullable()();
  IntColumn get responseMs => integer().nullable()();
  BoolColumn get unsure => boolean().withDefault(const Constant(false))();
  DateTimeColumn get reviewedAt => dateTime()();
}

class Jobs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get documentId =>
      integer().references(Documents, #id, onDelete: KeyAction.cascade)();
  TextColumn get scopeJson => text()();
  TextColumn get profileJson => text()();

  /// queued | running | paused | done | failed
  TextColumn get status => text().withDefault(const Constant('queued'))();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  TextColumn get error => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@TableIndex(name: 'idx_job_items_job', columns: {#jobId, #status})
class JobItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get jobId =>
      integer().references(Jobs, #id, onDelete: KeyAction.cascade)();
  IntColumn get chunkId =>
      integer().references(Chunks, #id, onDelete: KeyAction.cascade)();
  TextColumn get stage => text()();

  /// queued | running | done | failed | skipped
  TextColumn get status => text().withDefault(const Constant('queued'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get cacheKey => text().nullable()();
  TextColumn get error => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Model outputs keyed by a hash of (chunk text, model, prompt version,
/// stage parameters), so reruns don't repeat finished work.
@DataClassName('LlmCacheEntry')
class LlmCacheEntries extends Table {
  TextColumn get cacheKey => text()();
  TextColumn get output => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {cacheKey};
}

/// Why generated items were dropped. Used to tune prompts.
class Rejections extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get documentId =>
      integer().references(Documents, #id, onDelete: KeyAction.cascade)();
  IntColumn get chunkId => integer().nullable()();
  TextColumn get stage => text()();
  TextColumn get reason => text()();
  TextColumn get payload => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class ChatThreads extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get documentId =>
      integer().references(Documents, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get summary => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// The model file that answers in this conversation. Null: the document's
  /// model. (Schema 2.)
  TextColumn get modelPath => text().nullable()();
}

@TableIndex(name: 'idx_chat_messages_thread', columns: {#threadId})
class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get threadId =>
      integer().references(ChatThreads, #id, onDelete: KeyAction.cascade)();

  /// user | assistant
  TextColumn get role => text()();
  TextColumn get content => text()();
  TextColumn get citationsJson => text().nullable()();
  BoolColumn get usedWeb => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class WebPages extends Table {
  TextColumn get url => text()();
  TextColumn get title => text().nullable()();
  TextColumn get body => text()();
  IntColumn get httpStatus => integer()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {url};
}

/// Every web query the app sent, shown on the Web activity screen.
@DataClassName('WebLogEntry')
class WebLogEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get query => text()();
  TextColumn get provider => text()();
  TextColumn get urlsJson => text().nullable()();
  DateTimeColumn get at => dateTime().withDefault(currentDateAndTime)();
}

class FactChecks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get factId => integer().nullable()();
  IntColumn get questionId => integer().nullable()();
  TextColumn get claim => text()();

  /// corroborated | conflict | notFound
  TextColumn get verdict => text()();
  TextColumn get evidenceJson => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Speed-test results, used for time estimates.
class BenchmarkRuns extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get modelName => text()();
  TextColumn get backend => text()();
  RealColumn get readTokensPerSecond => real()();
  RealColumn get writeTokensPerSecond => real()();
  IntColumn get firstQuestionMs => integer()();
  IntColumn get nextQuestionMs => integer()();
  RealColumn get cachedPromptShare => real().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
