import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';
import '../ingest/content_kind.dart';
import 'chunk_generator.dart';
import 'profile.dart';
import 'prompts.dart';

/// Stages of a job item. Facts come first for every chunk in scope, so cloze
/// cards and flashcards are ready early; questions refine afterwards.
abstract final class Stage {
  static const facts = 'facts';
  static const questions = 'questions';

  /// Adds more questions of one kind to facts that already have some.
  static String more(MoreKind kind) => 'more_${kind.name}';

  /// The kind a [more] stage adds, or null for other stages.
  static MoreKind? moreKind(String stage) => stage.startsWith('more_')
      ? MoreKind.values.where((k) => 'more_${k.name}' == stage).firstOrNull
      : null;
}

/// One unit of queued work.
class WorkItem {
  const WorkItem({
    required this.itemId,
    required this.jobId,
    required this.documentId,
    required this.chunkId,
    required this.stage,
    required this.attempts,
    required this.profile,
    this.perFact = 1,
  });

  final int itemId;
  final int jobId;
  final int documentId;
  final int chunkId;
  final String stage;
  final int attempts;
  final GenerationProfile profile;

  /// For a "more" stage: how many to add per fact.
  final int perFact;
}

class JobSummary {
  const JobSummary({
    required this.job,
    required this.done,
    required this.failed,
    required this.total,
    required this.remainingByStage,
  });

  final Job job;
  final int done;
  final int failed;
  final int total;
  final Map<String, int> remainingByStage;

  GenerationProfile get profile => GenerationProfile.fromJson(
    Map<String, Object?>.from(jsonDecode(job.profileJson) as Map),
  );
  int get remaining => total - done - failed;
}

/// Counts of generated items for one section.
class SectionCounts {
  const SectionCounts({this.facts = 0, this.questions = 0, this.mcq = 0});

  final int facts;
  final int questions;
  final int mcq;
}

/// A fact with its active questions, for review screens.
class FactWithQuestions {
  const FactWithQuestions(this.fact, this.questions);

  final Fact fact;
  final List<Question> questions;
}

class GenerationRepository {
  GenerationRepository(this.db);

  final AppDatabase db;

  // ---------------------------------------------------------------- jobs

  /// Queues generation for a document, or for some of its sections (and
  /// their subsections). Returns the job id, or null when there is nothing
  /// to do.
  ///
  /// With [more], the job only adds [perFact] more questions of that kind to
  /// facts that exist already; passages without facts are left out.
  Future<int?> createJob({
    required int documentId,
    required GenerationProfile profile,
    List<int>? sectionIds,
    int priority = 0,
    MoreKind? more,
    int perFact = 1,
  }) {
    return db.transaction(() async {
      var chunks = await _studyChunks(documentId, sectionIds);
      if (more != null) {
        final withFacts = {
          for (final f
              in await (db.select(db.facts)..where(
                    (f) =>
                        f.documentId.equals(documentId) &
                        f.status.equals('active'),
                  ))
                  .get())
            f.chunkId,
        };
        chunks = [
          for (final c in chunks)
            if (withFacts.contains(c.id)) c,
        ];
      }
      if (chunks.isEmpty) return null;
      final jobId = await db
          .into(db.jobs)
          .insert(
            JobsCompanion.insert(
              documentId: documentId,
              scopeJson: jsonEncode({
                'sections': sectionIds,
                if (more != null) 'more': more.name,
                if (more != null) 'perFact': perFact,
              }),
              profileJson: jsonEncode(profile.toJson()),
              priority: Value(priority),
              status: const Value('running'),
            ),
          );
      if (more != null) {
        for (final chunk in chunks) {
          await db
              .into(db.jobItems)
              .insert(
                JobItemsCompanion.insert(
                  jobId: jobId,
                  chunkId: chunk.id,
                  stage: Stage.more(more),
                ),
              );
        }
        return jobId;
      }
      for (final chunk in chunks) {
        await db
            .into(db.jobItems)
            .insert(
              JobItemsCompanion.insert(
                jobId: jobId,
                chunkId: chunk.id,
                stage: Stage.facts,
              ),
            );
      }
      if (profile.multipleChoice) {
        for (final chunk in chunks) {
          await db
              .into(db.jobItems)
              .insert(
                JobItemsCompanion.insert(
                  jobId: jobId,
                  chunkId: chunk.id,
                  stage: Stage.questions,
                ),
              );
        }
      }
      return jobId;
    });
  }

  Future<List<Chunk>> _studyChunks(
    int documentId,
    List<int>? sectionIds,
  ) async {
    final query = db.select(db.chunks)
      ..where(
        (c) =>
            c.documentId.equals(documentId) &
            c.kind.equals(ContentKind.study.name),
      )
      ..orderBy([(c) => OrderingTerm(expression: c.ord)]);
    final chunks = await query.get();
    if (sectionIds == null) return chunks;
    final scope = await _withDescendants(documentId, sectionIds.toSet());
    return [
      for (final c in chunks)
        if (scope.contains(c.sectionId)) c,
    ];
  }

  Future<Set<int>> _withDescendants(int documentId, Set<int> roots) async {
    final sections = await (db.select(
      db.sections,
    )..where((s) => s.documentId.equals(documentId))).get();
    final result = {...roots};
    var grew = true;
    while (grew) {
      grew = false;
      for (final s in sections) {
        if (s.parentId != null &&
            result.contains(s.parentId) &&
            result.add(s.id)) {
          grew = true;
        }
      }
    }
    return result;
  }

  /// The next queued item: highest-priority job first, all facts items
  /// before questions items, then document order.
  Future<WorkItem?> nextItem() async {
    final row = await db
        .customSelect(
          'SELECT ji.id, ji.job_id, ji.chunk_id, ji.stage, ji.attempts, '
          'j.document_id, j.profile_json, j.scope_json '
          'FROM job_items ji '
          'JOIN jobs j ON j.id = ji.job_id '
          'JOIN chunks c ON c.id = ji.chunk_id '
          "WHERE ji.status = 'queued' AND j.status = 'running' "
          'ORDER BY j.priority DESC, '
          "CASE ji.stage WHEN 'facts' THEN 0 ELSE 1 END, "
          'j.created_at, c.ord '
          'LIMIT 1',
          readsFrom: {db.jobItems, db.jobs, db.chunks},
        )
        .getSingleOrNull();
    if (row == null) return null;
    return WorkItem(
      itemId: row.read<int>('id'),
      jobId: row.read<int>('job_id'),
      documentId: row.read<int>('document_id'),
      chunkId: row.read<int>('chunk_id'),
      stage: row.read<String>('stage'),
      attempts: row.read<int>('attempts'),
      profile: GenerationProfile.fromJson(
        Map<String, Object?>.from(
          jsonDecode(row.read<String>('profile_json')) as Map,
        ),
      ),
      perFact:
          (jsonDecode(row.read<String>('scope_json')) as Map)['perFact']
              as int? ??
          1,
    );
  }

  Future<void> setItemStatus(
    int itemId,
    String status, {
    String? error,
    bool countAttempt = false,
  }) async {
    final item = await (db.select(
      db.jobItems,
    )..where((i) => i.id.equals(itemId))).getSingle();
    await (db.update(db.jobItems)..where((i) => i.id.equals(itemId))).write(
      JobItemsCompanion(
        status: Value(status),
        error: Value(error),
        attempts: Value(item.attempts + (countAttempt ? 1 : 0)),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Items left "running" by a killed app go back to the queue.
  Future<int> resetInterrupted() =>
      (db.update(db.jobItems)..where((i) => i.status.equals('running'))).write(
        const JobItemsCompanion(status: Value('queued')),
      );

  Future<bool> hasQueuedWork() async =>
      (await db
          .customSelect(
            'SELECT 1 FROM job_items ji JOIN jobs j ON j.id = ji.job_id '
            "WHERE ji.status = 'queued' AND j.status = 'running' LIMIT 1",
          )
          .getSingleOrNull()) !=
      null;

  Future<void> setJobStatus(int jobId, String status) =>
      (db.update(db.jobs)..where((j) => j.id.equals(jobId))).write(
        JobsCompanion(status: Value(status), updatedAt: Value(DateTime.now())),
      );

  /// Marks running jobs with nothing left as done.
  /// Uses customUpdate (not customStatement) so that live queries on jobs,
  /// such as the progress card, see the change.
  Future<void> finishCompletedJobs() async {
    await db.customUpdate(
      "UPDATE jobs SET status = 'done', updated_at = strftime('%s','now') "
      "WHERE status = 'running' AND NOT EXISTS ("
      "SELECT 1 FROM job_items ji WHERE ji.job_id = jobs.id "
      "AND ji.status IN ('queued', 'running'))",
      updates: {db.jobs},
      updateKind: UpdateKind.update,
    );
  }

  Future<JobSummary?> summary(int jobId) async {
    final job = await (db.select(
      db.jobs,
    )..where((j) => j.id.equals(jobId))).getSingleOrNull();
    if (job == null) return null;
    final rows = await db
        .customSelect(
          'SELECT stage, status, COUNT(*) AS n FROM job_items '
          'WHERE job_id = ? GROUP BY stage, status',
          variables: [Variable.withInt(jobId)],
          readsFrom: {db.jobItems},
        )
        .get();
    var done = 0, failed = 0, total = 0;
    final remaining = <String, int>{};
    for (final row in rows) {
      final n = row.read<int>('n');
      final status = row.read<String>('status');
      total += n;
      if (status == 'done' || status == 'skipped') {
        done += n;
      } else if (status == 'failed') {
        failed += n;
      } else {
        final stage = row.read<String>('stage');
        remaining[stage] = (remaining[stage] ?? 0) + n;
      }
    }
    return JobSummary(
      job: job,
      done: done,
      failed: failed,
      total: total,
      remainingByStage: remaining,
    );
  }

  /// Unfinished jobs for a document (running or paused), newest first.
  Stream<List<Job>> watchOpenJobs(int documentId) =>
      (db.select(db.jobs)
            ..where(
              (j) =>
                  j.documentId.equals(documentId) &
                  j.status.isIn(['running', 'paused']),
            )
            ..orderBy([
              (j) => OrderingTerm(
                expression: j.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .watch();

  // -------------------------------------------------------------- inputs

  Future<(PassageInput, Chunk)> passage(
    int chunkId, {
    bool withContext = false,
  }) async {
    final chunk = await (db.select(
      db.chunks,
    )..where((c) => c.id.equals(chunkId))).getSingle();
    final document = await (db.select(
      db.documents,
    )..where((d) => d.id.equals(chunk.documentId))).getSingle();
    String? context;
    if (withContext) {
      final neighbors =
          await (db.select(db.chunks)
                ..where(
                  (c) =>
                      c.sectionId.equals(chunk.sectionId) &
                      c.ord.isIn([chunk.ord - 1, chunk.ord + 1]) &
                      c.kind.equals(ContentKind.study.name),
                )
                ..orderBy([(c) => OrderingTerm(expression: c.ord)]))
              .get();
      if (neighbors.isNotEmpty) {
        context = neighbors.map((n) => _shorten(n.body, 180)).join('\n\n');
      }
    }
    return (
      PassageInput(
        chunkId: chunk.id,
        text: chunk.body,
        headingPath: chunk.headingPath,
        language: document.language,
        context: context,
      ),
      chunk,
    );
  }

  Future<bool> hasFacts(int chunkId) async =>
      (await (db.select(db.facts)
            ..where((f) => f.chunkId.equals(chunkId))
            ..limit(1))
          .getSingleOrNull()) !=
      null;

  /// Active facts of a chunk that still lack a multiple-choice question of
  /// at least [quality].
  Future<List<FactInput>> factsNeedingQuestions(
    int chunkId,
    Quality quality,
  ) async {
    final facts =
        await (db.select(db.facts)
              ..where(
                (f) => f.chunkId.equals(chunkId) & f.status.equals('active'),
              )
              ..orderBy([(f) => OrderingTerm(expression: f.quoteStart)]))
            .get();
    final result = <FactInput>[];
    for (final fact in facts) {
      final mcqs =
          await (db.select(db.questions)..where(
                (q) =>
                    q.factId.equals(fact.id) &
                    q.type.equals(QuestionType.mcq.name) &
                    q.status.equals('active'),
              ))
              .get();
      final covered = mcqs.any(
        (q) => Quality.values.byName(q.quality).index >= quality.index,
      );
      if (!covered) {
        result.add(
          FactInput(id: fact.id, statement: fact.statement, quote: fact.quote),
        );
      }
    }
    return result;
  }

  /// Active facts of a chunk, each with what it already has of [kind], for
  /// adding more: question text for multiple choice and flashcards, the
  /// blanked words for fill-in-the-blank.
  Future<List<FactInput>> factsForMore(int chunkId, MoreKind kind) async {
    final facts =
        await (db.select(db.facts)
              ..where(
                (f) => f.chunkId.equals(chunkId) & f.status.equals('active'),
              )
              ..orderBy([(f) => OrderingTerm(expression: f.quoteStart)]))
            .get();
    final result = <FactInput>[];
    for (final fact in facts) {
      final questions =
          await (db.select(db.questions)..where(
                (q) =>
                    q.factId.equals(fact.id) &
                    q.type.equals(kind.type.name) &
                    q.status.equals('active'),
              ))
              .get();
      result.add(
        FactInput(
          id: fact.id,
          statement: fact.statement,
          quote: fact.quote,
          existing: [
            for (final q in questions)
              kind == MoreKind.cloze ? q.answer : q.prompt,
          ],
        ),
      );
    }
    return result;
  }

  /// "question answer" of the document's active questions, for dedupe.
  Future<List<String>> existingQuestionTexts(int documentId) async {
    final rows = await db
        .customSelect(
          'SELECT q.prompt, q.answer FROM questions q '
          'JOIN facts f ON f.id = q.fact_id '
          "WHERE f.document_id = ? AND q.status = 'active' AND q.type = 'mcq'",
          variables: [Variable.withInt(documentId)],
          readsFrom: {db.questions, db.facts},
        )
        .get();
    return [
      for (final r in rows)
        '${r.read<String>('prompt')} ${r.read<String>('answer')}',
    ];
  }

  // ------------------------------------------------------------- outputs

  Future<void> saveFacts({
    required Chunk chunk,
    required FactsResult result,
    required GenerationProfile profile,
    required String modelId,
  }) {
    return db.transaction(() async {
      final ids = <int>[];
      for (final fact in result.facts) {
        ids.add(
          await db
              .into(db.facts)
              .insert(
                FactsCompanion.insert(
                  documentId: chunk.documentId,
                  chunkId: chunk.id,
                  sectionId: chunk.sectionId,
                  statement: fact.statement,
                  quote: fact.quote,
                  quoteStart: fact.quoteStart,
                  quoteEnd: fact.quoteEnd,
                  keyTerm: fact.keyTerm,
                  importance: Value(fact.importance),
                ),
              ),
        );
      }
      for (final question in result.questions) {
        await _insertQuestion(
          ids[question.factIndex],
          question,
          profile,
          modelId,
        );
      }
      await _insertRejections(chunk, result.rejections);
    });
  }

  Future<void> saveQuestions({
    required Chunk chunk,
    required List<FactInput> facts,
    required QuestionsResult result,
    required GenerationProfile profile,
    required String modelId,
    bool replace = true,
  }) {
    return db.transaction(() async {
      // With [replace], a better question retires the lower-quality ones of
      // the same fact, once per fact. Without it (adding more), they stay.
      final retired = <int>{};
      for (final question in result.questions) {
        final factId = facts[question.factIndex].id;
        if (replace && retired.add(factId)) {
          await (db.update(db.questions)..where(
                (q) =>
                    q.factId.equals(factId) &
                    q.type.equals(QuestionType.mcq.name) &
                    q.status.equals('active'),
              ))
              .write(const QuestionsCompanion(status: Value('retired')));
        }
        await _insertQuestion(factId, question, profile, modelId);
      }
      await _insertRejections(chunk, result.rejections);
    });
  }

  Future<void> _insertQuestion(
    int factId,
    QuestionDraft question,
    GenerationProfile profile,
    String modelId,
  ) => db
      .into(db.questions)
      .insert(
        QuestionsCompanion.insert(
          factId: factId,
          type: question.type.name,
          depth: question.depth.name,
          prompt: question.prompt,
          answer: question.answer,
          distractorsJson: Value(
            question.distractors.isEmpty
                ? null
                : jsonEncode(question.distractors),
          ),
          explanation: Value(
            question.distractorNotes.isEmpty
                ? question.explanation
                : jsonEncode({
                    'why': question.explanation,
                    'why_wrong': question.distractorNotes,
                  }),
          ),
          quality: profile.quality.name,
          modelId: modelId,
          promptVersion: promptVersion,
          checksJson: Value(
            question.checks.isEmpty ? null : jsonEncode(question.checks),
          ),
        ),
      );

  Future<void> _insertRejections(
    Chunk chunk,
    List<RejectionDraft> rejections,
  ) async {
    for (final r in rejections) {
      await db
          .into(db.rejections)
          .insert(
            RejectionsCompanion.insert(
              documentId: chunk.documentId,
              chunkId: Value(chunk.id),
              stage: r.stage,
              reason: r.reason,
              payload: Value(jsonEncode(r.payload)),
            ),
          );
    }
  }

  // --------------------------------------------------------------- reads

  Future<Map<int, SectionCounts>> countsBySection(int documentId) async {
    final rows = await db
        .customSelect(
          'SELECT f.section_id AS s, COUNT(DISTINCT f.id) AS facts, '
          'COUNT(q.id) AS questions, '
          "SUM(CASE WHEN q.type = 'mcq' THEN 1 ELSE 0 END) AS mcq "
          'FROM facts f LEFT JOIN questions q '
          "ON q.fact_id = f.id AND q.status = 'active' "
          "WHERE f.document_id = ? AND f.status = 'active' "
          'GROUP BY f.section_id',
          variables: [Variable.withInt(documentId)],
          readsFrom: {db.facts, db.questions},
        )
        .get();
    return {
      for (final r in rows)
        r.read<int>('s'): SectionCounts(
          facts: r.read<int>('facts'),
          questions: r.read<int>('questions'),
          mcq: r.read<int?>('mcq') ?? 0,
        ),
    };
  }

  Future<List<FactWithQuestions>> factsOfSection(int sectionId) async {
    final facts =
        await (db.select(db.facts)
              ..where(
                (f) =>
                    f.sectionId.equals(sectionId) & f.status.equals('active'),
              )
              ..orderBy([
                (f) => OrderingTerm(expression: f.chunkId),
                (f) => OrderingTerm(expression: f.quoteStart),
              ]))
            .get();
    return [
      for (final fact in facts)
        FactWithQuestions(
          fact,
          await (db.select(db.questions)
                ..where(
                  (q) => q.factId.equals(fact.id) & q.status.equals('active'),
                )
                ..orderBy([(q) => OrderingTerm(expression: q.id)]))
              .get(),
        ),
    ];
  }

  static String _shorten(String text, int words) {
    final parts = text.split(RegExp(r'\s+'));
    return parts.length <= words ? text : '${parts.take(words).join(' ')} …';
  }
}
