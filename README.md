# PDF Study Assistant

An Android app that turns a PDF or a text file into study material with a language model that runs on the phone. It finds the facts in each section, checks each one against a quote from the source, and writes cloze cards, flashcards and multiple-choice questions from them. You study with spaced repetition (FSRS), and a mastery map shows which sections you know. A chat answers questions about the document with citations. If you turn web access on, cards and answers can be checked against Wikipedia or a search server you run.

Nothing leaves the phone unless you turn web access on. Otherwise the network is only used to download a model.

[DESIGN.md](DESIGN.md) has the design, the reasons behind it and the measurements.

## Features

- **Import.** PDF, `.txt` and `.md`. The outline comes from the PDF's bookmarks, or from detected headings when there are none. Running headers and footers, contents pages, the index and the references are left out. Scanned pages are read with on-device text recognition (ML Kit, Latin script only).
- **Generation.** You pick a quality level and the kinds of questions (Depth).
  - Quick: one model call per passage, for facts, cloze cards and flashcards.
  - Standard: adds multiple-choice questions and a blind check, in which the model answers each question without seeing the key.
  - Thorough: adds a critique that rewrites weak questions, and two candidates per fact.
  - Deep: three candidates per fact and a second blind check.

  A fact is kept only if its quote is found in the source. Questions also go through code checks: the answer has to come from the quote, a distractor may not be true according to the source, the right answer may not stand out by its length, and repeats are dropped. Depth goes from Recall and Understand to Apply (Standard and up) and Analyze (Thorough and up).
- **Background work.** Generation runs in a foreground service with a progress notification, picks up where it stopped after the app restarts, and pauses at 20% battery when the phone isn't charging. You can study the sections that are ready while the rest is generated.
- **Study.** Flashcards, typed cloze answers and multiple choice. FSRS schedules each fact. You can report a bad card.
- **Mastery.** Predicted recall a week from now for each section, as a list and as a treemap.
- **Chat.** Answers are built from the document's passages (full-text search) and cite them as [1], [2]. An answer that the passages don't support is marked as not covered by the document and can't be saved as a card.
- **Web (off by default).** Searches Wikipedia, or a SearXNG server you set up. A verdict is given only when a quote from the page supports it. When the page conflicts with the document, the app shows the conflict and leaves your cards as they are. You allow web access per document, and Settings → Web access lists every query sent.

## Models

The app runs GGUF models with llama.cpp through [llamadart](https://pub.dev/packages/llamadart). Settings → AI model recommends one of these from the phone's RAM and downloads it from Hugging Face:

| Model | Download | Recommended when the phone reports |
|---|---|---|
| Qwen3.5-4B Q4_K_M | 2.7 GB | 6.5 GiB of RAM or more (phones sold as 8 GB) |
| Qwen3.5-2B Q4_K_M | 1.3 GB | 4.5 GiB or more |
| Qwen3.5-0.8B Q4_K_M | 533 MB | less than 4.5 GiB |

The files are unsloth's GGUF conversions of Qwen3.5 (Apache-2.0). The same screen has a speed test, which the time estimates are based on.

To put a model on a debug build without downloading it on the phone, copy it into the app's `sideload` folder; the AI model screen lists it next to the downloads:

```bash
adb push Qwen3.5-0.8B-Q4_K_M.gguf /data/local/tmp/
```

```bash
adb shell "run-as com.example.pdf_study_assistant sh -c 'mkdir -p files/sideload && cp /data/local/tmp/Qwen3.5-0.8B-Q4_K_M.gguf files/sideload/'"
```

## Build

You need Flutter 3.44 (Dart 3.12) and the Android SDK. The app runs on 64-bit Android 7.0 (API 24) or later: llamadart ships llama.cpp for arm64-v8a and x86_64 only, so a 32-bit build would install but couldn't run a model. The first build downloads the llama.cpp and PDFium libraries through build hooks.

```bash
flutter pub get
```

```bash
flutter run
```

```bash
flutter build apk --release --split-per-abi --target-platform android-arm64,android-x64
```

This writes one APK per CPU type to `build/app/outputs/flutter-apk/`: arm64 for phones, x86_64 for the emulator.

Before publishing, change the application ID (still `com.example.pdf_study_assistant`) and set up release signing in `android/app/build.gradle.kts`. For now, release builds are signed with the debug key.

## Tests

The unit and widget tests use an in-memory database and a fake model:

```bash
flutter test
```

The two real-model tests are skipped unless `TEST_MODEL` names a GGUF file. Keep model files in `models/`, which git ignores. This one checks JSON output, streaming and speed:

```bash
TEST_MODEL=models/Qwen3.5-0.8B-Q4_K_M.gguf flutter test --tags model test/integration/model_host_test.dart
```

This one generates questions for the fixture textbook and writes a report to `build/eval/`, for judging question quality:

```bash
TEST_MODEL=models/Qwen3.5-4B-Q4_K_M.gguf EVAL_QUALITY=standard flutter test --tags model test/integration/eval_test.dart
```

A model writes much the same questions on a laptop as on a phone, so quality can be judged on the laptop. Speed can't.

`tool/fixtures/make_fixture_pdfs.py` builds the PDFs in `test/fixtures/`. It needs reportlab, Pillow and the Liberation fonts.

## Layout

| Path | Contents |
|---|---|
| `lib/core/ingest` | PDF and text extraction, text recognition, cleanup, outline, chunking |
| `lib/core/llm` | The llama.cpp engine, JSON handling, model catalog and storage |
| `lib/core/generate` | Prompts, checks, the job queue and runner, battery policy, estimates |
| `lib/core/study` | Scheduling, study sessions, mastery and the treemap layout |
| `lib/core/chat`, `lib/core/web` | Passage search, chat, web search and fact checks |
| `lib/core/db` | drift (SQLite) tables and queries |
| `lib/features` | Screens, one folder per feature |
| `test/integration` | Real-model tests |

## Known limits

- Speed and battery use have only been measured on a laptop and an emulator, not on a real phone.
- Qwen3.5 models mix attention and state-space layers, so llama.cpp can't reuse a prompt prefix from one call to the next. The app batches each passage's work into as few calls as it can instead.
- Text recognition reads Latin script only.
- Not built yet: export to CSV or Anki, a quiz mode in the chat, and search providers other than Wikipedia and SearXNG.
