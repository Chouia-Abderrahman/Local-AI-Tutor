// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DocumentsTable extends Documents
    with TableInfo<$DocumentsTable, StudyDocument> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourcePathMeta = const VerificationMeta(
    'sourcePath',
  );
  @override
  late final GeneratedColumn<String> sourcePath = GeneratedColumn<String>(
    'source_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('importing'),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _settingsJsonMeta = const VerificationMeta(
    'settingsJson',
  );
  @override
  late final GeneratedColumn<String> settingsJson = GeneratedColumn<String>(
    'settings_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _modelPathMeta = const VerificationMeta(
    'modelPath',
  );
  @override
  late final GeneratedColumn<String> modelPath = GeneratedColumn<String>(
    'model_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    sourcePath,
    sha256,
    pageCount,
    language,
    status,
    errorMessage,
    settingsJson,
    importedAt,
    modelPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudyDocument> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('source_path')) {
      context.handle(
        _sourcePathMeta,
        sourcePath.isAcceptableOrUnknown(data['source_path']!, _sourcePathMeta),
      );
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('settings_json')) {
      context.handle(
        _settingsJsonMeta,
        settingsJson.isAcceptableOrUnknown(
          data['settings_json']!,
          _settingsJsonMeta,
        ),
      );
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    }
    if (data.containsKey('model_path')) {
      context.handle(
        _modelPathMeta,
        modelPath.isAcceptableOrUnknown(data['model_path']!, _modelPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudyDocument map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudyDocument(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      sourcePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_path'],
      ),
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      settingsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settings_json'],
      ),
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
      modelPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_path'],
      ),
    );
  }

  @override
  $DocumentsTable createAlias(String alias) {
    return $DocumentsTable(attachedDatabase, alias);
  }
}

class StudyDocument extends DataClass implements Insertable<StudyDocument> {
  final int id;
  final String title;
  final String? sourcePath;
  final String sha256;
  final int pageCount;
  final String? language;

  /// importing | ready | failed
  final String status;
  final String? errorMessage;
  final String? settingsJson;
  final DateTime importedAt;

  /// The model file that generates for this document and answers its new
  /// conversations. Null: the app's default model. (Schema 2.)
  final String? modelPath;
  const StudyDocument({
    required this.id,
    required this.title,
    this.sourcePath,
    required this.sha256,
    required this.pageCount,
    this.language,
    required this.status,
    this.errorMessage,
    this.settingsJson,
    required this.importedAt,
    this.modelPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || sourcePath != null) {
      map['source_path'] = Variable<String>(sourcePath);
    }
    map['sha256'] = Variable<String>(sha256);
    map['page_count'] = Variable<int>(pageCount);
    if (!nullToAbsent || language != null) {
      map['language'] = Variable<String>(language);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || settingsJson != null) {
      map['settings_json'] = Variable<String>(settingsJson);
    }
    map['imported_at'] = Variable<DateTime>(importedAt);
    if (!nullToAbsent || modelPath != null) {
      map['model_path'] = Variable<String>(modelPath);
    }
    return map;
  }

  DocumentsCompanion toCompanion(bool nullToAbsent) {
    return DocumentsCompanion(
      id: Value(id),
      title: Value(title),
      sourcePath: sourcePath == null && nullToAbsent
          ? const Value.absent()
          : Value(sourcePath),
      sha256: Value(sha256),
      pageCount: Value(pageCount),
      language: language == null && nullToAbsent
          ? const Value.absent()
          : Value(language),
      status: Value(status),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      settingsJson: settingsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(settingsJson),
      importedAt: Value(importedAt),
      modelPath: modelPath == null && nullToAbsent
          ? const Value.absent()
          : Value(modelPath),
    );
  }

  factory StudyDocument.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudyDocument(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      sourcePath: serializer.fromJson<String?>(json['sourcePath']),
      sha256: serializer.fromJson<String>(json['sha256']),
      pageCount: serializer.fromJson<int>(json['pageCount']),
      language: serializer.fromJson<String?>(json['language']),
      status: serializer.fromJson<String>(json['status']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      settingsJson: serializer.fromJson<String?>(json['settingsJson']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
      modelPath: serializer.fromJson<String?>(json['modelPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'sourcePath': serializer.toJson<String?>(sourcePath),
      'sha256': serializer.toJson<String>(sha256),
      'pageCount': serializer.toJson<int>(pageCount),
      'language': serializer.toJson<String?>(language),
      'status': serializer.toJson<String>(status),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'settingsJson': serializer.toJson<String?>(settingsJson),
      'importedAt': serializer.toJson<DateTime>(importedAt),
      'modelPath': serializer.toJson<String?>(modelPath),
    };
  }

  StudyDocument copyWith({
    int? id,
    String? title,
    Value<String?> sourcePath = const Value.absent(),
    String? sha256,
    int? pageCount,
    Value<String?> language = const Value.absent(),
    String? status,
    Value<String?> errorMessage = const Value.absent(),
    Value<String?> settingsJson = const Value.absent(),
    DateTime? importedAt,
    Value<String?> modelPath = const Value.absent(),
  }) => StudyDocument(
    id: id ?? this.id,
    title: title ?? this.title,
    sourcePath: sourcePath.present ? sourcePath.value : this.sourcePath,
    sha256: sha256 ?? this.sha256,
    pageCount: pageCount ?? this.pageCount,
    language: language.present ? language.value : this.language,
    status: status ?? this.status,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    settingsJson: settingsJson.present ? settingsJson.value : this.settingsJson,
    importedAt: importedAt ?? this.importedAt,
    modelPath: modelPath.present ? modelPath.value : this.modelPath,
  );
  StudyDocument copyWithCompanion(DocumentsCompanion data) {
    return StudyDocument(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      sourcePath: data.sourcePath.present
          ? data.sourcePath.value
          : this.sourcePath,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      language: data.language.present ? data.language.value : this.language,
      status: data.status.present ? data.status.value : this.status,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      settingsJson: data.settingsJson.present
          ? data.settingsJson.value
          : this.settingsJson,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
      modelPath: data.modelPath.present ? data.modelPath.value : this.modelPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudyDocument(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('sourcePath: $sourcePath, ')
          ..write('sha256: $sha256, ')
          ..write('pageCount: $pageCount, ')
          ..write('language: $language, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('importedAt: $importedAt, ')
          ..write('modelPath: $modelPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    sourcePath,
    sha256,
    pageCount,
    language,
    status,
    errorMessage,
    settingsJson,
    importedAt,
    modelPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudyDocument &&
          other.id == this.id &&
          other.title == this.title &&
          other.sourcePath == this.sourcePath &&
          other.sha256 == this.sha256 &&
          other.pageCount == this.pageCount &&
          other.language == this.language &&
          other.status == this.status &&
          other.errorMessage == this.errorMessage &&
          other.settingsJson == this.settingsJson &&
          other.importedAt == this.importedAt &&
          other.modelPath == this.modelPath);
}

class DocumentsCompanion extends UpdateCompanion<StudyDocument> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> sourcePath;
  final Value<String> sha256;
  final Value<int> pageCount;
  final Value<String?> language;
  final Value<String> status;
  final Value<String?> errorMessage;
  final Value<String?> settingsJson;
  final Value<DateTime> importedAt;
  final Value<String?> modelPath;
  const DocumentsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.sourcePath = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.language = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.settingsJson = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.modelPath = const Value.absent(),
  });
  DocumentsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.sourcePath = const Value.absent(),
    required String sha256,
    this.pageCount = const Value.absent(),
    this.language = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.settingsJson = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.modelPath = const Value.absent(),
  }) : title = Value(title),
       sha256 = Value(sha256);
  static Insertable<StudyDocument> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? sourcePath,
    Expression<String>? sha256,
    Expression<int>? pageCount,
    Expression<String>? language,
    Expression<String>? status,
    Expression<String>? errorMessage,
    Expression<String>? settingsJson,
    Expression<DateTime>? importedAt,
    Expression<String>? modelPath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (sourcePath != null) 'source_path': sourcePath,
      if (sha256 != null) 'sha256': sha256,
      if (pageCount != null) 'page_count': pageCount,
      if (language != null) 'language': language,
      if (status != null) 'status': status,
      if (errorMessage != null) 'error_message': errorMessage,
      if (settingsJson != null) 'settings_json': settingsJson,
      if (importedAt != null) 'imported_at': importedAt,
      if (modelPath != null) 'model_path': modelPath,
    });
  }

  DocumentsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? sourcePath,
    Value<String>? sha256,
    Value<int>? pageCount,
    Value<String?>? language,
    Value<String>? status,
    Value<String?>? errorMessage,
    Value<String?>? settingsJson,
    Value<DateTime>? importedAt,
    Value<String?>? modelPath,
  }) {
    return DocumentsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      sourcePath: sourcePath ?? this.sourcePath,
      sha256: sha256 ?? this.sha256,
      pageCount: pageCount ?? this.pageCount,
      language: language ?? this.language,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      settingsJson: settingsJson ?? this.settingsJson,
      importedAt: importedAt ?? this.importedAt,
      modelPath: modelPath ?? this.modelPath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (sourcePath.present) {
      map['source_path'] = Variable<String>(sourcePath.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (settingsJson.present) {
      map['settings_json'] = Variable<String>(settingsJson.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (modelPath.present) {
      map['model_path'] = Variable<String>(modelPath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('sourcePath: $sourcePath, ')
          ..write('sha256: $sha256, ')
          ..write('pageCount: $pageCount, ')
          ..write('language: $language, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('importedAt: $importedAt, ')
          ..write('modelPath: $modelPath')
          ..write(')'))
        .toString();
  }
}

class $SectionsTable extends Sections with TableInfo<$SectionsTable, Section> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<int> documentId = GeneratedColumn<int>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documents (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordMeta = const VerificationMeta('ord');
  @override
  late final GeneratedColumn<int> ord = GeneratedColumn<int>(
    'ord',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageStartMeta = const VerificationMeta(
    'pageStart',
  );
  @override
  late final GeneratedColumn<int> pageStart = GeneratedColumn<int>(
    'page_start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageEndMeta = const VerificationMeta(
    'pageEnd',
  );
  @override
  late final GeneratedColumn<int> pageEnd = GeneratedColumn<int>(
    'page_end',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    documentId,
    parentId,
    title,
    level,
    ord,
    pageStart,
    pageEnd,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Section> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('ord')) {
      context.handle(
        _ordMeta,
        ord.isAcceptableOrUnknown(data['ord']!, _ordMeta),
      );
    } else if (isInserting) {
      context.missing(_ordMeta);
    }
    if (data.containsKey('page_start')) {
      context.handle(
        _pageStartMeta,
        pageStart.isAcceptableOrUnknown(data['page_start']!, _pageStartMeta),
      );
    } else if (isInserting) {
      context.missing(_pageStartMeta);
    }
    if (data.containsKey('page_end')) {
      context.handle(
        _pageEndMeta,
        pageEnd.isAcceptableOrUnknown(data['page_end']!, _pageEndMeta),
      );
    } else if (isInserting) {
      context.missing(_pageEndMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Section map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Section(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}document_id'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      ord: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ord'],
      )!,
      pageStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_start'],
      )!,
      pageEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_end'],
      )!,
    );
  }

  @override
  $SectionsTable createAlias(String alias) {
    return $SectionsTable(attachedDatabase, alias);
  }
}

class Section extends DataClass implements Insertable<Section> {
  final int id;
  final int documentId;
  final int? parentId;
  final String title;
  final int level;
  final int ord;
  final int pageStart;
  final int pageEnd;
  const Section({
    required this.id,
    required this.documentId,
    this.parentId,
    required this.title,
    required this.level,
    required this.ord,
    required this.pageStart,
    required this.pageEnd,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['document_id'] = Variable<int>(documentId);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    map['title'] = Variable<String>(title);
    map['level'] = Variable<int>(level);
    map['ord'] = Variable<int>(ord);
    map['page_start'] = Variable<int>(pageStart);
    map['page_end'] = Variable<int>(pageEnd);
    return map;
  }

  SectionsCompanion toCompanion(bool nullToAbsent) {
    return SectionsCompanion(
      id: Value(id),
      documentId: Value(documentId),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      title: Value(title),
      level: Value(level),
      ord: Value(ord),
      pageStart: Value(pageStart),
      pageEnd: Value(pageEnd),
    );
  }

  factory Section.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Section(
      id: serializer.fromJson<int>(json['id']),
      documentId: serializer.fromJson<int>(json['documentId']),
      parentId: serializer.fromJson<int?>(json['parentId']),
      title: serializer.fromJson<String>(json['title']),
      level: serializer.fromJson<int>(json['level']),
      ord: serializer.fromJson<int>(json['ord']),
      pageStart: serializer.fromJson<int>(json['pageStart']),
      pageEnd: serializer.fromJson<int>(json['pageEnd']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'documentId': serializer.toJson<int>(documentId),
      'parentId': serializer.toJson<int?>(parentId),
      'title': serializer.toJson<String>(title),
      'level': serializer.toJson<int>(level),
      'ord': serializer.toJson<int>(ord),
      'pageStart': serializer.toJson<int>(pageStart),
      'pageEnd': serializer.toJson<int>(pageEnd),
    };
  }

  Section copyWith({
    int? id,
    int? documentId,
    Value<int?> parentId = const Value.absent(),
    String? title,
    int? level,
    int? ord,
    int? pageStart,
    int? pageEnd,
  }) => Section(
    id: id ?? this.id,
    documentId: documentId ?? this.documentId,
    parentId: parentId.present ? parentId.value : this.parentId,
    title: title ?? this.title,
    level: level ?? this.level,
    ord: ord ?? this.ord,
    pageStart: pageStart ?? this.pageStart,
    pageEnd: pageEnd ?? this.pageEnd,
  );
  Section copyWithCompanion(SectionsCompanion data) {
    return Section(
      id: data.id.present ? data.id.value : this.id,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      title: data.title.present ? data.title.value : this.title,
      level: data.level.present ? data.level.value : this.level,
      ord: data.ord.present ? data.ord.value : this.ord,
      pageStart: data.pageStart.present ? data.pageStart.value : this.pageStart,
      pageEnd: data.pageEnd.present ? data.pageEnd.value : this.pageEnd,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Section(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('parentId: $parentId, ')
          ..write('title: $title, ')
          ..write('level: $level, ')
          ..write('ord: $ord, ')
          ..write('pageStart: $pageStart, ')
          ..write('pageEnd: $pageEnd')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    documentId,
    parentId,
    title,
    level,
    ord,
    pageStart,
    pageEnd,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Section &&
          other.id == this.id &&
          other.documentId == this.documentId &&
          other.parentId == this.parentId &&
          other.title == this.title &&
          other.level == this.level &&
          other.ord == this.ord &&
          other.pageStart == this.pageStart &&
          other.pageEnd == this.pageEnd);
}

class SectionsCompanion extends UpdateCompanion<Section> {
  final Value<int> id;
  final Value<int> documentId;
  final Value<int?> parentId;
  final Value<String> title;
  final Value<int> level;
  final Value<int> ord;
  final Value<int> pageStart;
  final Value<int> pageEnd;
  const SectionsCompanion({
    this.id = const Value.absent(),
    this.documentId = const Value.absent(),
    this.parentId = const Value.absent(),
    this.title = const Value.absent(),
    this.level = const Value.absent(),
    this.ord = const Value.absent(),
    this.pageStart = const Value.absent(),
    this.pageEnd = const Value.absent(),
  });
  SectionsCompanion.insert({
    this.id = const Value.absent(),
    required int documentId,
    this.parentId = const Value.absent(),
    required String title,
    required int level,
    required int ord,
    required int pageStart,
    required int pageEnd,
  }) : documentId = Value(documentId),
       title = Value(title),
       level = Value(level),
       ord = Value(ord),
       pageStart = Value(pageStart),
       pageEnd = Value(pageEnd);
  static Insertable<Section> custom({
    Expression<int>? id,
    Expression<int>? documentId,
    Expression<int>? parentId,
    Expression<String>? title,
    Expression<int>? level,
    Expression<int>? ord,
    Expression<int>? pageStart,
    Expression<int>? pageEnd,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentId != null) 'document_id': documentId,
      if (parentId != null) 'parent_id': parentId,
      if (title != null) 'title': title,
      if (level != null) 'level': level,
      if (ord != null) 'ord': ord,
      if (pageStart != null) 'page_start': pageStart,
      if (pageEnd != null) 'page_end': pageEnd,
    });
  }

  SectionsCompanion copyWith({
    Value<int>? id,
    Value<int>? documentId,
    Value<int?>? parentId,
    Value<String>? title,
    Value<int>? level,
    Value<int>? ord,
    Value<int>? pageStart,
    Value<int>? pageEnd,
  }) {
    return SectionsCompanion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      parentId: parentId ?? this.parentId,
      title: title ?? this.title,
      level: level ?? this.level,
      ord: ord ?? this.ord,
      pageStart: pageStart ?? this.pageStart,
      pageEnd: pageEnd ?? this.pageEnd,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<int>(documentId.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (ord.present) {
      map['ord'] = Variable<int>(ord.value);
    }
    if (pageStart.present) {
      map['page_start'] = Variable<int>(pageStart.value);
    }
    if (pageEnd.present) {
      map['page_end'] = Variable<int>(pageEnd.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SectionsCompanion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('parentId: $parentId, ')
          ..write('title: $title, ')
          ..write('level: $level, ')
          ..write('ord: $ord, ')
          ..write('pageStart: $pageStart, ')
          ..write('pageEnd: $pageEnd')
          ..write(')'))
        .toString();
  }
}

class $ChunksTable extends Chunks with TableInfo<$ChunksTable, Chunk> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChunksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<int> documentId = GeneratedColumn<int>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documents (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<int> sectionId = GeneratedColumn<int>(
    'section_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sections (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ordMeta = const VerificationMeta('ord');
  @override
  late final GeneratedColumn<int> ord = GeneratedColumn<int>(
    'ord',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _headingPathMeta = const VerificationMeta(
    'headingPath',
  );
  @override
  late final GeneratedColumn<String> headingPath = GeneratedColumn<String>(
    'heading_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageStartMeta = const VerificationMeta(
    'pageStart',
  );
  @override
  late final GeneratedColumn<int> pageStart = GeneratedColumn<int>(
    'page_start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageEndMeta = const VerificationMeta(
    'pageEnd',
  );
  @override
  late final GeneratedColumn<int> pageEnd = GeneratedColumn<int>(
    'page_end',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tokenEstimateMeta = const VerificationMeta(
    'tokenEstimate',
  );
  @override
  late final GeneratedColumn<int> tokenEstimate = GeneratedColumn<int>(
    'token_estimate',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('study'),
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    documentId,
    sectionId,
    ord,
    body,
    headingPath,
    pageStart,
    pageEnd,
    tokenEstimate,
    kind,
    sha256,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chunks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Chunk> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('ord')) {
      context.handle(
        _ordMeta,
        ord.isAcceptableOrUnknown(data['ord']!, _ordMeta),
      );
    } else if (isInserting) {
      context.missing(_ordMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('heading_path')) {
      context.handle(
        _headingPathMeta,
        headingPath.isAcceptableOrUnknown(
          data['heading_path']!,
          _headingPathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_headingPathMeta);
    }
    if (data.containsKey('page_start')) {
      context.handle(
        _pageStartMeta,
        pageStart.isAcceptableOrUnknown(data['page_start']!, _pageStartMeta),
      );
    } else if (isInserting) {
      context.missing(_pageStartMeta);
    }
    if (data.containsKey('page_end')) {
      context.handle(
        _pageEndMeta,
        pageEnd.isAcceptableOrUnknown(data['page_end']!, _pageEndMeta),
      );
    } else if (isInserting) {
      context.missing(_pageEndMeta);
    }
    if (data.containsKey('token_estimate')) {
      context.handle(
        _tokenEstimateMeta,
        tokenEstimate.isAcceptableOrUnknown(
          data['token_estimate']!,
          _tokenEstimateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tokenEstimateMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Chunk map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Chunk(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}document_id'],
      )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}section_id'],
      )!,
      ord: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ord'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      headingPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}heading_path'],
      )!,
      pageStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_start'],
      )!,
      pageEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_end'],
      )!,
      tokenEstimate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}token_estimate'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
    );
  }

  @override
  $ChunksTable createAlias(String alias) {
    return $ChunksTable(attachedDatabase, alias);
  }
}

class Chunk extends DataClass implements Insertable<Chunk> {
  final int id;
  final int documentId;
  final int sectionId;
  final int ord;
  final String body;
  final String headingPath;
  final int pageStart;
  final int pageEnd;
  final int tokenEstimate;

  /// study | toc | bookIndex | refs | front | math (ContentKind.name)
  final String kind;
  final String sha256;
  const Chunk({
    required this.id,
    required this.documentId,
    required this.sectionId,
    required this.ord,
    required this.body,
    required this.headingPath,
    required this.pageStart,
    required this.pageEnd,
    required this.tokenEstimate,
    required this.kind,
    required this.sha256,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['document_id'] = Variable<int>(documentId);
    map['section_id'] = Variable<int>(sectionId);
    map['ord'] = Variable<int>(ord);
    map['body'] = Variable<String>(body);
    map['heading_path'] = Variable<String>(headingPath);
    map['page_start'] = Variable<int>(pageStart);
    map['page_end'] = Variable<int>(pageEnd);
    map['token_estimate'] = Variable<int>(tokenEstimate);
    map['kind'] = Variable<String>(kind);
    map['sha256'] = Variable<String>(sha256);
    return map;
  }

  ChunksCompanion toCompanion(bool nullToAbsent) {
    return ChunksCompanion(
      id: Value(id),
      documentId: Value(documentId),
      sectionId: Value(sectionId),
      ord: Value(ord),
      body: Value(body),
      headingPath: Value(headingPath),
      pageStart: Value(pageStart),
      pageEnd: Value(pageEnd),
      tokenEstimate: Value(tokenEstimate),
      kind: Value(kind),
      sha256: Value(sha256),
    );
  }

  factory Chunk.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Chunk(
      id: serializer.fromJson<int>(json['id']),
      documentId: serializer.fromJson<int>(json['documentId']),
      sectionId: serializer.fromJson<int>(json['sectionId']),
      ord: serializer.fromJson<int>(json['ord']),
      body: serializer.fromJson<String>(json['body']),
      headingPath: serializer.fromJson<String>(json['headingPath']),
      pageStart: serializer.fromJson<int>(json['pageStart']),
      pageEnd: serializer.fromJson<int>(json['pageEnd']),
      tokenEstimate: serializer.fromJson<int>(json['tokenEstimate']),
      kind: serializer.fromJson<String>(json['kind']),
      sha256: serializer.fromJson<String>(json['sha256']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'documentId': serializer.toJson<int>(documentId),
      'sectionId': serializer.toJson<int>(sectionId),
      'ord': serializer.toJson<int>(ord),
      'body': serializer.toJson<String>(body),
      'headingPath': serializer.toJson<String>(headingPath),
      'pageStart': serializer.toJson<int>(pageStart),
      'pageEnd': serializer.toJson<int>(pageEnd),
      'tokenEstimate': serializer.toJson<int>(tokenEstimate),
      'kind': serializer.toJson<String>(kind),
      'sha256': serializer.toJson<String>(sha256),
    };
  }

  Chunk copyWith({
    int? id,
    int? documentId,
    int? sectionId,
    int? ord,
    String? body,
    String? headingPath,
    int? pageStart,
    int? pageEnd,
    int? tokenEstimate,
    String? kind,
    String? sha256,
  }) => Chunk(
    id: id ?? this.id,
    documentId: documentId ?? this.documentId,
    sectionId: sectionId ?? this.sectionId,
    ord: ord ?? this.ord,
    body: body ?? this.body,
    headingPath: headingPath ?? this.headingPath,
    pageStart: pageStart ?? this.pageStart,
    pageEnd: pageEnd ?? this.pageEnd,
    tokenEstimate: tokenEstimate ?? this.tokenEstimate,
    kind: kind ?? this.kind,
    sha256: sha256 ?? this.sha256,
  );
  Chunk copyWithCompanion(ChunksCompanion data) {
    return Chunk(
      id: data.id.present ? data.id.value : this.id,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      ord: data.ord.present ? data.ord.value : this.ord,
      body: data.body.present ? data.body.value : this.body,
      headingPath: data.headingPath.present
          ? data.headingPath.value
          : this.headingPath,
      pageStart: data.pageStart.present ? data.pageStart.value : this.pageStart,
      pageEnd: data.pageEnd.present ? data.pageEnd.value : this.pageEnd,
      tokenEstimate: data.tokenEstimate.present
          ? data.tokenEstimate.value
          : this.tokenEstimate,
      kind: data.kind.present ? data.kind.value : this.kind,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Chunk(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('sectionId: $sectionId, ')
          ..write('ord: $ord, ')
          ..write('body: $body, ')
          ..write('headingPath: $headingPath, ')
          ..write('pageStart: $pageStart, ')
          ..write('pageEnd: $pageEnd, ')
          ..write('tokenEstimate: $tokenEstimate, ')
          ..write('kind: $kind, ')
          ..write('sha256: $sha256')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    documentId,
    sectionId,
    ord,
    body,
    headingPath,
    pageStart,
    pageEnd,
    tokenEstimate,
    kind,
    sha256,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Chunk &&
          other.id == this.id &&
          other.documentId == this.documentId &&
          other.sectionId == this.sectionId &&
          other.ord == this.ord &&
          other.body == this.body &&
          other.headingPath == this.headingPath &&
          other.pageStart == this.pageStart &&
          other.pageEnd == this.pageEnd &&
          other.tokenEstimate == this.tokenEstimate &&
          other.kind == this.kind &&
          other.sha256 == this.sha256);
}

class ChunksCompanion extends UpdateCompanion<Chunk> {
  final Value<int> id;
  final Value<int> documentId;
  final Value<int> sectionId;
  final Value<int> ord;
  final Value<String> body;
  final Value<String> headingPath;
  final Value<int> pageStart;
  final Value<int> pageEnd;
  final Value<int> tokenEstimate;
  final Value<String> kind;
  final Value<String> sha256;
  const ChunksCompanion({
    this.id = const Value.absent(),
    this.documentId = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.ord = const Value.absent(),
    this.body = const Value.absent(),
    this.headingPath = const Value.absent(),
    this.pageStart = const Value.absent(),
    this.pageEnd = const Value.absent(),
    this.tokenEstimate = const Value.absent(),
    this.kind = const Value.absent(),
    this.sha256 = const Value.absent(),
  });
  ChunksCompanion.insert({
    this.id = const Value.absent(),
    required int documentId,
    required int sectionId,
    required int ord,
    required String body,
    required String headingPath,
    required int pageStart,
    required int pageEnd,
    required int tokenEstimate,
    this.kind = const Value.absent(),
    required String sha256,
  }) : documentId = Value(documentId),
       sectionId = Value(sectionId),
       ord = Value(ord),
       body = Value(body),
       headingPath = Value(headingPath),
       pageStart = Value(pageStart),
       pageEnd = Value(pageEnd),
       tokenEstimate = Value(tokenEstimate),
       sha256 = Value(sha256);
  static Insertable<Chunk> custom({
    Expression<int>? id,
    Expression<int>? documentId,
    Expression<int>? sectionId,
    Expression<int>? ord,
    Expression<String>? body,
    Expression<String>? headingPath,
    Expression<int>? pageStart,
    Expression<int>? pageEnd,
    Expression<int>? tokenEstimate,
    Expression<String>? kind,
    Expression<String>? sha256,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentId != null) 'document_id': documentId,
      if (sectionId != null) 'section_id': sectionId,
      if (ord != null) 'ord': ord,
      if (body != null) 'body': body,
      if (headingPath != null) 'heading_path': headingPath,
      if (pageStart != null) 'page_start': pageStart,
      if (pageEnd != null) 'page_end': pageEnd,
      if (tokenEstimate != null) 'token_estimate': tokenEstimate,
      if (kind != null) 'kind': kind,
      if (sha256 != null) 'sha256': sha256,
    });
  }

  ChunksCompanion copyWith({
    Value<int>? id,
    Value<int>? documentId,
    Value<int>? sectionId,
    Value<int>? ord,
    Value<String>? body,
    Value<String>? headingPath,
    Value<int>? pageStart,
    Value<int>? pageEnd,
    Value<int>? tokenEstimate,
    Value<String>? kind,
    Value<String>? sha256,
  }) {
    return ChunksCompanion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      sectionId: sectionId ?? this.sectionId,
      ord: ord ?? this.ord,
      body: body ?? this.body,
      headingPath: headingPath ?? this.headingPath,
      pageStart: pageStart ?? this.pageStart,
      pageEnd: pageEnd ?? this.pageEnd,
      tokenEstimate: tokenEstimate ?? this.tokenEstimate,
      kind: kind ?? this.kind,
      sha256: sha256 ?? this.sha256,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<int>(documentId.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<int>(sectionId.value);
    }
    if (ord.present) {
      map['ord'] = Variable<int>(ord.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (headingPath.present) {
      map['heading_path'] = Variable<String>(headingPath.value);
    }
    if (pageStart.present) {
      map['page_start'] = Variable<int>(pageStart.value);
    }
    if (pageEnd.present) {
      map['page_end'] = Variable<int>(pageEnd.value);
    }
    if (tokenEstimate.present) {
      map['token_estimate'] = Variable<int>(tokenEstimate.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChunksCompanion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('sectionId: $sectionId, ')
          ..write('ord: $ord, ')
          ..write('body: $body, ')
          ..write('headingPath: $headingPath, ')
          ..write('pageStart: $pageStart, ')
          ..write('pageEnd: $pageEnd, ')
          ..write('tokenEstimate: $tokenEstimate, ')
          ..write('kind: $kind, ')
          ..write('sha256: $sha256')
          ..write(')'))
        .toString();
  }
}

class $FactsTable extends Facts with TableInfo<$FactsTable, Fact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<int> documentId = GeneratedColumn<int>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documents (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _chunkIdMeta = const VerificationMeta(
    'chunkId',
  );
  @override
  late final GeneratedColumn<int> chunkId = GeneratedColumn<int>(
    'chunk_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chunks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<int> sectionId = GeneratedColumn<int>(
    'section_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statementMeta = const VerificationMeta(
    'statement',
  );
  @override
  late final GeneratedColumn<String> statement = GeneratedColumn<String>(
    'statement',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quoteMeta = const VerificationMeta('quote');
  @override
  late final GeneratedColumn<String> quote = GeneratedColumn<String>(
    'quote',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quoteStartMeta = const VerificationMeta(
    'quoteStart',
  );
  @override
  late final GeneratedColumn<int> quoteStart = GeneratedColumn<int>(
    'quote_start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quoteEndMeta = const VerificationMeta(
    'quoteEnd',
  );
  @override
  late final GeneratedColumn<int> quoteEnd = GeneratedColumn<int>(
    'quote_end',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyTermMeta = const VerificationMeta(
    'keyTerm',
  );
  @override
  late final GeneratedColumn<String> keyTerm = GeneratedColumn<String>(
    'key_term',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importanceMeta = const VerificationMeta(
    'importance',
  );
  @override
  late final GeneratedColumn<int> importance = GeneratedColumn<int>(
    'importance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    documentId,
    chunkId,
    sectionId,
    statement,
    quote,
    quoteStart,
    quoteEnd,
    keyTerm,
    importance,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'facts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Fact> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('chunk_id')) {
      context.handle(
        _chunkIdMeta,
        chunkId.isAcceptableOrUnknown(data['chunk_id']!, _chunkIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chunkIdMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('statement')) {
      context.handle(
        _statementMeta,
        statement.isAcceptableOrUnknown(data['statement']!, _statementMeta),
      );
    } else if (isInserting) {
      context.missing(_statementMeta);
    }
    if (data.containsKey('quote')) {
      context.handle(
        _quoteMeta,
        quote.isAcceptableOrUnknown(data['quote']!, _quoteMeta),
      );
    } else if (isInserting) {
      context.missing(_quoteMeta);
    }
    if (data.containsKey('quote_start')) {
      context.handle(
        _quoteStartMeta,
        quoteStart.isAcceptableOrUnknown(data['quote_start']!, _quoteStartMeta),
      );
    } else if (isInserting) {
      context.missing(_quoteStartMeta);
    }
    if (data.containsKey('quote_end')) {
      context.handle(
        _quoteEndMeta,
        quoteEnd.isAcceptableOrUnknown(data['quote_end']!, _quoteEndMeta),
      );
    } else if (isInserting) {
      context.missing(_quoteEndMeta);
    }
    if (data.containsKey('key_term')) {
      context.handle(
        _keyTermMeta,
        keyTerm.isAcceptableOrUnknown(data['key_term']!, _keyTermMeta),
      );
    } else if (isInserting) {
      context.missing(_keyTermMeta);
    }
    if (data.containsKey('importance')) {
      context.handle(
        _importanceMeta,
        importance.isAcceptableOrUnknown(data['importance']!, _importanceMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Fact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Fact(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}document_id'],
      )!,
      chunkId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chunk_id'],
      )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}section_id'],
      )!,
      statement: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}statement'],
      )!,
      quote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quote'],
      )!,
      quoteStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quote_start'],
      )!,
      quoteEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quote_end'],
      )!,
      keyTerm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key_term'],
      )!,
      importance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}importance'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FactsTable createAlias(String alias) {
    return $FactsTable(attachedDatabase, alias);
  }
}

class Fact extends DataClass implements Insertable<Fact> {
  final int id;
  final int documentId;
  final int chunkId;
  final int sectionId;
  final String statement;
  final String quote;
  final int quoteStart;
  final int quoteEnd;
  final String keyTerm;
  final int importance;

  /// active | retired | disputed
  final String status;
  final DateTime createdAt;
  const Fact({
    required this.id,
    required this.documentId,
    required this.chunkId,
    required this.sectionId,
    required this.statement,
    required this.quote,
    required this.quoteStart,
    required this.quoteEnd,
    required this.keyTerm,
    required this.importance,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['document_id'] = Variable<int>(documentId);
    map['chunk_id'] = Variable<int>(chunkId);
    map['section_id'] = Variable<int>(sectionId);
    map['statement'] = Variable<String>(statement);
    map['quote'] = Variable<String>(quote);
    map['quote_start'] = Variable<int>(quoteStart);
    map['quote_end'] = Variable<int>(quoteEnd);
    map['key_term'] = Variable<String>(keyTerm);
    map['importance'] = Variable<int>(importance);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FactsCompanion toCompanion(bool nullToAbsent) {
    return FactsCompanion(
      id: Value(id),
      documentId: Value(documentId),
      chunkId: Value(chunkId),
      sectionId: Value(sectionId),
      statement: Value(statement),
      quote: Value(quote),
      quoteStart: Value(quoteStart),
      quoteEnd: Value(quoteEnd),
      keyTerm: Value(keyTerm),
      importance: Value(importance),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory Fact.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Fact(
      id: serializer.fromJson<int>(json['id']),
      documentId: serializer.fromJson<int>(json['documentId']),
      chunkId: serializer.fromJson<int>(json['chunkId']),
      sectionId: serializer.fromJson<int>(json['sectionId']),
      statement: serializer.fromJson<String>(json['statement']),
      quote: serializer.fromJson<String>(json['quote']),
      quoteStart: serializer.fromJson<int>(json['quoteStart']),
      quoteEnd: serializer.fromJson<int>(json['quoteEnd']),
      keyTerm: serializer.fromJson<String>(json['keyTerm']),
      importance: serializer.fromJson<int>(json['importance']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'documentId': serializer.toJson<int>(documentId),
      'chunkId': serializer.toJson<int>(chunkId),
      'sectionId': serializer.toJson<int>(sectionId),
      'statement': serializer.toJson<String>(statement),
      'quote': serializer.toJson<String>(quote),
      'quoteStart': serializer.toJson<int>(quoteStart),
      'quoteEnd': serializer.toJson<int>(quoteEnd),
      'keyTerm': serializer.toJson<String>(keyTerm),
      'importance': serializer.toJson<int>(importance),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Fact copyWith({
    int? id,
    int? documentId,
    int? chunkId,
    int? sectionId,
    String? statement,
    String? quote,
    int? quoteStart,
    int? quoteEnd,
    String? keyTerm,
    int? importance,
    String? status,
    DateTime? createdAt,
  }) => Fact(
    id: id ?? this.id,
    documentId: documentId ?? this.documentId,
    chunkId: chunkId ?? this.chunkId,
    sectionId: sectionId ?? this.sectionId,
    statement: statement ?? this.statement,
    quote: quote ?? this.quote,
    quoteStart: quoteStart ?? this.quoteStart,
    quoteEnd: quoteEnd ?? this.quoteEnd,
    keyTerm: keyTerm ?? this.keyTerm,
    importance: importance ?? this.importance,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  Fact copyWithCompanion(FactsCompanion data) {
    return Fact(
      id: data.id.present ? data.id.value : this.id,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      chunkId: data.chunkId.present ? data.chunkId.value : this.chunkId,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      statement: data.statement.present ? data.statement.value : this.statement,
      quote: data.quote.present ? data.quote.value : this.quote,
      quoteStart: data.quoteStart.present
          ? data.quoteStart.value
          : this.quoteStart,
      quoteEnd: data.quoteEnd.present ? data.quoteEnd.value : this.quoteEnd,
      keyTerm: data.keyTerm.present ? data.keyTerm.value : this.keyTerm,
      importance: data.importance.present
          ? data.importance.value
          : this.importance,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Fact(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('chunkId: $chunkId, ')
          ..write('sectionId: $sectionId, ')
          ..write('statement: $statement, ')
          ..write('quote: $quote, ')
          ..write('quoteStart: $quoteStart, ')
          ..write('quoteEnd: $quoteEnd, ')
          ..write('keyTerm: $keyTerm, ')
          ..write('importance: $importance, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    documentId,
    chunkId,
    sectionId,
    statement,
    quote,
    quoteStart,
    quoteEnd,
    keyTerm,
    importance,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Fact &&
          other.id == this.id &&
          other.documentId == this.documentId &&
          other.chunkId == this.chunkId &&
          other.sectionId == this.sectionId &&
          other.statement == this.statement &&
          other.quote == this.quote &&
          other.quoteStart == this.quoteStart &&
          other.quoteEnd == this.quoteEnd &&
          other.keyTerm == this.keyTerm &&
          other.importance == this.importance &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class FactsCompanion extends UpdateCompanion<Fact> {
  final Value<int> id;
  final Value<int> documentId;
  final Value<int> chunkId;
  final Value<int> sectionId;
  final Value<String> statement;
  final Value<String> quote;
  final Value<int> quoteStart;
  final Value<int> quoteEnd;
  final Value<String> keyTerm;
  final Value<int> importance;
  final Value<String> status;
  final Value<DateTime> createdAt;
  const FactsCompanion({
    this.id = const Value.absent(),
    this.documentId = const Value.absent(),
    this.chunkId = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.statement = const Value.absent(),
    this.quote = const Value.absent(),
    this.quoteStart = const Value.absent(),
    this.quoteEnd = const Value.absent(),
    this.keyTerm = const Value.absent(),
    this.importance = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FactsCompanion.insert({
    this.id = const Value.absent(),
    required int documentId,
    required int chunkId,
    required int sectionId,
    required String statement,
    required String quote,
    required int quoteStart,
    required int quoteEnd,
    required String keyTerm,
    this.importance = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : documentId = Value(documentId),
       chunkId = Value(chunkId),
       sectionId = Value(sectionId),
       statement = Value(statement),
       quote = Value(quote),
       quoteStart = Value(quoteStart),
       quoteEnd = Value(quoteEnd),
       keyTerm = Value(keyTerm);
  static Insertable<Fact> custom({
    Expression<int>? id,
    Expression<int>? documentId,
    Expression<int>? chunkId,
    Expression<int>? sectionId,
    Expression<String>? statement,
    Expression<String>? quote,
    Expression<int>? quoteStart,
    Expression<int>? quoteEnd,
    Expression<String>? keyTerm,
    Expression<int>? importance,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentId != null) 'document_id': documentId,
      if (chunkId != null) 'chunk_id': chunkId,
      if (sectionId != null) 'section_id': sectionId,
      if (statement != null) 'statement': statement,
      if (quote != null) 'quote': quote,
      if (quoteStart != null) 'quote_start': quoteStart,
      if (quoteEnd != null) 'quote_end': quoteEnd,
      if (keyTerm != null) 'key_term': keyTerm,
      if (importance != null) 'importance': importance,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FactsCompanion copyWith({
    Value<int>? id,
    Value<int>? documentId,
    Value<int>? chunkId,
    Value<int>? sectionId,
    Value<String>? statement,
    Value<String>? quote,
    Value<int>? quoteStart,
    Value<int>? quoteEnd,
    Value<String>? keyTerm,
    Value<int>? importance,
    Value<String>? status,
    Value<DateTime>? createdAt,
  }) {
    return FactsCompanion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      chunkId: chunkId ?? this.chunkId,
      sectionId: sectionId ?? this.sectionId,
      statement: statement ?? this.statement,
      quote: quote ?? this.quote,
      quoteStart: quoteStart ?? this.quoteStart,
      quoteEnd: quoteEnd ?? this.quoteEnd,
      keyTerm: keyTerm ?? this.keyTerm,
      importance: importance ?? this.importance,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<int>(documentId.value);
    }
    if (chunkId.present) {
      map['chunk_id'] = Variable<int>(chunkId.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<int>(sectionId.value);
    }
    if (statement.present) {
      map['statement'] = Variable<String>(statement.value);
    }
    if (quote.present) {
      map['quote'] = Variable<String>(quote.value);
    }
    if (quoteStart.present) {
      map['quote_start'] = Variable<int>(quoteStart.value);
    }
    if (quoteEnd.present) {
      map['quote_end'] = Variable<int>(quoteEnd.value);
    }
    if (keyTerm.present) {
      map['key_term'] = Variable<String>(keyTerm.value);
    }
    if (importance.present) {
      map['importance'] = Variable<int>(importance.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FactsCompanion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('chunkId: $chunkId, ')
          ..write('sectionId: $sectionId, ')
          ..write('statement: $statement, ')
          ..write('quote: $quote, ')
          ..write('quoteStart: $quoteStart, ')
          ..write('quoteEnd: $quoteEnd, ')
          ..write('keyTerm: $keyTerm, ')
          ..write('importance: $importance, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $QuestionsTable extends Questions
    with TableInfo<$QuestionsTable, Question> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _factIdMeta = const VerificationMeta('factId');
  @override
  late final GeneratedColumn<int> factId = GeneratedColumn<int>(
    'fact_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES facts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _depthMeta = const VerificationMeta('depth');
  @override
  late final GeneratedColumn<String> depth = GeneratedColumn<String>(
    'depth',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promptMeta = const VerificationMeta('prompt');
  @override
  late final GeneratedColumn<String> prompt = GeneratedColumn<String>(
    'prompt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answerMeta = const VerificationMeta('answer');
  @override
  late final GeneratedColumn<String> answer = GeneratedColumn<String>(
    'answer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distractorsJsonMeta = const VerificationMeta(
    'distractorsJson',
  );
  @override
  late final GeneratedColumn<String> distractorsJson = GeneratedColumn<String>(
    'distractors_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _explanationMeta = const VerificationMeta(
    'explanation',
  );
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
    'explanation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qualityMeta = const VerificationMeta(
    'quality',
  );
  @override
  late final GeneratedColumn<String> quality = GeneratedColumn<String>(
    'quality',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promptVersionMeta = const VerificationMeta(
    'promptVersion',
  );
  @override
  late final GeneratedColumn<int> promptVersion = GeneratedColumn<int>(
    'prompt_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checksJsonMeta = const VerificationMeta(
    'checksJson',
  );
  @override
  late final GeneratedColumn<String> checksJson = GeneratedColumn<String>(
    'checks_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    factId,
    type,
    depth,
    prompt,
    answer,
    distractorsJson,
    explanation,
    quality,
    modelId,
    promptVersion,
    checksJson,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'questions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Question> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fact_id')) {
      context.handle(
        _factIdMeta,
        factId.isAcceptableOrUnknown(data['fact_id']!, _factIdMeta),
      );
    } else if (isInserting) {
      context.missing(_factIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('depth')) {
      context.handle(
        _depthMeta,
        depth.isAcceptableOrUnknown(data['depth']!, _depthMeta),
      );
    } else if (isInserting) {
      context.missing(_depthMeta);
    }
    if (data.containsKey('prompt')) {
      context.handle(
        _promptMeta,
        prompt.isAcceptableOrUnknown(data['prompt']!, _promptMeta),
      );
    } else if (isInserting) {
      context.missing(_promptMeta);
    }
    if (data.containsKey('answer')) {
      context.handle(
        _answerMeta,
        answer.isAcceptableOrUnknown(data['answer']!, _answerMeta),
      );
    } else if (isInserting) {
      context.missing(_answerMeta);
    }
    if (data.containsKey('distractors_json')) {
      context.handle(
        _distractorsJsonMeta,
        distractorsJson.isAcceptableOrUnknown(
          data['distractors_json']!,
          _distractorsJsonMeta,
        ),
      );
    }
    if (data.containsKey('explanation')) {
      context.handle(
        _explanationMeta,
        explanation.isAcceptableOrUnknown(
          data['explanation']!,
          _explanationMeta,
        ),
      );
    }
    if (data.containsKey('quality')) {
      context.handle(
        _qualityMeta,
        quality.isAcceptableOrUnknown(data['quality']!, _qualityMeta),
      );
    } else if (isInserting) {
      context.missing(_qualityMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('prompt_version')) {
      context.handle(
        _promptVersionMeta,
        promptVersion.isAcceptableOrUnknown(
          data['prompt_version']!,
          _promptVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_promptVersionMeta);
    }
    if (data.containsKey('checks_json')) {
      context.handle(
        _checksJsonMeta,
        checksJson.isAcceptableOrUnknown(data['checks_json']!, _checksJsonMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Question map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Question(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      factId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fact_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      depth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}depth'],
      )!,
      prompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt'],
      )!,
      answer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answer'],
      )!,
      distractorsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}distractors_json'],
      ),
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      ),
      quality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quality'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      promptVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prompt_version'],
      )!,
      checksJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checks_json'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $QuestionsTable createAlias(String alias) {
    return $QuestionsTable(attachedDatabase, alias);
  }
}

class Question extends DataClass implements Insertable<Question> {
  final int id;
  final int factId;

  /// cloze | flashcard | mcq
  final String type;

  /// recall | understand | apply | analyze
  final String depth;
  final String prompt;
  final String answer;
  final String? distractorsJson;
  final String? explanation;

  /// quick | standard | thorough | deep
  final String quality;
  final String modelId;
  final int promptVersion;
  final String? checksJson;

  /// active | retired | reported
  final String status;
  final DateTime createdAt;
  const Question({
    required this.id,
    required this.factId,
    required this.type,
    required this.depth,
    required this.prompt,
    required this.answer,
    this.distractorsJson,
    this.explanation,
    required this.quality,
    required this.modelId,
    required this.promptVersion,
    this.checksJson,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fact_id'] = Variable<int>(factId);
    map['type'] = Variable<String>(type);
    map['depth'] = Variable<String>(depth);
    map['prompt'] = Variable<String>(prompt);
    map['answer'] = Variable<String>(answer);
    if (!nullToAbsent || distractorsJson != null) {
      map['distractors_json'] = Variable<String>(distractorsJson);
    }
    if (!nullToAbsent || explanation != null) {
      map['explanation'] = Variable<String>(explanation);
    }
    map['quality'] = Variable<String>(quality);
    map['model_id'] = Variable<String>(modelId);
    map['prompt_version'] = Variable<int>(promptVersion);
    if (!nullToAbsent || checksJson != null) {
      map['checks_json'] = Variable<String>(checksJson);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  QuestionsCompanion toCompanion(bool nullToAbsent) {
    return QuestionsCompanion(
      id: Value(id),
      factId: Value(factId),
      type: Value(type),
      depth: Value(depth),
      prompt: Value(prompt),
      answer: Value(answer),
      distractorsJson: distractorsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(distractorsJson),
      explanation: explanation == null && nullToAbsent
          ? const Value.absent()
          : Value(explanation),
      quality: Value(quality),
      modelId: Value(modelId),
      promptVersion: Value(promptVersion),
      checksJson: checksJson == null && nullToAbsent
          ? const Value.absent()
          : Value(checksJson),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory Question.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Question(
      id: serializer.fromJson<int>(json['id']),
      factId: serializer.fromJson<int>(json['factId']),
      type: serializer.fromJson<String>(json['type']),
      depth: serializer.fromJson<String>(json['depth']),
      prompt: serializer.fromJson<String>(json['prompt']),
      answer: serializer.fromJson<String>(json['answer']),
      distractorsJson: serializer.fromJson<String?>(json['distractorsJson']),
      explanation: serializer.fromJson<String?>(json['explanation']),
      quality: serializer.fromJson<String>(json['quality']),
      modelId: serializer.fromJson<String>(json['modelId']),
      promptVersion: serializer.fromJson<int>(json['promptVersion']),
      checksJson: serializer.fromJson<String?>(json['checksJson']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'factId': serializer.toJson<int>(factId),
      'type': serializer.toJson<String>(type),
      'depth': serializer.toJson<String>(depth),
      'prompt': serializer.toJson<String>(prompt),
      'answer': serializer.toJson<String>(answer),
      'distractorsJson': serializer.toJson<String?>(distractorsJson),
      'explanation': serializer.toJson<String?>(explanation),
      'quality': serializer.toJson<String>(quality),
      'modelId': serializer.toJson<String>(modelId),
      'promptVersion': serializer.toJson<int>(promptVersion),
      'checksJson': serializer.toJson<String?>(checksJson),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Question copyWith({
    int? id,
    int? factId,
    String? type,
    String? depth,
    String? prompt,
    String? answer,
    Value<String?> distractorsJson = const Value.absent(),
    Value<String?> explanation = const Value.absent(),
    String? quality,
    String? modelId,
    int? promptVersion,
    Value<String?> checksJson = const Value.absent(),
    String? status,
    DateTime? createdAt,
  }) => Question(
    id: id ?? this.id,
    factId: factId ?? this.factId,
    type: type ?? this.type,
    depth: depth ?? this.depth,
    prompt: prompt ?? this.prompt,
    answer: answer ?? this.answer,
    distractorsJson: distractorsJson.present
        ? distractorsJson.value
        : this.distractorsJson,
    explanation: explanation.present ? explanation.value : this.explanation,
    quality: quality ?? this.quality,
    modelId: modelId ?? this.modelId,
    promptVersion: promptVersion ?? this.promptVersion,
    checksJson: checksJson.present ? checksJson.value : this.checksJson,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  Question copyWithCompanion(QuestionsCompanion data) {
    return Question(
      id: data.id.present ? data.id.value : this.id,
      factId: data.factId.present ? data.factId.value : this.factId,
      type: data.type.present ? data.type.value : this.type,
      depth: data.depth.present ? data.depth.value : this.depth,
      prompt: data.prompt.present ? data.prompt.value : this.prompt,
      answer: data.answer.present ? data.answer.value : this.answer,
      distractorsJson: data.distractorsJson.present
          ? data.distractorsJson.value
          : this.distractorsJson,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
      quality: data.quality.present ? data.quality.value : this.quality,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      promptVersion: data.promptVersion.present
          ? data.promptVersion.value
          : this.promptVersion,
      checksJson: data.checksJson.present
          ? data.checksJson.value
          : this.checksJson,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Question(')
          ..write('id: $id, ')
          ..write('factId: $factId, ')
          ..write('type: $type, ')
          ..write('depth: $depth, ')
          ..write('prompt: $prompt, ')
          ..write('answer: $answer, ')
          ..write('distractorsJson: $distractorsJson, ')
          ..write('explanation: $explanation, ')
          ..write('quality: $quality, ')
          ..write('modelId: $modelId, ')
          ..write('promptVersion: $promptVersion, ')
          ..write('checksJson: $checksJson, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    factId,
    type,
    depth,
    prompt,
    answer,
    distractorsJson,
    explanation,
    quality,
    modelId,
    promptVersion,
    checksJson,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Question &&
          other.id == this.id &&
          other.factId == this.factId &&
          other.type == this.type &&
          other.depth == this.depth &&
          other.prompt == this.prompt &&
          other.answer == this.answer &&
          other.distractorsJson == this.distractorsJson &&
          other.explanation == this.explanation &&
          other.quality == this.quality &&
          other.modelId == this.modelId &&
          other.promptVersion == this.promptVersion &&
          other.checksJson == this.checksJson &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class QuestionsCompanion extends UpdateCompanion<Question> {
  final Value<int> id;
  final Value<int> factId;
  final Value<String> type;
  final Value<String> depth;
  final Value<String> prompt;
  final Value<String> answer;
  final Value<String?> distractorsJson;
  final Value<String?> explanation;
  final Value<String> quality;
  final Value<String> modelId;
  final Value<int> promptVersion;
  final Value<String?> checksJson;
  final Value<String> status;
  final Value<DateTime> createdAt;
  const QuestionsCompanion({
    this.id = const Value.absent(),
    this.factId = const Value.absent(),
    this.type = const Value.absent(),
    this.depth = const Value.absent(),
    this.prompt = const Value.absent(),
    this.answer = const Value.absent(),
    this.distractorsJson = const Value.absent(),
    this.explanation = const Value.absent(),
    this.quality = const Value.absent(),
    this.modelId = const Value.absent(),
    this.promptVersion = const Value.absent(),
    this.checksJson = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  QuestionsCompanion.insert({
    this.id = const Value.absent(),
    required int factId,
    required String type,
    required String depth,
    required String prompt,
    required String answer,
    this.distractorsJson = const Value.absent(),
    this.explanation = const Value.absent(),
    required String quality,
    required String modelId,
    required int promptVersion,
    this.checksJson = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : factId = Value(factId),
       type = Value(type),
       depth = Value(depth),
       prompt = Value(prompt),
       answer = Value(answer),
       quality = Value(quality),
       modelId = Value(modelId),
       promptVersion = Value(promptVersion);
  static Insertable<Question> custom({
    Expression<int>? id,
    Expression<int>? factId,
    Expression<String>? type,
    Expression<String>? depth,
    Expression<String>? prompt,
    Expression<String>? answer,
    Expression<String>? distractorsJson,
    Expression<String>? explanation,
    Expression<String>? quality,
    Expression<String>? modelId,
    Expression<int>? promptVersion,
    Expression<String>? checksJson,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (factId != null) 'fact_id': factId,
      if (type != null) 'type': type,
      if (depth != null) 'depth': depth,
      if (prompt != null) 'prompt': prompt,
      if (answer != null) 'answer': answer,
      if (distractorsJson != null) 'distractors_json': distractorsJson,
      if (explanation != null) 'explanation': explanation,
      if (quality != null) 'quality': quality,
      if (modelId != null) 'model_id': modelId,
      if (promptVersion != null) 'prompt_version': promptVersion,
      if (checksJson != null) 'checks_json': checksJson,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  QuestionsCompanion copyWith({
    Value<int>? id,
    Value<int>? factId,
    Value<String>? type,
    Value<String>? depth,
    Value<String>? prompt,
    Value<String>? answer,
    Value<String?>? distractorsJson,
    Value<String?>? explanation,
    Value<String>? quality,
    Value<String>? modelId,
    Value<int>? promptVersion,
    Value<String?>? checksJson,
    Value<String>? status,
    Value<DateTime>? createdAt,
  }) {
    return QuestionsCompanion(
      id: id ?? this.id,
      factId: factId ?? this.factId,
      type: type ?? this.type,
      depth: depth ?? this.depth,
      prompt: prompt ?? this.prompt,
      answer: answer ?? this.answer,
      distractorsJson: distractorsJson ?? this.distractorsJson,
      explanation: explanation ?? this.explanation,
      quality: quality ?? this.quality,
      modelId: modelId ?? this.modelId,
      promptVersion: promptVersion ?? this.promptVersion,
      checksJson: checksJson ?? this.checksJson,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (factId.present) {
      map['fact_id'] = Variable<int>(factId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (depth.present) {
      map['depth'] = Variable<String>(depth.value);
    }
    if (prompt.present) {
      map['prompt'] = Variable<String>(prompt.value);
    }
    if (answer.present) {
      map['answer'] = Variable<String>(answer.value);
    }
    if (distractorsJson.present) {
      map['distractors_json'] = Variable<String>(distractorsJson.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (quality.present) {
      map['quality'] = Variable<String>(quality.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (promptVersion.present) {
      map['prompt_version'] = Variable<int>(promptVersion.value);
    }
    if (checksJson.present) {
      map['checks_json'] = Variable<String>(checksJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionsCompanion(')
          ..write('id: $id, ')
          ..write('factId: $factId, ')
          ..write('type: $type, ')
          ..write('depth: $depth, ')
          ..write('prompt: $prompt, ')
          ..write('answer: $answer, ')
          ..write('distractorsJson: $distractorsJson, ')
          ..write('explanation: $explanation, ')
          ..write('quality: $quality, ')
          ..write('modelId: $modelId, ')
          ..write('promptVersion: $promptVersion, ')
          ..write('checksJson: $checksJson, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $QuestionSectionsTable extends QuestionSections
    with TableInfo<$QuestionSectionsTable, QuestionSection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionSectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<int> questionId = GeneratedColumn<int>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES questions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<int> sectionId = GeneratedColumn<int>(
    'section_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sections (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [questionId, sectionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'question_sections';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuestionSection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {questionId, sectionId};
  @override
  QuestionSection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestionSection(
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_id'],
      )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}section_id'],
      )!,
    );
  }

  @override
  $QuestionSectionsTable createAlias(String alias) {
    return $QuestionSectionsTable(attachedDatabase, alias);
  }
}

class QuestionSection extends DataClass implements Insertable<QuestionSection> {
  final int questionId;
  final int sectionId;
  const QuestionSection({required this.questionId, required this.sectionId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['question_id'] = Variable<int>(questionId);
    map['section_id'] = Variable<int>(sectionId);
    return map;
  }

  QuestionSectionsCompanion toCompanion(bool nullToAbsent) {
    return QuestionSectionsCompanion(
      questionId: Value(questionId),
      sectionId: Value(sectionId),
    );
  }

  factory QuestionSection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestionSection(
      questionId: serializer.fromJson<int>(json['questionId']),
      sectionId: serializer.fromJson<int>(json['sectionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'questionId': serializer.toJson<int>(questionId),
      'sectionId': serializer.toJson<int>(sectionId),
    };
  }

  QuestionSection copyWith({int? questionId, int? sectionId}) =>
      QuestionSection(
        questionId: questionId ?? this.questionId,
        sectionId: sectionId ?? this.sectionId,
      );
  QuestionSection copyWithCompanion(QuestionSectionsCompanion data) {
    return QuestionSection(
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestionSection(')
          ..write('questionId: $questionId, ')
          ..write('sectionId: $sectionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(questionId, sectionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestionSection &&
          other.questionId == this.questionId &&
          other.sectionId == this.sectionId);
}

class QuestionSectionsCompanion extends UpdateCompanion<QuestionSection> {
  final Value<int> questionId;
  final Value<int> sectionId;
  final Value<int> rowid;
  const QuestionSectionsCompanion({
    this.questionId = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestionSectionsCompanion.insert({
    required int questionId,
    required int sectionId,
    this.rowid = const Value.absent(),
  }) : questionId = Value(questionId),
       sectionId = Value(sectionId);
  static Insertable<QuestionSection> custom({
    Expression<int>? questionId,
    Expression<int>? sectionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (questionId != null) 'question_id': questionId,
      if (sectionId != null) 'section_id': sectionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestionSectionsCompanion copyWith({
    Value<int>? questionId,
    Value<int>? sectionId,
    Value<int>? rowid,
  }) {
    return QuestionSectionsCompanion(
      questionId: questionId ?? this.questionId,
      sectionId: sectionId ?? this.sectionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (questionId.present) {
      map['question_id'] = Variable<int>(questionId.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<int>(sectionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionSectionsCompanion(')
          ..write('questionId: $questionId, ')
          ..write('sectionId: $sectionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FactCardsTable extends FactCards
    with TableInfo<$FactCardsTable, FactCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FactCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _factIdMeta = const VerificationMeta('factId');
  @override
  late final GeneratedColumn<int> factId = GeneratedColumn<int>(
    'fact_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES facts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fsrsJsonMeta = const VerificationMeta(
    'fsrsJson',
  );
  @override
  late final GeneratedColumn<String> fsrsJson = GeneratedColumn<String>(
    'fsrs_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueMeta = const VerificationMeta('due');
  @override
  late final GeneratedColumn<DateTime> due = GeneratedColumn<DateTime>(
    'due',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stabilityMeta = const VerificationMeta(
    'stability',
  );
  @override
  late final GeneratedColumn<double> stability = GeneratedColumn<double>(
    'stability',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
    'difficulty',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastReviewMeta = const VerificationMeta(
    'lastReview',
  );
  @override
  late final GeneratedColumn<DateTime> lastReview = GeneratedColumn<DateTime>(
    'last_review',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    factId,
    fsrsJson,
    due,
    stability,
    difficulty,
    state,
    lastReview,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fact_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<FactCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('fact_id')) {
      context.handle(
        _factIdMeta,
        factId.isAcceptableOrUnknown(data['fact_id']!, _factIdMeta),
      );
    }
    if (data.containsKey('fsrs_json')) {
      context.handle(
        _fsrsJsonMeta,
        fsrsJson.isAcceptableOrUnknown(data['fsrs_json']!, _fsrsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_fsrsJsonMeta);
    }
    if (data.containsKey('due')) {
      context.handle(
        _dueMeta,
        due.isAcceptableOrUnknown(data['due']!, _dueMeta),
      );
    } else if (isInserting) {
      context.missing(_dueMeta);
    }
    if (data.containsKey('stability')) {
      context.handle(
        _stabilityMeta,
        stability.isAcceptableOrUnknown(data['stability']!, _stabilityMeta),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('last_review')) {
      context.handle(
        _lastReviewMeta,
        lastReview.isAcceptableOrUnknown(data['last_review']!, _lastReviewMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {factId};
  @override
  FactCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FactCard(
      factId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fact_id'],
      )!,
      fsrsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fsrs_json'],
      )!,
      due: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due'],
      )!,
      stability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stability'],
      ),
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}difficulty'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      lastReview: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_review'],
      ),
    );
  }

  @override
  $FactCardsTable createAlias(String alias) {
    return $FactCardsTable(attachedDatabase, alias);
  }
}

class FactCard extends DataClass implements Insertable<FactCard> {
  final int factId;
  final String fsrsJson;
  final DateTime due;
  final double? stability;
  final double? difficulty;

  /// learning | review | relearning
  final String state;
  final DateTime? lastReview;
  const FactCard({
    required this.factId,
    required this.fsrsJson,
    required this.due,
    this.stability,
    this.difficulty,
    required this.state,
    this.lastReview,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['fact_id'] = Variable<int>(factId);
    map['fsrs_json'] = Variable<String>(fsrsJson);
    map['due'] = Variable<DateTime>(due);
    if (!nullToAbsent || stability != null) {
      map['stability'] = Variable<double>(stability);
    }
    if (!nullToAbsent || difficulty != null) {
      map['difficulty'] = Variable<double>(difficulty);
    }
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || lastReview != null) {
      map['last_review'] = Variable<DateTime>(lastReview);
    }
    return map;
  }

  FactCardsCompanion toCompanion(bool nullToAbsent) {
    return FactCardsCompanion(
      factId: Value(factId),
      fsrsJson: Value(fsrsJson),
      due: Value(due),
      stability: stability == null && nullToAbsent
          ? const Value.absent()
          : Value(stability),
      difficulty: difficulty == null && nullToAbsent
          ? const Value.absent()
          : Value(difficulty),
      state: Value(state),
      lastReview: lastReview == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReview),
    );
  }

  factory FactCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FactCard(
      factId: serializer.fromJson<int>(json['factId']),
      fsrsJson: serializer.fromJson<String>(json['fsrsJson']),
      due: serializer.fromJson<DateTime>(json['due']),
      stability: serializer.fromJson<double?>(json['stability']),
      difficulty: serializer.fromJson<double?>(json['difficulty']),
      state: serializer.fromJson<String>(json['state']),
      lastReview: serializer.fromJson<DateTime?>(json['lastReview']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'factId': serializer.toJson<int>(factId),
      'fsrsJson': serializer.toJson<String>(fsrsJson),
      'due': serializer.toJson<DateTime>(due),
      'stability': serializer.toJson<double?>(stability),
      'difficulty': serializer.toJson<double?>(difficulty),
      'state': serializer.toJson<String>(state),
      'lastReview': serializer.toJson<DateTime?>(lastReview),
    };
  }

  FactCard copyWith({
    int? factId,
    String? fsrsJson,
    DateTime? due,
    Value<double?> stability = const Value.absent(),
    Value<double?> difficulty = const Value.absent(),
    String? state,
    Value<DateTime?> lastReview = const Value.absent(),
  }) => FactCard(
    factId: factId ?? this.factId,
    fsrsJson: fsrsJson ?? this.fsrsJson,
    due: due ?? this.due,
    stability: stability.present ? stability.value : this.stability,
    difficulty: difficulty.present ? difficulty.value : this.difficulty,
    state: state ?? this.state,
    lastReview: lastReview.present ? lastReview.value : this.lastReview,
  );
  FactCard copyWithCompanion(FactCardsCompanion data) {
    return FactCard(
      factId: data.factId.present ? data.factId.value : this.factId,
      fsrsJson: data.fsrsJson.present ? data.fsrsJson.value : this.fsrsJson,
      due: data.due.present ? data.due.value : this.due,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      state: data.state.present ? data.state.value : this.state,
      lastReview: data.lastReview.present
          ? data.lastReview.value
          : this.lastReview,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FactCard(')
          ..write('factId: $factId, ')
          ..write('fsrsJson: $fsrsJson, ')
          ..write('due: $due, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('state: $state, ')
          ..write('lastReview: $lastReview')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    factId,
    fsrsJson,
    due,
    stability,
    difficulty,
    state,
    lastReview,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FactCard &&
          other.factId == this.factId &&
          other.fsrsJson == this.fsrsJson &&
          other.due == this.due &&
          other.stability == this.stability &&
          other.difficulty == this.difficulty &&
          other.state == this.state &&
          other.lastReview == this.lastReview);
}

class FactCardsCompanion extends UpdateCompanion<FactCard> {
  final Value<int> factId;
  final Value<String> fsrsJson;
  final Value<DateTime> due;
  final Value<double?> stability;
  final Value<double?> difficulty;
  final Value<String> state;
  final Value<DateTime?> lastReview;
  const FactCardsCompanion({
    this.factId = const Value.absent(),
    this.fsrsJson = const Value.absent(),
    this.due = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.state = const Value.absent(),
    this.lastReview = const Value.absent(),
  });
  FactCardsCompanion.insert({
    this.factId = const Value.absent(),
    required String fsrsJson,
    required DateTime due,
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    required String state,
    this.lastReview = const Value.absent(),
  }) : fsrsJson = Value(fsrsJson),
       due = Value(due),
       state = Value(state);
  static Insertable<FactCard> custom({
    Expression<int>? factId,
    Expression<String>? fsrsJson,
    Expression<DateTime>? due,
    Expression<double>? stability,
    Expression<double>? difficulty,
    Expression<String>? state,
    Expression<DateTime>? lastReview,
  }) {
    return RawValuesInsertable({
      if (factId != null) 'fact_id': factId,
      if (fsrsJson != null) 'fsrs_json': fsrsJson,
      if (due != null) 'due': due,
      if (stability != null) 'stability': stability,
      if (difficulty != null) 'difficulty': difficulty,
      if (state != null) 'state': state,
      if (lastReview != null) 'last_review': lastReview,
    });
  }

  FactCardsCompanion copyWith({
    Value<int>? factId,
    Value<String>? fsrsJson,
    Value<DateTime>? due,
    Value<double?>? stability,
    Value<double?>? difficulty,
    Value<String>? state,
    Value<DateTime?>? lastReview,
  }) {
    return FactCardsCompanion(
      factId: factId ?? this.factId,
      fsrsJson: fsrsJson ?? this.fsrsJson,
      due: due ?? this.due,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      state: state ?? this.state,
      lastReview: lastReview ?? this.lastReview,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (factId.present) {
      map['fact_id'] = Variable<int>(factId.value);
    }
    if (fsrsJson.present) {
      map['fsrs_json'] = Variable<String>(fsrsJson.value);
    }
    if (due.present) {
      map['due'] = Variable<DateTime>(due.value);
    }
    if (stability.present) {
      map['stability'] = Variable<double>(stability.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (lastReview.present) {
      map['last_review'] = Variable<DateTime>(lastReview.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FactCardsCompanion(')
          ..write('factId: $factId, ')
          ..write('fsrsJson: $fsrsJson, ')
          ..write('due: $due, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('state: $state, ')
          ..write('lastReview: $lastReview')
          ..write(')'))
        .toString();
  }
}

class $ReviewsTable extends Reviews with TableInfo<$ReviewsTable, Review> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _factIdMeta = const VerificationMeta('factId');
  @override
  late final GeneratedColumn<int> factId = GeneratedColumn<int>(
    'fact_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES facts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<int> questionId = GeneratedColumn<int>(
    'question_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctMeta = const VerificationMeta(
    'correct',
  );
  @override
  late final GeneratedColumn<bool> correct = GeneratedColumn<bool>(
    'correct',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _responseMsMeta = const VerificationMeta(
    'responseMs',
  );
  @override
  late final GeneratedColumn<int> responseMs = GeneratedColumn<int>(
    'response_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unsureMeta = const VerificationMeta('unsure');
  @override
  late final GeneratedColumn<bool> unsure = GeneratedColumn<bool>(
    'unsure',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("unsure" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
    'reviewed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    factId,
    questionId,
    rating,
    correct,
    responseMs,
    unsure,
    reviewedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reviews';
  @override
  VerificationContext validateIntegrity(
    Insertable<Review> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fact_id')) {
      context.handle(
        _factIdMeta,
        factId.isAcceptableOrUnknown(data['fact_id']!, _factIdMeta),
      );
    } else if (isInserting) {
      context.missing(_factIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('correct')) {
      context.handle(
        _correctMeta,
        correct.isAcceptableOrUnknown(data['correct']!, _correctMeta),
      );
    }
    if (data.containsKey('response_ms')) {
      context.handle(
        _responseMsMeta,
        responseMs.isAcceptableOrUnknown(data['response_ms']!, _responseMsMeta),
      );
    }
    if (data.containsKey('unsure')) {
      context.handle(
        _unsureMeta,
        unsure.isAcceptableOrUnknown(data['unsure']!, _unsureMeta),
      );
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_reviewedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Review map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Review(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      factId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fact_id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_id'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      )!,
      correct: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}correct'],
      ),
      responseMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}response_ms'],
      ),
      unsure: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}unsure'],
      )!,
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reviewed_at'],
      )!,
    );
  }

  @override
  $ReviewsTable createAlias(String alias) {
    return $ReviewsTable(attachedDatabase, alias);
  }
}

class Review extends DataClass implements Insertable<Review> {
  final int id;
  final int factId;
  final int? questionId;

  /// FSRS rating: 1 again, 2 hard, 3 good, 4 easy.
  final int rating;
  final bool? correct;
  final int? responseMs;
  final bool unsure;
  final DateTime reviewedAt;
  const Review({
    required this.id,
    required this.factId,
    this.questionId,
    required this.rating,
    this.correct,
    this.responseMs,
    required this.unsure,
    required this.reviewedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fact_id'] = Variable<int>(factId);
    if (!nullToAbsent || questionId != null) {
      map['question_id'] = Variable<int>(questionId);
    }
    map['rating'] = Variable<int>(rating);
    if (!nullToAbsent || correct != null) {
      map['correct'] = Variable<bool>(correct);
    }
    if (!nullToAbsent || responseMs != null) {
      map['response_ms'] = Variable<int>(responseMs);
    }
    map['unsure'] = Variable<bool>(unsure);
    map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    return map;
  }

  ReviewsCompanion toCompanion(bool nullToAbsent) {
    return ReviewsCompanion(
      id: Value(id),
      factId: Value(factId),
      questionId: questionId == null && nullToAbsent
          ? const Value.absent()
          : Value(questionId),
      rating: Value(rating),
      correct: correct == null && nullToAbsent
          ? const Value.absent()
          : Value(correct),
      responseMs: responseMs == null && nullToAbsent
          ? const Value.absent()
          : Value(responseMs),
      unsure: Value(unsure),
      reviewedAt: Value(reviewedAt),
    );
  }

  factory Review.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Review(
      id: serializer.fromJson<int>(json['id']),
      factId: serializer.fromJson<int>(json['factId']),
      questionId: serializer.fromJson<int?>(json['questionId']),
      rating: serializer.fromJson<int>(json['rating']),
      correct: serializer.fromJson<bool?>(json['correct']),
      responseMs: serializer.fromJson<int?>(json['responseMs']),
      unsure: serializer.fromJson<bool>(json['unsure']),
      reviewedAt: serializer.fromJson<DateTime>(json['reviewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'factId': serializer.toJson<int>(factId),
      'questionId': serializer.toJson<int?>(questionId),
      'rating': serializer.toJson<int>(rating),
      'correct': serializer.toJson<bool?>(correct),
      'responseMs': serializer.toJson<int?>(responseMs),
      'unsure': serializer.toJson<bool>(unsure),
      'reviewedAt': serializer.toJson<DateTime>(reviewedAt),
    };
  }

  Review copyWith({
    int? id,
    int? factId,
    Value<int?> questionId = const Value.absent(),
    int? rating,
    Value<bool?> correct = const Value.absent(),
    Value<int?> responseMs = const Value.absent(),
    bool? unsure,
    DateTime? reviewedAt,
  }) => Review(
    id: id ?? this.id,
    factId: factId ?? this.factId,
    questionId: questionId.present ? questionId.value : this.questionId,
    rating: rating ?? this.rating,
    correct: correct.present ? correct.value : this.correct,
    responseMs: responseMs.present ? responseMs.value : this.responseMs,
    unsure: unsure ?? this.unsure,
    reviewedAt: reviewedAt ?? this.reviewedAt,
  );
  Review copyWithCompanion(ReviewsCompanion data) {
    return Review(
      id: data.id.present ? data.id.value : this.id,
      factId: data.factId.present ? data.factId.value : this.factId,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      rating: data.rating.present ? data.rating.value : this.rating,
      correct: data.correct.present ? data.correct.value : this.correct,
      responseMs: data.responseMs.present
          ? data.responseMs.value
          : this.responseMs,
      unsure: data.unsure.present ? data.unsure.value : this.unsure,
      reviewedAt: data.reviewedAt.present
          ? data.reviewedAt.value
          : this.reviewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Review(')
          ..write('id: $id, ')
          ..write('factId: $factId, ')
          ..write('questionId: $questionId, ')
          ..write('rating: $rating, ')
          ..write('correct: $correct, ')
          ..write('responseMs: $responseMs, ')
          ..write('unsure: $unsure, ')
          ..write('reviewedAt: $reviewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    factId,
    questionId,
    rating,
    correct,
    responseMs,
    unsure,
    reviewedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Review &&
          other.id == this.id &&
          other.factId == this.factId &&
          other.questionId == this.questionId &&
          other.rating == this.rating &&
          other.correct == this.correct &&
          other.responseMs == this.responseMs &&
          other.unsure == this.unsure &&
          other.reviewedAt == this.reviewedAt);
}

class ReviewsCompanion extends UpdateCompanion<Review> {
  final Value<int> id;
  final Value<int> factId;
  final Value<int?> questionId;
  final Value<int> rating;
  final Value<bool?> correct;
  final Value<int?> responseMs;
  final Value<bool> unsure;
  final Value<DateTime> reviewedAt;
  const ReviewsCompanion({
    this.id = const Value.absent(),
    this.factId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.rating = const Value.absent(),
    this.correct = const Value.absent(),
    this.responseMs = const Value.absent(),
    this.unsure = const Value.absent(),
    this.reviewedAt = const Value.absent(),
  });
  ReviewsCompanion.insert({
    this.id = const Value.absent(),
    required int factId,
    this.questionId = const Value.absent(),
    required int rating,
    this.correct = const Value.absent(),
    this.responseMs = const Value.absent(),
    this.unsure = const Value.absent(),
    required DateTime reviewedAt,
  }) : factId = Value(factId),
       rating = Value(rating),
       reviewedAt = Value(reviewedAt);
  static Insertable<Review> custom({
    Expression<int>? id,
    Expression<int>? factId,
    Expression<int>? questionId,
    Expression<int>? rating,
    Expression<bool>? correct,
    Expression<int>? responseMs,
    Expression<bool>? unsure,
    Expression<DateTime>? reviewedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (factId != null) 'fact_id': factId,
      if (questionId != null) 'question_id': questionId,
      if (rating != null) 'rating': rating,
      if (correct != null) 'correct': correct,
      if (responseMs != null) 'response_ms': responseMs,
      if (unsure != null) 'unsure': unsure,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
    });
  }

  ReviewsCompanion copyWith({
    Value<int>? id,
    Value<int>? factId,
    Value<int?>? questionId,
    Value<int>? rating,
    Value<bool?>? correct,
    Value<int?>? responseMs,
    Value<bool>? unsure,
    Value<DateTime>? reviewedAt,
  }) {
    return ReviewsCompanion(
      id: id ?? this.id,
      factId: factId ?? this.factId,
      questionId: questionId ?? this.questionId,
      rating: rating ?? this.rating,
      correct: correct ?? this.correct,
      responseMs: responseMs ?? this.responseMs,
      unsure: unsure ?? this.unsure,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (factId.present) {
      map['fact_id'] = Variable<int>(factId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<int>(questionId.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (correct.present) {
      map['correct'] = Variable<bool>(correct.value);
    }
    if (responseMs.present) {
      map['response_ms'] = Variable<int>(responseMs.value);
    }
    if (unsure.present) {
      map['unsure'] = Variable<bool>(unsure.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewsCompanion(')
          ..write('id: $id, ')
          ..write('factId: $factId, ')
          ..write('questionId: $questionId, ')
          ..write('rating: $rating, ')
          ..write('correct: $correct, ')
          ..write('responseMs: $responseMs, ')
          ..write('unsure: $unsure, ')
          ..write('reviewedAt: $reviewedAt')
          ..write(')'))
        .toString();
  }
}

class $JobsTable extends Jobs with TableInfo<$JobsTable, Job> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<int> documentId = GeneratedColumn<int>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documents (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _scopeJsonMeta = const VerificationMeta(
    'scopeJson',
  );
  @override
  late final GeneratedColumn<String> scopeJson = GeneratedColumn<String>(
    'scope_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileJsonMeta = const VerificationMeta(
    'profileJson',
  );
  @override
  late final GeneratedColumn<String> profileJson = GeneratedColumn<String>(
    'profile_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    documentId,
    scopeJson,
    profileJson,
    status,
    priority,
    error,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Job> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('scope_json')) {
      context.handle(
        _scopeJsonMeta,
        scopeJson.isAcceptableOrUnknown(data['scope_json']!, _scopeJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeJsonMeta);
    }
    if (data.containsKey('profile_json')) {
      context.handle(
        _profileJsonMeta,
        profileJson.isAcceptableOrUnknown(
          data['profile_json']!,
          _profileJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_profileJsonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Job map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Job(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}document_id'],
      )!,
      scopeJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_json'],
      )!,
      profileJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_json'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $JobsTable createAlias(String alias) {
    return $JobsTable(attachedDatabase, alias);
  }
}

class Job extends DataClass implements Insertable<Job> {
  final int id;
  final int documentId;
  final String scopeJson;
  final String profileJson;

  /// queued | running | paused | done | failed
  final String status;
  final int priority;
  final String? error;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Job({
    required this.id,
    required this.documentId,
    required this.scopeJson,
    required this.profileJson,
    required this.status,
    required this.priority,
    this.error,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['document_id'] = Variable<int>(documentId);
    map['scope_json'] = Variable<String>(scopeJson);
    map['profile_json'] = Variable<String>(profileJson);
    map['status'] = Variable<String>(status);
    map['priority'] = Variable<int>(priority);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  JobsCompanion toCompanion(bool nullToAbsent) {
    return JobsCompanion(
      id: Value(id),
      documentId: Value(documentId),
      scopeJson: Value(scopeJson),
      profileJson: Value(profileJson),
      status: Value(status),
      priority: Value(priority),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Job.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Job(
      id: serializer.fromJson<int>(json['id']),
      documentId: serializer.fromJson<int>(json['documentId']),
      scopeJson: serializer.fromJson<String>(json['scopeJson']),
      profileJson: serializer.fromJson<String>(json['profileJson']),
      status: serializer.fromJson<String>(json['status']),
      priority: serializer.fromJson<int>(json['priority']),
      error: serializer.fromJson<String?>(json['error']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'documentId': serializer.toJson<int>(documentId),
      'scopeJson': serializer.toJson<String>(scopeJson),
      'profileJson': serializer.toJson<String>(profileJson),
      'status': serializer.toJson<String>(status),
      'priority': serializer.toJson<int>(priority),
      'error': serializer.toJson<String?>(error),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Job copyWith({
    int? id,
    int? documentId,
    String? scopeJson,
    String? profileJson,
    String? status,
    int? priority,
    Value<String?> error = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Job(
    id: id ?? this.id,
    documentId: documentId ?? this.documentId,
    scopeJson: scopeJson ?? this.scopeJson,
    profileJson: profileJson ?? this.profileJson,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    error: error.present ? error.value : this.error,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Job copyWithCompanion(JobsCompanion data) {
    return Job(
      id: data.id.present ? data.id.value : this.id,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      scopeJson: data.scopeJson.present ? data.scopeJson.value : this.scopeJson,
      profileJson: data.profileJson.present
          ? data.profileJson.value
          : this.profileJson,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      error: data.error.present ? data.error.value : this.error,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Job(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('scopeJson: $scopeJson, ')
          ..write('profileJson: $profileJson, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('error: $error, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    documentId,
    scopeJson,
    profileJson,
    status,
    priority,
    error,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Job &&
          other.id == this.id &&
          other.documentId == this.documentId &&
          other.scopeJson == this.scopeJson &&
          other.profileJson == this.profileJson &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.error == this.error &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class JobsCompanion extends UpdateCompanion<Job> {
  final Value<int> id;
  final Value<int> documentId;
  final Value<String> scopeJson;
  final Value<String> profileJson;
  final Value<String> status;
  final Value<int> priority;
  final Value<String?> error;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const JobsCompanion({
    this.id = const Value.absent(),
    this.documentId = const Value.absent(),
    this.scopeJson = const Value.absent(),
    this.profileJson = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.error = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  JobsCompanion.insert({
    this.id = const Value.absent(),
    required int documentId,
    required String scopeJson,
    required String profileJson,
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.error = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : documentId = Value(documentId),
       scopeJson = Value(scopeJson),
       profileJson = Value(profileJson);
  static Insertable<Job> custom({
    Expression<int>? id,
    Expression<int>? documentId,
    Expression<String>? scopeJson,
    Expression<String>? profileJson,
    Expression<String>? status,
    Expression<int>? priority,
    Expression<String>? error,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentId != null) 'document_id': documentId,
      if (scopeJson != null) 'scope_json': scopeJson,
      if (profileJson != null) 'profile_json': profileJson,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (error != null) 'error': error,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  JobsCompanion copyWith({
    Value<int>? id,
    Value<int>? documentId,
    Value<String>? scopeJson,
    Value<String>? profileJson,
    Value<String>? status,
    Value<int>? priority,
    Value<String?>? error,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return JobsCompanion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      scopeJson: scopeJson ?? this.scopeJson,
      profileJson: profileJson ?? this.profileJson,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      error: error ?? this.error,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<int>(documentId.value);
    }
    if (scopeJson.present) {
      map['scope_json'] = Variable<String>(scopeJson.value);
    }
    if (profileJson.present) {
      map['profile_json'] = Variable<String>(profileJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobsCompanion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('scopeJson: $scopeJson, ')
          ..write('profileJson: $profileJson, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('error: $error, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $JobItemsTable extends JobItems with TableInfo<$JobItemsTable, JobItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _jobIdMeta = const VerificationMeta('jobId');
  @override
  late final GeneratedColumn<int> jobId = GeneratedColumn<int>(
    'job_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES jobs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _chunkIdMeta = const VerificationMeta(
    'chunkId',
  );
  @override
  late final GeneratedColumn<int> chunkId = GeneratedColumn<int>(
    'chunk_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chunks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
    'stage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta(
    'cacheKey',
  );
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jobId,
    chunkId,
    stage,
    status,
    attempts,
    cacheKey,
    error,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'job_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<JobItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('job_id')) {
      context.handle(
        _jobIdMeta,
        jobId.isAcceptableOrUnknown(data['job_id']!, _jobIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jobIdMeta);
    }
    if (data.containsKey('chunk_id')) {
      context.handle(
        _chunkIdMeta,
        chunkId.isAcceptableOrUnknown(data['chunk_id']!, _chunkIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chunkIdMeta);
    }
    if (data.containsKey('stage')) {
      context.handle(
        _stageMeta,
        stage.isAcceptableOrUnknown(data['stage']!, _stageMeta),
      );
    } else if (isInserting) {
      context.missing(_stageMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('cache_key')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JobItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JobItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      jobId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}job_id'],
      )!,
      chunkId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chunk_id'],
      )!,
      stage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_key'],
      ),
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $JobItemsTable createAlias(String alias) {
    return $JobItemsTable(attachedDatabase, alias);
  }
}

class JobItem extends DataClass implements Insertable<JobItem> {
  final int id;
  final int jobId;
  final int chunkId;
  final String stage;

  /// queued | running | done | failed | skipped
  final String status;
  final int attempts;
  final String? cacheKey;
  final String? error;
  final DateTime updatedAt;
  const JobItem({
    required this.id,
    required this.jobId,
    required this.chunkId,
    required this.stage,
    required this.status,
    required this.attempts,
    this.cacheKey,
    this.error,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['job_id'] = Variable<int>(jobId);
    map['chunk_id'] = Variable<int>(chunkId);
    map['stage'] = Variable<String>(stage);
    map['status'] = Variable<String>(status);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || cacheKey != null) {
      map['cache_key'] = Variable<String>(cacheKey);
    }
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  JobItemsCompanion toCompanion(bool nullToAbsent) {
    return JobItemsCompanion(
      id: Value(id),
      jobId: Value(jobId),
      chunkId: Value(chunkId),
      stage: Value(stage),
      status: Value(status),
      attempts: Value(attempts),
      cacheKey: cacheKey == null && nullToAbsent
          ? const Value.absent()
          : Value(cacheKey),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
      updatedAt: Value(updatedAt),
    );
  }

  factory JobItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JobItem(
      id: serializer.fromJson<int>(json['id']),
      jobId: serializer.fromJson<int>(json['jobId']),
      chunkId: serializer.fromJson<int>(json['chunkId']),
      stage: serializer.fromJson<String>(json['stage']),
      status: serializer.fromJson<String>(json['status']),
      attempts: serializer.fromJson<int>(json['attempts']),
      cacheKey: serializer.fromJson<String?>(json['cacheKey']),
      error: serializer.fromJson<String?>(json['error']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'jobId': serializer.toJson<int>(jobId),
      'chunkId': serializer.toJson<int>(chunkId),
      'stage': serializer.toJson<String>(stage),
      'status': serializer.toJson<String>(status),
      'attempts': serializer.toJson<int>(attempts),
      'cacheKey': serializer.toJson<String?>(cacheKey),
      'error': serializer.toJson<String?>(error),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  JobItem copyWith({
    int? id,
    int? jobId,
    int? chunkId,
    String? stage,
    String? status,
    int? attempts,
    Value<String?> cacheKey = const Value.absent(),
    Value<String?> error = const Value.absent(),
    DateTime? updatedAt,
  }) => JobItem(
    id: id ?? this.id,
    jobId: jobId ?? this.jobId,
    chunkId: chunkId ?? this.chunkId,
    stage: stage ?? this.stage,
    status: status ?? this.status,
    attempts: attempts ?? this.attempts,
    cacheKey: cacheKey.present ? cacheKey.value : this.cacheKey,
    error: error.present ? error.value : this.error,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  JobItem copyWithCompanion(JobItemsCompanion data) {
    return JobItem(
      id: data.id.present ? data.id.value : this.id,
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      chunkId: data.chunkId.present ? data.chunkId.value : this.chunkId,
      stage: data.stage.present ? data.stage.value : this.stage,
      status: data.status.present ? data.status.value : this.status,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      error: data.error.present ? data.error.value : this.error,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JobItem(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('chunkId: $chunkId, ')
          ..write('stage: $stage, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('cacheKey: $cacheKey, ')
          ..write('error: $error, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    jobId,
    chunkId,
    stage,
    status,
    attempts,
    cacheKey,
    error,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JobItem &&
          other.id == this.id &&
          other.jobId == this.jobId &&
          other.chunkId == this.chunkId &&
          other.stage == this.stage &&
          other.status == this.status &&
          other.attempts == this.attempts &&
          other.cacheKey == this.cacheKey &&
          other.error == this.error &&
          other.updatedAt == this.updatedAt);
}

class JobItemsCompanion extends UpdateCompanion<JobItem> {
  final Value<int> id;
  final Value<int> jobId;
  final Value<int> chunkId;
  final Value<String> stage;
  final Value<String> status;
  final Value<int> attempts;
  final Value<String?> cacheKey;
  final Value<String?> error;
  final Value<DateTime> updatedAt;
  const JobItemsCompanion({
    this.id = const Value.absent(),
    this.jobId = const Value.absent(),
    this.chunkId = const Value.absent(),
    this.stage = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.cacheKey = const Value.absent(),
    this.error = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  JobItemsCompanion.insert({
    this.id = const Value.absent(),
    required int jobId,
    required int chunkId,
    required String stage,
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.cacheKey = const Value.absent(),
    this.error = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : jobId = Value(jobId),
       chunkId = Value(chunkId),
       stage = Value(stage);
  static Insertable<JobItem> custom({
    Expression<int>? id,
    Expression<int>? jobId,
    Expression<int>? chunkId,
    Expression<String>? stage,
    Expression<String>? status,
    Expression<int>? attempts,
    Expression<String>? cacheKey,
    Expression<String>? error,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jobId != null) 'job_id': jobId,
      if (chunkId != null) 'chunk_id': chunkId,
      if (stage != null) 'stage': stage,
      if (status != null) 'status': status,
      if (attempts != null) 'attempts': attempts,
      if (cacheKey != null) 'cache_key': cacheKey,
      if (error != null) 'error': error,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  JobItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? jobId,
    Value<int>? chunkId,
    Value<String>? stage,
    Value<String>? status,
    Value<int>? attempts,
    Value<String?>? cacheKey,
    Value<String?>? error,
    Value<DateTime>? updatedAt,
  }) {
    return JobItemsCompanion(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      chunkId: chunkId ?? this.chunkId,
      stage: stage ?? this.stage,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      cacheKey: cacheKey ?? this.cacheKey,
      error: error ?? this.error,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (jobId.present) {
      map['job_id'] = Variable<int>(jobId.value);
    }
    if (chunkId.present) {
      map['chunk_id'] = Variable<int>(chunkId.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobItemsCompanion(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('chunkId: $chunkId, ')
          ..write('stage: $stage, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('cacheKey: $cacheKey, ')
          ..write('error: $error, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LlmCacheEntriesTable extends LlmCacheEntries
    with TableInfo<$LlmCacheEntriesTable, LlmCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LlmCacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta(
    'cacheKey',
  );
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outputMeta = const VerificationMeta('output');
  @override
  late final GeneratedColumn<String> output = GeneratedColumn<String>(
    'output',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [cacheKey, output, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'llm_cache_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LlmCacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cache_key')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('output')) {
      context.handle(
        _outputMeta,
        output.isAcceptableOrUnknown(data['output']!, _outputMeta),
      );
    } else if (isInserting) {
      context.missing(_outputMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cacheKey};
  @override
  LlmCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LlmCacheEntry(
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_key'],
      )!,
      output: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}output'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LlmCacheEntriesTable createAlias(String alias) {
    return $LlmCacheEntriesTable(attachedDatabase, alias);
  }
}

class LlmCacheEntry extends DataClass implements Insertable<LlmCacheEntry> {
  final String cacheKey;
  final String output;
  final DateTime createdAt;
  const LlmCacheEntry({
    required this.cacheKey,
    required this.output,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cache_key'] = Variable<String>(cacheKey);
    map['output'] = Variable<String>(output);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LlmCacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return LlmCacheEntriesCompanion(
      cacheKey: Value(cacheKey),
      output: Value(output),
      createdAt: Value(createdAt),
    );
  }

  factory LlmCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LlmCacheEntry(
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      output: serializer.fromJson<String>(json['output']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cacheKey': serializer.toJson<String>(cacheKey),
      'output': serializer.toJson<String>(output),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LlmCacheEntry copyWith({
    String? cacheKey,
    String? output,
    DateTime? createdAt,
  }) => LlmCacheEntry(
    cacheKey: cacheKey ?? this.cacheKey,
    output: output ?? this.output,
    createdAt: createdAt ?? this.createdAt,
  );
  LlmCacheEntry copyWithCompanion(LlmCacheEntriesCompanion data) {
    return LlmCacheEntry(
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      output: data.output.present ? data.output.value : this.output,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LlmCacheEntry(')
          ..write('cacheKey: $cacheKey, ')
          ..write('output: $output, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cacheKey, output, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LlmCacheEntry &&
          other.cacheKey == this.cacheKey &&
          other.output == this.output &&
          other.createdAt == this.createdAt);
}

class LlmCacheEntriesCompanion extends UpdateCompanion<LlmCacheEntry> {
  final Value<String> cacheKey;
  final Value<String> output;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LlmCacheEntriesCompanion({
    this.cacheKey = const Value.absent(),
    this.output = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LlmCacheEntriesCompanion.insert({
    required String cacheKey,
    required String output,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : cacheKey = Value(cacheKey),
       output = Value(output);
  static Insertable<LlmCacheEntry> custom({
    Expression<String>? cacheKey,
    Expression<String>? output,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cacheKey != null) 'cache_key': cacheKey,
      if (output != null) 'output': output,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LlmCacheEntriesCompanion copyWith({
    Value<String>? cacheKey,
    Value<String>? output,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LlmCacheEntriesCompanion(
      cacheKey: cacheKey ?? this.cacheKey,
      output: output ?? this.output,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (output.present) {
      map['output'] = Variable<String>(output.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LlmCacheEntriesCompanion(')
          ..write('cacheKey: $cacheKey, ')
          ..write('output: $output, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RejectionsTable extends Rejections
    with TableInfo<$RejectionsTable, Rejection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RejectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<int> documentId = GeneratedColumn<int>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documents (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _chunkIdMeta = const VerificationMeta(
    'chunkId',
  );
  @override
  late final GeneratedColumn<int> chunkId = GeneratedColumn<int>(
    'chunk_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
    'stage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    documentId,
    chunkId,
    stage,
    reason,
    payload,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rejections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Rejection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('chunk_id')) {
      context.handle(
        _chunkIdMeta,
        chunkId.isAcceptableOrUnknown(data['chunk_id']!, _chunkIdMeta),
      );
    }
    if (data.containsKey('stage')) {
      context.handle(
        _stageMeta,
        stage.isAcceptableOrUnknown(data['stage']!, _stageMeta),
      );
    } else if (isInserting) {
      context.missing(_stageMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Rejection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Rejection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}document_id'],
      )!,
      chunkId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chunk_id'],
      ),
      stage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RejectionsTable createAlias(String alias) {
    return $RejectionsTable(attachedDatabase, alias);
  }
}

class Rejection extends DataClass implements Insertable<Rejection> {
  final int id;
  final int documentId;
  final int? chunkId;
  final String stage;
  final String reason;
  final String? payload;
  final DateTime createdAt;
  const Rejection({
    required this.id,
    required this.documentId,
    this.chunkId,
    required this.stage,
    required this.reason,
    this.payload,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['document_id'] = Variable<int>(documentId);
    if (!nullToAbsent || chunkId != null) {
      map['chunk_id'] = Variable<int>(chunkId);
    }
    map['stage'] = Variable<String>(stage);
    map['reason'] = Variable<String>(reason);
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RejectionsCompanion toCompanion(bool nullToAbsent) {
    return RejectionsCompanion(
      id: Value(id),
      documentId: Value(documentId),
      chunkId: chunkId == null && nullToAbsent
          ? const Value.absent()
          : Value(chunkId),
      stage: Value(stage),
      reason: Value(reason),
      payload: payload == null && nullToAbsent
          ? const Value.absent()
          : Value(payload),
      createdAt: Value(createdAt),
    );
  }

  factory Rejection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Rejection(
      id: serializer.fromJson<int>(json['id']),
      documentId: serializer.fromJson<int>(json['documentId']),
      chunkId: serializer.fromJson<int?>(json['chunkId']),
      stage: serializer.fromJson<String>(json['stage']),
      reason: serializer.fromJson<String>(json['reason']),
      payload: serializer.fromJson<String?>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'documentId': serializer.toJson<int>(documentId),
      'chunkId': serializer.toJson<int?>(chunkId),
      'stage': serializer.toJson<String>(stage),
      'reason': serializer.toJson<String>(reason),
      'payload': serializer.toJson<String?>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Rejection copyWith({
    int? id,
    int? documentId,
    Value<int?> chunkId = const Value.absent(),
    String? stage,
    String? reason,
    Value<String?> payload = const Value.absent(),
    DateTime? createdAt,
  }) => Rejection(
    id: id ?? this.id,
    documentId: documentId ?? this.documentId,
    chunkId: chunkId.present ? chunkId.value : this.chunkId,
    stage: stage ?? this.stage,
    reason: reason ?? this.reason,
    payload: payload.present ? payload.value : this.payload,
    createdAt: createdAt ?? this.createdAt,
  );
  Rejection copyWithCompanion(RejectionsCompanion data) {
    return Rejection(
      id: data.id.present ? data.id.value : this.id,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      chunkId: data.chunkId.present ? data.chunkId.value : this.chunkId,
      stage: data.stage.present ? data.stage.value : this.stage,
      reason: data.reason.present ? data.reason.value : this.reason,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Rejection(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('chunkId: $chunkId, ')
          ..write('stage: $stage, ')
          ..write('reason: $reason, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, documentId, chunkId, stage, reason, payload, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Rejection &&
          other.id == this.id &&
          other.documentId == this.documentId &&
          other.chunkId == this.chunkId &&
          other.stage == this.stage &&
          other.reason == this.reason &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt);
}

class RejectionsCompanion extends UpdateCompanion<Rejection> {
  final Value<int> id;
  final Value<int> documentId;
  final Value<int?> chunkId;
  final Value<String> stage;
  final Value<String> reason;
  final Value<String?> payload;
  final Value<DateTime> createdAt;
  const RejectionsCompanion({
    this.id = const Value.absent(),
    this.documentId = const Value.absent(),
    this.chunkId = const Value.absent(),
    this.stage = const Value.absent(),
    this.reason = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RejectionsCompanion.insert({
    this.id = const Value.absent(),
    required int documentId,
    this.chunkId = const Value.absent(),
    required String stage,
    required String reason,
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : documentId = Value(documentId),
       stage = Value(stage),
       reason = Value(reason);
  static Insertable<Rejection> custom({
    Expression<int>? id,
    Expression<int>? documentId,
    Expression<int>? chunkId,
    Expression<String>? stage,
    Expression<String>? reason,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentId != null) 'document_id': documentId,
      if (chunkId != null) 'chunk_id': chunkId,
      if (stage != null) 'stage': stage,
      if (reason != null) 'reason': reason,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RejectionsCompanion copyWith({
    Value<int>? id,
    Value<int>? documentId,
    Value<int?>? chunkId,
    Value<String>? stage,
    Value<String>? reason,
    Value<String?>? payload,
    Value<DateTime>? createdAt,
  }) {
    return RejectionsCompanion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      chunkId: chunkId ?? this.chunkId,
      stage: stage ?? this.stage,
      reason: reason ?? this.reason,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<int>(documentId.value);
    }
    if (chunkId.present) {
      map['chunk_id'] = Variable<int>(chunkId.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RejectionsCompanion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('chunkId: $chunkId, ')
          ..write('stage: $stage, ')
          ..write('reason: $reason, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ChatThreadsTable extends ChatThreads
    with TableInfo<$ChatThreadsTable, ChatThread> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatThreadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<int> documentId = GeneratedColumn<int>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documents (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _modelPathMeta = const VerificationMeta(
    'modelPath',
  );
  @override
  late final GeneratedColumn<String> modelPath = GeneratedColumn<String>(
    'model_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    documentId,
    title,
    summary,
    createdAt,
    modelPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_threads';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatThread> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('model_path')) {
      context.handle(
        _modelPathMeta,
        modelPath.isAcceptableOrUnknown(data['model_path']!, _modelPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatThread map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatThread(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}document_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      modelPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_path'],
      ),
    );
  }

  @override
  $ChatThreadsTable createAlias(String alias) {
    return $ChatThreadsTable(attachedDatabase, alias);
  }
}

class ChatThread extends DataClass implements Insertable<ChatThread> {
  final int id;
  final int documentId;
  final String title;
  final String? summary;
  final DateTime createdAt;

  /// The model file that answers in this conversation. Null: the document's
  /// model. (Schema 2.)
  final String? modelPath;
  const ChatThread({
    required this.id,
    required this.documentId,
    required this.title,
    this.summary,
    required this.createdAt,
    this.modelPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['document_id'] = Variable<int>(documentId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || modelPath != null) {
      map['model_path'] = Variable<String>(modelPath);
    }
    return map;
  }

  ChatThreadsCompanion toCompanion(bool nullToAbsent) {
    return ChatThreadsCompanion(
      id: Value(id),
      documentId: Value(documentId),
      title: Value(title),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      createdAt: Value(createdAt),
      modelPath: modelPath == null && nullToAbsent
          ? const Value.absent()
          : Value(modelPath),
    );
  }

  factory ChatThread.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatThread(
      id: serializer.fromJson<int>(json['id']),
      documentId: serializer.fromJson<int>(json['documentId']),
      title: serializer.fromJson<String>(json['title']),
      summary: serializer.fromJson<String?>(json['summary']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      modelPath: serializer.fromJson<String?>(json['modelPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'documentId': serializer.toJson<int>(documentId),
      'title': serializer.toJson<String>(title),
      'summary': serializer.toJson<String?>(summary),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'modelPath': serializer.toJson<String?>(modelPath),
    };
  }

  ChatThread copyWith({
    int? id,
    int? documentId,
    String? title,
    Value<String?> summary = const Value.absent(),
    DateTime? createdAt,
    Value<String?> modelPath = const Value.absent(),
  }) => ChatThread(
    id: id ?? this.id,
    documentId: documentId ?? this.documentId,
    title: title ?? this.title,
    summary: summary.present ? summary.value : this.summary,
    createdAt: createdAt ?? this.createdAt,
    modelPath: modelPath.present ? modelPath.value : this.modelPath,
  );
  ChatThread copyWithCompanion(ChatThreadsCompanion data) {
    return ChatThread(
      id: data.id.present ? data.id.value : this.id,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      title: data.title.present ? data.title.value : this.title,
      summary: data.summary.present ? data.summary.value : this.summary,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      modelPath: data.modelPath.present ? data.modelPath.value : this.modelPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatThread(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('createdAt: $createdAt, ')
          ..write('modelPath: $modelPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, documentId, title, summary, createdAt, modelPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatThread &&
          other.id == this.id &&
          other.documentId == this.documentId &&
          other.title == this.title &&
          other.summary == this.summary &&
          other.createdAt == this.createdAt &&
          other.modelPath == this.modelPath);
}

class ChatThreadsCompanion extends UpdateCompanion<ChatThread> {
  final Value<int> id;
  final Value<int> documentId;
  final Value<String> title;
  final Value<String?> summary;
  final Value<DateTime> createdAt;
  final Value<String?> modelPath;
  const ChatThreadsCompanion({
    this.id = const Value.absent(),
    this.documentId = const Value.absent(),
    this.title = const Value.absent(),
    this.summary = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modelPath = const Value.absent(),
  });
  ChatThreadsCompanion.insert({
    this.id = const Value.absent(),
    required int documentId,
    required String title,
    this.summary = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modelPath = const Value.absent(),
  }) : documentId = Value(documentId),
       title = Value(title);
  static Insertable<ChatThread> custom({
    Expression<int>? id,
    Expression<int>? documentId,
    Expression<String>? title,
    Expression<String>? summary,
    Expression<DateTime>? createdAt,
    Expression<String>? modelPath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentId != null) 'document_id': documentId,
      if (title != null) 'title': title,
      if (summary != null) 'summary': summary,
      if (createdAt != null) 'created_at': createdAt,
      if (modelPath != null) 'model_path': modelPath,
    });
  }

  ChatThreadsCompanion copyWith({
    Value<int>? id,
    Value<int>? documentId,
    Value<String>? title,
    Value<String?>? summary,
    Value<DateTime>? createdAt,
    Value<String?>? modelPath,
  }) {
    return ChatThreadsCompanion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      createdAt: createdAt ?? this.createdAt,
      modelPath: modelPath ?? this.modelPath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<int>(documentId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (modelPath.present) {
      map['model_path'] = Variable<String>(modelPath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatThreadsCompanion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('createdAt: $createdAt, ')
          ..write('modelPath: $modelPath')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _threadIdMeta = const VerificationMeta(
    'threadId',
  );
  @override
  late final GeneratedColumn<int> threadId = GeneratedColumn<int>(
    'thread_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chat_threads (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _citationsJsonMeta = const VerificationMeta(
    'citationsJson',
  );
  @override
  late final GeneratedColumn<String> citationsJson = GeneratedColumn<String>(
    'citations_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usedWebMeta = const VerificationMeta(
    'usedWeb',
  );
  @override
  late final GeneratedColumn<bool> usedWeb = GeneratedColumn<bool>(
    'used_web',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("used_web" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    threadId,
    role,
    content,
    citationsJson,
    usedWeb,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('thread_id')) {
      context.handle(
        _threadIdMeta,
        threadId.isAcceptableOrUnknown(data['thread_id']!, _threadIdMeta),
      );
    } else if (isInserting) {
      context.missing(_threadIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('citations_json')) {
      context.handle(
        _citationsJsonMeta,
        citationsJson.isAcceptableOrUnknown(
          data['citations_json']!,
          _citationsJsonMeta,
        ),
      );
    }
    if (data.containsKey('used_web')) {
      context.handle(
        _usedWebMeta,
        usedWeb.isAcceptableOrUnknown(data['used_web']!, _usedWebMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      threadId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}thread_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      citationsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}citations_json'],
      ),
      usedWeb: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}used_web'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessage extends DataClass implements Insertable<ChatMessage> {
  final int id;
  final int threadId;

  /// user | assistant
  final String role;
  final String content;
  final String? citationsJson;
  final bool usedWeb;
  final DateTime createdAt;
  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.role,
    required this.content,
    this.citationsJson,
    required this.usedWeb,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['thread_id'] = Variable<int>(threadId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || citationsJson != null) {
      map['citations_json'] = Variable<String>(citationsJson);
    }
    map['used_web'] = Variable<bool>(usedWeb);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      threadId: Value(threadId),
      role: Value(role),
      content: Value(content),
      citationsJson: citationsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(citationsJson),
      usedWeb: Value(usedWeb),
      createdAt: Value(createdAt),
    );
  }

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessage(
      id: serializer.fromJson<int>(json['id']),
      threadId: serializer.fromJson<int>(json['threadId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      citationsJson: serializer.fromJson<String?>(json['citationsJson']),
      usedWeb: serializer.fromJson<bool>(json['usedWeb']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'threadId': serializer.toJson<int>(threadId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'citationsJson': serializer.toJson<String?>(citationsJson),
      'usedWeb': serializer.toJson<bool>(usedWeb),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ChatMessage copyWith({
    int? id,
    int? threadId,
    String? role,
    String? content,
    Value<String?> citationsJson = const Value.absent(),
    bool? usedWeb,
    DateTime? createdAt,
  }) => ChatMessage(
    id: id ?? this.id,
    threadId: threadId ?? this.threadId,
    role: role ?? this.role,
    content: content ?? this.content,
    citationsJson: citationsJson.present
        ? citationsJson.value
        : this.citationsJson,
    usedWeb: usedWeb ?? this.usedWeb,
    createdAt: createdAt ?? this.createdAt,
  );
  ChatMessage copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessage(
      id: data.id.present ? data.id.value : this.id,
      threadId: data.threadId.present ? data.threadId.value : this.threadId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      citationsJson: data.citationsJson.present
          ? data.citationsJson.value
          : this.citationsJson,
      usedWeb: data.usedWeb.present ? data.usedWeb.value : this.usedWeb,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessage(')
          ..write('id: $id, ')
          ..write('threadId: $threadId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('citationsJson: $citationsJson, ')
          ..write('usedWeb: $usedWeb, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    threadId,
    role,
    content,
    citationsJson,
    usedWeb,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessage &&
          other.id == this.id &&
          other.threadId == this.threadId &&
          other.role == this.role &&
          other.content == this.content &&
          other.citationsJson == this.citationsJson &&
          other.usedWeb == this.usedWeb &&
          other.createdAt == this.createdAt);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessage> {
  final Value<int> id;
  final Value<int> threadId;
  final Value<String> role;
  final Value<String> content;
  final Value<String?> citationsJson;
  final Value<bool> usedWeb;
  final Value<DateTime> createdAt;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.threadId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.citationsJson = const Value.absent(),
    this.usedWeb = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    this.id = const Value.absent(),
    required int threadId,
    required String role,
    required String content,
    this.citationsJson = const Value.absent(),
    this.usedWeb = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : threadId = Value(threadId),
       role = Value(role),
       content = Value(content);
  static Insertable<ChatMessage> custom({
    Expression<int>? id,
    Expression<int>? threadId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? citationsJson,
    Expression<bool>? usedWeb,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (threadId != null) 'thread_id': threadId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (citationsJson != null) 'citations_json': citationsJson,
      if (usedWeb != null) 'used_web': usedWeb,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ChatMessagesCompanion copyWith({
    Value<int>? id,
    Value<int>? threadId,
    Value<String>? role,
    Value<String>? content,
    Value<String?>? citationsJson,
    Value<bool>? usedWeb,
    Value<DateTime>? createdAt,
  }) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      role: role ?? this.role,
      content: content ?? this.content,
      citationsJson: citationsJson ?? this.citationsJson,
      usedWeb: usedWeb ?? this.usedWeb,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (threadId.present) {
      map['thread_id'] = Variable<int>(threadId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (citationsJson.present) {
      map['citations_json'] = Variable<String>(citationsJson.value);
    }
    if (usedWeb.present) {
      map['used_web'] = Variable<bool>(usedWeb.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('threadId: $threadId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('citationsJson: $citationsJson, ')
          ..write('usedWeb: $usedWeb, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $WebPagesTable extends WebPages with TableInfo<$WebPagesTable, WebPage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WebPagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _httpStatusMeta = const VerificationMeta(
    'httpStatus',
  );
  @override
  late final GeneratedColumn<int> httpStatus = GeneratedColumn<int>(
    'http_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    url,
    title,
    body,
    httpStatus,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'web_pages';
  @override
  VerificationContext validateIntegrity(
    Insertable<WebPage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('http_status')) {
      context.handle(
        _httpStatusMeta,
        httpStatus.isAcceptableOrUnknown(data['http_status']!, _httpStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_httpStatusMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {url};
  @override
  WebPage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WebPage(
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      httpStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}http_status'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $WebPagesTable createAlias(String alias) {
    return $WebPagesTable(attachedDatabase, alias);
  }
}

class WebPage extends DataClass implements Insertable<WebPage> {
  final String url;
  final String? title;
  final String body;
  final int httpStatus;
  final DateTime fetchedAt;
  const WebPage({
    required this.url,
    this.title,
    required this.body,
    required this.httpStatus,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['body'] = Variable<String>(body);
    map['http_status'] = Variable<int>(httpStatus);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  WebPagesCompanion toCompanion(bool nullToAbsent) {
    return WebPagesCompanion(
      url: Value(url),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      body: Value(body),
      httpStatus: Value(httpStatus),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory WebPage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WebPage(
      url: serializer.fromJson<String>(json['url']),
      title: serializer.fromJson<String?>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      httpStatus: serializer.fromJson<int>(json['httpStatus']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'url': serializer.toJson<String>(url),
      'title': serializer.toJson<String?>(title),
      'body': serializer.toJson<String>(body),
      'httpStatus': serializer.toJson<int>(httpStatus),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  WebPage copyWith({
    String? url,
    Value<String?> title = const Value.absent(),
    String? body,
    int? httpStatus,
    DateTime? fetchedAt,
  }) => WebPage(
    url: url ?? this.url,
    title: title.present ? title.value : this.title,
    body: body ?? this.body,
    httpStatus: httpStatus ?? this.httpStatus,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  WebPage copyWithCompanion(WebPagesCompanion data) {
    return WebPage(
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      httpStatus: data.httpStatus.present
          ? data.httpStatus.value
          : this.httpStatus,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WebPage(')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('httpStatus: $httpStatus, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(url, title, body, httpStatus, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WebPage &&
          other.url == this.url &&
          other.title == this.title &&
          other.body == this.body &&
          other.httpStatus == this.httpStatus &&
          other.fetchedAt == this.fetchedAt);
}

class WebPagesCompanion extends UpdateCompanion<WebPage> {
  final Value<String> url;
  final Value<String?> title;
  final Value<String> body;
  final Value<int> httpStatus;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const WebPagesCompanion({
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.httpStatus = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WebPagesCompanion.insert({
    required String url,
    this.title = const Value.absent(),
    required String body,
    required int httpStatus,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : url = Value(url),
       body = Value(body),
       httpStatus = Value(httpStatus),
       fetchedAt = Value(fetchedAt);
  static Insertable<WebPage> custom({
    Expression<String>? url,
    Expression<String>? title,
    Expression<String>? body,
    Expression<int>? httpStatus,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (httpStatus != null) 'http_status': httpStatus,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WebPagesCompanion copyWith({
    Value<String>? url,
    Value<String?>? title,
    Value<String>? body,
    Value<int>? httpStatus,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return WebPagesCompanion(
      url: url ?? this.url,
      title: title ?? this.title,
      body: body ?? this.body,
      httpStatus: httpStatus ?? this.httpStatus,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (httpStatus.present) {
      map['http_status'] = Variable<int>(httpStatus.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WebPagesCompanion(')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('httpStatus: $httpStatus, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WebLogEntriesTable extends WebLogEntries
    with TableInfo<$WebLogEntriesTable, WebLogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WebLogEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlsJsonMeta = const VerificationMeta(
    'urlsJson',
  );
  @override
  late final GeneratedColumn<String> urlsJson = GeneratedColumn<String>(
    'urls_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, query, provider, urlsJson, at];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'web_log_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<WebLogEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('query')) {
      context.handle(
        _queryMeta,
        query.isAcceptableOrUnknown(data['query']!, _queryMeta),
      );
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('urls_json')) {
      context.handle(
        _urlsJsonMeta,
        urlsJson.isAcceptableOrUnknown(data['urls_json']!, _urlsJsonMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WebLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WebLogEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      query: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      urlsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}urls_json'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $WebLogEntriesTable createAlias(String alias) {
    return $WebLogEntriesTable(attachedDatabase, alias);
  }
}

class WebLogEntry extends DataClass implements Insertable<WebLogEntry> {
  final int id;
  final String query;
  final String provider;
  final String? urlsJson;
  final DateTime at;
  const WebLogEntry({
    required this.id,
    required this.query,
    required this.provider,
    this.urlsJson,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['query'] = Variable<String>(query);
    map['provider'] = Variable<String>(provider);
    if (!nullToAbsent || urlsJson != null) {
      map['urls_json'] = Variable<String>(urlsJson);
    }
    map['at'] = Variable<DateTime>(at);
    return map;
  }

  WebLogEntriesCompanion toCompanion(bool nullToAbsent) {
    return WebLogEntriesCompanion(
      id: Value(id),
      query: Value(query),
      provider: Value(provider),
      urlsJson: urlsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(urlsJson),
      at: Value(at),
    );
  }

  factory WebLogEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WebLogEntry(
      id: serializer.fromJson<int>(json['id']),
      query: serializer.fromJson<String>(json['query']),
      provider: serializer.fromJson<String>(json['provider']),
      urlsJson: serializer.fromJson<String?>(json['urlsJson']),
      at: serializer.fromJson<DateTime>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'query': serializer.toJson<String>(query),
      'provider': serializer.toJson<String>(provider),
      'urlsJson': serializer.toJson<String?>(urlsJson),
      'at': serializer.toJson<DateTime>(at),
    };
  }

  WebLogEntry copyWith({
    int? id,
    String? query,
    String? provider,
    Value<String?> urlsJson = const Value.absent(),
    DateTime? at,
  }) => WebLogEntry(
    id: id ?? this.id,
    query: query ?? this.query,
    provider: provider ?? this.provider,
    urlsJson: urlsJson.present ? urlsJson.value : this.urlsJson,
    at: at ?? this.at,
  );
  WebLogEntry copyWithCompanion(WebLogEntriesCompanion data) {
    return WebLogEntry(
      id: data.id.present ? data.id.value : this.id,
      query: data.query.present ? data.query.value : this.query,
      provider: data.provider.present ? data.provider.value : this.provider,
      urlsJson: data.urlsJson.present ? data.urlsJson.value : this.urlsJson,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WebLogEntry(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('provider: $provider, ')
          ..write('urlsJson: $urlsJson, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, query, provider, urlsJson, at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WebLogEntry &&
          other.id == this.id &&
          other.query == this.query &&
          other.provider == this.provider &&
          other.urlsJson == this.urlsJson &&
          other.at == this.at);
}

class WebLogEntriesCompanion extends UpdateCompanion<WebLogEntry> {
  final Value<int> id;
  final Value<String> query;
  final Value<String> provider;
  final Value<String?> urlsJson;
  final Value<DateTime> at;
  const WebLogEntriesCompanion({
    this.id = const Value.absent(),
    this.query = const Value.absent(),
    this.provider = const Value.absent(),
    this.urlsJson = const Value.absent(),
    this.at = const Value.absent(),
  });
  WebLogEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String query,
    required String provider,
    this.urlsJson = const Value.absent(),
    this.at = const Value.absent(),
  }) : query = Value(query),
       provider = Value(provider);
  static Insertable<WebLogEntry> custom({
    Expression<int>? id,
    Expression<String>? query,
    Expression<String>? provider,
    Expression<String>? urlsJson,
    Expression<DateTime>? at,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (query != null) 'query': query,
      if (provider != null) 'provider': provider,
      if (urlsJson != null) 'urls_json': urlsJson,
      if (at != null) 'at': at,
    });
  }

  WebLogEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? query,
    Value<String>? provider,
    Value<String?>? urlsJson,
    Value<DateTime>? at,
  }) {
    return WebLogEntriesCompanion(
      id: id ?? this.id,
      query: query ?? this.query,
      provider: provider ?? this.provider,
      urlsJson: urlsJson ?? this.urlsJson,
      at: at ?? this.at,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (urlsJson.present) {
      map['urls_json'] = Variable<String>(urlsJson.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WebLogEntriesCompanion(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('provider: $provider, ')
          ..write('urlsJson: $urlsJson, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }
}

class $FactChecksTable extends FactChecks
    with TableInfo<$FactChecksTable, FactCheck> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FactChecksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _factIdMeta = const VerificationMeta('factId');
  @override
  late final GeneratedColumn<int> factId = GeneratedColumn<int>(
    'fact_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<int> questionId = GeneratedColumn<int>(
    'question_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _claimMeta = const VerificationMeta('claim');
  @override
  late final GeneratedColumn<String> claim = GeneratedColumn<String>(
    'claim',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verdictMeta = const VerificationMeta(
    'verdict',
  );
  @override
  late final GeneratedColumn<String> verdict = GeneratedColumn<String>(
    'verdict',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _evidenceJsonMeta = const VerificationMeta(
    'evidenceJson',
  );
  @override
  late final GeneratedColumn<String> evidenceJson = GeneratedColumn<String>(
    'evidence_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    factId,
    questionId,
    claim,
    verdict,
    evidenceJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fact_checks';
  @override
  VerificationContext validateIntegrity(
    Insertable<FactCheck> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fact_id')) {
      context.handle(
        _factIdMeta,
        factId.isAcceptableOrUnknown(data['fact_id']!, _factIdMeta),
      );
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    }
    if (data.containsKey('claim')) {
      context.handle(
        _claimMeta,
        claim.isAcceptableOrUnknown(data['claim']!, _claimMeta),
      );
    } else if (isInserting) {
      context.missing(_claimMeta);
    }
    if (data.containsKey('verdict')) {
      context.handle(
        _verdictMeta,
        verdict.isAcceptableOrUnknown(data['verdict']!, _verdictMeta),
      );
    } else if (isInserting) {
      context.missing(_verdictMeta);
    }
    if (data.containsKey('evidence_json')) {
      context.handle(
        _evidenceJsonMeta,
        evidenceJson.isAcceptableOrUnknown(
          data['evidence_json']!,
          _evidenceJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_evidenceJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FactCheck map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FactCheck(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      factId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fact_id'],
      ),
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_id'],
      ),
      claim: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}claim'],
      )!,
      verdict: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verdict'],
      )!,
      evidenceJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FactChecksTable createAlias(String alias) {
    return $FactChecksTable(attachedDatabase, alias);
  }
}

class FactCheck extends DataClass implements Insertable<FactCheck> {
  final int id;
  final int? factId;
  final int? questionId;
  final String claim;

  /// corroborated | conflict | notFound
  final String verdict;
  final String evidenceJson;
  final DateTime createdAt;
  const FactCheck({
    required this.id,
    this.factId,
    this.questionId,
    required this.claim,
    required this.verdict,
    required this.evidenceJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || factId != null) {
      map['fact_id'] = Variable<int>(factId);
    }
    if (!nullToAbsent || questionId != null) {
      map['question_id'] = Variable<int>(questionId);
    }
    map['claim'] = Variable<String>(claim);
    map['verdict'] = Variable<String>(verdict);
    map['evidence_json'] = Variable<String>(evidenceJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FactChecksCompanion toCompanion(bool nullToAbsent) {
    return FactChecksCompanion(
      id: Value(id),
      factId: factId == null && nullToAbsent
          ? const Value.absent()
          : Value(factId),
      questionId: questionId == null && nullToAbsent
          ? const Value.absent()
          : Value(questionId),
      claim: Value(claim),
      verdict: Value(verdict),
      evidenceJson: Value(evidenceJson),
      createdAt: Value(createdAt),
    );
  }

  factory FactCheck.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FactCheck(
      id: serializer.fromJson<int>(json['id']),
      factId: serializer.fromJson<int?>(json['factId']),
      questionId: serializer.fromJson<int?>(json['questionId']),
      claim: serializer.fromJson<String>(json['claim']),
      verdict: serializer.fromJson<String>(json['verdict']),
      evidenceJson: serializer.fromJson<String>(json['evidenceJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'factId': serializer.toJson<int?>(factId),
      'questionId': serializer.toJson<int?>(questionId),
      'claim': serializer.toJson<String>(claim),
      'verdict': serializer.toJson<String>(verdict),
      'evidenceJson': serializer.toJson<String>(evidenceJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FactCheck copyWith({
    int? id,
    Value<int?> factId = const Value.absent(),
    Value<int?> questionId = const Value.absent(),
    String? claim,
    String? verdict,
    String? evidenceJson,
    DateTime? createdAt,
  }) => FactCheck(
    id: id ?? this.id,
    factId: factId.present ? factId.value : this.factId,
    questionId: questionId.present ? questionId.value : this.questionId,
    claim: claim ?? this.claim,
    verdict: verdict ?? this.verdict,
    evidenceJson: evidenceJson ?? this.evidenceJson,
    createdAt: createdAt ?? this.createdAt,
  );
  FactCheck copyWithCompanion(FactChecksCompanion data) {
    return FactCheck(
      id: data.id.present ? data.id.value : this.id,
      factId: data.factId.present ? data.factId.value : this.factId,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      claim: data.claim.present ? data.claim.value : this.claim,
      verdict: data.verdict.present ? data.verdict.value : this.verdict,
      evidenceJson: data.evidenceJson.present
          ? data.evidenceJson.value
          : this.evidenceJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FactCheck(')
          ..write('id: $id, ')
          ..write('factId: $factId, ')
          ..write('questionId: $questionId, ')
          ..write('claim: $claim, ')
          ..write('verdict: $verdict, ')
          ..write('evidenceJson: $evidenceJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    factId,
    questionId,
    claim,
    verdict,
    evidenceJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FactCheck &&
          other.id == this.id &&
          other.factId == this.factId &&
          other.questionId == this.questionId &&
          other.claim == this.claim &&
          other.verdict == this.verdict &&
          other.evidenceJson == this.evidenceJson &&
          other.createdAt == this.createdAt);
}

class FactChecksCompanion extends UpdateCompanion<FactCheck> {
  final Value<int> id;
  final Value<int?> factId;
  final Value<int?> questionId;
  final Value<String> claim;
  final Value<String> verdict;
  final Value<String> evidenceJson;
  final Value<DateTime> createdAt;
  const FactChecksCompanion({
    this.id = const Value.absent(),
    this.factId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.claim = const Value.absent(),
    this.verdict = const Value.absent(),
    this.evidenceJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FactChecksCompanion.insert({
    this.id = const Value.absent(),
    this.factId = const Value.absent(),
    this.questionId = const Value.absent(),
    required String claim,
    required String verdict,
    required String evidenceJson,
    this.createdAt = const Value.absent(),
  }) : claim = Value(claim),
       verdict = Value(verdict),
       evidenceJson = Value(evidenceJson);
  static Insertable<FactCheck> custom({
    Expression<int>? id,
    Expression<int>? factId,
    Expression<int>? questionId,
    Expression<String>? claim,
    Expression<String>? verdict,
    Expression<String>? evidenceJson,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (factId != null) 'fact_id': factId,
      if (questionId != null) 'question_id': questionId,
      if (claim != null) 'claim': claim,
      if (verdict != null) 'verdict': verdict,
      if (evidenceJson != null) 'evidence_json': evidenceJson,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FactChecksCompanion copyWith({
    Value<int>? id,
    Value<int?>? factId,
    Value<int?>? questionId,
    Value<String>? claim,
    Value<String>? verdict,
    Value<String>? evidenceJson,
    Value<DateTime>? createdAt,
  }) {
    return FactChecksCompanion(
      id: id ?? this.id,
      factId: factId ?? this.factId,
      questionId: questionId ?? this.questionId,
      claim: claim ?? this.claim,
      verdict: verdict ?? this.verdict,
      evidenceJson: evidenceJson ?? this.evidenceJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (factId.present) {
      map['fact_id'] = Variable<int>(factId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<int>(questionId.value);
    }
    if (claim.present) {
      map['claim'] = Variable<String>(claim.value);
    }
    if (verdict.present) {
      map['verdict'] = Variable<String>(verdict.value);
    }
    if (evidenceJson.present) {
      map['evidence_json'] = Variable<String>(evidenceJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FactChecksCompanion(')
          ..write('id: $id, ')
          ..write('factId: $factId, ')
          ..write('questionId: $questionId, ')
          ..write('claim: $claim, ')
          ..write('verdict: $verdict, ')
          ..write('evidenceJson: $evidenceJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BenchmarkRunsTable extends BenchmarkRuns
    with TableInfo<$BenchmarkRunsTable, BenchmarkRun> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BenchmarkRunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _modelNameMeta = const VerificationMeta(
    'modelName',
  );
  @override
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
    'model_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _backendMeta = const VerificationMeta(
    'backend',
  );
  @override
  late final GeneratedColumn<String> backend = GeneratedColumn<String>(
    'backend',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readTokensPerSecondMeta =
      const VerificationMeta('readTokensPerSecond');
  @override
  late final GeneratedColumn<double> readTokensPerSecond =
      GeneratedColumn<double>(
        'read_tokens_per_second',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _writeTokensPerSecondMeta =
      const VerificationMeta('writeTokensPerSecond');
  @override
  late final GeneratedColumn<double> writeTokensPerSecond =
      GeneratedColumn<double>(
        'write_tokens_per_second',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _firstQuestionMsMeta = const VerificationMeta(
    'firstQuestionMs',
  );
  @override
  late final GeneratedColumn<int> firstQuestionMs = GeneratedColumn<int>(
    'first_question_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextQuestionMsMeta = const VerificationMeta(
    'nextQuestionMs',
  );
  @override
  late final GeneratedColumn<int> nextQuestionMs = GeneratedColumn<int>(
    'next_question_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedPromptShareMeta = const VerificationMeta(
    'cachedPromptShare',
  );
  @override
  late final GeneratedColumn<double> cachedPromptShare =
      GeneratedColumn<double>(
        'cached_prompt_share',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    modelName,
    backend,
    readTokensPerSecond,
    writeTokensPerSecond,
    firstQuestionMs,
    nextQuestionMs,
    cachedPromptShare,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'benchmark_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<BenchmarkRun> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('model_name')) {
      context.handle(
        _modelNameMeta,
        modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta),
      );
    } else if (isInserting) {
      context.missing(_modelNameMeta);
    }
    if (data.containsKey('backend')) {
      context.handle(
        _backendMeta,
        backend.isAcceptableOrUnknown(data['backend']!, _backendMeta),
      );
    } else if (isInserting) {
      context.missing(_backendMeta);
    }
    if (data.containsKey('read_tokens_per_second')) {
      context.handle(
        _readTokensPerSecondMeta,
        readTokensPerSecond.isAcceptableOrUnknown(
          data['read_tokens_per_second']!,
          _readTokensPerSecondMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_readTokensPerSecondMeta);
    }
    if (data.containsKey('write_tokens_per_second')) {
      context.handle(
        _writeTokensPerSecondMeta,
        writeTokensPerSecond.isAcceptableOrUnknown(
          data['write_tokens_per_second']!,
          _writeTokensPerSecondMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_writeTokensPerSecondMeta);
    }
    if (data.containsKey('first_question_ms')) {
      context.handle(
        _firstQuestionMsMeta,
        firstQuestionMs.isAcceptableOrUnknown(
          data['first_question_ms']!,
          _firstQuestionMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstQuestionMsMeta);
    }
    if (data.containsKey('next_question_ms')) {
      context.handle(
        _nextQuestionMsMeta,
        nextQuestionMs.isAcceptableOrUnknown(
          data['next_question_ms']!,
          _nextQuestionMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextQuestionMsMeta);
    }
    if (data.containsKey('cached_prompt_share')) {
      context.handle(
        _cachedPromptShareMeta,
        cachedPromptShare.isAcceptableOrUnknown(
          data['cached_prompt_share']!,
          _cachedPromptShareMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BenchmarkRun map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BenchmarkRun(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      modelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_name'],
      )!,
      backend: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}backend'],
      )!,
      readTokensPerSecond: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}read_tokens_per_second'],
      )!,
      writeTokensPerSecond: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}write_tokens_per_second'],
      )!,
      firstQuestionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_question_ms'],
      )!,
      nextQuestionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_question_ms'],
      )!,
      cachedPromptShare: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cached_prompt_share'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BenchmarkRunsTable createAlias(String alias) {
    return $BenchmarkRunsTable(attachedDatabase, alias);
  }
}

class BenchmarkRun extends DataClass implements Insertable<BenchmarkRun> {
  final int id;
  final String modelName;
  final String backend;
  final double readTokensPerSecond;
  final double writeTokensPerSecond;
  final int firstQuestionMs;
  final int nextQuestionMs;
  final double? cachedPromptShare;
  final DateTime createdAt;
  const BenchmarkRun({
    required this.id,
    required this.modelName,
    required this.backend,
    required this.readTokensPerSecond,
    required this.writeTokensPerSecond,
    required this.firstQuestionMs,
    required this.nextQuestionMs,
    this.cachedPromptShare,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['model_name'] = Variable<String>(modelName);
    map['backend'] = Variable<String>(backend);
    map['read_tokens_per_second'] = Variable<double>(readTokensPerSecond);
    map['write_tokens_per_second'] = Variable<double>(writeTokensPerSecond);
    map['first_question_ms'] = Variable<int>(firstQuestionMs);
    map['next_question_ms'] = Variable<int>(nextQuestionMs);
    if (!nullToAbsent || cachedPromptShare != null) {
      map['cached_prompt_share'] = Variable<double>(cachedPromptShare);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BenchmarkRunsCompanion toCompanion(bool nullToAbsent) {
    return BenchmarkRunsCompanion(
      id: Value(id),
      modelName: Value(modelName),
      backend: Value(backend),
      readTokensPerSecond: Value(readTokensPerSecond),
      writeTokensPerSecond: Value(writeTokensPerSecond),
      firstQuestionMs: Value(firstQuestionMs),
      nextQuestionMs: Value(nextQuestionMs),
      cachedPromptShare: cachedPromptShare == null && nullToAbsent
          ? const Value.absent()
          : Value(cachedPromptShare),
      createdAt: Value(createdAt),
    );
  }

  factory BenchmarkRun.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BenchmarkRun(
      id: serializer.fromJson<int>(json['id']),
      modelName: serializer.fromJson<String>(json['modelName']),
      backend: serializer.fromJson<String>(json['backend']),
      readTokensPerSecond: serializer.fromJson<double>(
        json['readTokensPerSecond'],
      ),
      writeTokensPerSecond: serializer.fromJson<double>(
        json['writeTokensPerSecond'],
      ),
      firstQuestionMs: serializer.fromJson<int>(json['firstQuestionMs']),
      nextQuestionMs: serializer.fromJson<int>(json['nextQuestionMs']),
      cachedPromptShare: serializer.fromJson<double?>(
        json['cachedPromptShare'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'modelName': serializer.toJson<String>(modelName),
      'backend': serializer.toJson<String>(backend),
      'readTokensPerSecond': serializer.toJson<double>(readTokensPerSecond),
      'writeTokensPerSecond': serializer.toJson<double>(writeTokensPerSecond),
      'firstQuestionMs': serializer.toJson<int>(firstQuestionMs),
      'nextQuestionMs': serializer.toJson<int>(nextQuestionMs),
      'cachedPromptShare': serializer.toJson<double?>(cachedPromptShare),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BenchmarkRun copyWith({
    int? id,
    String? modelName,
    String? backend,
    double? readTokensPerSecond,
    double? writeTokensPerSecond,
    int? firstQuestionMs,
    int? nextQuestionMs,
    Value<double?> cachedPromptShare = const Value.absent(),
    DateTime? createdAt,
  }) => BenchmarkRun(
    id: id ?? this.id,
    modelName: modelName ?? this.modelName,
    backend: backend ?? this.backend,
    readTokensPerSecond: readTokensPerSecond ?? this.readTokensPerSecond,
    writeTokensPerSecond: writeTokensPerSecond ?? this.writeTokensPerSecond,
    firstQuestionMs: firstQuestionMs ?? this.firstQuestionMs,
    nextQuestionMs: nextQuestionMs ?? this.nextQuestionMs,
    cachedPromptShare: cachedPromptShare.present
        ? cachedPromptShare.value
        : this.cachedPromptShare,
    createdAt: createdAt ?? this.createdAt,
  );
  BenchmarkRun copyWithCompanion(BenchmarkRunsCompanion data) {
    return BenchmarkRun(
      id: data.id.present ? data.id.value : this.id,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      backend: data.backend.present ? data.backend.value : this.backend,
      readTokensPerSecond: data.readTokensPerSecond.present
          ? data.readTokensPerSecond.value
          : this.readTokensPerSecond,
      writeTokensPerSecond: data.writeTokensPerSecond.present
          ? data.writeTokensPerSecond.value
          : this.writeTokensPerSecond,
      firstQuestionMs: data.firstQuestionMs.present
          ? data.firstQuestionMs.value
          : this.firstQuestionMs,
      nextQuestionMs: data.nextQuestionMs.present
          ? data.nextQuestionMs.value
          : this.nextQuestionMs,
      cachedPromptShare: data.cachedPromptShare.present
          ? data.cachedPromptShare.value
          : this.cachedPromptShare,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BenchmarkRun(')
          ..write('id: $id, ')
          ..write('modelName: $modelName, ')
          ..write('backend: $backend, ')
          ..write('readTokensPerSecond: $readTokensPerSecond, ')
          ..write('writeTokensPerSecond: $writeTokensPerSecond, ')
          ..write('firstQuestionMs: $firstQuestionMs, ')
          ..write('nextQuestionMs: $nextQuestionMs, ')
          ..write('cachedPromptShare: $cachedPromptShare, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    modelName,
    backend,
    readTokensPerSecond,
    writeTokensPerSecond,
    firstQuestionMs,
    nextQuestionMs,
    cachedPromptShare,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BenchmarkRun &&
          other.id == this.id &&
          other.modelName == this.modelName &&
          other.backend == this.backend &&
          other.readTokensPerSecond == this.readTokensPerSecond &&
          other.writeTokensPerSecond == this.writeTokensPerSecond &&
          other.firstQuestionMs == this.firstQuestionMs &&
          other.nextQuestionMs == this.nextQuestionMs &&
          other.cachedPromptShare == this.cachedPromptShare &&
          other.createdAt == this.createdAt);
}

class BenchmarkRunsCompanion extends UpdateCompanion<BenchmarkRun> {
  final Value<int> id;
  final Value<String> modelName;
  final Value<String> backend;
  final Value<double> readTokensPerSecond;
  final Value<double> writeTokensPerSecond;
  final Value<int> firstQuestionMs;
  final Value<int> nextQuestionMs;
  final Value<double?> cachedPromptShare;
  final Value<DateTime> createdAt;
  const BenchmarkRunsCompanion({
    this.id = const Value.absent(),
    this.modelName = const Value.absent(),
    this.backend = const Value.absent(),
    this.readTokensPerSecond = const Value.absent(),
    this.writeTokensPerSecond = const Value.absent(),
    this.firstQuestionMs = const Value.absent(),
    this.nextQuestionMs = const Value.absent(),
    this.cachedPromptShare = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BenchmarkRunsCompanion.insert({
    this.id = const Value.absent(),
    required String modelName,
    required String backend,
    required double readTokensPerSecond,
    required double writeTokensPerSecond,
    required int firstQuestionMs,
    required int nextQuestionMs,
    this.cachedPromptShare = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : modelName = Value(modelName),
       backend = Value(backend),
       readTokensPerSecond = Value(readTokensPerSecond),
       writeTokensPerSecond = Value(writeTokensPerSecond),
       firstQuestionMs = Value(firstQuestionMs),
       nextQuestionMs = Value(nextQuestionMs);
  static Insertable<BenchmarkRun> custom({
    Expression<int>? id,
    Expression<String>? modelName,
    Expression<String>? backend,
    Expression<double>? readTokensPerSecond,
    Expression<double>? writeTokensPerSecond,
    Expression<int>? firstQuestionMs,
    Expression<int>? nextQuestionMs,
    Expression<double>? cachedPromptShare,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (modelName != null) 'model_name': modelName,
      if (backend != null) 'backend': backend,
      if (readTokensPerSecond != null)
        'read_tokens_per_second': readTokensPerSecond,
      if (writeTokensPerSecond != null)
        'write_tokens_per_second': writeTokensPerSecond,
      if (firstQuestionMs != null) 'first_question_ms': firstQuestionMs,
      if (nextQuestionMs != null) 'next_question_ms': nextQuestionMs,
      if (cachedPromptShare != null) 'cached_prompt_share': cachedPromptShare,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BenchmarkRunsCompanion copyWith({
    Value<int>? id,
    Value<String>? modelName,
    Value<String>? backend,
    Value<double>? readTokensPerSecond,
    Value<double>? writeTokensPerSecond,
    Value<int>? firstQuestionMs,
    Value<int>? nextQuestionMs,
    Value<double?>? cachedPromptShare,
    Value<DateTime>? createdAt,
  }) {
    return BenchmarkRunsCompanion(
      id: id ?? this.id,
      modelName: modelName ?? this.modelName,
      backend: backend ?? this.backend,
      readTokensPerSecond: readTokensPerSecond ?? this.readTokensPerSecond,
      writeTokensPerSecond: writeTokensPerSecond ?? this.writeTokensPerSecond,
      firstQuestionMs: firstQuestionMs ?? this.firstQuestionMs,
      nextQuestionMs: nextQuestionMs ?? this.nextQuestionMs,
      cachedPromptShare: cachedPromptShare ?? this.cachedPromptShare,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (backend.present) {
      map['backend'] = Variable<String>(backend.value);
    }
    if (readTokensPerSecond.present) {
      map['read_tokens_per_second'] = Variable<double>(
        readTokensPerSecond.value,
      );
    }
    if (writeTokensPerSecond.present) {
      map['write_tokens_per_second'] = Variable<double>(
        writeTokensPerSecond.value,
      );
    }
    if (firstQuestionMs.present) {
      map['first_question_ms'] = Variable<int>(firstQuestionMs.value);
    }
    if (nextQuestionMs.present) {
      map['next_question_ms'] = Variable<int>(nextQuestionMs.value);
    }
    if (cachedPromptShare.present) {
      map['cached_prompt_share'] = Variable<double>(cachedPromptShare.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BenchmarkRunsCompanion(')
          ..write('id: $id, ')
          ..write('modelName: $modelName, ')
          ..write('backend: $backend, ')
          ..write('readTokensPerSecond: $readTokensPerSecond, ')
          ..write('writeTokensPerSecond: $writeTokensPerSecond, ')
          ..write('firstQuestionMs: $firstQuestionMs, ')
          ..write('nextQuestionMs: $nextQuestionMs, ')
          ..write('cachedPromptShare: $cachedPromptShare, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DocumentsTable documents = $DocumentsTable(this);
  late final $SectionsTable sections = $SectionsTable(this);
  late final $ChunksTable chunks = $ChunksTable(this);
  late final $FactsTable facts = $FactsTable(this);
  late final $QuestionsTable questions = $QuestionsTable(this);
  late final $QuestionSectionsTable questionSections = $QuestionSectionsTable(
    this,
  );
  late final $FactCardsTable factCards = $FactCardsTable(this);
  late final $ReviewsTable reviews = $ReviewsTable(this);
  late final $JobsTable jobs = $JobsTable(this);
  late final $JobItemsTable jobItems = $JobItemsTable(this);
  late final $LlmCacheEntriesTable llmCacheEntries = $LlmCacheEntriesTable(
    this,
  );
  late final $RejectionsTable rejections = $RejectionsTable(this);
  late final $ChatThreadsTable chatThreads = $ChatThreadsTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $WebPagesTable webPages = $WebPagesTable(this);
  late final $WebLogEntriesTable webLogEntries = $WebLogEntriesTable(this);
  late final $FactChecksTable factChecks = $FactChecksTable(this);
  late final $BenchmarkRunsTable benchmarkRuns = $BenchmarkRunsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final Index idxSectionsDocument = Index(
    'idx_sections_document',
    'CREATE INDEX idx_sections_document ON sections (document_id, ord)',
  );
  late final Index idxChunksDocument = Index(
    'idx_chunks_document',
    'CREATE INDEX idx_chunks_document ON chunks (document_id, ord)',
  );
  late final Index idxChunksSection = Index(
    'idx_chunks_section',
    'CREATE INDEX idx_chunks_section ON chunks (section_id)',
  );
  late final Index idxFactsDocument = Index(
    'idx_facts_document',
    'CREATE INDEX idx_facts_document ON facts (document_id)',
  );
  late final Index idxFactsChunk = Index(
    'idx_facts_chunk',
    'CREATE INDEX idx_facts_chunk ON facts (chunk_id)',
  );
  late final Index idxQuestionsFact = Index(
    'idx_questions_fact',
    'CREATE INDEX idx_questions_fact ON questions (fact_id)',
  );
  late final Index idxFactCardsDue = Index(
    'idx_fact_cards_due',
    'CREATE INDEX idx_fact_cards_due ON fact_cards (due)',
  );
  late final Index idxReviewsFact = Index(
    'idx_reviews_fact',
    'CREATE INDEX idx_reviews_fact ON reviews (fact_id)',
  );
  late final Index idxJobItemsJob = Index(
    'idx_job_items_job',
    'CREATE INDEX idx_job_items_job ON job_items (job_id, status)',
  );
  late final Index idxChatMessagesThread = Index(
    'idx_chat_messages_thread',
    'CREATE INDEX idx_chat_messages_thread ON chat_messages (thread_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    documents,
    sections,
    chunks,
    facts,
    questions,
    questionSections,
    factCards,
    reviews,
    jobs,
    jobItems,
    llmCacheEntries,
    rejections,
    chatThreads,
    chatMessages,
    webPages,
    webLogEntries,
    factChecks,
    benchmarkRuns,
    appSettings,
    idxSectionsDocument,
    idxChunksDocument,
    idxChunksSection,
    idxFactsDocument,
    idxFactsChunk,
    idxQuestionsFact,
    idxFactCardsDue,
    idxReviewsFact,
    idxJobItemsJob,
    idxChatMessagesThread,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sections', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chunks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sections',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chunks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('facts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'chunks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('facts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'facts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('questions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'questions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('question_sections', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sections',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('question_sections', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'facts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('fact_cards', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'facts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reviews', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('jobs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'jobs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('job_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'chunks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('job_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('rejections', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chat_threads', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'chat_threads',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chat_messages', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$DocumentsTableCreateCompanionBuilder =
    DocumentsCompanion Function({
      Value<int> id,
      required String title,
      Value<String?> sourcePath,
      required String sha256,
      Value<int> pageCount,
      Value<String?> language,
      Value<String> status,
      Value<String?> errorMessage,
      Value<String?> settingsJson,
      Value<DateTime> importedAt,
      Value<String?> modelPath,
    });
typedef $$DocumentsTableUpdateCompanionBuilder =
    DocumentsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String?> sourcePath,
      Value<String> sha256,
      Value<int> pageCount,
      Value<String?> language,
      Value<String> status,
      Value<String?> errorMessage,
      Value<String?> settingsJson,
      Value<DateTime> importedAt,
      Value<String?> modelPath,
    });

final class $$DocumentsTableReferences
    extends BaseReferences<_$AppDatabase, $DocumentsTable, StudyDocument> {
  $$DocumentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SectionsTable, List<Section>> _sectionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sections,
    aliasName: 'documents__id__sections__document_id',
  );

  $$SectionsTableProcessedTableManager get sectionsRefs {
    final manager = $$SectionsTableTableManager(
      $_db,
      $_db.sections,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sectionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChunksTable, List<Chunk>> _chunksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.chunks,
    aliasName: 'documents__id__chunks__document_id',
  );

  $$ChunksTableProcessedTableManager get chunksRefs {
    final manager = $$ChunksTableTableManager(
      $_db,
      $_db.chunks,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_chunksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FactsTable, List<Fact>> _factsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.facts,
    aliasName: 'documents__id__facts__document_id',
  );

  $$FactsTableProcessedTableManager get factsRefs {
    final manager = $$FactsTableTableManager(
      $_db,
      $_db.facts,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_factsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$JobsTable, List<Job>> _jobsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.jobs,
    aliasName: 'documents__id__jobs__document_id',
  );

  $$JobsTableProcessedTableManager get jobsRefs {
    final manager = $$JobsTableTableManager(
      $_db,
      $_db.jobs,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_jobsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RejectionsTable, List<Rejection>>
  _rejectionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.rejections,
    aliasName: 'documents__id__rejections__document_id',
  );

  $$RejectionsTableProcessedTableManager get rejectionsRefs {
    final manager = $$RejectionsTableTableManager(
      $_db,
      $_db.rejections,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_rejectionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChatThreadsTable, List<ChatThread>>
  _chatThreadsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chatThreads,
    aliasName: 'documents__id__chat_threads__document_id',
  );

  $$ChatThreadsTableProcessedTableManager get chatThreadsRefs {
    final manager = $$ChatThreadsTableTableManager(
      $_db,
      $_db.chatThreads,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_chatThreadsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourcePath => $composableBuilder(
    column: $table.sourcePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelPath => $composableBuilder(
    column: $table.modelPath,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sectionsRefs(
    Expression<bool> Function($$SectionsTableFilterComposer f) f,
  ) {
    final $$SectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableFilterComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> chunksRefs(
    Expression<bool> Function($$ChunksTableFilterComposer f) f,
  ) {
    final $$ChunksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chunks,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChunksTableFilterComposer(
            $db: $db,
            $table: $db.chunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> factsRefs(
    Expression<bool> Function($$FactsTableFilterComposer f) f,
  ) {
    final $$FactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.facts,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactsTableFilterComposer(
            $db: $db,
            $table: $db.facts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> jobsRefs(
    Expression<bool> Function($$JobsTableFilterComposer f) f,
  ) {
    final $$JobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableFilterComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> rejectionsRefs(
    Expression<bool> Function($$RejectionsTableFilterComposer f) f,
  ) {
    final $$RejectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rejections,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RejectionsTableFilterComposer(
            $db: $db,
            $table: $db.rejections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> chatThreadsRefs(
    Expression<bool> Function($$ChatThreadsTableFilterComposer f) f,
  ) {
    final $$ChatThreadsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatThreads,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatThreadsTableFilterComposer(
            $db: $db,
            $table: $db.chatThreads,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourcePath => $composableBuilder(
    column: $table.sourcePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelPath => $composableBuilder(
    column: $table.modelPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get sourcePath => $composableBuilder(
    column: $table.sourcePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelPath =>
      $composableBuilder(column: $table.modelPath, builder: (column) => column);

  Expression<T> sectionsRefs<T extends Object>(
    Expression<T> Function($$SectionsTableAnnotationComposer a) f,
  ) {
    final $$SectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> chunksRefs<T extends Object>(
    Expression<T> Function($$ChunksTableAnnotationComposer a) f,
  ) {
    final $$ChunksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chunks,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChunksTableAnnotationComposer(
            $db: $db,
            $table: $db.chunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> factsRefs<T extends Object>(
    Expression<T> Function($$FactsTableAnnotationComposer a) f,
  ) {
    final $$FactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.facts,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactsTableAnnotationComposer(
            $db: $db,
            $table: $db.facts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> jobsRefs<T extends Object>(
    Expression<T> Function($$JobsTableAnnotationComposer a) f,
  ) {
    final $$JobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> rejectionsRefs<T extends Object>(
    Expression<T> Function($$RejectionsTableAnnotationComposer a) f,
  ) {
    final $$RejectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rejections,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RejectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.rejections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> chatThreadsRefs<T extends Object>(
    Expression<T> Function($$ChatThreadsTableAnnotationComposer a) f,
  ) {
    final $$ChatThreadsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatThreads,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatThreadsTableAnnotationComposer(
            $db: $db,
            $table: $db.chatThreads,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocumentsTable,
          StudyDocument,
          $$DocumentsTableFilterComposer,
          $$DocumentsTableOrderingComposer,
          $$DocumentsTableAnnotationComposer,
          $$DocumentsTableCreateCompanionBuilder,
          $$DocumentsTableUpdateCompanionBuilder,
          (StudyDocument, $$DocumentsTableReferences),
          StudyDocument,
          PrefetchHooks Function({
            bool sectionsRefs,
            bool chunksRefs,
            bool factsRefs,
            bool jobsRefs,
            bool rejectionsRefs,
            bool chatThreadsRefs,
          })
        > {
  $$DocumentsTableTableManager(_$AppDatabase db, $DocumentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> sourcePath = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<int> pageCount = const Value.absent(),
                Value<String?> language = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String?> settingsJson = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<String?> modelPath = const Value.absent(),
              }) => DocumentsCompanion(
                id: id,
                title: title,
                sourcePath: sourcePath,
                sha256: sha256,
                pageCount: pageCount,
                language: language,
                status: status,
                errorMessage: errorMessage,
                settingsJson: settingsJson,
                importedAt: importedAt,
                modelPath: modelPath,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> sourcePath = const Value.absent(),
                required String sha256,
                Value<int> pageCount = const Value.absent(),
                Value<String?> language = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String?> settingsJson = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<String?> modelPath = const Value.absent(),
              }) => DocumentsCompanion.insert(
                id: id,
                title: title,
                sourcePath: sourcePath,
                sha256: sha256,
                pageCount: pageCount,
                language: language,
                status: status,
                errorMessage: errorMessage,
                settingsJson: settingsJson,
                importedAt: importedAt,
                modelPath: modelPath,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DocumentsTable, StudyDocument>(table),
                  $$DocumentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sectionsRefs = false,
                chunksRefs = false,
                factsRefs = false,
                jobsRefs = false,
                rejectionsRefs = false,
                chatThreadsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sectionsRefs) db.sections,
                    if (chunksRefs) db.chunks,
                    if (factsRefs) db.facts,
                    if (jobsRefs) db.jobs,
                    if (rejectionsRefs) db.rejections,
                    if (chatThreadsRefs) db.chatThreads,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sectionsRefs)
                        await $_getPrefetchedDataByColumns<
                          StudyDocument,
                          $DocumentsTable,
                          Section,
                          $SectionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentsTableReferences
                              ._sectionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).sectionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'document_id',
                          typedResults: items,
                        ),
                      if (chunksRefs)
                        await $_getPrefetchedDataByColumns<
                          StudyDocument,
                          $DocumentsTable,
                          Chunk,
                          $ChunksTable
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentsTableReferences
                              ._chunksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).chunksRefs,
                          currentColumn: 'id',
                          referencedColumn: 'document_id',
                          typedResults: items,
                        ),
                      if (factsRefs)
                        await $_getPrefetchedDataByColumns<
                          StudyDocument,
                          $DocumentsTable,
                          Fact,
                          $FactsTable
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentsTableReferences
                              ._factsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).factsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'document_id',
                          typedResults: items,
                        ),
                      if (jobsRefs)
                        await $_getPrefetchedDataByColumns<
                          StudyDocument,
                          $DocumentsTable,
                          Job,
                          $JobsTable
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentsTableReferences
                              ._jobsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).jobsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'document_id',
                          typedResults: items,
                        ),
                      if (rejectionsRefs)
                        await $_getPrefetchedDataByColumns<
                          StudyDocument,
                          $DocumentsTable,
                          Rejection,
                          $RejectionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentsTableReferences
                              ._rejectionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).rejectionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'document_id',
                          typedResults: items,
                        ),
                      if (chatThreadsRefs)
                        await $_getPrefetchedDataByColumns<
                          StudyDocument,
                          $DocumentsTable,
                          ChatThread,
                          $ChatThreadsTable
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentsTableReferences
                              ._chatThreadsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).chatThreadsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'document_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocumentsTable,
      StudyDocument,
      $$DocumentsTableFilterComposer,
      $$DocumentsTableOrderingComposer,
      $$DocumentsTableAnnotationComposer,
      $$DocumentsTableCreateCompanionBuilder,
      $$DocumentsTableUpdateCompanionBuilder,
      (StudyDocument, $$DocumentsTableReferences),
      StudyDocument,
      PrefetchHooks Function({
        bool sectionsRefs,
        bool chunksRefs,
        bool factsRefs,
        bool jobsRefs,
        bool rejectionsRefs,
        bool chatThreadsRefs,
      })
    >;
typedef $$SectionsTableCreateCompanionBuilder =
    SectionsCompanion Function({
      Value<int> id,
      required int documentId,
      Value<int?> parentId,
      required String title,
      required int level,
      required int ord,
      required int pageStart,
      required int pageEnd,
    });
typedef $$SectionsTableUpdateCompanionBuilder =
    SectionsCompanion Function({
      Value<int> id,
      Value<int> documentId,
      Value<int?> parentId,
      Value<String> title,
      Value<int> level,
      Value<int> ord,
      Value<int> pageStart,
      Value<int> pageEnd,
    });

final class $$SectionsTableReferences
    extends BaseReferences<_$AppDatabase, $SectionsTable, Section> {
  $$SectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DocumentsTable _documentIdTable(_$AppDatabase db) =>
      db.documents.createAlias('sections__document_id__documents__id');

  $$DocumentsTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<int>('document_id')!;

    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ChunksTable, List<Chunk>> _chunksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.chunks,
    aliasName: 'sections__id__chunks__section_id',
  );

  $$ChunksTableProcessedTableManager get chunksRefs {
    final manager = $$ChunksTableTableManager(
      $_db,
      $_db.chunks,
    ).filter((f) => f.sectionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_chunksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QuestionSectionsTable, List<QuestionSection>>
  _questionSectionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.questionSections,
    aliasName: 'sections__id__question_sections__section_id',
  );

  $$QuestionSectionsTableProcessedTableManager get questionSectionsRefs {
    final manager = $$QuestionSectionsTableTableManager(
      $_db,
      $_db.questionSections,
    ).filter((f) => f.sectionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _questionSectionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SectionsTableFilterComposer
    extends Composer<_$AppDatabase, $SectionsTable> {
  $$SectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ord => $composableBuilder(
    column: $table.ord,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageStart => $composableBuilder(
    column: $table.pageStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageEnd => $composableBuilder(
    column: $table.pageEnd,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentsTableFilterComposer get documentId {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> chunksRefs(
    Expression<bool> Function($$ChunksTableFilterComposer f) f,
  ) {
    final $$ChunksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chunks,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChunksTableFilterComposer(
            $db: $db,
            $table: $db.chunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> questionSectionsRefs(
    Expression<bool> Function($$QuestionSectionsTableFilterComposer f) f,
  ) {
    final $$QuestionSectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questionSections,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionSectionsTableFilterComposer(
            $db: $db,
            $table: $db.questionSections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SectionsTable> {
  $$SectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ord => $composableBuilder(
    column: $table.ord,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageStart => $composableBuilder(
    column: $table.pageStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageEnd => $composableBuilder(
    column: $table.pageEnd,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentsTableOrderingComposer get documentId {
    final $$DocumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableOrderingComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SectionsTable> {
  $$SectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get ord =>
      $composableBuilder(column: $table.ord, builder: (column) => column);

  GeneratedColumn<int> get pageStart =>
      $composableBuilder(column: $table.pageStart, builder: (column) => column);

  GeneratedColumn<int> get pageEnd =>
      $composableBuilder(column: $table.pageEnd, builder: (column) => column);

  $$DocumentsTableAnnotationComposer get documentId {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> chunksRefs<T extends Object>(
    Expression<T> Function($$ChunksTableAnnotationComposer a) f,
  ) {
    final $$ChunksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chunks,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChunksTableAnnotationComposer(
            $db: $db,
            $table: $db.chunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> questionSectionsRefs<T extends Object>(
    Expression<T> Function($$QuestionSectionsTableAnnotationComposer a) f,
  ) {
    final $$QuestionSectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questionSections,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionSectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.questionSections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SectionsTable,
          Section,
          $$SectionsTableFilterComposer,
          $$SectionsTableOrderingComposer,
          $$SectionsTableAnnotationComposer,
          $$SectionsTableCreateCompanionBuilder,
          $$SectionsTableUpdateCompanionBuilder,
          (Section, $$SectionsTableReferences),
          Section,
          PrefetchHooks Function({
            bool documentId,
            bool chunksRefs,
            bool questionSectionsRefs,
          })
        > {
  $$SectionsTableTableManager(_$AppDatabase db, $SectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> documentId = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> ord = const Value.absent(),
                Value<int> pageStart = const Value.absent(),
                Value<int> pageEnd = const Value.absent(),
              }) => SectionsCompanion(
                id: id,
                documentId: documentId,
                parentId: parentId,
                title: title,
                level: level,
                ord: ord,
                pageStart: pageStart,
                pageEnd: pageEnd,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int documentId,
                Value<int?> parentId = const Value.absent(),
                required String title,
                required int level,
                required int ord,
                required int pageStart,
                required int pageEnd,
              }) => SectionsCompanion.insert(
                id: id,
                documentId: documentId,
                parentId: parentId,
                title: title,
                level: level,
                ord: ord,
                pageStart: pageStart,
                pageEnd: pageEnd,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SectionsTable, Section>(table),
                  $$SectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                documentId = false,
                chunksRefs = false,
                questionSectionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (chunksRefs) db.chunks,
                    if (questionSectionsRefs) db.questionSections,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (documentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.documentId,
                                    referencedTable: $$SectionsTableReferences
                                        ._documentIdTable(db),
                                    referencedColumn: $$SectionsTableReferences
                                        ._documentIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (chunksRefs)
                        await $_getPrefetchedDataByColumns<
                          Section,
                          $SectionsTable,
                          Chunk,
                          $ChunksTable
                        >(
                          currentTable: table,
                          referencedTable: $$SectionsTableReferences
                              ._chunksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).chunksRefs,
                          currentColumn: 'id',
                          referencedColumn: 'section_id',
                          typedResults: items,
                        ),
                      if (questionSectionsRefs)
                        await $_getPrefetchedDataByColumns<
                          Section,
                          $SectionsTable,
                          QuestionSection,
                          $QuestionSectionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$SectionsTableReferences
                              ._questionSectionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).questionSectionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'section_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SectionsTable,
      Section,
      $$SectionsTableFilterComposer,
      $$SectionsTableOrderingComposer,
      $$SectionsTableAnnotationComposer,
      $$SectionsTableCreateCompanionBuilder,
      $$SectionsTableUpdateCompanionBuilder,
      (Section, $$SectionsTableReferences),
      Section,
      PrefetchHooks Function({
        bool documentId,
        bool chunksRefs,
        bool questionSectionsRefs,
      })
    >;
typedef $$ChunksTableCreateCompanionBuilder =
    ChunksCompanion Function({
      Value<int> id,
      required int documentId,
      required int sectionId,
      required int ord,
      required String body,
      required String headingPath,
      required int pageStart,
      required int pageEnd,
      required int tokenEstimate,
      Value<String> kind,
      required String sha256,
    });
typedef $$ChunksTableUpdateCompanionBuilder =
    ChunksCompanion Function({
      Value<int> id,
      Value<int> documentId,
      Value<int> sectionId,
      Value<int> ord,
      Value<String> body,
      Value<String> headingPath,
      Value<int> pageStart,
      Value<int> pageEnd,
      Value<int> tokenEstimate,
      Value<String> kind,
      Value<String> sha256,
    });

final class $$ChunksTableReferences
    extends BaseReferences<_$AppDatabase, $ChunksTable, Chunk> {
  $$ChunksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DocumentsTable _documentIdTable(_$AppDatabase db) =>
      db.documents.createAlias('chunks__document_id__documents__id');

  $$DocumentsTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<int>('document_id')!;

    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SectionsTable _sectionIdTable(_$AppDatabase db) =>
      db.sections.createAlias('chunks__section_id__sections__id');

  $$SectionsTableProcessedTableManager get sectionId {
    final $_column = $_itemColumn<int>('section_id')!;

    final manager = $$SectionsTableTableManager(
      $_db,
      $_db.sections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$FactsTable, List<Fact>> _factsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.facts,
    aliasName: 'chunks__id__facts__chunk_id',
  );

  $$FactsTableProcessedTableManager get factsRefs {
    final manager = $$FactsTableTableManager(
      $_db,
      $_db.facts,
    ).filter((f) => f.chunkId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_factsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$JobItemsTable, List<JobItem>> _jobItemsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.jobItems,
    aliasName: 'chunks__id__job_items__chunk_id',
  );

  $$JobItemsTableProcessedTableManager get jobItemsRefs {
    final manager = $$JobItemsTableTableManager(
      $_db,
      $_db.jobItems,
    ).filter((f) => f.chunkId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_jobItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ChunksTableFilterComposer
    extends Composer<_$AppDatabase, $ChunksTable> {
  $$ChunksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ord => $composableBuilder(
    column: $table.ord,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get headingPath => $composableBuilder(
    column: $table.headingPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageStart => $composableBuilder(
    column: $table.pageStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageEnd => $composableBuilder(
    column: $table.pageEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tokenEstimate => $composableBuilder(
    column: $table.tokenEstimate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentsTableFilterComposer get documentId {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SectionsTableFilterComposer get sectionId {
    final $$SectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableFilterComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> factsRefs(
    Expression<bool> Function($$FactsTableFilterComposer f) f,
  ) {
    final $$FactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.facts,
      getReferencedColumn: (t) => t.chunkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactsTableFilterComposer(
            $db: $db,
            $table: $db.facts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> jobItemsRefs(
    Expression<bool> Function($$JobItemsTableFilterComposer f) f,
  ) {
    final $$JobItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobItems,
      getReferencedColumn: (t) => t.chunkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobItemsTableFilterComposer(
            $db: $db,
            $table: $db.jobItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChunksTableOrderingComposer
    extends Composer<_$AppDatabase, $ChunksTable> {
  $$ChunksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ord => $composableBuilder(
    column: $table.ord,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headingPath => $composableBuilder(
    column: $table.headingPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageStart => $composableBuilder(
    column: $table.pageStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageEnd => $composableBuilder(
    column: $table.pageEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tokenEstimate => $composableBuilder(
    column: $table.tokenEstimate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentsTableOrderingComposer get documentId {
    final $$DocumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableOrderingComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SectionsTableOrderingComposer get sectionId {
    final $$SectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableOrderingComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChunksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChunksTable> {
  $$ChunksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ord =>
      $composableBuilder(column: $table.ord, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get headingPath => $composableBuilder(
    column: $table.headingPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pageStart =>
      $composableBuilder(column: $table.pageStart, builder: (column) => column);

  GeneratedColumn<int> get pageEnd =>
      $composableBuilder(column: $table.pageEnd, builder: (column) => column);

  GeneratedColumn<int> get tokenEstimate => $composableBuilder(
    column: $table.tokenEstimate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  $$DocumentsTableAnnotationComposer get documentId {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SectionsTableAnnotationComposer get sectionId {
    final $$SectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> factsRefs<T extends Object>(
    Expression<T> Function($$FactsTableAnnotationComposer a) f,
  ) {
    final $$FactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.facts,
      getReferencedColumn: (t) => t.chunkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactsTableAnnotationComposer(
            $db: $db,
            $table: $db.facts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> jobItemsRefs<T extends Object>(
    Expression<T> Function($$JobItemsTableAnnotationComposer a) f,
  ) {
    final $$JobItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobItems,
      getReferencedColumn: (t) => t.chunkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChunksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChunksTable,
          Chunk,
          $$ChunksTableFilterComposer,
          $$ChunksTableOrderingComposer,
          $$ChunksTableAnnotationComposer,
          $$ChunksTableCreateCompanionBuilder,
          $$ChunksTableUpdateCompanionBuilder,
          (Chunk, $$ChunksTableReferences),
          Chunk,
          PrefetchHooks Function({
            bool documentId,
            bool sectionId,
            bool factsRefs,
            bool jobItemsRefs,
          })
        > {
  $$ChunksTableTableManager(_$AppDatabase db, $ChunksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChunksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChunksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChunksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> documentId = const Value.absent(),
                Value<int> sectionId = const Value.absent(),
                Value<int> ord = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> headingPath = const Value.absent(),
                Value<int> pageStart = const Value.absent(),
                Value<int> pageEnd = const Value.absent(),
                Value<int> tokenEstimate = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
              }) => ChunksCompanion(
                id: id,
                documentId: documentId,
                sectionId: sectionId,
                ord: ord,
                body: body,
                headingPath: headingPath,
                pageStart: pageStart,
                pageEnd: pageEnd,
                tokenEstimate: tokenEstimate,
                kind: kind,
                sha256: sha256,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int documentId,
                required int sectionId,
                required int ord,
                required String body,
                required String headingPath,
                required int pageStart,
                required int pageEnd,
                required int tokenEstimate,
                Value<String> kind = const Value.absent(),
                required String sha256,
              }) => ChunksCompanion.insert(
                id: id,
                documentId: documentId,
                sectionId: sectionId,
                ord: ord,
                body: body,
                headingPath: headingPath,
                pageStart: pageStart,
                pageEnd: pageEnd,
                tokenEstimate: tokenEstimate,
                kind: kind,
                sha256: sha256,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChunksTable, Chunk>(table),
                  $$ChunksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                documentId = false,
                sectionId = false,
                factsRefs = false,
                jobItemsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (factsRefs) db.facts,
                    if (jobItemsRefs) db.jobItems,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (documentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.documentId,
                                    referencedTable: $$ChunksTableReferences
                                        ._documentIdTable(db),
                                    referencedColumn: $$ChunksTableReferences
                                        ._documentIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (sectionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sectionId,
                                    referencedTable: $$ChunksTableReferences
                                        ._sectionIdTable(db),
                                    referencedColumn: $$ChunksTableReferences
                                        ._sectionIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (factsRefs)
                        await $_getPrefetchedDataByColumns<
                          Chunk,
                          $ChunksTable,
                          Fact,
                          $FactsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ChunksTableReferences
                              ._factsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChunksTableReferences(db, table, p0).factsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'chunk_id',
                          typedResults: items,
                        ),
                      if (jobItemsRefs)
                        await $_getPrefetchedDataByColumns<
                          Chunk,
                          $ChunksTable,
                          JobItem,
                          $JobItemsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ChunksTableReferences
                              ._jobItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChunksTableReferences(
                                db,
                                table,
                                p0,
                              ).jobItemsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'chunk_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ChunksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChunksTable,
      Chunk,
      $$ChunksTableFilterComposer,
      $$ChunksTableOrderingComposer,
      $$ChunksTableAnnotationComposer,
      $$ChunksTableCreateCompanionBuilder,
      $$ChunksTableUpdateCompanionBuilder,
      (Chunk, $$ChunksTableReferences),
      Chunk,
      PrefetchHooks Function({
        bool documentId,
        bool sectionId,
        bool factsRefs,
        bool jobItemsRefs,
      })
    >;
typedef $$FactsTableCreateCompanionBuilder =
    FactsCompanion Function({
      Value<int> id,
      required int documentId,
      required int chunkId,
      required int sectionId,
      required String statement,
      required String quote,
      required int quoteStart,
      required int quoteEnd,
      required String keyTerm,
      Value<int> importance,
      Value<String> status,
      Value<DateTime> createdAt,
    });
typedef $$FactsTableUpdateCompanionBuilder =
    FactsCompanion Function({
      Value<int> id,
      Value<int> documentId,
      Value<int> chunkId,
      Value<int> sectionId,
      Value<String> statement,
      Value<String> quote,
      Value<int> quoteStart,
      Value<int> quoteEnd,
      Value<String> keyTerm,
      Value<int> importance,
      Value<String> status,
      Value<DateTime> createdAt,
    });

final class $$FactsTableReferences
    extends BaseReferences<_$AppDatabase, $FactsTable, Fact> {
  $$FactsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DocumentsTable _documentIdTable(_$AppDatabase db) =>
      db.documents.createAlias('facts__document_id__documents__id');

  $$DocumentsTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<int>('document_id')!;

    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ChunksTable _chunkIdTable(_$AppDatabase db) =>
      db.chunks.createAlias('facts__chunk_id__chunks__id');

  $$ChunksTableProcessedTableManager get chunkId {
    final $_column = $_itemColumn<int>('chunk_id')!;

    final manager = $$ChunksTableTableManager(
      $_db,
      $_db.chunks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chunkIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$QuestionsTable, List<Question>>
  _questionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.questions,
    aliasName: 'facts__id__questions__fact_id',
  );

  $$QuestionsTableProcessedTableManager get questionsRefs {
    final manager = $$QuestionsTableTableManager(
      $_db,
      $_db.questions,
    ).filter((f) => f.factId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_questionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FactCardsTable, List<FactCard>>
  _factCardsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.factCards,
    aliasName: 'facts__id__fact_cards__fact_id',
  );

  $$FactCardsTableProcessedTableManager get factCardsRefs {
    final manager = $$FactCardsTableTableManager(
      $_db,
      $_db.factCards,
    ).filter((f) => f.factId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_factCardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReviewsTable, List<Review>> _reviewsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.reviews,
    aliasName: 'facts__id__reviews__fact_id',
  );

  $$ReviewsTableProcessedTableManager get reviewsRefs {
    final manager = $$ReviewsTableTableManager(
      $_db,
      $_db.reviews,
    ).filter((f) => f.factId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_reviewsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FactsTableFilterComposer extends Composer<_$AppDatabase, $FactsTable> {
  $$FactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statement => $composableBuilder(
    column: $table.statement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quote => $composableBuilder(
    column: $table.quote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quoteStart => $composableBuilder(
    column: $table.quoteStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quoteEnd => $composableBuilder(
    column: $table.quoteEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keyTerm => $composableBuilder(
    column: $table.keyTerm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get importance => $composableBuilder(
    column: $table.importance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentsTableFilterComposer get documentId {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChunksTableFilterComposer get chunkId {
    final $$ChunksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chunkId,
      referencedTable: $db.chunks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChunksTableFilterComposer(
            $db: $db,
            $table: $db.chunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> questionsRefs(
    Expression<bool> Function($$QuestionsTableFilterComposer f) f,
  ) {
    final $$QuestionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.factId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableFilterComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> factCardsRefs(
    Expression<bool> Function($$FactCardsTableFilterComposer f) f,
  ) {
    final $$FactCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.factCards,
      getReferencedColumn: (t) => t.factId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactCardsTableFilterComposer(
            $db: $db,
            $table: $db.factCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reviewsRefs(
    Expression<bool> Function($$ReviewsTableFilterComposer f) f,
  ) {
    final $$ReviewsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviews,
      getReferencedColumn: (t) => t.factId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewsTableFilterComposer(
            $db: $db,
            $table: $db.reviews,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FactsTableOrderingComposer
    extends Composer<_$AppDatabase, $FactsTable> {
  $$FactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statement => $composableBuilder(
    column: $table.statement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quote => $composableBuilder(
    column: $table.quote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quoteStart => $composableBuilder(
    column: $table.quoteStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quoteEnd => $composableBuilder(
    column: $table.quoteEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keyTerm => $composableBuilder(
    column: $table.keyTerm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get importance => $composableBuilder(
    column: $table.importance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentsTableOrderingComposer get documentId {
    final $$DocumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableOrderingComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChunksTableOrderingComposer get chunkId {
    final $$ChunksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chunkId,
      referencedTable: $db.chunks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChunksTableOrderingComposer(
            $db: $db,
            $table: $db.chunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FactsTable> {
  $$FactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sectionId =>
      $composableBuilder(column: $table.sectionId, builder: (column) => column);

  GeneratedColumn<String> get statement =>
      $composableBuilder(column: $table.statement, builder: (column) => column);

  GeneratedColumn<String> get quote =>
      $composableBuilder(column: $table.quote, builder: (column) => column);

  GeneratedColumn<int> get quoteStart => $composableBuilder(
    column: $table.quoteStart,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quoteEnd =>
      $composableBuilder(column: $table.quoteEnd, builder: (column) => column);

  GeneratedColumn<String> get keyTerm =>
      $composableBuilder(column: $table.keyTerm, builder: (column) => column);

  GeneratedColumn<int> get importance => $composableBuilder(
    column: $table.importance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$DocumentsTableAnnotationComposer get documentId {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChunksTableAnnotationComposer get chunkId {
    final $$ChunksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chunkId,
      referencedTable: $db.chunks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChunksTableAnnotationComposer(
            $db: $db,
            $table: $db.chunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> questionsRefs<T extends Object>(
    Expression<T> Function($$QuestionsTableAnnotationComposer a) f,
  ) {
    final $$QuestionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.factId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableAnnotationComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> factCardsRefs<T extends Object>(
    Expression<T> Function($$FactCardsTableAnnotationComposer a) f,
  ) {
    final $$FactCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.factCards,
      getReferencedColumn: (t) => t.factId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.factCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> reviewsRefs<T extends Object>(
    Expression<T> Function($$ReviewsTableAnnotationComposer a) f,
  ) {
    final $$ReviewsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviews,
      getReferencedColumn: (t) => t.factId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewsTableAnnotationComposer(
            $db: $db,
            $table: $db.reviews,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FactsTable,
          Fact,
          $$FactsTableFilterComposer,
          $$FactsTableOrderingComposer,
          $$FactsTableAnnotationComposer,
          $$FactsTableCreateCompanionBuilder,
          $$FactsTableUpdateCompanionBuilder,
          (Fact, $$FactsTableReferences),
          Fact,
          PrefetchHooks Function({
            bool documentId,
            bool chunkId,
            bool questionsRefs,
            bool factCardsRefs,
            bool reviewsRefs,
          })
        > {
  $$FactsTableTableManager(_$AppDatabase db, $FactsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> documentId = const Value.absent(),
                Value<int> chunkId = const Value.absent(),
                Value<int> sectionId = const Value.absent(),
                Value<String> statement = const Value.absent(),
                Value<String> quote = const Value.absent(),
                Value<int> quoteStart = const Value.absent(),
                Value<int> quoteEnd = const Value.absent(),
                Value<String> keyTerm = const Value.absent(),
                Value<int> importance = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FactsCompanion(
                id: id,
                documentId: documentId,
                chunkId: chunkId,
                sectionId: sectionId,
                statement: statement,
                quote: quote,
                quoteStart: quoteStart,
                quoteEnd: quoteEnd,
                keyTerm: keyTerm,
                importance: importance,
                status: status,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int documentId,
                required int chunkId,
                required int sectionId,
                required String statement,
                required String quote,
                required int quoteStart,
                required int quoteEnd,
                required String keyTerm,
                Value<int> importance = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FactsCompanion.insert(
                id: id,
                documentId: documentId,
                chunkId: chunkId,
                sectionId: sectionId,
                statement: statement,
                quote: quote,
                quoteStart: quoteStart,
                quoteEnd: quoteEnd,
                keyTerm: keyTerm,
                importance: importance,
                status: status,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FactsTable, Fact>(table),
                  $$FactsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                documentId = false,
                chunkId = false,
                questionsRefs = false,
                factCardsRefs = false,
                reviewsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (questionsRefs) db.questions,
                    if (factCardsRefs) db.factCards,
                    if (reviewsRefs) db.reviews,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (documentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.documentId,
                                    referencedTable: $$FactsTableReferences
                                        ._documentIdTable(db),
                                    referencedColumn: $$FactsTableReferences
                                        ._documentIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (chunkId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.chunkId,
                                    referencedTable: $$FactsTableReferences
                                        ._chunkIdTable(db),
                                    referencedColumn: $$FactsTableReferences
                                        ._chunkIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (questionsRefs)
                        await $_getPrefetchedDataByColumns<
                          Fact,
                          $FactsTable,
                          Question,
                          $QuestionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$FactsTableReferences
                              ._questionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FactsTableReferences(
                                db,
                                table,
                                p0,
                              ).questionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'fact_id',
                          typedResults: items,
                        ),
                      if (factCardsRefs)
                        await $_getPrefetchedDataByColumns<
                          Fact,
                          $FactsTable,
                          FactCard,
                          $FactCardsTable
                        >(
                          currentTable: table,
                          referencedTable: $$FactsTableReferences
                              ._factCardsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FactsTableReferences(
                                db,
                                table,
                                p0,
                              ).factCardsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'fact_id',
                          typedResults: items,
                        ),
                      if (reviewsRefs)
                        await $_getPrefetchedDataByColumns<
                          Fact,
                          $FactsTable,
                          Review,
                          $ReviewsTable
                        >(
                          currentTable: table,
                          referencedTable: $$FactsTableReferences
                              ._reviewsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FactsTableReferences(db, table, p0).reviewsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'fact_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FactsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FactsTable,
      Fact,
      $$FactsTableFilterComposer,
      $$FactsTableOrderingComposer,
      $$FactsTableAnnotationComposer,
      $$FactsTableCreateCompanionBuilder,
      $$FactsTableUpdateCompanionBuilder,
      (Fact, $$FactsTableReferences),
      Fact,
      PrefetchHooks Function({
        bool documentId,
        bool chunkId,
        bool questionsRefs,
        bool factCardsRefs,
        bool reviewsRefs,
      })
    >;
typedef $$QuestionsTableCreateCompanionBuilder =
    QuestionsCompanion Function({
      Value<int> id,
      required int factId,
      required String type,
      required String depth,
      required String prompt,
      required String answer,
      Value<String?> distractorsJson,
      Value<String?> explanation,
      required String quality,
      required String modelId,
      required int promptVersion,
      Value<String?> checksJson,
      Value<String> status,
      Value<DateTime> createdAt,
    });
typedef $$QuestionsTableUpdateCompanionBuilder =
    QuestionsCompanion Function({
      Value<int> id,
      Value<int> factId,
      Value<String> type,
      Value<String> depth,
      Value<String> prompt,
      Value<String> answer,
      Value<String?> distractorsJson,
      Value<String?> explanation,
      Value<String> quality,
      Value<String> modelId,
      Value<int> promptVersion,
      Value<String?> checksJson,
      Value<String> status,
      Value<DateTime> createdAt,
    });

final class $$QuestionsTableReferences
    extends BaseReferences<_$AppDatabase, $QuestionsTable, Question> {
  $$QuestionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FactsTable _factIdTable(_$AppDatabase db) =>
      db.facts.createAlias('questions__fact_id__facts__id');

  $$FactsTableProcessedTableManager get factId {
    final $_column = $_itemColumn<int>('fact_id')!;

    final manager = $$FactsTableTableManager(
      $_db,
      $_db.facts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_factIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$QuestionSectionsTable, List<QuestionSection>>
  _questionSectionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.questionSections,
    aliasName: 'questions__id__question_sections__question_id',
  );

  $$QuestionSectionsTableProcessedTableManager get questionSectionsRefs {
    final manager = $$QuestionSectionsTableTableManager(
      $_db,
      $_db.questionSections,
    ).filter((f) => f.questionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _questionSectionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$QuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get depth => $composableBuilder(
    column: $table.depth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get distractorsJson => $composableBuilder(
    column: $table.distractorsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get promptVersion => $composableBuilder(
    column: $table.promptVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checksJson => $composableBuilder(
    column: $table.checksJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FactsTableFilterComposer get factId {
    final $$FactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.factId,
      referencedTable: $db.facts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactsTableFilterComposer(
            $db: $db,
            $table: $db.facts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> questionSectionsRefs(
    Expression<bool> Function($$QuestionSectionsTableFilterComposer f) f,
  ) {
    final $$QuestionSectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questionSections,
      getReferencedColumn: (t) => t.questionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionSectionsTableFilterComposer(
            $db: $db,
            $table: $db.questionSections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get depth => $composableBuilder(
    column: $table.depth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get distractorsJson => $composableBuilder(
    column: $table.distractorsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get promptVersion => $composableBuilder(
    column: $table.promptVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checksJson => $composableBuilder(
    column: $table.checksJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FactsTableOrderingComposer get factId {
    final $$FactsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.factId,
      referencedTable: $db.facts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactsTableOrderingComposer(
            $db: $db,
            $table: $db.facts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get depth =>
      $composableBuilder(column: $table.depth, builder: (column) => column);

  GeneratedColumn<String> get prompt =>
      $composableBuilder(column: $table.prompt, builder: (column) => column);

  GeneratedColumn<String> get answer =>
      $composableBuilder(column: $table.answer, builder: (column) => column);

  GeneratedColumn<String> get distractorsJson => $composableBuilder(
    column: $table.distractorsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quality =>
      $composableBuilder(column: $table.quality, builder: (column) => column);

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<int> get promptVersion => $composableBuilder(
    column: $table.promptVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get checksJson => $composableBuilder(
    column: $table.checksJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$FactsTableAnnotationComposer get factId {
    final $$FactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.factId,
      referencedTable: $db.facts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactsTableAnnotationComposer(
            $db: $db,
            $table: $db.facts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> questionSectionsRefs<T extends Object>(
    Expression<T> Function($$QuestionSectionsTableAnnotationComposer a) f,
  ) {
    final $$QuestionSectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questionSections,
      getReferencedColumn: (t) => t.questionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionSectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.questionSections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QuestionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestionsTable,
          Question,
          $$QuestionsTableFilterComposer,
          $$QuestionsTableOrderingComposer,
          $$QuestionsTableAnnotationComposer,
          $$QuestionsTableCreateCompanionBuilder,
          $$QuestionsTableUpdateCompanionBuilder,
          (Question, $$QuestionsTableReferences),
          Question,
          PrefetchHooks Function({bool factId, bool questionSectionsRefs})
        > {
  $$QuestionsTableTableManager(_$AppDatabase db, $QuestionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> factId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> depth = const Value.absent(),
                Value<String> prompt = const Value.absent(),
                Value<String> answer = const Value.absent(),
                Value<String?> distractorsJson = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
                Value<String> quality = const Value.absent(),
                Value<String> modelId = const Value.absent(),
                Value<int> promptVersion = const Value.absent(),
                Value<String?> checksJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => QuestionsCompanion(
                id: id,
                factId: factId,
                type: type,
                depth: depth,
                prompt: prompt,
                answer: answer,
                distractorsJson: distractorsJson,
                explanation: explanation,
                quality: quality,
                modelId: modelId,
                promptVersion: promptVersion,
                checksJson: checksJson,
                status: status,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int factId,
                required String type,
                required String depth,
                required String prompt,
                required String answer,
                Value<String?> distractorsJson = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
                required String quality,
                required String modelId,
                required int promptVersion,
                Value<String?> checksJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => QuestionsCompanion.insert(
                id: id,
                factId: factId,
                type: type,
                depth: depth,
                prompt: prompt,
                answer: answer,
                distractorsJson: distractorsJson,
                explanation: explanation,
                quality: quality,
                modelId: modelId,
                promptVersion: promptVersion,
                checksJson: checksJson,
                status: status,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuestionsTable, Question>(table),
                  $$QuestionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({factId = false, questionSectionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (questionSectionsRefs) db.questionSections,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (factId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.factId,
                                    referencedTable: $$QuestionsTableReferences
                                        ._factIdTable(db),
                                    referencedColumn: $$QuestionsTableReferences
                                        ._factIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (questionSectionsRefs)
                        await $_getPrefetchedDataByColumns<
                          Question,
                          $QuestionsTable,
                          QuestionSection,
                          $QuestionSectionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$QuestionsTableReferences
                              ._questionSectionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$QuestionsTableReferences(
                                db,
                                table,
                                p0,
                              ).questionSectionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'question_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$QuestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestionsTable,
      Question,
      $$QuestionsTableFilterComposer,
      $$QuestionsTableOrderingComposer,
      $$QuestionsTableAnnotationComposer,
      $$QuestionsTableCreateCompanionBuilder,
      $$QuestionsTableUpdateCompanionBuilder,
      (Question, $$QuestionsTableReferences),
      Question,
      PrefetchHooks Function({bool factId, bool questionSectionsRefs})
    >;
typedef $$QuestionSectionsTableCreateCompanionBuilder =
    QuestionSectionsCompanion Function({
      required int questionId,
      required int sectionId,
      Value<int> rowid,
    });
typedef $$QuestionSectionsTableUpdateCompanionBuilder =
    QuestionSectionsCompanion Function({
      Value<int> questionId,
      Value<int> sectionId,
      Value<int> rowid,
    });

final class $$QuestionSectionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $QuestionSectionsTable, QuestionSection> {
  $$QuestionSectionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $QuestionsTable _questionIdTable(_$AppDatabase db) =>
      db.questions.createAlias('question_sections__question_id__questions__id');

  $$QuestionsTableProcessedTableManager get questionId {
    final $_column = $_itemColumn<int>('question_id')!;

    final manager = $$QuestionsTableTableManager(
      $_db,
      $_db.questions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_questionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SectionsTable _sectionIdTable(_$AppDatabase db) =>
      db.sections.createAlias('question_sections__section_id__sections__id');

  $$SectionsTableProcessedTableManager get sectionId {
    final $_column = $_itemColumn<int>('section_id')!;

    final manager = $$SectionsTableTableManager(
      $_db,
      $_db.sections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QuestionSectionsTableFilterComposer
    extends Composer<_$AppDatabase, $QuestionSectionsTable> {
  $$QuestionSectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$QuestionsTableFilterComposer get questionId {
    final $$QuestionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableFilterComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SectionsTableFilterComposer get sectionId {
    final $$SectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableFilterComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestionSectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestionSectionsTable> {
  $$QuestionSectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$QuestionsTableOrderingComposer get questionId {
    final $$QuestionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableOrderingComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SectionsTableOrderingComposer get sectionId {
    final $$SectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableOrderingComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestionSectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestionSectionsTable> {
  $$QuestionSectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$QuestionsTableAnnotationComposer get questionId {
    final $$QuestionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableAnnotationComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SectionsTableAnnotationComposer get sectionId {
    final $$SectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestionSectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestionSectionsTable,
          QuestionSection,
          $$QuestionSectionsTableFilterComposer,
          $$QuestionSectionsTableOrderingComposer,
          $$QuestionSectionsTableAnnotationComposer,
          $$QuestionSectionsTableCreateCompanionBuilder,
          $$QuestionSectionsTableUpdateCompanionBuilder,
          (QuestionSection, $$QuestionSectionsTableReferences),
          QuestionSection,
          PrefetchHooks Function({bool questionId, bool sectionId})
        > {
  $$QuestionSectionsTableTableManager(
    _$AppDatabase db,
    $QuestionSectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionSectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestionSectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestionSectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> questionId = const Value.absent(),
                Value<int> sectionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestionSectionsCompanion(
                questionId: questionId,
                sectionId: sectionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int questionId,
                required int sectionId,
                Value<int> rowid = const Value.absent(),
              }) => QuestionSectionsCompanion.insert(
                questionId: questionId,
                sectionId: sectionId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuestionSectionsTable, QuestionSection>(table),
                  $$QuestionSectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({questionId = false, sectionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (questionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.questionId,
                                referencedTable:
                                    $$QuestionSectionsTableReferences
                                        ._questionIdTable(db),
                                referencedColumn:
                                    $$QuestionSectionsTableReferences
                                        ._questionIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (sectionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sectionId,
                                referencedTable:
                                    $$QuestionSectionsTableReferences
                                        ._sectionIdTable(db),
                                referencedColumn:
                                    $$QuestionSectionsTableReferences
                                        ._sectionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$QuestionSectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestionSectionsTable,
      QuestionSection,
      $$QuestionSectionsTableFilterComposer,
      $$QuestionSectionsTableOrderingComposer,
      $$QuestionSectionsTableAnnotationComposer,
      $$QuestionSectionsTableCreateCompanionBuilder,
      $$QuestionSectionsTableUpdateCompanionBuilder,
      (QuestionSection, $$QuestionSectionsTableReferences),
      QuestionSection,
      PrefetchHooks Function({bool questionId, bool sectionId})
    >;
typedef $$FactCardsTableCreateCompanionBuilder =
    FactCardsCompanion Function({
      Value<int> factId,
      required String fsrsJson,
      required DateTime due,
      Value<double?> stability,
      Value<double?> difficulty,
      required String state,
      Value<DateTime?> lastReview,
    });
typedef $$FactCardsTableUpdateCompanionBuilder =
    FactCardsCompanion Function({
      Value<int> factId,
      Value<String> fsrsJson,
      Value<DateTime> due,
      Value<double?> stability,
      Value<double?> difficulty,
      Value<String> state,
      Value<DateTime?> lastReview,
    });

final class $$FactCardsTableReferences
    extends BaseReferences<_$AppDatabase, $FactCardsTable, FactCard> {
  $$FactCardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FactsTable _factIdTable(_$AppDatabase db) =>
      db.facts.createAlias('fact_cards__fact_id__facts__id');

  $$FactsTableProcessedTableManager get factId {
    final $_column = $_itemColumn<int>('fact_id')!;

    final manager = $$FactsTableTableManager(
      $_db,
      $_db.facts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_factIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FactCardsTableFilterComposer
    extends Composer<_$AppDatabase, $FactCardsTable> {
  $$FactCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get fsrsJson => $composableBuilder(
    column: $table.fsrsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => ColumnFilters(column),
  );

  $$FactsTableFilterComposer get factId {
    final $$FactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.factId,
      referencedTable: $db.facts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactsTableFilterComposer(
            $db: $db,
            $table: $db.facts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FactCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $FactCardsTable> {
  $$FactCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get fsrsJson => $composableBuilder(
    column: $table.fsrsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => ColumnOrderings(column),
  );

  $$FactsTableOrderingComposer get factId {
    final $$FactsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.factId,
      referencedTable: $db.facts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactsTableOrderingComposer(
            $db: $db,
            $table: $db.facts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FactCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FactCardsTable> {
  $$FactCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get fsrsJson =>
      $composableBuilder(column: $table.fsrsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get due =>
      $composableBuilder(column: $table.due, builder: (column) => column);

  GeneratedColumn<double> get stability =>
      $composableBuilder(column: $table.stability, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => column,
  );

  $$FactsTableAnnotationComposer get factId {
    final $$FactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.factId,
      referencedTable: $db.facts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactsTableAnnotationComposer(
            $db: $db,
            $table: $db.facts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FactCardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FactCardsTable,
          FactCard,
          $$FactCardsTableFilterComposer,
          $$FactCardsTableOrderingComposer,
          $$FactCardsTableAnnotationComposer,
          $$FactCardsTableCreateCompanionBuilder,
          $$FactCardsTableUpdateCompanionBuilder,
          (FactCard, $$FactCardsTableReferences),
          FactCard,
          PrefetchHooks Function({bool factId})
        > {
  $$FactCardsTableTableManager(_$AppDatabase db, $FactCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FactCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FactCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FactCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> factId = const Value.absent(),
                Value<String> fsrsJson = const Value.absent(),
                Value<DateTime> due = const Value.absent(),
                Value<double?> stability = const Value.absent(),
                Value<double?> difficulty = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<DateTime?> lastReview = const Value.absent(),
              }) => FactCardsCompanion(
                factId: factId,
                fsrsJson: fsrsJson,
                due: due,
                stability: stability,
                difficulty: difficulty,
                state: state,
                lastReview: lastReview,
              ),
          createCompanionCallback:
              ({
                Value<int> factId = const Value.absent(),
                required String fsrsJson,
                required DateTime due,
                Value<double?> stability = const Value.absent(),
                Value<double?> difficulty = const Value.absent(),
                required String state,
                Value<DateTime?> lastReview = const Value.absent(),
              }) => FactCardsCompanion.insert(
                factId: factId,
                fsrsJson: fsrsJson,
                due: due,
                stability: stability,
                difficulty: difficulty,
                state: state,
                lastReview: lastReview,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FactCardsTable, FactCard>(table),
                  $$FactCardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({factId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (factId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.factId,
                                referencedTable: $$FactCardsTableReferences
                                    ._factIdTable(db),
                                referencedColumn: $$FactCardsTableReferences
                                    ._factIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FactCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FactCardsTable,
      FactCard,
      $$FactCardsTableFilterComposer,
      $$FactCardsTableOrderingComposer,
      $$FactCardsTableAnnotationComposer,
      $$FactCardsTableCreateCompanionBuilder,
      $$FactCardsTableUpdateCompanionBuilder,
      (FactCard, $$FactCardsTableReferences),
      FactCard,
      PrefetchHooks Function({bool factId})
    >;
typedef $$ReviewsTableCreateCompanionBuilder =
    ReviewsCompanion Function({
      Value<int> id,
      required int factId,
      Value<int?> questionId,
      required int rating,
      Value<bool?> correct,
      Value<int?> responseMs,
      Value<bool> unsure,
      required DateTime reviewedAt,
    });
typedef $$ReviewsTableUpdateCompanionBuilder =
    ReviewsCompanion Function({
      Value<int> id,
      Value<int> factId,
      Value<int?> questionId,
      Value<int> rating,
      Value<bool?> correct,
      Value<int?> responseMs,
      Value<bool> unsure,
      Value<DateTime> reviewedAt,
    });

final class $$ReviewsTableReferences
    extends BaseReferences<_$AppDatabase, $ReviewsTable, Review> {
  $$ReviewsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FactsTable _factIdTable(_$AppDatabase db) =>
      db.facts.createAlias('reviews__fact_id__facts__id');

  $$FactsTableProcessedTableManager get factId {
    final $_column = $_itemColumn<int>('fact_id')!;

    final manager = $$FactsTableTableManager(
      $_db,
      $_db.facts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_factIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReviewsTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewsTable> {
  $$ReviewsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get responseMs => $composableBuilder(
    column: $table.responseMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get unsure => $composableBuilder(
    column: $table.unsure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FactsTableFilterComposer get factId {
    final $$FactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.factId,
      referencedTable: $db.facts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactsTableFilterComposer(
            $db: $db,
            $table: $db.facts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewsTable> {
  $$ReviewsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get responseMs => $composableBuilder(
    column: $table.responseMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get unsure => $composableBuilder(
    column: $table.unsure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FactsTableOrderingComposer get factId {
    final $$FactsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.factId,
      referencedTable: $db.facts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactsTableOrderingComposer(
            $db: $db,
            $table: $db.facts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewsTable> {
  $$ReviewsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<bool> get correct =>
      $composableBuilder(column: $table.correct, builder: (column) => column);

  GeneratedColumn<int> get responseMs => $composableBuilder(
    column: $table.responseMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get unsure =>
      $composableBuilder(column: $table.unsure, builder: (column) => column);

  GeneratedColumn<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );

  $$FactsTableAnnotationComposer get factId {
    final $$FactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.factId,
      referencedTable: $db.facts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactsTableAnnotationComposer(
            $db: $db,
            $table: $db.facts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReviewsTable,
          Review,
          $$ReviewsTableFilterComposer,
          $$ReviewsTableOrderingComposer,
          $$ReviewsTableAnnotationComposer,
          $$ReviewsTableCreateCompanionBuilder,
          $$ReviewsTableUpdateCompanionBuilder,
          (Review, $$ReviewsTableReferences),
          Review,
          PrefetchHooks Function({bool factId})
        > {
  $$ReviewsTableTableManager(_$AppDatabase db, $ReviewsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> factId = const Value.absent(),
                Value<int?> questionId = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<bool?> correct = const Value.absent(),
                Value<int?> responseMs = const Value.absent(),
                Value<bool> unsure = const Value.absent(),
                Value<DateTime> reviewedAt = const Value.absent(),
              }) => ReviewsCompanion(
                id: id,
                factId: factId,
                questionId: questionId,
                rating: rating,
                correct: correct,
                responseMs: responseMs,
                unsure: unsure,
                reviewedAt: reviewedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int factId,
                Value<int?> questionId = const Value.absent(),
                required int rating,
                Value<bool?> correct = const Value.absent(),
                Value<int?> responseMs = const Value.absent(),
                Value<bool> unsure = const Value.absent(),
                required DateTime reviewedAt,
              }) => ReviewsCompanion.insert(
                id: id,
                factId: factId,
                questionId: questionId,
                rating: rating,
                correct: correct,
                responseMs: responseMs,
                unsure: unsure,
                reviewedAt: reviewedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReviewsTable, Review>(table),
                  $$ReviewsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({factId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (factId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.factId,
                                referencedTable: $$ReviewsTableReferences
                                    ._factIdTable(db),
                                referencedColumn: $$ReviewsTableReferences
                                    ._factIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReviewsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReviewsTable,
      Review,
      $$ReviewsTableFilterComposer,
      $$ReviewsTableOrderingComposer,
      $$ReviewsTableAnnotationComposer,
      $$ReviewsTableCreateCompanionBuilder,
      $$ReviewsTableUpdateCompanionBuilder,
      (Review, $$ReviewsTableReferences),
      Review,
      PrefetchHooks Function({bool factId})
    >;
typedef $$JobsTableCreateCompanionBuilder =
    JobsCompanion Function({
      Value<int> id,
      required int documentId,
      required String scopeJson,
      required String profileJson,
      Value<String> status,
      Value<int> priority,
      Value<String?> error,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$JobsTableUpdateCompanionBuilder =
    JobsCompanion Function({
      Value<int> id,
      Value<int> documentId,
      Value<String> scopeJson,
      Value<String> profileJson,
      Value<String> status,
      Value<int> priority,
      Value<String?> error,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$JobsTableReferences
    extends BaseReferences<_$AppDatabase, $JobsTable, Job> {
  $$JobsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DocumentsTable _documentIdTable(_$AppDatabase db) =>
      db.documents.createAlias('jobs__document_id__documents__id');

  $$DocumentsTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<int>('document_id')!;

    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$JobItemsTable, List<JobItem>> _jobItemsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.jobItems,
    aliasName: 'jobs__id__job_items__job_id',
  );

  $$JobItemsTableProcessedTableManager get jobItemsRefs {
    final manager = $$JobItemsTableTableManager(
      $_db,
      $_db.jobItems,
    ).filter((f) => f.jobId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_jobItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$JobsTableFilterComposer extends Composer<_$AppDatabase, $JobsTable> {
  $$JobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopeJson => $composableBuilder(
    column: $table.scopeJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileJson => $composableBuilder(
    column: $table.profileJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentsTableFilterComposer get documentId {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> jobItemsRefs(
    Expression<bool> Function($$JobItemsTableFilterComposer f) f,
  ) {
    final $$JobItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobItems,
      getReferencedColumn: (t) => t.jobId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobItemsTableFilterComposer(
            $db: $db,
            $table: $db.jobItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JobsTableOrderingComposer extends Composer<_$AppDatabase, $JobsTable> {
  $$JobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopeJson => $composableBuilder(
    column: $table.scopeJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileJson => $composableBuilder(
    column: $table.profileJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentsTableOrderingComposer get documentId {
    final $$DocumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableOrderingComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $JobsTable> {
  $$JobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scopeJson =>
      $composableBuilder(column: $table.scopeJson, builder: (column) => column);

  GeneratedColumn<String> get profileJson => $composableBuilder(
    column: $table.profileJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$DocumentsTableAnnotationComposer get documentId {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> jobItemsRefs<T extends Object>(
    Expression<T> Function($$JobItemsTableAnnotationComposer a) f,
  ) {
    final $$JobItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobItems,
      getReferencedColumn: (t) => t.jobId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JobsTable,
          Job,
          $$JobsTableFilterComposer,
          $$JobsTableOrderingComposer,
          $$JobsTableAnnotationComposer,
          $$JobsTableCreateCompanionBuilder,
          $$JobsTableUpdateCompanionBuilder,
          (Job, $$JobsTableReferences),
          Job,
          PrefetchHooks Function({bool documentId, bool jobItemsRefs})
        > {
  $$JobsTableTableManager(_$AppDatabase db, $JobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> documentId = const Value.absent(),
                Value<String> scopeJson = const Value.absent(),
                Value<String> profileJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => JobsCompanion(
                id: id,
                documentId: documentId,
                scopeJson: scopeJson,
                profileJson: profileJson,
                status: status,
                priority: priority,
                error: error,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int documentId,
                required String scopeJson,
                required String profileJson,
                Value<String> status = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => JobsCompanion.insert(
                id: id,
                documentId: documentId,
                scopeJson: scopeJson,
                profileJson: profileJson,
                status: status,
                priority: priority,
                error: error,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$JobsTable, Job>(table),
                  $$JobsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentId = false, jobItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (jobItemsRefs) db.jobItems],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (documentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.documentId,
                                referencedTable: $$JobsTableReferences
                                    ._documentIdTable(db),
                                referencedColumn: $$JobsTableReferences
                                    ._documentIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (jobItemsRefs)
                    await $_getPrefetchedDataByColumns<
                      Job,
                      $JobsTable,
                      JobItem,
                      $JobItemsTable
                    >(
                      currentTable: table,
                      referencedTable: $$JobsTableReferences._jobItemsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$JobsTableReferences(db, table, p0).jobItemsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'job_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$JobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JobsTable,
      Job,
      $$JobsTableFilterComposer,
      $$JobsTableOrderingComposer,
      $$JobsTableAnnotationComposer,
      $$JobsTableCreateCompanionBuilder,
      $$JobsTableUpdateCompanionBuilder,
      (Job, $$JobsTableReferences),
      Job,
      PrefetchHooks Function({bool documentId, bool jobItemsRefs})
    >;
typedef $$JobItemsTableCreateCompanionBuilder =
    JobItemsCompanion Function({
      Value<int> id,
      required int jobId,
      required int chunkId,
      required String stage,
      Value<String> status,
      Value<int> attempts,
      Value<String?> cacheKey,
      Value<String?> error,
      Value<DateTime> updatedAt,
    });
typedef $$JobItemsTableUpdateCompanionBuilder =
    JobItemsCompanion Function({
      Value<int> id,
      Value<int> jobId,
      Value<int> chunkId,
      Value<String> stage,
      Value<String> status,
      Value<int> attempts,
      Value<String?> cacheKey,
      Value<String?> error,
      Value<DateTime> updatedAt,
    });

final class $$JobItemsTableReferences
    extends BaseReferences<_$AppDatabase, $JobItemsTable, JobItem> {
  $$JobItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $JobsTable _jobIdTable(_$AppDatabase db) =>
      db.jobs.createAlias('job_items__job_id__jobs__id');

  $$JobsTableProcessedTableManager get jobId {
    final $_column = $_itemColumn<int>('job_id')!;

    final manager = $$JobsTableTableManager(
      $_db,
      $_db.jobs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_jobIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ChunksTable _chunkIdTable(_$AppDatabase db) =>
      db.chunks.createAlias('job_items__chunk_id__chunks__id');

  $$ChunksTableProcessedTableManager get chunkId {
    final $_column = $_itemColumn<int>('chunk_id')!;

    final manager = $$ChunksTableTableManager(
      $_db,
      $_db.chunks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chunkIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$JobItemsTableFilterComposer
    extends Composer<_$AppDatabase, $JobItemsTable> {
  $$JobItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$JobsTableFilterComposer get jobId {
    final $$JobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableFilterComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChunksTableFilterComposer get chunkId {
    final $$ChunksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chunkId,
      referencedTable: $db.chunks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChunksTableFilterComposer(
            $db: $db,
            $table: $db.chunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JobItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $JobItemsTable> {
  $$JobItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$JobsTableOrderingComposer get jobId {
    final $$JobsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableOrderingComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChunksTableOrderingComposer get chunkId {
    final $$ChunksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chunkId,
      referencedTable: $db.chunks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChunksTableOrderingComposer(
            $db: $db,
            $table: $db.chunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JobItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $JobItemsTable> {
  $$JobItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$JobsTableAnnotationComposer get jobId {
    final $$JobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChunksTableAnnotationComposer get chunkId {
    final $$ChunksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chunkId,
      referencedTable: $db.chunks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChunksTableAnnotationComposer(
            $db: $db,
            $table: $db.chunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JobItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JobItemsTable,
          JobItem,
          $$JobItemsTableFilterComposer,
          $$JobItemsTableOrderingComposer,
          $$JobItemsTableAnnotationComposer,
          $$JobItemsTableCreateCompanionBuilder,
          $$JobItemsTableUpdateCompanionBuilder,
          (JobItem, $$JobItemsTableReferences),
          JobItem,
          PrefetchHooks Function({bool jobId, bool chunkId})
        > {
  $$JobItemsTableTableManager(_$AppDatabase db, $JobItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JobItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JobItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JobItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> jobId = const Value.absent(),
                Value<int> chunkId = const Value.absent(),
                Value<String> stage = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> cacheKey = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => JobItemsCompanion(
                id: id,
                jobId: jobId,
                chunkId: chunkId,
                stage: stage,
                status: status,
                attempts: attempts,
                cacheKey: cacheKey,
                error: error,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int jobId,
                required int chunkId,
                required String stage,
                Value<String> status = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> cacheKey = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => JobItemsCompanion.insert(
                id: id,
                jobId: jobId,
                chunkId: chunkId,
                stage: stage,
                status: status,
                attempts: attempts,
                cacheKey: cacheKey,
                error: error,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$JobItemsTable, JobItem>(table),
                  $$JobItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({jobId = false, chunkId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (jobId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.jobId,
                                referencedTable: $$JobItemsTableReferences
                                    ._jobIdTable(db),
                                referencedColumn: $$JobItemsTableReferences
                                    ._jobIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (chunkId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.chunkId,
                                referencedTable: $$JobItemsTableReferences
                                    ._chunkIdTable(db),
                                referencedColumn: $$JobItemsTableReferences
                                    ._chunkIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$JobItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JobItemsTable,
      JobItem,
      $$JobItemsTableFilterComposer,
      $$JobItemsTableOrderingComposer,
      $$JobItemsTableAnnotationComposer,
      $$JobItemsTableCreateCompanionBuilder,
      $$JobItemsTableUpdateCompanionBuilder,
      (JobItem, $$JobItemsTableReferences),
      JobItem,
      PrefetchHooks Function({bool jobId, bool chunkId})
    >;
typedef $$LlmCacheEntriesTableCreateCompanionBuilder =
    LlmCacheEntriesCompanion Function({
      required String cacheKey,
      required String output,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$LlmCacheEntriesTableUpdateCompanionBuilder =
    LlmCacheEntriesCompanion Function({
      Value<String> cacheKey,
      Value<String> output,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LlmCacheEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LlmCacheEntriesTable> {
  $$LlmCacheEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get output => $composableBuilder(
    column: $table.output,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LlmCacheEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LlmCacheEntriesTable> {
  $$LlmCacheEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get output => $composableBuilder(
    column: $table.output,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LlmCacheEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LlmCacheEntriesTable> {
  $$LlmCacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get output =>
      $composableBuilder(column: $table.output, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LlmCacheEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LlmCacheEntriesTable,
          LlmCacheEntry,
          $$LlmCacheEntriesTableFilterComposer,
          $$LlmCacheEntriesTableOrderingComposer,
          $$LlmCacheEntriesTableAnnotationComposer,
          $$LlmCacheEntriesTableCreateCompanionBuilder,
          $$LlmCacheEntriesTableUpdateCompanionBuilder,
          (
            LlmCacheEntry,
            BaseReferences<_$AppDatabase, $LlmCacheEntriesTable, LlmCacheEntry>,
          ),
          LlmCacheEntry,
          PrefetchHooks Function()
        > {
  $$LlmCacheEntriesTableTableManager(
    _$AppDatabase db,
    $LlmCacheEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LlmCacheEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LlmCacheEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LlmCacheEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cacheKey = const Value.absent(),
                Value<String> output = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LlmCacheEntriesCompanion(
                cacheKey: cacheKey,
                output: output,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cacheKey,
                required String output,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LlmCacheEntriesCompanion.insert(
                cacheKey: cacheKey,
                output: output,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LlmCacheEntriesTable, LlmCacheEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LlmCacheEntriesTable,
                    LlmCacheEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LlmCacheEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LlmCacheEntriesTable,
      LlmCacheEntry,
      $$LlmCacheEntriesTableFilterComposer,
      $$LlmCacheEntriesTableOrderingComposer,
      $$LlmCacheEntriesTableAnnotationComposer,
      $$LlmCacheEntriesTableCreateCompanionBuilder,
      $$LlmCacheEntriesTableUpdateCompanionBuilder,
      (
        LlmCacheEntry,
        BaseReferences<_$AppDatabase, $LlmCacheEntriesTable, LlmCacheEntry>,
      ),
      LlmCacheEntry,
      PrefetchHooks Function()
    >;
typedef $$RejectionsTableCreateCompanionBuilder =
    RejectionsCompanion Function({
      Value<int> id,
      required int documentId,
      Value<int?> chunkId,
      required String stage,
      required String reason,
      Value<String?> payload,
      Value<DateTime> createdAt,
    });
typedef $$RejectionsTableUpdateCompanionBuilder =
    RejectionsCompanion Function({
      Value<int> id,
      Value<int> documentId,
      Value<int?> chunkId,
      Value<String> stage,
      Value<String> reason,
      Value<String?> payload,
      Value<DateTime> createdAt,
    });

final class $$RejectionsTableReferences
    extends BaseReferences<_$AppDatabase, $RejectionsTable, Rejection> {
  $$RejectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DocumentsTable _documentIdTable(_$AppDatabase db) =>
      db.documents.createAlias('rejections__document_id__documents__id');

  $$DocumentsTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<int>('document_id')!;

    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RejectionsTableFilterComposer
    extends Composer<_$AppDatabase, $RejectionsTable> {
  $$RejectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chunkId => $composableBuilder(
    column: $table.chunkId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentsTableFilterComposer get documentId {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RejectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RejectionsTable> {
  $$RejectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chunkId => $composableBuilder(
    column: $table.chunkId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentsTableOrderingComposer get documentId {
    final $$DocumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableOrderingComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RejectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RejectionsTable> {
  $$RejectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get chunkId =>
      $composableBuilder(column: $table.chunkId, builder: (column) => column);

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$DocumentsTableAnnotationComposer get documentId {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RejectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RejectionsTable,
          Rejection,
          $$RejectionsTableFilterComposer,
          $$RejectionsTableOrderingComposer,
          $$RejectionsTableAnnotationComposer,
          $$RejectionsTableCreateCompanionBuilder,
          $$RejectionsTableUpdateCompanionBuilder,
          (Rejection, $$RejectionsTableReferences),
          Rejection,
          PrefetchHooks Function({bool documentId})
        > {
  $$RejectionsTableTableManager(_$AppDatabase db, $RejectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RejectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RejectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RejectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> documentId = const Value.absent(),
                Value<int?> chunkId = const Value.absent(),
                Value<String> stage = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String?> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RejectionsCompanion(
                id: id,
                documentId: documentId,
                chunkId: chunkId,
                stage: stage,
                reason: reason,
                payload: payload,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int documentId,
                Value<int?> chunkId = const Value.absent(),
                required String stage,
                required String reason,
                Value<String?> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RejectionsCompanion.insert(
                id: id,
                documentId: documentId,
                chunkId: chunkId,
                stage: stage,
                reason: reason,
                payload: payload,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RejectionsTable, Rejection>(table),
                  $$RejectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (documentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.documentId,
                                referencedTable: $$RejectionsTableReferences
                                    ._documentIdTable(db),
                                referencedColumn: $$RejectionsTableReferences
                                    ._documentIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RejectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RejectionsTable,
      Rejection,
      $$RejectionsTableFilterComposer,
      $$RejectionsTableOrderingComposer,
      $$RejectionsTableAnnotationComposer,
      $$RejectionsTableCreateCompanionBuilder,
      $$RejectionsTableUpdateCompanionBuilder,
      (Rejection, $$RejectionsTableReferences),
      Rejection,
      PrefetchHooks Function({bool documentId})
    >;
typedef $$ChatThreadsTableCreateCompanionBuilder =
    ChatThreadsCompanion Function({
      Value<int> id,
      required int documentId,
      required String title,
      Value<String?> summary,
      Value<DateTime> createdAt,
      Value<String?> modelPath,
    });
typedef $$ChatThreadsTableUpdateCompanionBuilder =
    ChatThreadsCompanion Function({
      Value<int> id,
      Value<int> documentId,
      Value<String> title,
      Value<String?> summary,
      Value<DateTime> createdAt,
      Value<String?> modelPath,
    });

final class $$ChatThreadsTableReferences
    extends BaseReferences<_$AppDatabase, $ChatThreadsTable, ChatThread> {
  $$ChatThreadsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DocumentsTable _documentIdTable(_$AppDatabase db) =>
      db.documents.createAlias('chat_threads__document_id__documents__id');

  $$DocumentsTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<int>('document_id')!;

    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ChatMessagesTable, List<ChatMessage>>
  _chatMessagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chatMessages,
    aliasName: 'chat_threads__id__chat_messages__thread_id',
  );

  $$ChatMessagesTableProcessedTableManager get chatMessagesRefs {
    final manager = $$ChatMessagesTableTableManager(
      $_db,
      $_db.chatMessages,
    ).filter((f) => f.threadId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_chatMessagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ChatThreadsTableFilterComposer
    extends Composer<_$AppDatabase, $ChatThreadsTable> {
  $$ChatThreadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelPath => $composableBuilder(
    column: $table.modelPath,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentsTableFilterComposer get documentId {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> chatMessagesRefs(
    Expression<bool> Function($$ChatMessagesTableFilterComposer f) f,
  ) {
    final $$ChatMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMessages,
      getReferencedColumn: (t) => t.threadId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMessagesTableFilterComposer(
            $db: $db,
            $table: $db.chatMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChatThreadsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatThreadsTable> {
  $$ChatThreadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelPath => $composableBuilder(
    column: $table.modelPath,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentsTableOrderingComposer get documentId {
    final $$DocumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableOrderingComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatThreadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatThreadsTable> {
  $$ChatThreadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get modelPath =>
      $composableBuilder(column: $table.modelPath, builder: (column) => column);

  $$DocumentsTableAnnotationComposer get documentId {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> chatMessagesRefs<T extends Object>(
    Expression<T> Function($$ChatMessagesTableAnnotationComposer a) f,
  ) {
    final $$ChatMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMessages,
      getReferencedColumn: (t) => t.threadId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.chatMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChatThreadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatThreadsTable,
          ChatThread,
          $$ChatThreadsTableFilterComposer,
          $$ChatThreadsTableOrderingComposer,
          $$ChatThreadsTableAnnotationComposer,
          $$ChatThreadsTableCreateCompanionBuilder,
          $$ChatThreadsTableUpdateCompanionBuilder,
          (ChatThread, $$ChatThreadsTableReferences),
          ChatThread,
          PrefetchHooks Function({bool documentId, bool chatMessagesRefs})
        > {
  $$ChatThreadsTableTableManager(_$AppDatabase db, $ChatThreadsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatThreadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatThreadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatThreadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> documentId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> modelPath = const Value.absent(),
              }) => ChatThreadsCompanion(
                id: id,
                documentId: documentId,
                title: title,
                summary: summary,
                createdAt: createdAt,
                modelPath: modelPath,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int documentId,
                required String title,
                Value<String?> summary = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> modelPath = const Value.absent(),
              }) => ChatThreadsCompanion.insert(
                id: id,
                documentId: documentId,
                title: title,
                summary: summary,
                createdAt: createdAt,
                modelPath: modelPath,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChatThreadsTable, ChatThread>(table),
                  $$ChatThreadsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({documentId = false, chatMessagesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (chatMessagesRefs) db.chatMessages,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (documentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.documentId,
                                    referencedTable:
                                        $$ChatThreadsTableReferences
                                            ._documentIdTable(db),
                                    referencedColumn:
                                        $$ChatThreadsTableReferences
                                            ._documentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (chatMessagesRefs)
                        await $_getPrefetchedDataByColumns<
                          ChatThread,
                          $ChatThreadsTable,
                          ChatMessage,
                          $ChatMessagesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ChatThreadsTableReferences
                              ._chatMessagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChatThreadsTableReferences(
                                db,
                                table,
                                p0,
                              ).chatMessagesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'thread_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ChatThreadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatThreadsTable,
      ChatThread,
      $$ChatThreadsTableFilterComposer,
      $$ChatThreadsTableOrderingComposer,
      $$ChatThreadsTableAnnotationComposer,
      $$ChatThreadsTableCreateCompanionBuilder,
      $$ChatThreadsTableUpdateCompanionBuilder,
      (ChatThread, $$ChatThreadsTableReferences),
      ChatThread,
      PrefetchHooks Function({bool documentId, bool chatMessagesRefs})
    >;
typedef $$ChatMessagesTableCreateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<int> id,
      required int threadId,
      required String role,
      required String content,
      Value<String?> citationsJson,
      Value<bool> usedWeb,
      Value<DateTime> createdAt,
    });
typedef $$ChatMessagesTableUpdateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<int> id,
      Value<int> threadId,
      Value<String> role,
      Value<String> content,
      Value<String?> citationsJson,
      Value<bool> usedWeb,
      Value<DateTime> createdAt,
    });

final class $$ChatMessagesTableReferences
    extends BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage> {
  $$ChatMessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChatThreadsTable _threadIdTable(_$AppDatabase db) =>
      db.chatThreads.createAlias('chat_messages__thread_id__chat_threads__id');

  $$ChatThreadsTableProcessedTableManager get threadId {
    final $_column = $_itemColumn<int>('thread_id')!;

    final manager = $$ChatThreadsTableTableManager(
      $_db,
      $_db.chatThreads,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_threadIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get citationsJson => $composableBuilder(
    column: $table.citationsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get usedWeb => $composableBuilder(
    column: $table.usedWeb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ChatThreadsTableFilterComposer get threadId {
    final $$ChatThreadsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.threadId,
      referencedTable: $db.chatThreads,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatThreadsTableFilterComposer(
            $db: $db,
            $table: $db.chatThreads,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get citationsJson => $composableBuilder(
    column: $table.citationsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get usedWeb => $composableBuilder(
    column: $table.usedWeb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChatThreadsTableOrderingComposer get threadId {
    final $$ChatThreadsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.threadId,
      referencedTable: $db.chatThreads,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatThreadsTableOrderingComposer(
            $db: $db,
            $table: $db.chatThreads,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get citationsJson => $composableBuilder(
    column: $table.citationsJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get usedWeb =>
      $composableBuilder(column: $table.usedWeb, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ChatThreadsTableAnnotationComposer get threadId {
    final $$ChatThreadsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.threadId,
      referencedTable: $db.chatThreads,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatThreadsTableAnnotationComposer(
            $db: $db,
            $table: $db.chatThreads,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatMessagesTable,
          ChatMessage,
          $$ChatMessagesTableFilterComposer,
          $$ChatMessagesTableOrderingComposer,
          $$ChatMessagesTableAnnotationComposer,
          $$ChatMessagesTableCreateCompanionBuilder,
          $$ChatMessagesTableUpdateCompanionBuilder,
          (ChatMessage, $$ChatMessagesTableReferences),
          ChatMessage,
          PrefetchHooks Function({bool threadId})
        > {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> threadId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> citationsJson = const Value.absent(),
                Value<bool> usedWeb = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ChatMessagesCompanion(
                id: id,
                threadId: threadId,
                role: role,
                content: content,
                citationsJson: citationsJson,
                usedWeb: usedWeb,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int threadId,
                required String role,
                required String content,
                Value<String?> citationsJson = const Value.absent(),
                Value<bool> usedWeb = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ChatMessagesCompanion.insert(
                id: id,
                threadId: threadId,
                role: role,
                content: content,
                citationsJson: citationsJson,
                usedWeb: usedWeb,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChatMessagesTable, ChatMessage>(table),
                  $$ChatMessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({threadId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (threadId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.threadId,
                                referencedTable: $$ChatMessagesTableReferences
                                    ._threadIdTable(db),
                                referencedColumn: $$ChatMessagesTableReferences
                                    ._threadIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatMessagesTable,
      ChatMessage,
      $$ChatMessagesTableFilterComposer,
      $$ChatMessagesTableOrderingComposer,
      $$ChatMessagesTableAnnotationComposer,
      $$ChatMessagesTableCreateCompanionBuilder,
      $$ChatMessagesTableUpdateCompanionBuilder,
      (ChatMessage, $$ChatMessagesTableReferences),
      ChatMessage,
      PrefetchHooks Function({bool threadId})
    >;
typedef $$WebPagesTableCreateCompanionBuilder =
    WebPagesCompanion Function({
      required String url,
      Value<String?> title,
      required String body,
      required int httpStatus,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$WebPagesTableUpdateCompanionBuilder =
    WebPagesCompanion Function({
      Value<String> url,
      Value<String?> title,
      Value<String> body,
      Value<int> httpStatus,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$WebPagesTableFilterComposer
    extends Composer<_$AppDatabase, $WebPagesTable> {
  $$WebPagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get httpStatus => $composableBuilder(
    column: $table.httpStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WebPagesTableOrderingComposer
    extends Composer<_$AppDatabase, $WebPagesTable> {
  $$WebPagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get httpStatus => $composableBuilder(
    column: $table.httpStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WebPagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WebPagesTable> {
  $$WebPagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<int> get httpStatus => $composableBuilder(
    column: $table.httpStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$WebPagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WebPagesTable,
          WebPage,
          $$WebPagesTableFilterComposer,
          $$WebPagesTableOrderingComposer,
          $$WebPagesTableAnnotationComposer,
          $$WebPagesTableCreateCompanionBuilder,
          $$WebPagesTableUpdateCompanionBuilder,
          (WebPage, BaseReferences<_$AppDatabase, $WebPagesTable, WebPage>),
          WebPage,
          PrefetchHooks Function()
        > {
  $$WebPagesTableTableManager(_$AppDatabase db, $WebPagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WebPagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WebPagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WebPagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> url = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> httpStatus = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WebPagesCompanion(
                url: url,
                title: title,
                body: body,
                httpStatus: httpStatus,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String url,
                Value<String?> title = const Value.absent(),
                required String body,
                required int httpStatus,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => WebPagesCompanion.insert(
                url: url,
                title: title,
                body: body,
                httpStatus: httpStatus,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WebPagesTable, WebPage>(table),
                  BaseReferences<_$AppDatabase, $WebPagesTable, WebPage>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WebPagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WebPagesTable,
      WebPage,
      $$WebPagesTableFilterComposer,
      $$WebPagesTableOrderingComposer,
      $$WebPagesTableAnnotationComposer,
      $$WebPagesTableCreateCompanionBuilder,
      $$WebPagesTableUpdateCompanionBuilder,
      (WebPage, BaseReferences<_$AppDatabase, $WebPagesTable, WebPage>),
      WebPage,
      PrefetchHooks Function()
    >;
typedef $$WebLogEntriesTableCreateCompanionBuilder =
    WebLogEntriesCompanion Function({
      Value<int> id,
      required String query,
      required String provider,
      Value<String?> urlsJson,
      Value<DateTime> at,
    });
typedef $$WebLogEntriesTableUpdateCompanionBuilder =
    WebLogEntriesCompanion Function({
      Value<int> id,
      Value<String> query,
      Value<String> provider,
      Value<String?> urlsJson,
      Value<DateTime> at,
    });

class $$WebLogEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $WebLogEntriesTable> {
  $$WebLogEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get urlsJson => $composableBuilder(
    column: $table.urlsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WebLogEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $WebLogEntriesTable> {
  $$WebLogEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get urlsJson => $composableBuilder(
    column: $table.urlsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WebLogEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WebLogEntriesTable> {
  $$WebLogEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get urlsJson =>
      $composableBuilder(column: $table.urlsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);
}

class $$WebLogEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WebLogEntriesTable,
          WebLogEntry,
          $$WebLogEntriesTableFilterComposer,
          $$WebLogEntriesTableOrderingComposer,
          $$WebLogEntriesTableAnnotationComposer,
          $$WebLogEntriesTableCreateCompanionBuilder,
          $$WebLogEntriesTableUpdateCompanionBuilder,
          (
            WebLogEntry,
            BaseReferences<_$AppDatabase, $WebLogEntriesTable, WebLogEntry>,
          ),
          WebLogEntry,
          PrefetchHooks Function()
        > {
  $$WebLogEntriesTableTableManager(_$AppDatabase db, $WebLogEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WebLogEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WebLogEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WebLogEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> query = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<String?> urlsJson = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
              }) => WebLogEntriesCompanion(
                id: id,
                query: query,
                provider: provider,
                urlsJson: urlsJson,
                at: at,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String query,
                required String provider,
                Value<String?> urlsJson = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
              }) => WebLogEntriesCompanion.insert(
                id: id,
                query: query,
                provider: provider,
                urlsJson: urlsJson,
                at: at,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WebLogEntriesTable, WebLogEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WebLogEntriesTable,
                    WebLogEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WebLogEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WebLogEntriesTable,
      WebLogEntry,
      $$WebLogEntriesTableFilterComposer,
      $$WebLogEntriesTableOrderingComposer,
      $$WebLogEntriesTableAnnotationComposer,
      $$WebLogEntriesTableCreateCompanionBuilder,
      $$WebLogEntriesTableUpdateCompanionBuilder,
      (
        WebLogEntry,
        BaseReferences<_$AppDatabase, $WebLogEntriesTable, WebLogEntry>,
      ),
      WebLogEntry,
      PrefetchHooks Function()
    >;
typedef $$FactChecksTableCreateCompanionBuilder =
    FactChecksCompanion Function({
      Value<int> id,
      Value<int?> factId,
      Value<int?> questionId,
      required String claim,
      required String verdict,
      required String evidenceJson,
      Value<DateTime> createdAt,
    });
typedef $$FactChecksTableUpdateCompanionBuilder =
    FactChecksCompanion Function({
      Value<int> id,
      Value<int?> factId,
      Value<int?> questionId,
      Value<String> claim,
      Value<String> verdict,
      Value<String> evidenceJson,
      Value<DateTime> createdAt,
    });

class $$FactChecksTableFilterComposer
    extends Composer<_$AppDatabase, $FactChecksTable> {
  $$FactChecksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get factId => $composableBuilder(
    column: $table.factId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get claim => $composableBuilder(
    column: $table.claim,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verdict => $composableBuilder(
    column: $table.verdict,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidenceJson => $composableBuilder(
    column: $table.evidenceJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FactChecksTableOrderingComposer
    extends Composer<_$AppDatabase, $FactChecksTable> {
  $$FactChecksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get factId => $composableBuilder(
    column: $table.factId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get claim => $composableBuilder(
    column: $table.claim,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verdict => $composableBuilder(
    column: $table.verdict,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidenceJson => $composableBuilder(
    column: $table.evidenceJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FactChecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $FactChecksTable> {
  $$FactChecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get factId =>
      $composableBuilder(column: $table.factId, builder: (column) => column);

  GeneratedColumn<int> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get claim =>
      $composableBuilder(column: $table.claim, builder: (column) => column);

  GeneratedColumn<String> get verdict =>
      $composableBuilder(column: $table.verdict, builder: (column) => column);

  GeneratedColumn<String> get evidenceJson => $composableBuilder(
    column: $table.evidenceJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FactChecksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FactChecksTable,
          FactCheck,
          $$FactChecksTableFilterComposer,
          $$FactChecksTableOrderingComposer,
          $$FactChecksTableAnnotationComposer,
          $$FactChecksTableCreateCompanionBuilder,
          $$FactChecksTableUpdateCompanionBuilder,
          (
            FactCheck,
            BaseReferences<_$AppDatabase, $FactChecksTable, FactCheck>,
          ),
          FactCheck,
          PrefetchHooks Function()
        > {
  $$FactChecksTableTableManager(_$AppDatabase db, $FactChecksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FactChecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FactChecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FactChecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> factId = const Value.absent(),
                Value<int?> questionId = const Value.absent(),
                Value<String> claim = const Value.absent(),
                Value<String> verdict = const Value.absent(),
                Value<String> evidenceJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FactChecksCompanion(
                id: id,
                factId: factId,
                questionId: questionId,
                claim: claim,
                verdict: verdict,
                evidenceJson: evidenceJson,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> factId = const Value.absent(),
                Value<int?> questionId = const Value.absent(),
                required String claim,
                required String verdict,
                required String evidenceJson,
                Value<DateTime> createdAt = const Value.absent(),
              }) => FactChecksCompanion.insert(
                id: id,
                factId: factId,
                questionId: questionId,
                claim: claim,
                verdict: verdict,
                evidenceJson: evidenceJson,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FactChecksTable, FactCheck>(table),
                  BaseReferences<_$AppDatabase, $FactChecksTable, FactCheck>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FactChecksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FactChecksTable,
      FactCheck,
      $$FactChecksTableFilterComposer,
      $$FactChecksTableOrderingComposer,
      $$FactChecksTableAnnotationComposer,
      $$FactChecksTableCreateCompanionBuilder,
      $$FactChecksTableUpdateCompanionBuilder,
      (FactCheck, BaseReferences<_$AppDatabase, $FactChecksTable, FactCheck>),
      FactCheck,
      PrefetchHooks Function()
    >;
typedef $$BenchmarkRunsTableCreateCompanionBuilder =
    BenchmarkRunsCompanion Function({
      Value<int> id,
      required String modelName,
      required String backend,
      required double readTokensPerSecond,
      required double writeTokensPerSecond,
      required int firstQuestionMs,
      required int nextQuestionMs,
      Value<double?> cachedPromptShare,
      Value<DateTime> createdAt,
    });
typedef $$BenchmarkRunsTableUpdateCompanionBuilder =
    BenchmarkRunsCompanion Function({
      Value<int> id,
      Value<String> modelName,
      Value<String> backend,
      Value<double> readTokensPerSecond,
      Value<double> writeTokensPerSecond,
      Value<int> firstQuestionMs,
      Value<int> nextQuestionMs,
      Value<double?> cachedPromptShare,
      Value<DateTime> createdAt,
    });

class $$BenchmarkRunsTableFilterComposer
    extends Composer<_$AppDatabase, $BenchmarkRunsTable> {
  $$BenchmarkRunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backend => $composableBuilder(
    column: $table.backend,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get readTokensPerSecond => $composableBuilder(
    column: $table.readTokensPerSecond,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get writeTokensPerSecond => $composableBuilder(
    column: $table.writeTokensPerSecond,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstQuestionMs => $composableBuilder(
    column: $table.firstQuestionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextQuestionMs => $composableBuilder(
    column: $table.nextQuestionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cachedPromptShare => $composableBuilder(
    column: $table.cachedPromptShare,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BenchmarkRunsTableOrderingComposer
    extends Composer<_$AppDatabase, $BenchmarkRunsTable> {
  $$BenchmarkRunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backend => $composableBuilder(
    column: $table.backend,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get readTokensPerSecond => $composableBuilder(
    column: $table.readTokensPerSecond,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get writeTokensPerSecond => $composableBuilder(
    column: $table.writeTokensPerSecond,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstQuestionMs => $composableBuilder(
    column: $table.firstQuestionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextQuestionMs => $composableBuilder(
    column: $table.nextQuestionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cachedPromptShare => $composableBuilder(
    column: $table.cachedPromptShare,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BenchmarkRunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BenchmarkRunsTable> {
  $$BenchmarkRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<String> get backend =>
      $composableBuilder(column: $table.backend, builder: (column) => column);

  GeneratedColumn<double> get readTokensPerSecond => $composableBuilder(
    column: $table.readTokensPerSecond,
    builder: (column) => column,
  );

  GeneratedColumn<double> get writeTokensPerSecond => $composableBuilder(
    column: $table.writeTokensPerSecond,
    builder: (column) => column,
  );

  GeneratedColumn<int> get firstQuestionMs => $composableBuilder(
    column: $table.firstQuestionMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextQuestionMs => $composableBuilder(
    column: $table.nextQuestionMs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cachedPromptShare => $composableBuilder(
    column: $table.cachedPromptShare,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BenchmarkRunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BenchmarkRunsTable,
          BenchmarkRun,
          $$BenchmarkRunsTableFilterComposer,
          $$BenchmarkRunsTableOrderingComposer,
          $$BenchmarkRunsTableAnnotationComposer,
          $$BenchmarkRunsTableCreateCompanionBuilder,
          $$BenchmarkRunsTableUpdateCompanionBuilder,
          (
            BenchmarkRun,
            BaseReferences<_$AppDatabase, $BenchmarkRunsTable, BenchmarkRun>,
          ),
          BenchmarkRun,
          PrefetchHooks Function()
        > {
  $$BenchmarkRunsTableTableManager(_$AppDatabase db, $BenchmarkRunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BenchmarkRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BenchmarkRunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BenchmarkRunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> modelName = const Value.absent(),
                Value<String> backend = const Value.absent(),
                Value<double> readTokensPerSecond = const Value.absent(),
                Value<double> writeTokensPerSecond = const Value.absent(),
                Value<int> firstQuestionMs = const Value.absent(),
                Value<int> nextQuestionMs = const Value.absent(),
                Value<double?> cachedPromptShare = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BenchmarkRunsCompanion(
                id: id,
                modelName: modelName,
                backend: backend,
                readTokensPerSecond: readTokensPerSecond,
                writeTokensPerSecond: writeTokensPerSecond,
                firstQuestionMs: firstQuestionMs,
                nextQuestionMs: nextQuestionMs,
                cachedPromptShare: cachedPromptShare,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String modelName,
                required String backend,
                required double readTokensPerSecond,
                required double writeTokensPerSecond,
                required int firstQuestionMs,
                required int nextQuestionMs,
                Value<double?> cachedPromptShare = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BenchmarkRunsCompanion.insert(
                id: id,
                modelName: modelName,
                backend: backend,
                readTokensPerSecond: readTokensPerSecond,
                writeTokensPerSecond: writeTokensPerSecond,
                firstQuestionMs: firstQuestionMs,
                nextQuestionMs: nextQuestionMs,
                cachedPromptShare: cachedPromptShare,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BenchmarkRunsTable, BenchmarkRun>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BenchmarkRunsTable,
                    BenchmarkRun
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BenchmarkRunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BenchmarkRunsTable,
      BenchmarkRun,
      $$BenchmarkRunsTableFilterComposer,
      $$BenchmarkRunsTableOrderingComposer,
      $$BenchmarkRunsTableAnnotationComposer,
      $$BenchmarkRunsTableCreateCompanionBuilder,
      $$BenchmarkRunsTableUpdateCompanionBuilder,
      (
        BenchmarkRun,
        BaseReferences<_$AppDatabase, $BenchmarkRunsTable, BenchmarkRun>,
      ),
      BenchmarkRun,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DocumentsTableTableManager get documents =>
      $$DocumentsTableTableManager(_db, _db.documents);
  $$SectionsTableTableManager get sections =>
      $$SectionsTableTableManager(_db, _db.sections);
  $$ChunksTableTableManager get chunks =>
      $$ChunksTableTableManager(_db, _db.chunks);
  $$FactsTableTableManager get facts =>
      $$FactsTableTableManager(_db, _db.facts);
  $$QuestionsTableTableManager get questions =>
      $$QuestionsTableTableManager(_db, _db.questions);
  $$QuestionSectionsTableTableManager get questionSections =>
      $$QuestionSectionsTableTableManager(_db, _db.questionSections);
  $$FactCardsTableTableManager get factCards =>
      $$FactCardsTableTableManager(_db, _db.factCards);
  $$ReviewsTableTableManager get reviews =>
      $$ReviewsTableTableManager(_db, _db.reviews);
  $$JobsTableTableManager get jobs => $$JobsTableTableManager(_db, _db.jobs);
  $$JobItemsTableTableManager get jobItems =>
      $$JobItemsTableTableManager(_db, _db.jobItems);
  $$LlmCacheEntriesTableTableManager get llmCacheEntries =>
      $$LlmCacheEntriesTableTableManager(_db, _db.llmCacheEntries);
  $$RejectionsTableTableManager get rejections =>
      $$RejectionsTableTableManager(_db, _db.rejections);
  $$ChatThreadsTableTableManager get chatThreads =>
      $$ChatThreadsTableTableManager(_db, _db.chatThreads);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$WebPagesTableTableManager get webPages =>
      $$WebPagesTableTableManager(_db, _db.webPages);
  $$WebLogEntriesTableTableManager get webLogEntries =>
      $$WebLogEntriesTableTableManager(_db, _db.webLogEntries);
  $$FactChecksTableTableManager get factChecks =>
      $$FactChecksTableTableManager(_db, _db.factChecks);
  $$BenchmarkRunsTableTableManager get benchmarkRuns =>
      $$BenchmarkRunsTableTableManager(_db, _db.benchmarkRuns);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
