# Local AI Tutor: Design

The app was called PDF Study Assistant until M8; the repository and the Dart package keep that working name.

Status, 2026-11-21: built through M8. "As built" notes mark where the app differs from the plan, section 15 lists what isn't built yet, and section 18 describes the look.

## 1. What it does

You import a PDF or text file and the app builds a topic outline from it. A local model turns each section into verified flashcards, cloze cards and multiple-choice questions. You study them with spaced repetition, and a mastery map shows which topics you know, which are fading and which you haven't started. A chat answers questions about the document with page citations. If you turn web access on, it can also check facts against the web.

Everything runs on the device by default. The network is used only for model downloads and, when you enable it, web lookups.

Target: Android only. The Flutter template also created ios, linux, macos, windows and web folders. M0 removes them (`flutter create` can recreate any of them later), so there is one code path for OCR, background work and file access.

The development laptop is used for two things only: running the automated tests, and judging question quality with the eval tool (section 14). The same model file writes essentially the same questions on any device, so quality can be judged on the laptop. Speed, time estimates, battery use and model size are decided on a phone.

## 2. Changes from the original draft

| Original | Change | Why |
|---|---|---|
| PyMuPDF or PDFium | pdfrx (PDFium) | PyMuPDF is Python and AGPL. pdfrx runs PDFium in Flutter on every platform and returns character boxes, so the app can highlight the source sentence on the page |
| Topic = chunk heading | Section tree built from the PDF outline, then heading detection, then model labels | Headings can be missing (plain text), generic ("Introduction", "Example 3") or repeated. Mastery needs a hierarchy that rolls up |
| One call writes the whole question | Two steps: extract verified facts, then write questions for each fact | Smaller tasks suit small models, the number of questions follows how dense the content is, and progress attaches to facts, so rewording a question keeps your history |
| "Strict JSON schema" | Schema enforced by constrained decoding (llama.cpp grammar) | Output is always parseable instead of usually parseable |
| Quote must be in the chunk (exact match) | Normalized fuzzy match, a check that the answer is grounded in the quote, and a blind-answer check from Standard up | Exact matching fails on PDF text (ligatures, hyphenation, line breaks, curly quotes). A real quote proves the model read the chunk. It doesn't prove the keyed answer is right or that the distractors are wrong |
| Options as the model wrote them | Options shuffled in code, plus length and format checks on distractors | Models put the right answer in predictable positions and often make it the longest option |
| Track results per topic | FSRS scheduling per fact. Mastery = predicted recall now, which decays | Without a scheduler and decay, the map is a scoreboard that never fades and never says what to review |
| No explanation at Quick | Every level shows the verified source quote, and higher levels add explanations | The quote costs nothing. Immediate feedback also stops you from learning the distractors |
| Effort = one slider mixing care and difficulty | Two settings: Quality (Quick to Deep: how careful) and Depth (Recall to Analyze: what is asked) | You may want easy questions done carefully, or hard ones fast. A slider can't interpolate between categories like "quote check" and "quote + blind check" |
| 1B model at Quick, 3-4B at Deep | One model chosen from the phone's RAM and speed. Deep may add a second model on phones with enough RAM | 1B models fail more of their own checks, so much of their speed goes to rejected output and what passes tends to be shallow. Model size is a hardware question |
| Fixed wait times per level (seconds to 20 min) | Estimates from a device benchmark multiplied by document size | Expect roughly 10 generated tokens/s from a 4B model on a recent phone (to be measured). A 100-page PDF at Standard takes hours, so the design has to let you study while it works |
| Generate the whole document | Generate the section you're about to study first, keep a buffer of ready cards, refine in the background | Makes on-device generation usable at that speed |
| (missing) | Resumable job queue, cache keyed by chunk, model and prompt version | Android and low battery kill long runs. Reruns and upgrades shouldn't redo finished work |
| (missing) | Skip the table of contents, index, references and front matter | Otherwise you get "Who published this book?" |
| (missing) | Generate in the document's language | Small models drift into English |

## 3. Stack

| Concern | Choice | Notes |
|---|---|---|
| App | Flutter 3.44, Dart 3.12, Riverpod, go_router | Already scaffolded |
| Storage | drift (SQLite) with FTS5 | Typed queries, migrations, reactive streams. FTS5 powers chat search |
| PDF | pdfrx | Text in reading order with character boxes, outline (bookmarks), page rendering |
| LLM runtime | llamadart (llama.cpp, GGUF) | MIT, verified publisher, prebuilt native libraries for Android (and Linux, used only by the eval tool), JSON-schema `responseFormat`, streaming, embeddings, KV state save/restore. Validated in the M0 spike. Fallbacks: fllamer (explicit grammar API, but GPL-3.0 and very new) or flutter_gemma (Google's on-device runtime; JSON enforcement not confirmed, so the code checks would carry more weight) |
| Models | GGUF Q4_K_M, downloaded on first run (Wi-Fi only by default) | A ~3-4B instruct model by default (8 GB+ RAM), a ~1-2B model for low-RAM phones, and a small embedding model for chat. The exact models are picked in the spike from what's current, by measured JSON validity, acceptance rate and speed |
| Scheduling | fsrs (Dart port of py-fsrs) | FSRS scheduler and retrievability |
| OCR | Google ML Kit text recognition | On-device, behind an `OcrEngine` interface |
| Web | http, Wikipedia API, pluggable search provider | Off by default |
| Power | battery_plus | Charging state and level for the power policy |
| Look | Source Sans 3 (SIL Open Font License), bundled | Ink and paper neutrals with one amber accent, 4 px corners, light and dark themes (section 18) |
| Background (Android) | Foreground service with a progress notification | Android stops long background work otherwise |

## 4. Architecture

```
┌───────────────────────── Flutter UI ─────────────────────────┐
│ Library · Outline / Mastery map · Study · Chat · Settings    │
└────────────────┬───────────────────────────────┬─────────────┘
                 │ Riverpod providers            │
┌────────────────▼────────┐    ┌─────────────────▼─────────────┐
│ Import pipeline         │    │ Study engine                  │
│ pdfrx → clean → tree    │    │ FSRS · session builder ·      │
│ → chunks → FTS index    │    │ mastery roll-up               │
└────────────────┬────────┘    └─────────────────┬─────────────┘
┌────────────────▼───────────────────────────────▼─────────────┐
│ Job runner (persisted queue, resumable, prioritized)         │
│   facts → questions → checks → critique → web check          │
└───────┬────────────────────┬────────────────────┬────────────┘
┌───────▼────────┐  ┌────────▼─────────┐  ┌───────▼────────────┐
│ LlmEngine      │  │ drift / SQLite   │  │ WebClient          │
│ llamadart      │  │ FTS5, caches     │  │ search · fetch ·   │
│ (fake in tests)│  │                  │  │ extract · cache    │
└────────────────┘  └──────────────────┘  └────────────────────┘
```

The pipeline is plain Dart behind interfaces (`LlmEngine`, `OcrEngine`, `SearchProvider`, `Clock`), so most of it can be unit-tested without a model or a device. Model calls run off the UI isolate.

## 5. Import pipeline

1. **Extract** with pdfrx: per-page text in reading order with character boxes, plus the outline. A character-to-(page, box) map is kept so any quote can be highlighted later.
2. **Scanned pages**: a page with fewer than 20 characters of text is rendered at 2x and read with ML Kit text recognition. The recognized line boxes are scaled back to PDF points, so heading detection works as it does on text pages. ML Kit's bundled model reads Latin script only. If recognition fails, the page stays flagged as unreadable. (M7, on the emulator: a two-page scanned fixture came back word for word, with both headings found.)
3. **Clean**: Unicode NFKC (ﬁ becomes fi), straight quotes, hyphenated line breaks joined (`exam-` + `ple` becomes `example`), paragraphs rebuilt from vertical gaps, running headers and footers removed (lines repeated at the same position on 40%+ of pages, with digits normalized so page numbers match).
4. **Language**: detected per document. Prompts ask for output in that language and a check rejects output in another one.
5. **Structure**: the section tree comes from the PDF outline. Without one, heading detection (taller glyphs, short line, numbering like `3.2`, body text after it). Without headings (plain text, slides), the model labels each chunk with a 2-5 word topic and consecutive chunks with the same label are merged.
6. **Non-study content**: the table of contents, index, references, copyright page and front matter are tagged and skipped (dot leaders followed by page numbers, citation patterns, headings like "References"). Chunks that are mostly symbols after extraction (equations) are flagged as low confidence.
7. **Chunk**: inside a section, whole paragraphs are packed to about 350-600 tokens. Sentences are never split. Tiny sections merge into a neighbor but keep their own topic. Each chunk stores its heading path ("3 Cells › 3.2 Osmosis"), pages and offsets.
8. **Index**: FTS5 over chunk text and heading path. Embeddings are computed in the background after import if the spike shows they're cheap enough.

Import takes seconds. The outline is visible before any generation starts.

## 6. Generation

### 6.1 Facts

One call per chunk. The model lists the facts a student should learn. For each it returns a verbatim supporting sentence (`quote`), a one-line `statement`, the `key_term`, and an `importance` from 1 to 3. The number of facts requested scales with chunk length (about one per 100-120 tokens, capped).

Each quote is located in the chunk with the matcher from section 7. Facts whose quote can't be found are dropped. The stored match offsets give the page and the boxes to highlight. Near-duplicate facts across the document are merged.

Facts are the unit of progress. Questions are interchangeable ways of testing a fact.

### 6.2 Questions

| Type | Made by | Notes |
|---|---|---|
| Cloze | Code | Blanks the fact's `key_term` inside the verified quote. No extra model call, and almost always correct. Rejected if the term is missing, appears twice or is a stopword |
| Flashcard | Model (inside the fact call at Quick) | Front is a question, back is a short answer grounded in the quote |
| Multiple choice | Model | Question, correct answer, 3 distractors, explanation. Options are shuffled in code at display time |
| Short answer (later) | Model grades a typed answer against the stored key and quote | Only after the eval shows the grader is reliable |

True/false is left out: a 50% guessing rate gives a weak signal.

Prompt layout is `[system rules][chunk][task]`, and each chunk gets as few model calls as possible: one call extracts the facts (with flashcards and key terms), one writes the multiple-choice questions for all of the chunk's facts, and one runs the blind check on all of them. Qwen3.5 is a hybrid model (recurrent layers plus an attention layer every fourth layer), and llama.cpp can't reuse a cached prompt prefix for hybrid models, so every call re-reads the chunk (measured in M0). Batching keeps that to a few reads per chunk. The chunk still comes first, so models that do support prefix reuse get it for free. The schema puts the evidence first (`quote`, then `question`, `answer`, `distractors`, `explanation`), so the model commits to the source before it writes.

JSON comes from a fast path: the prompt shows the expected shape, the reply is extracted and validated against the schema in Dart, and only a reply that fails validation is retried with grammar-constrained decoding. llamadart 0.20 applies the grammar to the whole vocabulary on every token, which made a question about 4.5x slower in M0 (32 s against 7 s with the 0.8B model on the laptop).

As built (M7): before falling back to the grammar, the engine repairs common near-misses (numbers written as text, integers out of range, too many array items, fields the schema doesn't allow, enum values with different case or punctuation) and gives the fast path a second try at a higher temperature. A Quick run on the emulator had been much slower than expected, probably because of grammar retries. After the change, the 0.8B model's test question on the laptop needed no retry.

Prompts are versioned. Every stored item records the model, prompt version and profile that produced it.

## 7. Verification

Code checks, at every level:

| Check | Rule |
|---|---|
| Schema | Fast path: validation, then repair, then a second try; constrained decoding only as a fallback (section 6.2) |
| Quote found | Normalize both sides (NFKC, case, quotes, whitespace, hyphens), try an exact search, then a fuzzy partial match of 0.92 or higher |
| Answer grounded | For Recall and Understand, most content words of the answer (60%+) appear in the quote or fact. Apply and Analyze questions rely on the blind check instead |
| Distractors | Three distinct options, none nearly equal to the answer (similarity below 0.85), no "all/none of the above" or "both A and B" |
| Length bias | The correct answer is at most 1.6x the average distractor length |
| No leak | The answer doesn't appear in the question |
| Duplicate | Not a near-duplicate of an existing question for the same fact or document |
| Language | Same script and language as the document |

Model checks:

| Check | From level | How |
|---|---|---|
| Blind answer | Standard | The model gets the chunk, the question and shuffled options without the key, and must pick one letter (schema-constrained). A wrong pick means the question is ambiguous or mis-keyed, so it is dropped or rewritten. Cheap: the chunk is cached and the output is one token |
| Second blind run | Deep | Options reshuffled to catch position bias. Uses a second model from another family if one is installed |
| Critique and rewrite | Thorough | Rubric: exactly one correct answer, distractors plausible but wrong, clear wording, actually tests the fact. Output is `{ok, problems[], rewrite}`, and a rewrite goes through every check again |
| Web fact-check | Optional | Section 12 |

Every rejection is logged with its reason. The eval report and prompt tuning both read this log.

## 8. Effort: Quality and Depth

**Quality** sets how careful generation is, and what it costs:

| | Quick | Standard (default) | Thorough | Deep |
|---|---|---|---|---|
| Model calls per chunk | 1 (facts and flashcards) | 3 (plus all MCQs, plus all blind checks) | 5 (plus critique and rewrites) | 6 or more (plus a second blind run) |
| Question types | Cloze, flashcard | Plus MCQ | Plus MCQ | Plus MCQ |
| Candidates per fact | 1 | 1 | 2, keep the best | 3, keep the best |
| Code checks | Yes | Yes | Yes | Yes |
| Blind answer | No | Yes | Yes | Twice |
| Critique and rewrite | No | No | Yes | Yes |
| Context | Chunk | Chunk | Chunk and neighbors | Chunk, neighbors and a section summary |
| Feedback | Source quote | Plus a one-line explanation | Plus why the answer is right | Plus why each distractor is wrong |
| Relative cost | 1x | ~2-3x | ~5x | ~8-10x |

The relative costs are guesses until the M0 and M2 benchmarks. The app shows measured numbers.

"Keep the best" ranks candidates in this order: passes all checks, blind check agreed (both runs at Deep), distractors similar in type and length to the answer, not similar to existing questions, matches the requested depth.

**Depth** sets what is asked (Bloom levels):

| Depth | Example | Minimum quality |
|---|---|---|
| Recall | "What is osmosis?" | Quick |
| Understand | "Which statement best describes osmosis?" | Quick |
| Apply | "Which situation is an example of osmosis?" | Standard (needs the blind check) |
| Analyze | "Why does X cause Y, given Z?" (uses neighboring sections) | Thorough (needs neighbors and critique) |

The UI enforces these minimums and explains why.

**Profile object.** Every stage reads only this:

```dart
class GenerationProfile {
  final Quality quality;          // quick | standard | thorough | deep | custom
  final Set<Depth> depth;         // recall, understand, apply, analyze
  final Map<QuestionType, double> typeMix;
  // Filled in from the quality preset. Custom edits them directly.
  final int candidatesPerFact;    // 1-3
  final int blindRuns;            // 0-2
  final bool critique;
  final ContextScope context;     // chunk | neighbors | neighborsAndSummary
  final FeedbackLevel feedback;   // quote | short | full | fullWithDistractors
  final String? judgeModelId;     // optional second model
  final bool webCheck;
}
```

The UI shows the four presets as a segmented control, and "Custom…" opens the individual fields. There is no slider, because model, checks and context are categories, not points on a line.

**Model.** Chosen from the phone's RAM and the benchmark, not from the quality level: a ~1-2B model below 8 GB of RAM, a ~3-4B model at 8 GB or more. Deep uses the same model with more checks. A second, larger model is offered only on phones with 12 GB or more, because it needs several more GB of memory.

As built (M8): the app default is chosen in Settings → AI models. Each document can choose its own model, which writes its questions and answers its new conversations, and each conversation can choose its own. A choice resolves conversation, then document, then app default, skipping files that are no longer on the phone. One model is in memory at a time: llamadart frees the old one before it loads the next, and loads run one after another. Work the user waits for (an answer, a web search, a fact check, a model test) first pauses generation, then loads its model; generation resumes afterwards and loads its document's model again, item by item. Speed tests and time estimates are kept per model file.

**Estimates.** A ~20 s benchmark on first run (and after a model change) measures prompt and generation tokens per second. The estimate is the expected prompt and output tokens per stage, summed over the chunks, divided by the measured speeds and by the expected acceptance rate. It is refined live during the run and shown per scope, for example "Chapter 3: ~6 min · whole book: ~3 h (Standard)". Battery cost is shown only after it has been measured on earlier runs on battery.

## 9. Jobs and progressive generation

- Import finishes in seconds and shows the outline.
- Work order: the section you open or start studying, then the sections after it, then the rest. A study session keeps at least 15 ready cards ahead of you.
- Two passes by default. Quick runs over the chosen scope first so you can study within minutes, then your chosen quality refines it in the background. Upgrades attach to the same facts, so review history is kept.
- Per-section quality can be set from the outline or the mastery map ("Deep on this chapter").
- **Generate more** (as built): the generate sheet can add 1 to 3 questions of one kind (multiple choice, flashcards or fill-in-the-blank) to facts that already have questions, instead of generating everything. The old questions stay. The model is told what each fact already has, code rejects repeats, multiple choice still gets the blind check (Standard and up), and flashcards and blanks are checked against the source sentence. Blanks are built by code from key terms the model names.
- **Improve this question** (as built): the card menu rewrites the question on screen from its source text, optionally guided by what is wrong with it. The rewrite passes the same code checks (and the blind check for multiple choice), is shown next to the old one, and replaces it in place when accepted, so its history stays. A card that was already answered keeps showing its answer; the new wording applies from the next time.
- **Upgrade this question** re-runs one fact at a higher level. **Report bad question** retires the question (and the fact, if the fact itself is wrong) and queues a replacement.
- Power policy, as built (M7): at 20% battery or less, when the phone isn't charging, generation pauses with a message saying why. It resumes when the phone charges or is back at 30%. A charger that is connected but not charging (a hot battery, for one) counts as not charging; the emulator also reports that state with no charger at all. If you resume or pause by hand in between, your choice stands until the battery recovers. Upgrading weak topics while charging is not built. Testing note: battery_plus reads the level from the battery service, which `adb shell dumpsys battery set` doesn't change, so on the emulator the policy is tested with `adb emu power capacity|status|ac`. Verified that way in a release build: paused at 15%, and shown as working again as soon as the emulator was plugged in.
- Jobs are persisted as small idempotent items (one chunk, one stage). Outputs are cached by `hash(chunk text, model, prompt version, stage params)`. If the app is killed, it resumes after the last finished item.
- On Android, long runs use a foreground service with a progress notification. As built (M7): a `dataSync` service (flutter_foreground_task) with a partial wake lock runs while the runner works and stops when it stops. Generation itself stays in the app's main isolate; the service only keeps the process alive (verified on the emulator: generation kept going with the app in the background). Android 15 and later allow a data-sync service 6 hours a day. When that runs out the plugin stops the service, generation goes on while the app is open, the service starts again the next time it can, and a job that Android stops resumes from its last finished item. As built (M8): the service runs whenever something long is in progress, not only generation: model downloads (with a Wi-Fi lock, so they keep their speed with the screen off), model loading, chat answers, web searches, fact checks and model tests. The notification names the most urgent one (downloads, then work the user waits for, then loading, then generation) and changes at most once a second.

## 10. Study, scheduling and mastery

**Scheduling.** Each fact has one FSRS card. A session mixes due facts with a daily number of new ones, interleaved across topics, and can be filtered to one topic. Each review shows one of the fact's questions, rotating so you don't memorize one wording. New facts tend to get multiple choice and mature facts get cloze or flashcards, because recall is harder than recognition and better for retention.

As built (after M8): every question gets its turn. A fact's next question is the one asked the fewest times, then the one asked longest ago (never asked first), and the kind only breaks ties, so no question sits unused while another is asked ten times. Facts that are known (out of their learning steps) and not due, but have a question that was never asked, join a session as "New question" cards, one per fact, interleaved after two reviews and one new fact. The Study screen counts them as "Unseen". The question just asked is skipped when another exists, so a missed fact comes back worded differently.

**Ratings sent to FSRS:**
- Flashcard and cloze: you rate Again, Hard, Good or Easy. Typed cloze answers are checked automatically.
- Multiple choice: wrong is Again, right is Good, right but slow or marked unsure is Hard. Never Easy, since recognizing an answer is weaker evidence than recalling it.
- A missed card (Again) comes back a few cards later in the same session, worded differently when the fact has another question. Cards answered right come back in a later session, when FSRS says they are due.

**Feedback** comes right after every answer: the correct answer, the source quote with its page (tap to open the page with the sentence highlighted), and the explanation for the chosen level. Buttons: Report, Upgrade, Explain in chat.

**Mastery per topic:**
- *Mastery* (the headline %): the chance of still recalling the topic's facts a week from now (FSRS retrievability seven days ahead), counting unseen facts as 0. Recall *now* was the first idea, but right after you miss a fact FSRS still predicts 90%+ recall because you have just seen the answer, which hides exactly the gaps the map is for. Looking a week ahead reflects how well a fact is learned, and still fades when you stop reviewing.
- *Coverage*: facts seen divided by facts in the topic.
- *Durable*: the share of facts with stability of 21 days or more.
- Parent topics roll up their children, weighted by fact count. A topic with fewer than 3 facts gets a "few items" badge instead of a confident color.

**Map views.** An outline tree with a bar and a due count per topic, which works on phones, and a treemap (area = number of facts, color = recall now) on wide screens. Gray means not started. Tapping a topic offers Study, Chat about it, Read pages, Generate more and Set quality.

## 11. Chat about the document

- **Retrieval**: FTS5 (BM25) over chunks, fused with embedding search by reciprocal rank fusion once embeddings exist. The last few turns are folded into the query so follow-up questions work. The top 4-6 chunks plus their neighbors go to the model, each labeled with heading path and page.
- **Answer**: streamed, from the excerpts only, with `[p. 12]` citations that open the page. Sentences with no support in the cited excerpts are dimmed and marked "not from your PDF" (a cheap overlap check).
- **Not found**: when retrieval scores are low or the model says the document doesn't cover it, the chat offers "Not in your PDF. Search the web?" (only if web access is on).
- **Modes**: Ask, Explain (short or worked through, per the tutoring setting), Quiz me (asks your weakest due facts conversationally and grades against the stored answer and quote), Summarize section.
- **Make a card**: turns a chat answer into a fact. Its quote is verified against the cited chunk before it enters your schedule.
- **Context budget**: small models have 4-8k tokens of context, so a thread keeps the last few turns plus a running summary.

Chat and flashcards share the same facts, so both feed one mastery map.

As built (M5): retrieval is FTS5 alone, with stemmed prefix terms so "osmotic" finds "osmosis"; embeddings can come later. A sentence that cites an excerpt that wasn't given (on the emulator the 0.8B model invented "[5]" with three excerpts and a false inventor of the microscope) counts as unsupported, and a reply that is mostly unsupported counts as "not covered", which offers the web search and hides "Save as card". A chat message pauses background generation (its current step is cancelled and retried later) so the reply doesn't wait behind it. Quiz-me mode is not built yet.

As built (M8): a document has any number of conversations, the most recently active first. An empty one is reused rather than piling up, and each takes its title from its first question. The header shows the conversation's model as a chip, which also changes it (section 8). Stopping an answer keeps what was written so far.

## 12. Web access and fact-checking

The model never browses on its own. The app runs a fixed pipeline and asks the model only to fill small, schema-constrained slots. With small models this is more reliable than tool calling, and it limits what a malicious page can do.

1. **Claim**: a statement built from a question and its answer, or a sentence from a chat answer.
2. **Query**: one or two short search queries (model, schema-constrained). Whole passages from the document are never sent.
3. **Search**: Wikipedia's API first, in the document's language. Then, if configured, a SearXNG instance you run. (Search APIs that need a key, such as Brave or Tavily, are not built yet.)
4. **Fetch** the top 3-5 results with timeouts, a 2 MB cap, HTML or plain text only, robots.txt respected, cached for 7 days. Main text is extracted (Wikipedia through its plain-text API, other sites with a readability-style heuristic).
5. **Rank** passages against the claim and keep the best 3.
6. **Judge** each passage: `{verdict: supports | contradicts | unrelated, quote}`.
7. **Verify** that the quote exists in the fetched text, with the same matcher as section 7.
8. **Result**: corroborated (a verified supporting quote and no verified contradiction), conflict (the PDF quote and the web quote side by side, with links), or not found.
9. **Never auto-correct** the answer that came from the PDF. Your course may define things differently from the web, and the web can be wrong. You choose: keep it, mark the fact as wrong, or add a note.

**Where it's used:** a "Check on the web" button on any card or chat answer, per-section checks, and optionally inside Deep runs. It is not a default for a whole book: each check is 1-3 page fetches and 2-4 model calls, roughly 10-60 s on device.

**In chat:** a web toggle on each message. Web excerpts are labeled with their site and PDF excerpts with their page, and the answer cites both.

**Privacy and safety:**
- Off by default and enabled per document. Queries reveal what you're studying, and include a few words from it.
- A Web activity screen lists every query sent and every URL fetched.
- Fetched text is treated as untrusted data: scripts and hidden elements are stripped, passages are length-capped, the model has no tools it can trigger, a verdict needs a verified quote, and conflicts go to you.

## 13. Data model (drift / SQLite)

```
documents          id, title, path, sha256, pages, language, imported_at, settings, model_path
sections           id, document_id, parent_id, title, level, ord, page_start, page_end
chunks             id, document_id, section_id, ord, text, heading_path, page_start, page_end,
                   char_start, char_end, tokens, kind (study|toc|index|refs|front|math), sha256
chunks_fts         FTS5(text, heading_path)
embeddings         chunk_id, model_id, vector
facts              id, chunk_id, section_id, statement, quote, quote_start, quote_end,
                   key_term, importance, status (active|retired|disputed)
questions          id, fact_id, type, depth, prompt, answer, distractors, explanation,
                   quality, model_id, prompt_version, checks, status (active|retired|reported)
question_sections  question_id, section_id          -- Analyze questions span sections
fact_cards         fact_id, fsrs_state, due, stability, difficulty, last_review
reviews            id, fact_id, question_id, rating, correct, response_ms, unsure, reviewed_at
jobs               id, document_id, scope, profile, status, priority, created_at, updated_at
job_items          id, job_id, chunk_id, stage, status, attempts, cache_key, error
llm_cache          cache_key, output, created_at
rejections         id, chunk_id, stage, reason, payload, created_at
chat_threads       id, document_id, title, summary, created_at, model_path
chat_messages      id, thread_id, role, content, citations, used_web, created_at
web_pages          url, fetched_at, title, text, status
web_log            id, query, provider, urls, at
fact_checks        id, fact_id, question_id, claim, verdict, evidence, created_at
models             id, name, path, kind (chat|embed), bytes, quant, bench_prompt_tps, bench_gen_tps
```

## 14. Testing and evaluation

- **Unit tests** in plain Dart, no model needed: normalization, de-hyphenation, header and footer removal, heading detection, chunking, the quote matcher, every check, the cloze builder, option shuffling, the FSRS rating mapping, mastery roll-up, retrieval fusion, job resume.
- **Pipeline tests** with a `FakeLlmEngine` that returns scripted JSON, including malformed and adversarial output.
- **Fixtures**: a few small, openly licensed PDFs: a textbook chapter, a slide deck, a scanned page and a non-English text. As built: `tool/fixtures/make_fixture_pdfs.py` generates a textbook (with and without bookmarks) and a scanned two-page PDF. The slide deck and the non-English text are still to do.
- **Eval tool** (as built: `test/integration/eval_test.dart`, run with `TEST_MODEL=<model file>` and `--tags model`): runs on the laptop with the same model files the phone uses, over the fixtures at each quality level. It reports the acceptance rate per check and blind-check agreement, and writes 20 random questions to a markdown file for rating by hand. Speed comes from the in-app benchmark on the phone, never from the laptop. Together they decide whether Thorough and Deep are worth their cost.
- **In the app**: the report rate per quality level and model.

## 15. Milestones

| # | Milestone | Done when |
|---|---|---|
| M0 | Foundations and runtime spike | Git repo, unused platform folders removed, app shell, drift schema, `LlmEngine` with llamadart on an Android phone: the default model returns schema-valid JSON and streams, and the benchmark records tokens/s on the phone. Go/no-go decision on llamadart |
| M1 | Import | PDF/TXT/MD become cleaned text, a section tree and chunks, with non-study pages skipped and pages without text flagged. Library, outline and section screens |
| M2 | Generation | Facts, cloze, flashcard and MCQ, all checks, profiles, resumable prioritized jobs, estimates, rejection log, eval tool |
| M3 | Study | FSRS, sessions, the three card screens, feedback with the highlighted source page, report and upgrade |
| M4 | Mastery map | Roll-up metrics, outline and treemap views, topic actions, per-section quality |
| M5 | Chat | Retrieval, streamed answers with citations, not-found handling, modes, make-a-card |
| M6 | Web | Providers, fetch/extract/cache, fact-check pipeline, conflict view, web in chat, activity log |
| M7 | Polish | Text recognition for scanned pages (moved from M1), power policy, Android foreground service, settings, CSV export (Anki later), presets tuned from eval results |
| M8 | Identity and models | The Local AI Tutor name, icon and splash; a compact, low-radius redesign in light and dark; a model per document and per conversation; the background service also covering downloads, loading and answers |

Status, 2026-11-21: M0 to M8 are built (M2 to M6 share one commit). Schema 2 adds the two `model_path` columns with a real migration, tested on a database written by schema 1 (earlier upgrades rebuilt the database); the emulator's data survived it too. Verified for M8 in a release build on the emulator: the launcher icon and splash; every screen in light and dark mode; a 533 MB model download that kept going with the app in the background (26% to 68% in 30 seconds, done in about a minute and a half, its notification gone after); and two conversations of one document answering with different model files, the app swapping the file in memory between them. The check caught five problems, all fixed: the send button's icon was invisible (IconButton takes any non-default ambient icon color as every variant's foreground, so the theme sets none); start-aligned tabs need a scrollable TabBar (a debug build would have asserted); bottom sheets opened under the navigation bar (they now use the root navigator); a copied-in file with a catalog name looked identical to its download (it is tagged "Copied in"); and the 0.8B model's `**bold**` showed as asterisks (answers now render it). Release builds need the R8 rules in `android/app/proguard-rules.pro`: ML Kit refers to script recognizers the app doesn't bundle, and creates its components by reflection, so without them the build fails and then text recognition fails at runtime. Verified in a release build on the emulator: text recognition of a scanned page, the foreground service notification, and the battery pause. Not built yet:

- Study: opening the source page with the sentence highlighted (feedback shows the quote and its page number), Upgrade this question, a replacement queued after a report, and a buffer of ready cards kept ahead of a session.
- Chat: the Quiz me and Summarize section modes, and embeddings (retrieval is FTS5 alone).
- Web: search providers that need a key (Brave, Tavily).
- Polish: CSV and Anki export, and Wi-Fi-only downloads (the model screen warns about mobile data instead). Presets are tuned only by the M2 eval so far (prompt version 2).
- Release: a real application ID (still `com.example`), release signing, and measurements on a real phone. Builds should target arm64 and x86_64 only (`--target-platform android-arm64,android-x64`): llamadart has no 32-bit ARM libraries. The arm64 APK is 94 MB, 25 MB of it llama.cpp's Vulkan backend, which hasn't been compared with the CPU backend on a phone yet.

## 16. Risks and open questions

- **Multiple-choice quality from small models**, especially distractors and non-English documents. Measured in M2. Quick (cloze and flashcards) is the fallback that always works.
- **No prompt-prefix reuse with Qwen3.5** (hybrid architecture). Every call re-reads its chunk, so calls per chunk are batched. A pure-attention model family would get reuse; worth re-checking when new small models ship.
- **llamadart moves fast**, and its grammar sampler is slow (whole vocabulary per token). The JSON fast path avoids it; worth reporting upstream.
- **Phone heat and battery** on long runs. Handled by resumable jobs and the power policy. Heat isn't measured; the battery level is the only signal.
- **Equations, tables and figures** don't survive text extraction. They are flagged for now. Page images with a vision model could come later.
- **Model downloads are 0.5-2.7 GB.** The model screen warns about mobile data; Wi-Fi-only downloads are not built.
- **Licenses**: pdfrx/PDFium and llamadart are permissive. fllamer is GPL-3.0, which would make a distributed app GPL. ML Kit has Google's terms, and each model has its own license.

## 17. Measurements

M0, on the development laptop (Ryzen 7 PRO 4750U, llama.cpp on the integrated GPU through Vulkan). Phone numbers come from the Model Lab speed test, which saves each run.

| Model | Reads (tokens/s) | Writes (tokens/s) | One multiple-choice question | Notes |
|---|---|---|---|---|
| Qwen3.5 0.8B Q4_K_M | 389 | 26.5 | 7-10 s | Valid JSON, but wrong answers were true sentences copied from the passage |
| Qwen3.5 4B Q4_K_M | 68 | 6.7 | 34 s | Conceptual question with plausible wrong answers; two of them meant the same thing |

- Grammar-constrained JSON: 32 s per question with the 0.8B model against 7 s for the fast path (sampling took 18 s of the 32).
- Prompt-prefix reuse: 0% for both models (hybrid architecture).

M2 eval, 4B model, Standard, on the fixture textbook (4 short passages, laptop): 8 facts, all with verified quotes; 8 cloze cards, 8 flashcards, 6 multiple-choice questions, all passing the blind check; 2 multiple-choice questions rejected for length bias (correct answer about twice as long as the wrong ones), which led to a shorter-answer rule in prompt version 2. Time per passage: facts 77 s, questions 102 s, blind check 15 s (3.2 min in all).

M7, after the JSON repair, 0.8B model on the laptop with the Android emulator running alongside: reads 256 tokens/s, writes 15.7 tokens/s, 14-16 s per question, valid JSON with no constrained retry.

## 18. Identity and interface

As built (M8).

- **Name and mark.** Local AI Tutor. The mark is an open book (two pages with sharp corners) and an amber spark above the spine, drawn on a 24-unit grid. The in-app `AppMark` and `tool/branding/make_icons.py` share that geometry; the script writes the adaptive and themed launcher icons, the Android 12+ splash, the notification icon, PNGs for Android 7 and a 512 px store icon.
- **Color.** Ink (#15171C) and warm paper (#F6F5F2) neutrals; in dark mode, paper-white on near-black. One amber accent (#E39A2D, #F0AE4C in dark mode) marks progress, highlights and the AI spark. Green and red are kept for right and wrong answers; mastery goes from rust through amber to green. Primary buttons are ink (paper in dark mode), not colored.
- **Shape and density.** 4 px corners on cards, buttons and inputs, 2 px on tags and bars, 6 px on the top of sheets; a square switch instead of Material's pill. Hairline borders instead of shadows. Compact density and 16 px page gutters; lists are rows in one bordered panel rather than separate cards.
- **Type.** Source Sans 3, bundled under the SIL Open Font License (listed on the licenses page). Small uppercase labels name sections; stats use tabular figures.
- **Components** (`lib/app/ui.dart`): Panel, PanelList and PanelRow, SectionLabel, Stat and StatRow, ThinBar, Tag, EmptyState, ModelChip, FileGlyph, SharpSwitch, Wordmark. The theme (`lib/app/theme.dart`) sets every Material component to match, so new screens get the look by default.
