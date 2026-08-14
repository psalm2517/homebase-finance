// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinHashMeta = const VerificationMeta(
    'pinHash',
  );
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
    'pin_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isAdminMeta = const VerificationMeta(
    'isAdmin',
  );
  @override
  late final GeneratedColumn<bool> isAdmin = GeneratedColumn<bool>(
    'is_admin',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_admin" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, pinHash, isAdmin];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('pin_hash')) {
      context.handle(
        _pinHashMeta,
        pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta),
      );
    }
    if (data.containsKey('is_admin')) {
      context.handle(
        _isAdminMeta,
        isAdmin.isAcceptableOrUnknown(data['is_admin']!, _isAdminMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      pinHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_hash'],
      ),
      isAdmin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_admin'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final int id;
  final String name;
  final String? pinHash;
  final bool isAdmin;
  const Profile({
    required this.id,
    required this.name,
    this.pinHash,
    required this.isAdmin,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || pinHash != null) {
      map['pin_hash'] = Variable<String>(pinHash);
    }
    map['is_admin'] = Variable<bool>(isAdmin);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      name: Value(name),
      pinHash: pinHash == null && nullToAbsent
          ? const Value.absent()
          : Value(pinHash),
      isAdmin: Value(isAdmin),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      pinHash: serializer.fromJson<String?>(json['pinHash']),
      isAdmin: serializer.fromJson<bool>(json['isAdmin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'pinHash': serializer.toJson<String?>(pinHash),
      'isAdmin': serializer.toJson<bool>(isAdmin),
    };
  }

  Profile copyWith({
    int? id,
    String? name,
    Value<String?> pinHash = const Value.absent(),
    bool? isAdmin,
  }) => Profile(
    id: id ?? this.id,
    name: name ?? this.name,
    pinHash: pinHash.present ? pinHash.value : this.pinHash,
    isAdmin: isAdmin ?? this.isAdmin,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      isAdmin: data.isAdmin.present ? data.isAdmin.value : this.isAdmin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('pinHash: $pinHash, ')
          ..write('isAdmin: $isAdmin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, pinHash, isAdmin);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.name == this.name &&
          other.pinHash == this.pinHash &&
          other.isAdmin == this.isAdmin);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> pinHash;
  final Value<bool> isAdmin;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.isAdmin = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.pinHash = const Value.absent(),
    this.isAdmin = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Profile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? pinHash,
    Expression<bool>? isAdmin,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (pinHash != null) 'pin_hash': pinHash,
      if (isAdmin != null) 'is_admin': isAdmin,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? pinHash,
    Value<bool>? isAdmin,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      pinHash: pinHash ?? this.pinHash,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (isAdmin.present) {
      map['is_admin'] = Variable<bool>(isAdmin.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('pinHash: $pinHash, ')
          ..write('isAdmin: $isAdmin')
          ..write(')'))
        .toString();
  }
}

class $CreditCardsTable extends CreditCards
    with TableInfo<$CreditCardsTable, CreditCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CreditCardsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceCentsMeta = const VerificationMeta(
    'balanceCents',
  );
  @override
  late final GeneratedColumn<int> balanceCents = GeneratedColumn<int>(
    'balance_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _creditLimitCentsMeta = const VerificationMeta(
    'creditLimitCents',
  );
  @override
  late final GeneratedColumn<int> creditLimitCents = GeneratedColumn<int>(
    'credit_limit_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aprMeta = const VerificationMeta('apr');
  @override
  late final GeneratedColumn<double> apr = GeneratedColumn<double>(
    'apr',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _annualFeeCentsMeta = const VerificationMeta(
    'annualFeeCents',
  );
  @override
  late final GeneratedColumn<int> annualFeeCents = GeneratedColumn<int>(
    'annual_fee_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _monthlyFeeCentsMeta = const VerificationMeta(
    'monthlyFeeCents',
  );
  @override
  late final GeneratedColumn<int> monthlyFeeCents = GeneratedColumn<int>(
    'monthly_fee_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    name,
    balanceCents,
    creditLimitCents,
    apr,
    annualFeeCents,
    monthlyFeeCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'credit_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<CreditCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('balance_cents')) {
      context.handle(
        _balanceCentsMeta,
        balanceCents.isAcceptableOrUnknown(
          data['balance_cents']!,
          _balanceCentsMeta,
        ),
      );
    }
    if (data.containsKey('credit_limit_cents')) {
      context.handle(
        _creditLimitCentsMeta,
        creditLimitCents.isAcceptableOrUnknown(
          data['credit_limit_cents']!,
          _creditLimitCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_creditLimitCentsMeta);
    }
    if (data.containsKey('apr')) {
      context.handle(
        _aprMeta,
        apr.isAcceptableOrUnknown(data['apr']!, _aprMeta),
      );
    }
    if (data.containsKey('annual_fee_cents')) {
      context.handle(
        _annualFeeCentsMeta,
        annualFeeCents.isAcceptableOrUnknown(
          data['annual_fee_cents']!,
          _annualFeeCentsMeta,
        ),
      );
    }
    if (data.containsKey('monthly_fee_cents')) {
      context.handle(
        _monthlyFeeCentsMeta,
        monthlyFeeCents.isAcceptableOrUnknown(
          data['monthly_fee_cents']!,
          _monthlyFeeCentsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CreditCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CreditCard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      balanceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance_cents'],
      )!,
      creditLimitCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credit_limit_cents'],
      )!,
      apr: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}apr'],
      )!,
      annualFeeCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}annual_fee_cents'],
      )!,
      monthlyFeeCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_fee_cents'],
      )!,
    );
  }

  @override
  $CreditCardsTable createAlias(String alias) {
    return $CreditCardsTable(attachedDatabase, alias);
  }
}

class CreditCard extends DataClass implements Insertable<CreditCard> {
  final int id;
  final int profileId;
  final String name;
  final int balanceCents;
  final int creditLimitCents;
  final double apr;
  final int annualFeeCents;
  final int monthlyFeeCents;
  const CreditCard({
    required this.id,
    required this.profileId,
    required this.name,
    required this.balanceCents,
    required this.creditLimitCents,
    required this.apr,
    required this.annualFeeCents,
    required this.monthlyFeeCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['name'] = Variable<String>(name);
    map['balance_cents'] = Variable<int>(balanceCents);
    map['credit_limit_cents'] = Variable<int>(creditLimitCents);
    map['apr'] = Variable<double>(apr);
    map['annual_fee_cents'] = Variable<int>(annualFeeCents);
    map['monthly_fee_cents'] = Variable<int>(monthlyFeeCents);
    return map;
  }

  CreditCardsCompanion toCompanion(bool nullToAbsent) {
    return CreditCardsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: Value(name),
      balanceCents: Value(balanceCents),
      creditLimitCents: Value(creditLimitCents),
      apr: Value(apr),
      annualFeeCents: Value(annualFeeCents),
      monthlyFeeCents: Value(monthlyFeeCents),
    );
  }

  factory CreditCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CreditCard(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      name: serializer.fromJson<String>(json['name']),
      balanceCents: serializer.fromJson<int>(json['balanceCents']),
      creditLimitCents: serializer.fromJson<int>(json['creditLimitCents']),
      apr: serializer.fromJson<double>(json['apr']),
      annualFeeCents: serializer.fromJson<int>(json['annualFeeCents']),
      monthlyFeeCents: serializer.fromJson<int>(json['monthlyFeeCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'name': serializer.toJson<String>(name),
      'balanceCents': serializer.toJson<int>(balanceCents),
      'creditLimitCents': serializer.toJson<int>(creditLimitCents),
      'apr': serializer.toJson<double>(apr),
      'annualFeeCents': serializer.toJson<int>(annualFeeCents),
      'monthlyFeeCents': serializer.toJson<int>(monthlyFeeCents),
    };
  }

  CreditCard copyWith({
    int? id,
    int? profileId,
    String? name,
    int? balanceCents,
    int? creditLimitCents,
    double? apr,
    int? annualFeeCents,
    int? monthlyFeeCents,
  }) => CreditCard(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    name: name ?? this.name,
    balanceCents: balanceCents ?? this.balanceCents,
    creditLimitCents: creditLimitCents ?? this.creditLimitCents,
    apr: apr ?? this.apr,
    annualFeeCents: annualFeeCents ?? this.annualFeeCents,
    monthlyFeeCents: monthlyFeeCents ?? this.monthlyFeeCents,
  );
  CreditCard copyWithCompanion(CreditCardsCompanion data) {
    return CreditCard(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      name: data.name.present ? data.name.value : this.name,
      balanceCents: data.balanceCents.present
          ? data.balanceCents.value
          : this.balanceCents,
      creditLimitCents: data.creditLimitCents.present
          ? data.creditLimitCents.value
          : this.creditLimitCents,
      apr: data.apr.present ? data.apr.value : this.apr,
      annualFeeCents: data.annualFeeCents.present
          ? data.annualFeeCents.value
          : this.annualFeeCents,
      monthlyFeeCents: data.monthlyFeeCents.present
          ? data.monthlyFeeCents.value
          : this.monthlyFeeCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CreditCard(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('balanceCents: $balanceCents, ')
          ..write('creditLimitCents: $creditLimitCents, ')
          ..write('apr: $apr, ')
          ..write('annualFeeCents: $annualFeeCents, ')
          ..write('monthlyFeeCents: $monthlyFeeCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    name,
    balanceCents,
    creditLimitCents,
    apr,
    annualFeeCents,
    monthlyFeeCents,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CreditCard &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.name == this.name &&
          other.balanceCents == this.balanceCents &&
          other.creditLimitCents == this.creditLimitCents &&
          other.apr == this.apr &&
          other.annualFeeCents == this.annualFeeCents &&
          other.monthlyFeeCents == this.monthlyFeeCents);
}

class CreditCardsCompanion extends UpdateCompanion<CreditCard> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> name;
  final Value<int> balanceCents;
  final Value<int> creditLimitCents;
  final Value<double> apr;
  final Value<int> annualFeeCents;
  final Value<int> monthlyFeeCents;
  const CreditCardsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.balanceCents = const Value.absent(),
    this.creditLimitCents = const Value.absent(),
    this.apr = const Value.absent(),
    this.annualFeeCents = const Value.absent(),
    this.monthlyFeeCents = const Value.absent(),
  });
  CreditCardsCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required String name,
    this.balanceCents = const Value.absent(),
    required int creditLimitCents,
    this.apr = const Value.absent(),
    this.annualFeeCents = const Value.absent(),
    this.monthlyFeeCents = const Value.absent(),
  }) : profileId = Value(profileId),
       name = Value(name),
       creditLimitCents = Value(creditLimitCents);
  static Insertable<CreditCard> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? name,
    Expression<int>? balanceCents,
    Expression<int>? creditLimitCents,
    Expression<double>? apr,
    Expression<int>? annualFeeCents,
    Expression<int>? monthlyFeeCents,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (balanceCents != null) 'balance_cents': balanceCents,
      if (creditLimitCents != null) 'credit_limit_cents': creditLimitCents,
      if (apr != null) 'apr': apr,
      if (annualFeeCents != null) 'annual_fee_cents': annualFeeCents,
      if (monthlyFeeCents != null) 'monthly_fee_cents': monthlyFeeCents,
    });
  }

  CreditCardsCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<String>? name,
    Value<int>? balanceCents,
    Value<int>? creditLimitCents,
    Value<double>? apr,
    Value<int>? annualFeeCents,
    Value<int>? monthlyFeeCents,
  }) {
    return CreditCardsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      balanceCents: balanceCents ?? this.balanceCents,
      creditLimitCents: creditLimitCents ?? this.creditLimitCents,
      apr: apr ?? this.apr,
      annualFeeCents: annualFeeCents ?? this.annualFeeCents,
      monthlyFeeCents: monthlyFeeCents ?? this.monthlyFeeCents,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (balanceCents.present) {
      map['balance_cents'] = Variable<int>(balanceCents.value);
    }
    if (creditLimitCents.present) {
      map['credit_limit_cents'] = Variable<int>(creditLimitCents.value);
    }
    if (apr.present) {
      map['apr'] = Variable<double>(apr.value);
    }
    if (annualFeeCents.present) {
      map['annual_fee_cents'] = Variable<int>(annualFeeCents.value);
    }
    if (monthlyFeeCents.present) {
      map['monthly_fee_cents'] = Variable<int>(monthlyFeeCents.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CreditCardsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('balanceCents: $balanceCents, ')
          ..write('creditLimitCents: $creditLimitCents, ')
          ..write('apr: $apr, ')
          ..write('annualFeeCents: $annualFeeCents, ')
          ..write('monthlyFeeCents: $monthlyFeeCents')
          ..write(')'))
        .toString();
  }
}

class $LoansTable extends Loans with TableInfo<$LoansTable, Loan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoansTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceCentsMeta = const VerificationMeta(
    'balanceCents',
  );
  @override
  late final GeneratedColumn<int> balanceCents = GeneratedColumn<int>(
    'balance_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalAmountCentsMeta =
      const VerificationMeta('originalAmountCents');
  @override
  late final GeneratedColumn<int> originalAmountCents = GeneratedColumn<int>(
    'original_amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aprMeta = const VerificationMeta('apr');
  @override
  late final GeneratedColumn<double> apr = GeneratedColumn<double>(
    'apr',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _monthlyPaymentCentsMeta =
      const VerificationMeta('monthlyPaymentCents');
  @override
  late final GeneratedColumn<int> monthlyPaymentCents = GeneratedColumn<int>(
    'monthly_payment_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    name,
    balanceCents,
    originalAmountCents,
    apr,
    monthlyPaymentCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loans';
  @override
  VerificationContext validateIntegrity(
    Insertable<Loan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('balance_cents')) {
      context.handle(
        _balanceCentsMeta,
        balanceCents.isAcceptableOrUnknown(
          data['balance_cents']!,
          _balanceCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_balanceCentsMeta);
    }
    if (data.containsKey('original_amount_cents')) {
      context.handle(
        _originalAmountCentsMeta,
        originalAmountCents.isAcceptableOrUnknown(
          data['original_amount_cents']!,
          _originalAmountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalAmountCentsMeta);
    }
    if (data.containsKey('apr')) {
      context.handle(
        _aprMeta,
        apr.isAcceptableOrUnknown(data['apr']!, _aprMeta),
      );
    }
    if (data.containsKey('monthly_payment_cents')) {
      context.handle(
        _monthlyPaymentCentsMeta,
        monthlyPaymentCents.isAcceptableOrUnknown(
          data['monthly_payment_cents']!,
          _monthlyPaymentCentsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Loan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Loan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      balanceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance_cents'],
      )!,
      originalAmountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_amount_cents'],
      )!,
      apr: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}apr'],
      )!,
      monthlyPaymentCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_payment_cents'],
      )!,
    );
  }

  @override
  $LoansTable createAlias(String alias) {
    return $LoansTable(attachedDatabase, alias);
  }
}

class Loan extends DataClass implements Insertable<Loan> {
  final int id;
  final int profileId;
  final String name;
  final int balanceCents;
  final int originalAmountCents;
  final double apr;
  final int monthlyPaymentCents;
  const Loan({
    required this.id,
    required this.profileId,
    required this.name,
    required this.balanceCents,
    required this.originalAmountCents,
    required this.apr,
    required this.monthlyPaymentCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['name'] = Variable<String>(name);
    map['balance_cents'] = Variable<int>(balanceCents);
    map['original_amount_cents'] = Variable<int>(originalAmountCents);
    map['apr'] = Variable<double>(apr);
    map['monthly_payment_cents'] = Variable<int>(monthlyPaymentCents);
    return map;
  }

  LoansCompanion toCompanion(bool nullToAbsent) {
    return LoansCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: Value(name),
      balanceCents: Value(balanceCents),
      originalAmountCents: Value(originalAmountCents),
      apr: Value(apr),
      monthlyPaymentCents: Value(monthlyPaymentCents),
    );
  }

  factory Loan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Loan(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      name: serializer.fromJson<String>(json['name']),
      balanceCents: serializer.fromJson<int>(json['balanceCents']),
      originalAmountCents: serializer.fromJson<int>(
        json['originalAmountCents'],
      ),
      apr: serializer.fromJson<double>(json['apr']),
      monthlyPaymentCents: serializer.fromJson<int>(
        json['monthlyPaymentCents'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'name': serializer.toJson<String>(name),
      'balanceCents': serializer.toJson<int>(balanceCents),
      'originalAmountCents': serializer.toJson<int>(originalAmountCents),
      'apr': serializer.toJson<double>(apr),
      'monthlyPaymentCents': serializer.toJson<int>(monthlyPaymentCents),
    };
  }

  Loan copyWith({
    int? id,
    int? profileId,
    String? name,
    int? balanceCents,
    int? originalAmountCents,
    double? apr,
    int? monthlyPaymentCents,
  }) => Loan(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    name: name ?? this.name,
    balanceCents: balanceCents ?? this.balanceCents,
    originalAmountCents: originalAmountCents ?? this.originalAmountCents,
    apr: apr ?? this.apr,
    monthlyPaymentCents: monthlyPaymentCents ?? this.monthlyPaymentCents,
  );
  Loan copyWithCompanion(LoansCompanion data) {
    return Loan(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      name: data.name.present ? data.name.value : this.name,
      balanceCents: data.balanceCents.present
          ? data.balanceCents.value
          : this.balanceCents,
      originalAmountCents: data.originalAmountCents.present
          ? data.originalAmountCents.value
          : this.originalAmountCents,
      apr: data.apr.present ? data.apr.value : this.apr,
      monthlyPaymentCents: data.monthlyPaymentCents.present
          ? data.monthlyPaymentCents.value
          : this.monthlyPaymentCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Loan(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('balanceCents: $balanceCents, ')
          ..write('originalAmountCents: $originalAmountCents, ')
          ..write('apr: $apr, ')
          ..write('monthlyPaymentCents: $monthlyPaymentCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    name,
    balanceCents,
    originalAmountCents,
    apr,
    monthlyPaymentCents,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Loan &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.name == this.name &&
          other.balanceCents == this.balanceCents &&
          other.originalAmountCents == this.originalAmountCents &&
          other.apr == this.apr &&
          other.monthlyPaymentCents == this.monthlyPaymentCents);
}

class LoansCompanion extends UpdateCompanion<Loan> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> name;
  final Value<int> balanceCents;
  final Value<int> originalAmountCents;
  final Value<double> apr;
  final Value<int> monthlyPaymentCents;
  const LoansCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.balanceCents = const Value.absent(),
    this.originalAmountCents = const Value.absent(),
    this.apr = const Value.absent(),
    this.monthlyPaymentCents = const Value.absent(),
  });
  LoansCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required String name,
    required int balanceCents,
    required int originalAmountCents,
    this.apr = const Value.absent(),
    this.monthlyPaymentCents = const Value.absent(),
  }) : profileId = Value(profileId),
       name = Value(name),
       balanceCents = Value(balanceCents),
       originalAmountCents = Value(originalAmountCents);
  static Insertable<Loan> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? name,
    Expression<int>? balanceCents,
    Expression<int>? originalAmountCents,
    Expression<double>? apr,
    Expression<int>? monthlyPaymentCents,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (balanceCents != null) 'balance_cents': balanceCents,
      if (originalAmountCents != null)
        'original_amount_cents': originalAmountCents,
      if (apr != null) 'apr': apr,
      if (monthlyPaymentCents != null)
        'monthly_payment_cents': monthlyPaymentCents,
    });
  }

  LoansCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<String>? name,
    Value<int>? balanceCents,
    Value<int>? originalAmountCents,
    Value<double>? apr,
    Value<int>? monthlyPaymentCents,
  }) {
    return LoansCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      balanceCents: balanceCents ?? this.balanceCents,
      originalAmountCents: originalAmountCents ?? this.originalAmountCents,
      apr: apr ?? this.apr,
      monthlyPaymentCents: monthlyPaymentCents ?? this.monthlyPaymentCents,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (balanceCents.present) {
      map['balance_cents'] = Variable<int>(balanceCents.value);
    }
    if (originalAmountCents.present) {
      map['original_amount_cents'] = Variable<int>(originalAmountCents.value);
    }
    if (apr.present) {
      map['apr'] = Variable<double>(apr.value);
    }
    if (monthlyPaymentCents.present) {
      map['monthly_payment_cents'] = Variable<int>(monthlyPaymentCents.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoansCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('balanceCents: $balanceCents, ')
          ..write('originalAmountCents: $originalAmountCents, ')
          ..write('apr: $apr, ')
          ..write('monthlyPaymentCents: $monthlyPaymentCents')
          ..write(')'))
        .toString();
  }
}

class $BillsTable extends Bills with TableInfo<$BillsTable, Bill> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BillsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDayMeta = const VerificationMeta('dueDay');
  @override
  late final GeneratedColumn<int> dueDay = GeneratedColumn<int>(
    'due_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recurringMeta = const VerificationMeta(
    'recurring',
  );
  @override
  late final GeneratedColumn<bool> recurring = GeneratedColumn<bool>(
    'recurring',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("recurring" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Other'),
  );
  static const VerificationMeta _paidThisMonthMeta = const VerificationMeta(
    'paidThisMonth',
  );
  @override
  late final GeneratedColumn<bool> paidThisMonth = GeneratedColumn<bool>(
    'paid_this_month',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("paid_this_month" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    name,
    amountCents,
    dueDay,
    recurring,
    category,
    paidThisMonth,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bills';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bill> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('due_day')) {
      context.handle(
        _dueDayMeta,
        dueDay.isAcceptableOrUnknown(data['due_day']!, _dueDayMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDayMeta);
    }
    if (data.containsKey('recurring')) {
      context.handle(
        _recurringMeta,
        recurring.isAcceptableOrUnknown(data['recurring']!, _recurringMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('paid_this_month')) {
      context.handle(
        _paidThisMonthMeta,
        paidThisMonth.isAcceptableOrUnknown(
          data['paid_this_month']!,
          _paidThisMonthMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bill map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bill(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      dueDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_day'],
      )!,
      recurring: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}recurring'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      paidThisMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}paid_this_month'],
      )!,
    );
  }

  @override
  $BillsTable createAlias(String alias) {
    return $BillsTable(attachedDatabase, alias);
  }
}

class Bill extends DataClass implements Insertable<Bill> {
  final int id;
  final int profileId;
  final String name;
  final int amountCents;
  final int dueDay;
  final bool recurring;
  final String category;
  final bool paidThisMonth;
  const Bill({
    required this.id,
    required this.profileId,
    required this.name,
    required this.amountCents,
    required this.dueDay,
    required this.recurring,
    required this.category,
    required this.paidThisMonth,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['name'] = Variable<String>(name);
    map['amount_cents'] = Variable<int>(amountCents);
    map['due_day'] = Variable<int>(dueDay);
    map['recurring'] = Variable<bool>(recurring);
    map['category'] = Variable<String>(category);
    map['paid_this_month'] = Variable<bool>(paidThisMonth);
    return map;
  }

  BillsCompanion toCompanion(bool nullToAbsent) {
    return BillsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: Value(name),
      amountCents: Value(amountCents),
      dueDay: Value(dueDay),
      recurring: Value(recurring),
      category: Value(category),
      paidThisMonth: Value(paidThisMonth),
    );
  }

  factory Bill.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bill(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      name: serializer.fromJson<String>(json['name']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      dueDay: serializer.fromJson<int>(json['dueDay']),
      recurring: serializer.fromJson<bool>(json['recurring']),
      category: serializer.fromJson<String>(json['category']),
      paidThisMonth: serializer.fromJson<bool>(json['paidThisMonth']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'name': serializer.toJson<String>(name),
      'amountCents': serializer.toJson<int>(amountCents),
      'dueDay': serializer.toJson<int>(dueDay),
      'recurring': serializer.toJson<bool>(recurring),
      'category': serializer.toJson<String>(category),
      'paidThisMonth': serializer.toJson<bool>(paidThisMonth),
    };
  }

  Bill copyWith({
    int? id,
    int? profileId,
    String? name,
    int? amountCents,
    int? dueDay,
    bool? recurring,
    String? category,
    bool? paidThisMonth,
  }) => Bill(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    name: name ?? this.name,
    amountCents: amountCents ?? this.amountCents,
    dueDay: dueDay ?? this.dueDay,
    recurring: recurring ?? this.recurring,
    category: category ?? this.category,
    paidThisMonth: paidThisMonth ?? this.paidThisMonth,
  );
  Bill copyWithCompanion(BillsCompanion data) {
    return Bill(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      name: data.name.present ? data.name.value : this.name,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      dueDay: data.dueDay.present ? data.dueDay.value : this.dueDay,
      recurring: data.recurring.present ? data.recurring.value : this.recurring,
      category: data.category.present ? data.category.value : this.category,
      paidThisMonth: data.paidThisMonth.present
          ? data.paidThisMonth.value
          : this.paidThisMonth,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bill(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('amountCents: $amountCents, ')
          ..write('dueDay: $dueDay, ')
          ..write('recurring: $recurring, ')
          ..write('category: $category, ')
          ..write('paidThisMonth: $paidThisMonth')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    name,
    amountCents,
    dueDay,
    recurring,
    category,
    paidThisMonth,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bill &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.name == this.name &&
          other.amountCents == this.amountCents &&
          other.dueDay == this.dueDay &&
          other.recurring == this.recurring &&
          other.category == this.category &&
          other.paidThisMonth == this.paidThisMonth);
}

class BillsCompanion extends UpdateCompanion<Bill> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> name;
  final Value<int> amountCents;
  final Value<int> dueDay;
  final Value<bool> recurring;
  final Value<String> category;
  final Value<bool> paidThisMonth;
  const BillsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.dueDay = const Value.absent(),
    this.recurring = const Value.absent(),
    this.category = const Value.absent(),
    this.paidThisMonth = const Value.absent(),
  });
  BillsCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required String name,
    required int amountCents,
    required int dueDay,
    this.recurring = const Value.absent(),
    this.category = const Value.absent(),
    this.paidThisMonth = const Value.absent(),
  }) : profileId = Value(profileId),
       name = Value(name),
       amountCents = Value(amountCents),
       dueDay = Value(dueDay);
  static Insertable<Bill> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? name,
    Expression<int>? amountCents,
    Expression<int>? dueDay,
    Expression<bool>? recurring,
    Expression<String>? category,
    Expression<bool>? paidThisMonth,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (amountCents != null) 'amount_cents': amountCents,
      if (dueDay != null) 'due_day': dueDay,
      if (recurring != null) 'recurring': recurring,
      if (category != null) 'category': category,
      if (paidThisMonth != null) 'paid_this_month': paidThisMonth,
    });
  }

  BillsCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<String>? name,
    Value<int>? amountCents,
    Value<int>? dueDay,
    Value<bool>? recurring,
    Value<String>? category,
    Value<bool>? paidThisMonth,
  }) {
    return BillsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      amountCents: amountCents ?? this.amountCents,
      dueDay: dueDay ?? this.dueDay,
      recurring: recurring ?? this.recurring,
      category: category ?? this.category,
      paidThisMonth: paidThisMonth ?? this.paidThisMonth,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (dueDay.present) {
      map['due_day'] = Variable<int>(dueDay.value);
    }
    if (recurring.present) {
      map['recurring'] = Variable<bool>(recurring.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (paidThisMonth.present) {
      map['paid_this_month'] = Variable<bool>(paidThisMonth.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BillsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('amountCents: $amountCents, ')
          ..write('dueDay: $dueDay, ')
          ..write('recurring: $recurring, ')
          ..write('category: $category, ')
          ..write('paidThisMonth: $paidThisMonth')
          ..write(')'))
        .toString();
  }
}

class $CreditScoreSnapshotsTable extends CreditScoreSnapshots
    with TableInfo<$CreditScoreSnapshotsTable, CreditScoreSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CreditScoreSnapshotsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _utilizationMeta = const VerificationMeta(
    'utilization',
  );
  @override
  late final GeneratedColumn<double> utilization = GeneratedColumn<double>(
    'utilization',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _derogatoryMarksMeta = const VerificationMeta(
    'derogatoryMarks',
  );
  @override
  late final GeneratedColumn<int> derogatoryMarks = GeneratedColumn<int>(
    'derogatory_marks',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _accountAgeMonthsMeta = const VerificationMeta(
    'accountAgeMonths',
  );
  @override
  late final GeneratedColumn<int> accountAgeMonths = GeneratedColumn<int>(
    'account_age_months',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hardInquiriesMeta = const VerificationMeta(
    'hardInquiries',
  );
  @override
  late final GeneratedColumn<int> hardInquiries = GeneratedColumn<int>(
    'hard_inquiries',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    date,
    score,
    utilization,
    derogatoryMarks,
    accountAgeMonths,
    hardInquiries,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'credit_score_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<CreditScoreSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('utilization')) {
      context.handle(
        _utilizationMeta,
        utilization.isAcceptableOrUnknown(
          data['utilization']!,
          _utilizationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_utilizationMeta);
    }
    if (data.containsKey('derogatory_marks')) {
      context.handle(
        _derogatoryMarksMeta,
        derogatoryMarks.isAcceptableOrUnknown(
          data['derogatory_marks']!,
          _derogatoryMarksMeta,
        ),
      );
    }
    if (data.containsKey('account_age_months')) {
      context.handle(
        _accountAgeMonthsMeta,
        accountAgeMonths.isAcceptableOrUnknown(
          data['account_age_months']!,
          _accountAgeMonthsMeta,
        ),
      );
    }
    if (data.containsKey('hard_inquiries')) {
      context.handle(
        _hardInquiriesMeta,
        hardInquiries.isAcceptableOrUnknown(
          data['hard_inquiries']!,
          _hardInquiriesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CreditScoreSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CreditScoreSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      utilization: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}utilization'],
      )!,
      derogatoryMarks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}derogatory_marks'],
      )!,
      accountAgeMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_age_months'],
      )!,
      hardInquiries: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hard_inquiries'],
      )!,
    );
  }

  @override
  $CreditScoreSnapshotsTable createAlias(String alias) {
    return $CreditScoreSnapshotsTable(attachedDatabase, alias);
  }
}

class CreditScoreSnapshot extends DataClass
    implements Insertable<CreditScoreSnapshot> {
  final int id;
  final int profileId;
  final DateTime date;
  final int score;
  final double utilization;
  final int derogatoryMarks;
  final int accountAgeMonths;
  final int hardInquiries;
  const CreditScoreSnapshot({
    required this.id,
    required this.profileId,
    required this.date,
    required this.score,
    required this.utilization,
    required this.derogatoryMarks,
    required this.accountAgeMonths,
    required this.hardInquiries,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['date'] = Variable<DateTime>(date);
    map['score'] = Variable<int>(score);
    map['utilization'] = Variable<double>(utilization);
    map['derogatory_marks'] = Variable<int>(derogatoryMarks);
    map['account_age_months'] = Variable<int>(accountAgeMonths);
    map['hard_inquiries'] = Variable<int>(hardInquiries);
    return map;
  }

  CreditScoreSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return CreditScoreSnapshotsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      date: Value(date),
      score: Value(score),
      utilization: Value(utilization),
      derogatoryMarks: Value(derogatoryMarks),
      accountAgeMonths: Value(accountAgeMonths),
      hardInquiries: Value(hardInquiries),
    );
  }

  factory CreditScoreSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CreditScoreSnapshot(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      date: serializer.fromJson<DateTime>(json['date']),
      score: serializer.fromJson<int>(json['score']),
      utilization: serializer.fromJson<double>(json['utilization']),
      derogatoryMarks: serializer.fromJson<int>(json['derogatoryMarks']),
      accountAgeMonths: serializer.fromJson<int>(json['accountAgeMonths']),
      hardInquiries: serializer.fromJson<int>(json['hardInquiries']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'date': serializer.toJson<DateTime>(date),
      'score': serializer.toJson<int>(score),
      'utilization': serializer.toJson<double>(utilization),
      'derogatoryMarks': serializer.toJson<int>(derogatoryMarks),
      'accountAgeMonths': serializer.toJson<int>(accountAgeMonths),
      'hardInquiries': serializer.toJson<int>(hardInquiries),
    };
  }

  CreditScoreSnapshot copyWith({
    int? id,
    int? profileId,
    DateTime? date,
    int? score,
    double? utilization,
    int? derogatoryMarks,
    int? accountAgeMonths,
    int? hardInquiries,
  }) => CreditScoreSnapshot(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    date: date ?? this.date,
    score: score ?? this.score,
    utilization: utilization ?? this.utilization,
    derogatoryMarks: derogatoryMarks ?? this.derogatoryMarks,
    accountAgeMonths: accountAgeMonths ?? this.accountAgeMonths,
    hardInquiries: hardInquiries ?? this.hardInquiries,
  );
  CreditScoreSnapshot copyWithCompanion(CreditScoreSnapshotsCompanion data) {
    return CreditScoreSnapshot(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      date: data.date.present ? data.date.value : this.date,
      score: data.score.present ? data.score.value : this.score,
      utilization: data.utilization.present
          ? data.utilization.value
          : this.utilization,
      derogatoryMarks: data.derogatoryMarks.present
          ? data.derogatoryMarks.value
          : this.derogatoryMarks,
      accountAgeMonths: data.accountAgeMonths.present
          ? data.accountAgeMonths.value
          : this.accountAgeMonths,
      hardInquiries: data.hardInquiries.present
          ? data.hardInquiries.value
          : this.hardInquiries,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CreditScoreSnapshot(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('date: $date, ')
          ..write('score: $score, ')
          ..write('utilization: $utilization, ')
          ..write('derogatoryMarks: $derogatoryMarks, ')
          ..write('accountAgeMonths: $accountAgeMonths, ')
          ..write('hardInquiries: $hardInquiries')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    date,
    score,
    utilization,
    derogatoryMarks,
    accountAgeMonths,
    hardInquiries,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CreditScoreSnapshot &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.date == this.date &&
          other.score == this.score &&
          other.utilization == this.utilization &&
          other.derogatoryMarks == this.derogatoryMarks &&
          other.accountAgeMonths == this.accountAgeMonths &&
          other.hardInquiries == this.hardInquiries);
}

class CreditScoreSnapshotsCompanion
    extends UpdateCompanion<CreditScoreSnapshot> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<DateTime> date;
  final Value<int> score;
  final Value<double> utilization;
  final Value<int> derogatoryMarks;
  final Value<int> accountAgeMonths;
  final Value<int> hardInquiries;
  const CreditScoreSnapshotsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.date = const Value.absent(),
    this.score = const Value.absent(),
    this.utilization = const Value.absent(),
    this.derogatoryMarks = const Value.absent(),
    this.accountAgeMonths = const Value.absent(),
    this.hardInquiries = const Value.absent(),
  });
  CreditScoreSnapshotsCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required DateTime date,
    required int score,
    required double utilization,
    this.derogatoryMarks = const Value.absent(),
    this.accountAgeMonths = const Value.absent(),
    this.hardInquiries = const Value.absent(),
  }) : profileId = Value(profileId),
       date = Value(date),
       score = Value(score),
       utilization = Value(utilization);
  static Insertable<CreditScoreSnapshot> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<DateTime>? date,
    Expression<int>? score,
    Expression<double>? utilization,
    Expression<int>? derogatoryMarks,
    Expression<int>? accountAgeMonths,
    Expression<int>? hardInquiries,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (date != null) 'date': date,
      if (score != null) 'score': score,
      if (utilization != null) 'utilization': utilization,
      if (derogatoryMarks != null) 'derogatory_marks': derogatoryMarks,
      if (accountAgeMonths != null) 'account_age_months': accountAgeMonths,
      if (hardInquiries != null) 'hard_inquiries': hardInquiries,
    });
  }

  CreditScoreSnapshotsCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<DateTime>? date,
    Value<int>? score,
    Value<double>? utilization,
    Value<int>? derogatoryMarks,
    Value<int>? accountAgeMonths,
    Value<int>? hardInquiries,
  }) {
    return CreditScoreSnapshotsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      date: date ?? this.date,
      score: score ?? this.score,
      utilization: utilization ?? this.utilization,
      derogatoryMarks: derogatoryMarks ?? this.derogatoryMarks,
      accountAgeMonths: accountAgeMonths ?? this.accountAgeMonths,
      hardInquiries: hardInquiries ?? this.hardInquiries,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (utilization.present) {
      map['utilization'] = Variable<double>(utilization.value);
    }
    if (derogatoryMarks.present) {
      map['derogatory_marks'] = Variable<int>(derogatoryMarks.value);
    }
    if (accountAgeMonths.present) {
      map['account_age_months'] = Variable<int>(accountAgeMonths.value);
    }
    if (hardInquiries.present) {
      map['hard_inquiries'] = Variable<int>(hardInquiries.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CreditScoreSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('date: $date, ')
          ..write('score: $score, ')
          ..write('utilization: $utilization, ')
          ..write('derogatoryMarks: $derogatoryMarks, ')
          ..write('accountAgeMonths: $accountAgeMonths, ')
          ..write('hardInquiries: $hardInquiries')
          ..write(')'))
        .toString();
  }
}

class $BudgetEntriesTable extends BudgetEntries
    with TableInfo<$BudgetEntriesTable, BudgetEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Other'),
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<EntryType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<EntryType>($BudgetEntriesTable.$convertertype);
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    date,
    category,
    amountCents,
    type,
    description,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      type: $BudgetEntriesTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
    );
  }

  @override
  $BudgetEntriesTable createAlias(String alias) {
    return $BudgetEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EntryType, String, String> $convertertype =
      const EnumNameConverter<EntryType>(EntryType.values);
}

class BudgetEntry extends DataClass implements Insertable<BudgetEntry> {
  final int id;
  final int profileId;
  final DateTime date;
  final String category;
  final int amountCents;
  final EntryType type;
  final String? description;
  const BudgetEntry({
    required this.id,
    required this.profileId,
    required this.date,
    required this.category,
    required this.amountCents,
    required this.type,
    this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['date'] = Variable<DateTime>(date);
    map['category'] = Variable<String>(category);
    map['amount_cents'] = Variable<int>(amountCents);
    {
      map['type'] = Variable<String>(
        $BudgetEntriesTable.$convertertype.toSql(type),
      );
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    return map;
  }

  BudgetEntriesCompanion toCompanion(bool nullToAbsent) {
    return BudgetEntriesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      date: Value(date),
      category: Value(category),
      amountCents: Value(amountCents),
      type: Value(type),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
    );
  }

  factory BudgetEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetEntry(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      date: serializer.fromJson<DateTime>(json['date']),
      category: serializer.fromJson<String>(json['category']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      type: $BudgetEntriesTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      description: serializer.fromJson<String?>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'date': serializer.toJson<DateTime>(date),
      'category': serializer.toJson<String>(category),
      'amountCents': serializer.toJson<int>(amountCents),
      'type': serializer.toJson<String>(
        $BudgetEntriesTable.$convertertype.toJson(type),
      ),
      'description': serializer.toJson<String?>(description),
    };
  }

  BudgetEntry copyWith({
    int? id,
    int? profileId,
    DateTime? date,
    String? category,
    int? amountCents,
    EntryType? type,
    Value<String?> description = const Value.absent(),
  }) => BudgetEntry(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    date: date ?? this.date,
    category: category ?? this.category,
    amountCents: amountCents ?? this.amountCents,
    type: type ?? this.type,
    description: description.present ? description.value : this.description,
  );
  BudgetEntry copyWithCompanion(BudgetEntriesCompanion data) {
    return BudgetEntry(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      date: data.date.present ? data.date.value : this.date,
      category: data.category.present ? data.category.value : this.category,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      type: data.type.present ? data.type.value : this.type,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetEntry(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('date: $date, ')
          ..write('category: $category, ')
          ..write('amountCents: $amountCents, ')
          ..write('type: $type, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    date,
    category,
    amountCents,
    type,
    description,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetEntry &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.date == this.date &&
          other.category == this.category &&
          other.amountCents == this.amountCents &&
          other.type == this.type &&
          other.description == this.description);
}

class BudgetEntriesCompanion extends UpdateCompanion<BudgetEntry> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<DateTime> date;
  final Value<String> category;
  final Value<int> amountCents;
  final Value<EntryType> type;
  final Value<String?> description;
  const BudgetEntriesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.date = const Value.absent(),
    this.category = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.type = const Value.absent(),
    this.description = const Value.absent(),
  });
  BudgetEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required DateTime date,
    this.category = const Value.absent(),
    required int amountCents,
    required EntryType type,
    this.description = const Value.absent(),
  }) : profileId = Value(profileId),
       date = Value(date),
       amountCents = Value(amountCents),
       type = Value(type);
  static Insertable<BudgetEntry> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<DateTime>? date,
    Expression<String>? category,
    Expression<int>? amountCents,
    Expression<String>? type,
    Expression<String>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (date != null) 'date': date,
      if (category != null) 'category': category,
      if (amountCents != null) 'amount_cents': amountCents,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
    });
  }

  BudgetEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<DateTime>? date,
    Value<String>? category,
    Value<int>? amountCents,
    Value<EntryType>? type,
    Value<String?>? description,
  }) {
    return BudgetEntriesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      date: date ?? this.date,
      category: category ?? this.category,
      amountCents: amountCents ?? this.amountCents,
      type: type ?? this.type,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $BudgetEntriesTable.$convertertype.toSql(type.value),
      );
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetEntriesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('date: $date, ')
          ..write('category: $category, ')
          ..write('amountCents: $amountCents, ')
          ..write('type: $type, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }
}

class $BudgetTargetsTable extends BudgetTargets
    with TableInfo<$BudgetTargetsTable, BudgetTarget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetTargetsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthlyTargetCentsMeta =
      const VerificationMeta('monthlyTargetCents');
  @override
  late final GeneratedColumn<int> monthlyTargetCents = GeneratedColumn<int>(
    'monthly_target_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    category,
    monthlyTargetCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_targets';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetTarget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('monthly_target_cents')) {
      context.handle(
        _monthlyTargetCentsMeta,
        monthlyTargetCents.isAcceptableOrUnknown(
          data['monthly_target_cents']!,
          _monthlyTargetCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monthlyTargetCentsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {profileId, category},
  ];
  @override
  BudgetTarget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetTarget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      monthlyTargetCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_target_cents'],
      )!,
    );
  }

  @override
  $BudgetTargetsTable createAlias(String alias) {
    return $BudgetTargetsTable(attachedDatabase, alias);
  }
}

class BudgetTarget extends DataClass implements Insertable<BudgetTarget> {
  final int id;
  final int profileId;
  final String category;
  final int monthlyTargetCents;
  const BudgetTarget({
    required this.id,
    required this.profileId,
    required this.category,
    required this.monthlyTargetCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['category'] = Variable<String>(category);
    map['monthly_target_cents'] = Variable<int>(monthlyTargetCents);
    return map;
  }

  BudgetTargetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetTargetsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      category: Value(category),
      monthlyTargetCents: Value(monthlyTargetCents),
    );
  }

  factory BudgetTarget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetTarget(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      category: serializer.fromJson<String>(json['category']),
      monthlyTargetCents: serializer.fromJson<int>(json['monthlyTargetCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'category': serializer.toJson<String>(category),
      'monthlyTargetCents': serializer.toJson<int>(monthlyTargetCents),
    };
  }

  BudgetTarget copyWith({
    int? id,
    int? profileId,
    String? category,
    int? monthlyTargetCents,
  }) => BudgetTarget(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    category: category ?? this.category,
    monthlyTargetCents: monthlyTargetCents ?? this.monthlyTargetCents,
  );
  BudgetTarget copyWithCompanion(BudgetTargetsCompanion data) {
    return BudgetTarget(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      category: data.category.present ? data.category.value : this.category,
      monthlyTargetCents: data.monthlyTargetCents.present
          ? data.monthlyTargetCents.value
          : this.monthlyTargetCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetTarget(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('category: $category, ')
          ..write('monthlyTargetCents: $monthlyTargetCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, category, monthlyTargetCents);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetTarget &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.category == this.category &&
          other.monthlyTargetCents == this.monthlyTargetCents);
}

class BudgetTargetsCompanion extends UpdateCompanion<BudgetTarget> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> category;
  final Value<int> monthlyTargetCents;
  const BudgetTargetsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.category = const Value.absent(),
    this.monthlyTargetCents = const Value.absent(),
  });
  BudgetTargetsCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required String category,
    required int monthlyTargetCents,
  }) : profileId = Value(profileId),
       category = Value(category),
       monthlyTargetCents = Value(monthlyTargetCents);
  static Insertable<BudgetTarget> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? category,
    Expression<int>? monthlyTargetCents,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (category != null) 'category': category,
      if (monthlyTargetCents != null)
        'monthly_target_cents': monthlyTargetCents,
    });
  }

  BudgetTargetsCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<String>? category,
    Value<int>? monthlyTargetCents,
  }) {
    return BudgetTargetsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      category: category ?? this.category,
      monthlyTargetCents: monthlyTargetCents ?? this.monthlyTargetCents,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (monthlyTargetCents.present) {
      map['monthly_target_cents'] = Variable<int>(monthlyTargetCents.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetTargetsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('category: $category, ')
          ..write('monthlyTargetCents: $monthlyTargetCents')
          ..write(')'))
        .toString();
  }
}

class $CategoryRulesTable extends CategoryRules
    with TableInfo<$CategoryRulesTable, CategoryRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryRulesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<RuleField, String> field =
      GeneratedColumn<String>(
        'field',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RuleField>($CategoryRulesTable.$converterfield);
  static const VerificationMeta _patternMeta = const VerificationMeta(
    'pattern',
  );
  @override
  late final GeneratedColumn<String> pattern = GeneratedColumn<String>(
    'pattern',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 128,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    field,
    pattern,
    category,
    priority,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('pattern')) {
      context.handle(
        _patternMeta,
        pattern.isAcceptableOrUnknown(data['pattern']!, _patternMeta),
      );
    } else if (isInserting) {
      context.missing(_patternMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      field: $CategoryRulesTable.$converterfield.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}field'],
        )!,
      ),
      pattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pattern'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
    );
  }

  @override
  $CategoryRulesTable createAlias(String alias) {
    return $CategoryRulesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RuleField, String, String> $converterfield =
      const EnumNameConverter<RuleField>(RuleField.values);
}

class CategoryRule extends DataClass implements Insertable<CategoryRule> {
  final int id;
  final int profileId;
  final RuleField field;
  final String pattern;
  final String category;
  final int priority;
  const CategoryRule({
    required this.id,
    required this.profileId,
    required this.field,
    required this.pattern,
    required this.category,
    required this.priority,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    {
      map['field'] = Variable<String>(
        $CategoryRulesTable.$converterfield.toSql(field),
      );
    }
    map['pattern'] = Variable<String>(pattern);
    map['category'] = Variable<String>(category);
    map['priority'] = Variable<int>(priority);
    return map;
  }

  CategoryRulesCompanion toCompanion(bool nullToAbsent) {
    return CategoryRulesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      field: Value(field),
      pattern: Value(pattern),
      category: Value(category),
      priority: Value(priority),
    );
  }

  factory CategoryRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRule(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      field: $CategoryRulesTable.$converterfield.fromJson(
        serializer.fromJson<String>(json['field']),
      ),
      pattern: serializer.fromJson<String>(json['pattern']),
      category: serializer.fromJson<String>(json['category']),
      priority: serializer.fromJson<int>(json['priority']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'field': serializer.toJson<String>(
        $CategoryRulesTable.$converterfield.toJson(field),
      ),
      'pattern': serializer.toJson<String>(pattern),
      'category': serializer.toJson<String>(category),
      'priority': serializer.toJson<int>(priority),
    };
  }

  CategoryRule copyWith({
    int? id,
    int? profileId,
    RuleField? field,
    String? pattern,
    String? category,
    int? priority,
  }) => CategoryRule(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    field: field ?? this.field,
    pattern: pattern ?? this.pattern,
    category: category ?? this.category,
    priority: priority ?? this.priority,
  );
  CategoryRule copyWithCompanion(CategoryRulesCompanion data) {
    return CategoryRule(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      field: data.field.present ? data.field.value : this.field,
      pattern: data.pattern.present ? data.pattern.value : this.pattern,
      category: data.category.present ? data.category.value : this.category,
      priority: data.priority.present ? data.priority.value : this.priority,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRule(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('field: $field, ')
          ..write('pattern: $pattern, ')
          ..write('category: $category, ')
          ..write('priority: $priority')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, profileId, field, pattern, category, priority);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRule &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.field == this.field &&
          other.pattern == this.pattern &&
          other.category == this.category &&
          other.priority == this.priority);
}

class CategoryRulesCompanion extends UpdateCompanion<CategoryRule> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<RuleField> field;
  final Value<String> pattern;
  final Value<String> category;
  final Value<int> priority;
  const CategoryRulesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.field = const Value.absent(),
    this.pattern = const Value.absent(),
    this.category = const Value.absent(),
    this.priority = const Value.absent(),
  });
  CategoryRulesCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required RuleField field,
    required String pattern,
    required String category,
    this.priority = const Value.absent(),
  }) : profileId = Value(profileId),
       field = Value(field),
       pattern = Value(pattern),
       category = Value(category);
  static Insertable<CategoryRule> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? field,
    Expression<String>? pattern,
    Expression<String>? category,
    Expression<int>? priority,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (field != null) 'field': field,
      if (pattern != null) 'pattern': pattern,
      if (category != null) 'category': category,
      if (priority != null) 'priority': priority,
    });
  }

  CategoryRulesCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<RuleField>? field,
    Value<String>? pattern,
    Value<String>? category,
    Value<int>? priority,
  }) {
    return CategoryRulesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      field: field ?? this.field,
      pattern: pattern ?? this.pattern,
      category: category ?? this.category,
      priority: priority ?? this.priority,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(
        $CategoryRulesTable.$converterfield.toSql(field.value),
      );
    }
    if (pattern.present) {
      map['pattern'] = Variable<String>(pattern.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRulesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('field: $field, ')
          ..write('pattern: $pattern, ')
          ..write('category: $category, ')
          ..write('priority: $priority')
          ..write(')'))
        .toString();
  }
}

class $PaychecksTable extends Paychecks
    with TableInfo<$PaychecksTable, Paycheck> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaychecksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedMeta = const VerificationMeta(
    'received',
  );
  @override
  late final GeneratedColumn<bool> received = GeneratedColumn<bool>(
    'received',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("received" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    name,
    date,
    amountCents,
    received,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'paychecks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Paycheck> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('received')) {
      context.handle(
        _receivedMeta,
        received.isAcceptableOrUnknown(data['received']!, _receivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Paycheck map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Paycheck(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      received: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}received'],
      )!,
    );
  }

  @override
  $PaychecksTable createAlias(String alias) {
    return $PaychecksTable(attachedDatabase, alias);
  }
}

class Paycheck extends DataClass implements Insertable<Paycheck> {
  final int id;
  final int profileId;
  final String name;
  final DateTime date;
  final int amountCents;
  final bool received;
  const Paycheck({
    required this.id,
    required this.profileId,
    required this.name,
    required this.date,
    required this.amountCents,
    required this.received,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['name'] = Variable<String>(name);
    map['date'] = Variable<DateTime>(date);
    map['amount_cents'] = Variable<int>(amountCents);
    map['received'] = Variable<bool>(received);
    return map;
  }

  PaychecksCompanion toCompanion(bool nullToAbsent) {
    return PaychecksCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: Value(name),
      date: Value(date),
      amountCents: Value(amountCents),
      received: Value(received),
    );
  }

  factory Paycheck.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Paycheck(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      name: serializer.fromJson<String>(json['name']),
      date: serializer.fromJson<DateTime>(json['date']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      received: serializer.fromJson<bool>(json['received']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'name': serializer.toJson<String>(name),
      'date': serializer.toJson<DateTime>(date),
      'amountCents': serializer.toJson<int>(amountCents),
      'received': serializer.toJson<bool>(received),
    };
  }

  Paycheck copyWith({
    int? id,
    int? profileId,
    String? name,
    DateTime? date,
    int? amountCents,
    bool? received,
  }) => Paycheck(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    name: name ?? this.name,
    date: date ?? this.date,
    amountCents: amountCents ?? this.amountCents,
    received: received ?? this.received,
  );
  Paycheck copyWithCompanion(PaychecksCompanion data) {
    return Paycheck(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      name: data.name.present ? data.name.value : this.name,
      date: data.date.present ? data.date.value : this.date,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      received: data.received.present ? data.received.value : this.received,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Paycheck(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('date: $date, ')
          ..write('amountCents: $amountCents, ')
          ..write('received: $received')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, profileId, name, date, amountCents, received);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Paycheck &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.name == this.name &&
          other.date == this.date &&
          other.amountCents == this.amountCents &&
          other.received == this.received);
}

class PaychecksCompanion extends UpdateCompanion<Paycheck> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> name;
  final Value<DateTime> date;
  final Value<int> amountCents;
  final Value<bool> received;
  const PaychecksCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.date = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.received = const Value.absent(),
  });
  PaychecksCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required String name,
    required DateTime date,
    required int amountCents,
    this.received = const Value.absent(),
  }) : profileId = Value(profileId),
       name = Value(name),
       date = Value(date),
       amountCents = Value(amountCents);
  static Insertable<Paycheck> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? name,
    Expression<DateTime>? date,
    Expression<int>? amountCents,
    Expression<bool>? received,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (date != null) 'date': date,
      if (amountCents != null) 'amount_cents': amountCents,
      if (received != null) 'received': received,
    });
  }

  PaychecksCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<String>? name,
    Value<DateTime>? date,
    Value<int>? amountCents,
    Value<bool>? received,
  }) {
    return PaychecksCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      date: date ?? this.date,
      amountCents: amountCents ?? this.amountCents,
      received: received ?? this.received,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (received.present) {
      map['received'] = Variable<bool>(received.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaychecksCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('date: $date, ')
          ..write('amountCents: $amountCents, ')
          ..write('received: $received')
          ..write(')'))
        .toString();
  }
}

class $PaycheckAllocationsTable extends PaycheckAllocations
    with TableInfo<$PaycheckAllocationsTable, PaycheckAllocation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaycheckAllocationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
  );
  static const VerificationMeta _paycheckIdMeta = const VerificationMeta(
    'paycheckId',
  );
  @override
  late final GeneratedColumn<int> paycheckId = GeneratedColumn<int>(
    'paycheck_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES paychecks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<String> target = GeneratedColumn<String>(
    'target',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _billIdMeta = const VerificationMeta('billId');
  @override
  late final GeneratedColumn<int> billId = GeneratedColumn<int>(
    'bill_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bills (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    paycheckId,
    target,
    amountCents,
    billId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'paycheck_allocations';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaycheckAllocation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('paycheck_id')) {
      context.handle(
        _paycheckIdMeta,
        paycheckId.isAcceptableOrUnknown(data['paycheck_id']!, _paycheckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_paycheckIdMeta);
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('bill_id')) {
      context.handle(
        _billIdMeta,
        billId.isAcceptableOrUnknown(data['bill_id']!, _billIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaycheckAllocation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaycheckAllocation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      paycheckId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paycheck_id'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      billId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bill_id'],
      ),
    );
  }

  @override
  $PaycheckAllocationsTable createAlias(String alias) {
    return $PaycheckAllocationsTable(attachedDatabase, alias);
  }
}

class PaycheckAllocation extends DataClass
    implements Insertable<PaycheckAllocation> {
  final int id;
  final int profileId;
  final int paycheckId;
  final String target;
  final int amountCents;
  final int? billId;
  const PaycheckAllocation({
    required this.id,
    required this.profileId,
    required this.paycheckId,
    required this.target,
    required this.amountCents,
    this.billId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['paycheck_id'] = Variable<int>(paycheckId);
    map['target'] = Variable<String>(target);
    map['amount_cents'] = Variable<int>(amountCents);
    if (!nullToAbsent || billId != null) {
      map['bill_id'] = Variable<int>(billId);
    }
    return map;
  }

  PaycheckAllocationsCompanion toCompanion(bool nullToAbsent) {
    return PaycheckAllocationsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      paycheckId: Value(paycheckId),
      target: Value(target),
      amountCents: Value(amountCents),
      billId: billId == null && nullToAbsent
          ? const Value.absent()
          : Value(billId),
    );
  }

  factory PaycheckAllocation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaycheckAllocation(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      paycheckId: serializer.fromJson<int>(json['paycheckId']),
      target: serializer.fromJson<String>(json['target']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      billId: serializer.fromJson<int?>(json['billId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'paycheckId': serializer.toJson<int>(paycheckId),
      'target': serializer.toJson<String>(target),
      'amountCents': serializer.toJson<int>(amountCents),
      'billId': serializer.toJson<int?>(billId),
    };
  }

  PaycheckAllocation copyWith({
    int? id,
    int? profileId,
    int? paycheckId,
    String? target,
    int? amountCents,
    Value<int?> billId = const Value.absent(),
  }) => PaycheckAllocation(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    paycheckId: paycheckId ?? this.paycheckId,
    target: target ?? this.target,
    amountCents: amountCents ?? this.amountCents,
    billId: billId.present ? billId.value : this.billId,
  );
  PaycheckAllocation copyWithCompanion(PaycheckAllocationsCompanion data) {
    return PaycheckAllocation(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      paycheckId: data.paycheckId.present
          ? data.paycheckId.value
          : this.paycheckId,
      target: data.target.present ? data.target.value : this.target,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      billId: data.billId.present ? data.billId.value : this.billId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaycheckAllocation(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('paycheckId: $paycheckId, ')
          ..write('target: $target, ')
          ..write('amountCents: $amountCents, ')
          ..write('billId: $billId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, profileId, paycheckId, target, amountCents, billId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaycheckAllocation &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.paycheckId == this.paycheckId &&
          other.target == this.target &&
          other.amountCents == this.amountCents &&
          other.billId == this.billId);
}

class PaycheckAllocationsCompanion extends UpdateCompanion<PaycheckAllocation> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<int> paycheckId;
  final Value<String> target;
  final Value<int> amountCents;
  final Value<int?> billId;
  const PaycheckAllocationsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.paycheckId = const Value.absent(),
    this.target = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.billId = const Value.absent(),
  });
  PaycheckAllocationsCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required int paycheckId,
    required String target,
    required int amountCents,
    this.billId = const Value.absent(),
  }) : profileId = Value(profileId),
       paycheckId = Value(paycheckId),
       target = Value(target),
       amountCents = Value(amountCents);
  static Insertable<PaycheckAllocation> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<int>? paycheckId,
    Expression<String>? target,
    Expression<int>? amountCents,
    Expression<int>? billId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (paycheckId != null) 'paycheck_id': paycheckId,
      if (target != null) 'target': target,
      if (amountCents != null) 'amount_cents': amountCents,
      if (billId != null) 'bill_id': billId,
    });
  }

  PaycheckAllocationsCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<int>? paycheckId,
    Value<String>? target,
    Value<int>? amountCents,
    Value<int?>? billId,
  }) {
    return PaycheckAllocationsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      paycheckId: paycheckId ?? this.paycheckId,
      target: target ?? this.target,
      amountCents: amountCents ?? this.amountCents,
      billId: billId ?? this.billId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (paycheckId.present) {
      map['paycheck_id'] = Variable<int>(paycheckId.value);
    }
    if (target.present) {
      map['target'] = Variable<String>(target.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (billId.present) {
      map['bill_id'] = Variable<int>(billId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaycheckAllocationsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('paycheckId: $paycheckId, ')
          ..write('target: $target, ')
          ..write('amountCents: $amountCents, ')
          ..write('billId: $billId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $CreditCardsTable creditCards = $CreditCardsTable(this);
  late final $LoansTable loans = $LoansTable(this);
  late final $BillsTable bills = $BillsTable(this);
  late final $CreditScoreSnapshotsTable creditScoreSnapshots =
      $CreditScoreSnapshotsTable(this);
  late final $BudgetEntriesTable budgetEntries = $BudgetEntriesTable(this);
  late final $BudgetTargetsTable budgetTargets = $BudgetTargetsTable(this);
  late final $CategoryRulesTable categoryRules = $CategoryRulesTable(this);
  late final $PaychecksTable paychecks = $PaychecksTable(this);
  late final $PaycheckAllocationsTable paycheckAllocations =
      $PaycheckAllocationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    creditCards,
    loans,
    bills,
    creditScoreSnapshots,
    budgetEntries,
    budgetTargets,
    categoryRules,
    paychecks,
    paycheckAllocations,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'paychecks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('paycheck_allocations', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> pinHash,
  Value<bool> isAdmin,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> pinHash,
  Value<bool> isAdmin,
});

final class $$ProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $ProfilesTable, Profile> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CreditCardsTable, List<CreditCard>>
  _creditCardsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.creditCards,
    aliasName: 'profiles__id__credit_cards__profile_id',
  );

  $$CreditCardsTableProcessedTableManager get creditCardsRefs {
    final manager = $$CreditCardsTableTableManager(
      $_db,
      $_db.creditCards,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_creditCardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LoansTable, List<Loan>> _loansRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.loans,
    aliasName: 'profiles__id__loans__profile_id',
  );

  $$LoansTableProcessedTableManager get loansRefs {
    final manager = $$LoansTableTableManager(
      $_db,
      $_db.loans,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_loansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BillsTable, List<Bill>> _billsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.bills,
    aliasName: 'profiles__id__bills__profile_id',
  );

  $$BillsTableProcessedTableManager get billsRefs {
    final manager = $$BillsTableTableManager(
      $_db,
      $_db.bills,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_billsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CreditScoreSnapshotsTable,
    List<CreditScoreSnapshot>
  >
  _creditScoreSnapshotsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.creditScoreSnapshots,
        aliasName: 'profiles__id__credit_score_snapshots__profile_id',
      );

  $$CreditScoreSnapshotsTableProcessedTableManager
  get creditScoreSnapshotsRefs {
    final manager = $$CreditScoreSnapshotsTableTableManager(
      $_db,
      $_db.creditScoreSnapshots,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _creditScoreSnapshotsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BudgetEntriesTable, List<BudgetEntry>>
  _budgetEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.budgetEntries,
    aliasName: 'profiles__id__budget_entries__profile_id',
  );

  $$BudgetEntriesTableProcessedTableManager get budgetEntriesRefs {
    final manager = $$BudgetEntriesTableTableManager(
      $_db,
      $_db.budgetEntries,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_budgetEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BudgetTargetsTable, List<BudgetTarget>>
  _budgetTargetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.budgetTargets,
    aliasName: 'profiles__id__budget_targets__profile_id',
  );

  $$BudgetTargetsTableProcessedTableManager get budgetTargetsRefs {
    final manager = $$BudgetTargetsTableTableManager(
      $_db,
      $_db.budgetTargets,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_budgetTargetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CategoryRulesTable, List<CategoryRule>>
  _categoryRulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.categoryRules,
    aliasName: 'profiles__id__category_rules__profile_id',
  );

  $$CategoryRulesTableProcessedTableManager get categoryRulesRefs {
    final manager = $$CategoryRulesTableTableManager(
      $_db,
      $_db.categoryRules,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_categoryRulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PaychecksTable, List<Paycheck>>
  _paychecksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.paychecks,
    aliasName: 'profiles__id__paychecks__profile_id',
  );

  $$PaychecksTableProcessedTableManager get paychecksRefs {
    final manager = $$PaychecksTableTableManager(
      $_db,
      $_db.paychecks,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_paychecksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PaycheckAllocationsTable,
    List<PaycheckAllocation>
  >
  _paycheckAllocationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.paycheckAllocations,
        aliasName: 'profiles__id__paycheck_allocations__profile_id',
      );

  $$PaycheckAllocationsTableProcessedTableManager get paycheckAllocationsRefs {
    final manager = $$PaycheckAllocationsTableTableManager(
      $_db,
      $_db.paycheckAllocations,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _paycheckAllocationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAdmin => $composableBuilder(
    column: $table.isAdmin,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> creditCardsRefs(
    Expression<bool> Function($$CreditCardsTableFilterComposer f) f,
  ) {
    final $$CreditCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.creditCards,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditCardsTableFilterComposer(
            $db: $db,
            $table: $db.creditCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> loansRefs(
    Expression<bool> Function($$LoansTableFilterComposer f) f,
  ) {
    final $$LoansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loans,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoansTableFilterComposer(
            $db: $db,
            $table: $db.loans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> billsRefs(
    Expression<bool> Function($$BillsTableFilterComposer f) f,
  ) {
    final $$BillsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableFilterComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> creditScoreSnapshotsRefs(
    Expression<bool> Function($$CreditScoreSnapshotsTableFilterComposer f) f,
  ) {
    final $$CreditScoreSnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.creditScoreSnapshots,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditScoreSnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.creditScoreSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> budgetEntriesRefs(
    Expression<bool> Function($$BudgetEntriesTableFilterComposer f) f,
  ) {
    final $$BudgetEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgetEntries,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetEntriesTableFilterComposer(
            $db: $db,
            $table: $db.budgetEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> budgetTargetsRefs(
    Expression<bool> Function($$BudgetTargetsTableFilterComposer f) f,
  ) {
    final $$BudgetTargetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgetTargets,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetTargetsTableFilterComposer(
            $db: $db,
            $table: $db.budgetTargets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> categoryRulesRefs(
    Expression<bool> Function($$CategoryRulesTableFilterComposer f) f,
  ) {
    final $$CategoryRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.categoryRules,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryRulesTableFilterComposer(
            $db: $db,
            $table: $db.categoryRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paychecksRefs(
    Expression<bool> Function($$PaychecksTableFilterComposer f) f,
  ) {
    final $$PaychecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paychecks,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaychecksTableFilterComposer(
            $db: $db,
            $table: $db.paychecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paycheckAllocationsRefs(
    Expression<bool> Function($$PaycheckAllocationsTableFilterComposer f) f,
  ) {
    final $$PaycheckAllocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paycheckAllocations,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaycheckAllocationsTableFilterComposer(
            $db: $db,
            $table: $db.paycheckAllocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAdmin => $composableBuilder(
    column: $table.isAdmin,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumn<bool> get isAdmin =>
      $composableBuilder(column: $table.isAdmin, builder: (column) => column);

  Expression<T> creditCardsRefs<T extends Object>(
    Expression<T> Function($$CreditCardsTableAnnotationComposer a) f,
  ) {
    final $$CreditCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.creditCards,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.creditCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> loansRefs<T extends Object>(
    Expression<T> Function($$LoansTableAnnotationComposer a) f,
  ) {
    final $$LoansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loans,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoansTableAnnotationComposer(
            $db: $db,
            $table: $db.loans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> billsRefs<T extends Object>(
    Expression<T> Function($$BillsTableAnnotationComposer a) f,
  ) {
    final $$BillsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableAnnotationComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> creditScoreSnapshotsRefs<T extends Object>(
    Expression<T> Function($$CreditScoreSnapshotsTableAnnotationComposer a) f,
  ) {
    final $$CreditScoreSnapshotsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.creditScoreSnapshots,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CreditScoreSnapshotsTableAnnotationComposer(
                $db: $db,
                $table: $db.creditScoreSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> budgetEntriesRefs<T extends Object>(
    Expression<T> Function($$BudgetEntriesTableAnnotationComposer a) f,
  ) {
    final $$BudgetEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgetEntries,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.budgetEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> budgetTargetsRefs<T extends Object>(
    Expression<T> Function($$BudgetTargetsTableAnnotationComposer a) f,
  ) {
    final $$BudgetTargetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgetTargets,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetTargetsTableAnnotationComposer(
            $db: $db,
            $table: $db.budgetTargets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> categoryRulesRefs<T extends Object>(
    Expression<T> Function($$CategoryRulesTableAnnotationComposer a) f,
  ) {
    final $$CategoryRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.categoryRules,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.categoryRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> paychecksRefs<T extends Object>(
    Expression<T> Function($$PaychecksTableAnnotationComposer a) f,
  ) {
    final $$PaychecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paychecks,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaychecksTableAnnotationComposer(
            $db: $db,
            $table: $db.paychecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> paycheckAllocationsRefs<T extends Object>(
    Expression<T> Function($$PaycheckAllocationsTableAnnotationComposer a) f,
  ) {
    final $$PaycheckAllocationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.paycheckAllocations,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PaycheckAllocationsTableAnnotationComposer(
                $db: $db,
                $table: $db.paycheckAllocations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, $$ProfilesTableReferences),
          Profile,
          PrefetchHooks Function({
            bool creditCardsRefs,
            bool loansRefs,
            bool billsRefs,
            bool creditScoreSnapshotsRefs,
            bool budgetEntriesRefs,
            bool budgetTargetsRefs,
            bool categoryRulesRefs,
            bool paychecksRefs,
            bool paycheckAllocationsRefs,
          })
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> pinHash = const Value.absent(),
                Value<bool> isAdmin = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                name: name,
                pinHash: pinHash,
                isAdmin: isAdmin,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> pinHash = const Value.absent(),
                Value<bool> isAdmin = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                name: name,
                pinHash: pinHash,
                isAdmin: isAdmin,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                creditCardsRefs = false,
                loansRefs = false,
                billsRefs = false,
                creditScoreSnapshotsRefs = false,
                budgetEntriesRefs = false,
                budgetTargetsRefs = false,
                categoryRulesRefs = false,
                paychecksRefs = false,
                paycheckAllocationsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (creditCardsRefs) db.creditCards,
                    if (loansRefs) db.loans,
                    if (billsRefs) db.bills,
                    if (creditScoreSnapshotsRefs) db.creditScoreSnapshots,
                    if (budgetEntriesRefs) db.budgetEntries,
                    if (budgetTargetsRefs) db.budgetTargets,
                    if (categoryRulesRefs) db.categoryRules,
                    if (paychecksRefs) db.paychecks,
                    if (paycheckAllocationsRefs) db.paycheckAllocations,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (creditCardsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          CreditCard
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._creditCardsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).creditCardsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (loansRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          Loan
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._loansRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).loansRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (billsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          Bill
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._billsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).billsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (creditScoreSnapshotsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          CreditScoreSnapshot
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._creditScoreSnapshotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).creditScoreSnapshotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (budgetEntriesRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          BudgetEntry
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._budgetEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).budgetEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (budgetTargetsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          BudgetTarget
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._budgetTargetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).budgetTargetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (categoryRulesRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          CategoryRule
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._categoryRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).categoryRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (paychecksRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          Paycheck
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._paychecksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).paychecksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (paycheckAllocationsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          PaycheckAllocation
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._paycheckAllocationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).paycheckAllocationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, $$ProfilesTableReferences),
      Profile,
      PrefetchHooks Function({
        bool creditCardsRefs,
        bool loansRefs,
        bool billsRefs,
        bool creditScoreSnapshotsRefs,
        bool budgetEntriesRefs,
        bool budgetTargetsRefs,
        bool categoryRulesRefs,
        bool paychecksRefs,
        bool paycheckAllocationsRefs,
      })
    >;
typedef $$CreditCardsTableCreateCompanionBuilder =
    CreditCardsCompanion Function({
      Value<int> id,
      required int profileId,
      required String name,
      Value<int> balanceCents,
      required int creditLimitCents,
      Value<double> apr,
      Value<int> annualFeeCents,
      Value<int> monthlyFeeCents,
    });
typedef $$CreditCardsTableUpdateCompanionBuilder =
    CreditCardsCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<String> name,
      Value<int> balanceCents,
      Value<int> creditLimitCents,
      Value<double> apr,
      Value<int> annualFeeCents,
      Value<int> monthlyFeeCents,
    });

final class $$CreditCardsTableReferences
    extends BaseReferences<_$AppDatabase, $CreditCardsTable, CreditCard> {
  $$CreditCardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('credit_cards__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CreditCardsTableFilterComposer
    extends Composer<_$AppDatabase, $CreditCardsTable> {
  $$CreditCardsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balanceCents => $composableBuilder(
    column: $table.balanceCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creditLimitCents => $composableBuilder(
    column: $table.creditLimitCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get apr => $composableBuilder(
    column: $table.apr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get annualFeeCents => $composableBuilder(
    column: $table.annualFeeCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthlyFeeCents => $composableBuilder(
    column: $table.monthlyFeeCents,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CreditCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $CreditCardsTable> {
  $$CreditCardsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balanceCents => $composableBuilder(
    column: $table.balanceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creditLimitCents => $composableBuilder(
    column: $table.creditLimitCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get apr => $composableBuilder(
    column: $table.apr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get annualFeeCents => $composableBuilder(
    column: $table.annualFeeCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthlyFeeCents => $composableBuilder(
    column: $table.monthlyFeeCents,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CreditCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CreditCardsTable> {
  $$CreditCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get balanceCents => $composableBuilder(
    column: $table.balanceCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get creditLimitCents => $composableBuilder(
    column: $table.creditLimitCents,
    builder: (column) => column,
  );

  GeneratedColumn<double> get apr =>
      $composableBuilder(column: $table.apr, builder: (column) => column);

  GeneratedColumn<int> get annualFeeCents => $composableBuilder(
    column: $table.annualFeeCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get monthlyFeeCents => $composableBuilder(
    column: $table.monthlyFeeCents,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CreditCardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CreditCardsTable,
          CreditCard,
          $$CreditCardsTableFilterComposer,
          $$CreditCardsTableOrderingComposer,
          $$CreditCardsTableAnnotationComposer,
          $$CreditCardsTableCreateCompanionBuilder,
          $$CreditCardsTableUpdateCompanionBuilder,
          (CreditCard, $$CreditCardsTableReferences),
          CreditCard,
          PrefetchHooks Function({bool profileId})
        > {
  $$CreditCardsTableTableManager(_$AppDatabase db, $CreditCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CreditCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CreditCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CreditCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> balanceCents = const Value.absent(),
                Value<int> creditLimitCents = const Value.absent(),
                Value<double> apr = const Value.absent(),
                Value<int> annualFeeCents = const Value.absent(),
                Value<int> monthlyFeeCents = const Value.absent(),
              }) => CreditCardsCompanion(
                id: id,
                profileId: profileId,
                name: name,
                balanceCents: balanceCents,
                creditLimitCents: creditLimitCents,
                apr: apr,
                annualFeeCents: annualFeeCents,
                monthlyFeeCents: monthlyFeeCents,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required String name,
                Value<int> balanceCents = const Value.absent(),
                required int creditLimitCents,
                Value<double> apr = const Value.absent(),
                Value<int> annualFeeCents = const Value.absent(),
                Value<int> monthlyFeeCents = const Value.absent(),
              }) => CreditCardsCompanion.insert(
                id: id,
                profileId: profileId,
                name: name,
                balanceCents: balanceCents,
                creditLimitCents: creditLimitCents,
                apr: apr,
                annualFeeCents: annualFeeCents,
                monthlyFeeCents: monthlyFeeCents,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CreditCardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
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
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $$CreditCardsTableReferences
                            ._profileIdTable(db),
                        referencedColumn: $$CreditCardsTableReferences
                            ._profileIdTable(db)
                            .id,
                      ) as T;
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

typedef $$CreditCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CreditCardsTable,
      CreditCard,
      $$CreditCardsTableFilterComposer,
      $$CreditCardsTableOrderingComposer,
      $$CreditCardsTableAnnotationComposer,
      $$CreditCardsTableCreateCompanionBuilder,
      $$CreditCardsTableUpdateCompanionBuilder,
      (CreditCard, $$CreditCardsTableReferences),
      CreditCard,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$LoansTableCreateCompanionBuilder = LoansCompanion Function({
  Value<int> id,
  required int profileId,
  required String name,
  required int balanceCents,
  required int originalAmountCents,
  Value<double> apr,
  Value<int> monthlyPaymentCents,
});
typedef $$LoansTableUpdateCompanionBuilder = LoansCompanion Function({
  Value<int> id,
  Value<int> profileId,
  Value<String> name,
  Value<int> balanceCents,
  Value<int> originalAmountCents,
  Value<double> apr,
  Value<int> monthlyPaymentCents,
});

final class $$LoansTableReferences
    extends BaseReferences<_$AppDatabase, $LoansTable, Loan> {
  $$LoansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('loans__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LoansTableFilterComposer extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balanceCents => $composableBuilder(
    column: $table.balanceCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originalAmountCents => $composableBuilder(
    column: $table.originalAmountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get apr => $composableBuilder(
    column: $table.apr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthlyPaymentCents => $composableBuilder(
    column: $table.monthlyPaymentCents,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoansTableOrderingComposer
    extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balanceCents => $composableBuilder(
    column: $table.balanceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalAmountCents => $composableBuilder(
    column: $table.originalAmountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get apr => $composableBuilder(
    column: $table.apr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthlyPaymentCents => $composableBuilder(
    column: $table.monthlyPaymentCents,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoansTableAnnotationComposer
    extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get balanceCents => $composableBuilder(
    column: $table.balanceCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get originalAmountCents => $composableBuilder(
    column: $table.originalAmountCents,
    builder: (column) => column,
  );

  GeneratedColumn<double> get apr =>
      $composableBuilder(column: $table.apr, builder: (column) => column);

  GeneratedColumn<int> get monthlyPaymentCents => $composableBuilder(
    column: $table.monthlyPaymentCents,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LoansTable,
          Loan,
          $$LoansTableFilterComposer,
          $$LoansTableOrderingComposer,
          $$LoansTableAnnotationComposer,
          $$LoansTableCreateCompanionBuilder,
          $$LoansTableUpdateCompanionBuilder,
          (Loan, $$LoansTableReferences),
          Loan,
          PrefetchHooks Function({bool profileId})
        > {
  $$LoansTableTableManager(_$AppDatabase db, $LoansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> balanceCents = const Value.absent(),
                Value<int> originalAmountCents = const Value.absent(),
                Value<double> apr = const Value.absent(),
                Value<int> monthlyPaymentCents = const Value.absent(),
              }) => LoansCompanion(
                id: id,
                profileId: profileId,
                name: name,
                balanceCents: balanceCents,
                originalAmountCents: originalAmountCents,
                apr: apr,
                monthlyPaymentCents: monthlyPaymentCents,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required String name,
                required int balanceCents,
                required int originalAmountCents,
                Value<double> apr = const Value.absent(),
                Value<int> monthlyPaymentCents = const Value.absent(),
              }) => LoansCompanion.insert(
                id: id,
                profileId: profileId,
                name: name,
                balanceCents: balanceCents,
                originalAmountCents: originalAmountCents,
                apr: apr,
                monthlyPaymentCents: monthlyPaymentCents,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$LoansTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
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
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $$LoansTableReferences._profileIdTable(
                          db,
                        ),
                        referencedColumn: $$LoansTableReferences
                            ._profileIdTable(db)
                            .id,
                      ) as T;
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

typedef $$LoansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LoansTable,
      Loan,
      $$LoansTableFilterComposer,
      $$LoansTableOrderingComposer,
      $$LoansTableAnnotationComposer,
      $$LoansTableCreateCompanionBuilder,
      $$LoansTableUpdateCompanionBuilder,
      (Loan, $$LoansTableReferences),
      Loan,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$BillsTableCreateCompanionBuilder = BillsCompanion Function({
  Value<int> id,
  required int profileId,
  required String name,
  required int amountCents,
  required int dueDay,
  Value<bool> recurring,
  Value<String> category,
  Value<bool> paidThisMonth,
});
typedef $$BillsTableUpdateCompanionBuilder = BillsCompanion Function({
  Value<int> id,
  Value<int> profileId,
  Value<String> name,
  Value<int> amountCents,
  Value<int> dueDay,
  Value<bool> recurring,
  Value<String> category,
  Value<bool> paidThisMonth,
});

final class $$BillsTableReferences
    extends BaseReferences<_$AppDatabase, $BillsTable, Bill> {
  $$BillsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('bills__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $PaycheckAllocationsTable,
    List<PaycheckAllocation>
  >
  _paycheckAllocationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.paycheckAllocations,
        aliasName: 'bills__id__paycheck_allocations__bill_id',
      );

  $$PaycheckAllocationsTableProcessedTableManager get paycheckAllocationsRefs {
    final manager = $$PaycheckAllocationsTableTableManager(
      $_db,
      $_db.paycheckAllocations,
    ).filter((f) => f.billId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _paycheckAllocationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BillsTableFilterComposer extends Composer<_$AppDatabase, $BillsTable> {
  $$BillsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get recurring => $composableBuilder(
    column: $table.recurring,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get paidThisMonth => $composableBuilder(
    column: $table.paidThisMonth,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> paycheckAllocationsRefs(
    Expression<bool> Function($$PaycheckAllocationsTableFilterComposer f) f,
  ) {
    final $$PaycheckAllocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paycheckAllocations,
      getReferencedColumn: (t) => t.billId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaycheckAllocationsTableFilterComposer(
            $db: $db,
            $table: $db.paycheckAllocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BillsTableOrderingComposer
    extends Composer<_$AppDatabase, $BillsTable> {
  $$BillsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get recurring => $composableBuilder(
    column: $table.recurring,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get paidThisMonth => $composableBuilder(
    column: $table.paidThisMonth,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BillsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BillsTable> {
  $$BillsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dueDay =>
      $composableBuilder(column: $table.dueDay, builder: (column) => column);

  GeneratedColumn<bool> get recurring =>
      $composableBuilder(column: $table.recurring, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get paidThisMonth => $composableBuilder(
    column: $table.paidThisMonth,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> paycheckAllocationsRefs<T extends Object>(
    Expression<T> Function($$PaycheckAllocationsTableAnnotationComposer a) f,
  ) {
    final $$PaycheckAllocationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.paycheckAllocations,
          getReferencedColumn: (t) => t.billId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PaycheckAllocationsTableAnnotationComposer(
                $db: $db,
                $table: $db.paycheckAllocations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$BillsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BillsTable,
          Bill,
          $$BillsTableFilterComposer,
          $$BillsTableOrderingComposer,
          $$BillsTableAnnotationComposer,
          $$BillsTableCreateCompanionBuilder,
          $$BillsTableUpdateCompanionBuilder,
          (Bill, $$BillsTableReferences),
          Bill,
          PrefetchHooks Function({bool profileId, bool paycheckAllocationsRefs})
        > {
  $$BillsTableTableManager(_$AppDatabase db, $BillsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BillsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BillsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BillsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<int> dueDay = const Value.absent(),
                Value<bool> recurring = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<bool> paidThisMonth = const Value.absent(),
              }) => BillsCompanion(
                id: id,
                profileId: profileId,
                name: name,
                amountCents: amountCents,
                dueDay: dueDay,
                recurring: recurring,
                category: category,
                paidThisMonth: paidThisMonth,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required String name,
                required int amountCents,
                required int dueDay,
                Value<bool> recurring = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<bool> paidThisMonth = const Value.absent(),
              }) => BillsCompanion.insert(
                id: id,
                profileId: profileId,
                name: name,
                amountCents: amountCents,
                dueDay: dueDay,
                recurring: recurring,
                category: category,
                paidThisMonth: paidThisMonth,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$BillsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({profileId = false, paycheckAllocationsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (paycheckAllocationsRefs) db.paycheckAllocations,
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
                        if (profileId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.profileId,
                            referencedTable: $$BillsTableReferences
                                ._profileIdTable(db),
                            referencedColumn: $$BillsTableReferences
                                ._profileIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (paycheckAllocationsRefs)
                        await $_getPrefetchedData<
                          Bill,
                          $BillsTable,
                          PaycheckAllocation
                        >(
                          currentTable: table,
                          referencedTable: $$BillsTableReferences
                              ._paycheckAllocationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BillsTableReferences(
                                db,
                                table,
                                p0,
                              ).paycheckAllocationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.billId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BillsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BillsTable,
      Bill,
      $$BillsTableFilterComposer,
      $$BillsTableOrderingComposer,
      $$BillsTableAnnotationComposer,
      $$BillsTableCreateCompanionBuilder,
      $$BillsTableUpdateCompanionBuilder,
      (Bill, $$BillsTableReferences),
      Bill,
      PrefetchHooks Function({bool profileId, bool paycheckAllocationsRefs})
    >;
typedef $$CreditScoreSnapshotsTableCreateCompanionBuilder =
    CreditScoreSnapshotsCompanion Function({
      Value<int> id,
      required int profileId,
      required DateTime date,
      required int score,
      required double utilization,
      Value<int> derogatoryMarks,
      Value<int> accountAgeMonths,
      Value<int> hardInquiries,
    });
typedef $$CreditScoreSnapshotsTableUpdateCompanionBuilder =
    CreditScoreSnapshotsCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<DateTime> date,
      Value<int> score,
      Value<double> utilization,
      Value<int> derogatoryMarks,
      Value<int> accountAgeMonths,
      Value<int> hardInquiries,
    });

final class $$CreditScoreSnapshotsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CreditScoreSnapshotsTable,
          CreditScoreSnapshot
        > {
  $$CreditScoreSnapshotsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _profileIdTable(_$AppDatabase db) => db.profiles
      .createAlias('credit_score_snapshots__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CreditScoreSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $CreditScoreSnapshotsTable> {
  $$CreditScoreSnapshotsTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get utilization => $composableBuilder(
    column: $table.utilization,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get derogatoryMarks => $composableBuilder(
    column: $table.derogatoryMarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accountAgeMonths => $composableBuilder(
    column: $table.accountAgeMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hardInquiries => $composableBuilder(
    column: $table.hardInquiries,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CreditScoreSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $CreditScoreSnapshotsTable> {
  $$CreditScoreSnapshotsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get utilization => $composableBuilder(
    column: $table.utilization,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get derogatoryMarks => $composableBuilder(
    column: $table.derogatoryMarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accountAgeMonths => $composableBuilder(
    column: $table.accountAgeMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hardInquiries => $composableBuilder(
    column: $table.hardInquiries,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CreditScoreSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CreditScoreSnapshotsTable> {
  $$CreditScoreSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<double> get utilization => $composableBuilder(
    column: $table.utilization,
    builder: (column) => column,
  );

  GeneratedColumn<int> get derogatoryMarks => $composableBuilder(
    column: $table.derogatoryMarks,
    builder: (column) => column,
  );

  GeneratedColumn<int> get accountAgeMonths => $composableBuilder(
    column: $table.accountAgeMonths,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hardInquiries => $composableBuilder(
    column: $table.hardInquiries,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CreditScoreSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CreditScoreSnapshotsTable,
          CreditScoreSnapshot,
          $$CreditScoreSnapshotsTableFilterComposer,
          $$CreditScoreSnapshotsTableOrderingComposer,
          $$CreditScoreSnapshotsTableAnnotationComposer,
          $$CreditScoreSnapshotsTableCreateCompanionBuilder,
          $$CreditScoreSnapshotsTableUpdateCompanionBuilder,
          (CreditScoreSnapshot, $$CreditScoreSnapshotsTableReferences),
          CreditScoreSnapshot,
          PrefetchHooks Function({bool profileId})
        > {
  $$CreditScoreSnapshotsTableTableManager(
    _$AppDatabase db,
    $CreditScoreSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CreditScoreSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CreditScoreSnapshotsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CreditScoreSnapshotsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<double> utilization = const Value.absent(),
                Value<int> derogatoryMarks = const Value.absent(),
                Value<int> accountAgeMonths = const Value.absent(),
                Value<int> hardInquiries = const Value.absent(),
              }) => CreditScoreSnapshotsCompanion(
                id: id,
                profileId: profileId,
                date: date,
                score: score,
                utilization: utilization,
                derogatoryMarks: derogatoryMarks,
                accountAgeMonths: accountAgeMonths,
                hardInquiries: hardInquiries,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required DateTime date,
                required int score,
                required double utilization,
                Value<int> derogatoryMarks = const Value.absent(),
                Value<int> accountAgeMonths = const Value.absent(),
                Value<int> hardInquiries = const Value.absent(),
              }) => CreditScoreSnapshotsCompanion.insert(
                id: id,
                profileId: profileId,
                date: date,
                score: score,
                utilization: utilization,
                derogatoryMarks: derogatoryMarks,
                accountAgeMonths: accountAgeMonths,
                hardInquiries: hardInquiries,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CreditScoreSnapshotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
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
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $$CreditScoreSnapshotsTableReferences
                            ._profileIdTable(db),
                        referencedColumn: $$CreditScoreSnapshotsTableReferences
                            ._profileIdTable(db)
                            .id,
                      ) as T;
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

typedef $$CreditScoreSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CreditScoreSnapshotsTable,
      CreditScoreSnapshot,
      $$CreditScoreSnapshotsTableFilterComposer,
      $$CreditScoreSnapshotsTableOrderingComposer,
      $$CreditScoreSnapshotsTableAnnotationComposer,
      $$CreditScoreSnapshotsTableCreateCompanionBuilder,
      $$CreditScoreSnapshotsTableUpdateCompanionBuilder,
      (CreditScoreSnapshot, $$CreditScoreSnapshotsTableReferences),
      CreditScoreSnapshot,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$BudgetEntriesTableCreateCompanionBuilder =
    BudgetEntriesCompanion Function({
      Value<int> id,
      required int profileId,
      required DateTime date,
      Value<String> category,
      required int amountCents,
      required EntryType type,
      Value<String?> description,
    });
typedef $$BudgetEntriesTableUpdateCompanionBuilder =
    BudgetEntriesCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<DateTime> date,
      Value<String> category,
      Value<int> amountCents,
      Value<EntryType> type,
      Value<String?> description,
    });

final class $$BudgetEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $BudgetEntriesTable, BudgetEntry> {
  $$BudgetEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('budget_entries__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BudgetEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetEntriesTable> {
  $$BudgetEntriesTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EntryType, EntryType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetEntriesTable> {
  $$BudgetEntriesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetEntriesTable> {
  $$BudgetEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<EntryType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetEntriesTable,
          BudgetEntry,
          $$BudgetEntriesTableFilterComposer,
          $$BudgetEntriesTableOrderingComposer,
          $$BudgetEntriesTableAnnotationComposer,
          $$BudgetEntriesTableCreateCompanionBuilder,
          $$BudgetEntriesTableUpdateCompanionBuilder,
          (BudgetEntry, $$BudgetEntriesTableReferences),
          BudgetEntry,
          PrefetchHooks Function({bool profileId})
        > {
  $$BudgetEntriesTableTableManager(_$AppDatabase db, $BudgetEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<EntryType> type = const Value.absent(),
                Value<String?> description = const Value.absent(),
              }) => BudgetEntriesCompanion(
                id: id,
                profileId: profileId,
                date: date,
                category: category,
                amountCents: amountCents,
                type: type,
                description: description,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required DateTime date,
                Value<String> category = const Value.absent(),
                required int amountCents,
                required EntryType type,
                Value<String?> description = const Value.absent(),
              }) => BudgetEntriesCompanion.insert(
                id: id,
                profileId: profileId,
                date: date,
                category: category,
                amountCents: amountCents,
                type: type,
                description: description,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BudgetEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
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
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $$BudgetEntriesTableReferences
                            ._profileIdTable(db),
                        referencedColumn: $$BudgetEntriesTableReferences
                            ._profileIdTable(db)
                            .id,
                      ) as T;
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

typedef $$BudgetEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetEntriesTable,
      BudgetEntry,
      $$BudgetEntriesTableFilterComposer,
      $$BudgetEntriesTableOrderingComposer,
      $$BudgetEntriesTableAnnotationComposer,
      $$BudgetEntriesTableCreateCompanionBuilder,
      $$BudgetEntriesTableUpdateCompanionBuilder,
      (BudgetEntry, $$BudgetEntriesTableReferences),
      BudgetEntry,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$BudgetTargetsTableCreateCompanionBuilder =
    BudgetTargetsCompanion Function({
      Value<int> id,
      required int profileId,
      required String category,
      required int monthlyTargetCents,
    });
typedef $$BudgetTargetsTableUpdateCompanionBuilder =
    BudgetTargetsCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<String> category,
      Value<int> monthlyTargetCents,
    });

final class $$BudgetTargetsTableReferences
    extends BaseReferences<_$AppDatabase, $BudgetTargetsTable, BudgetTarget> {
  $$BudgetTargetsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('budget_targets__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BudgetTargetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetTargetsTable> {
  $$BudgetTargetsTableFilterComposer({
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

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthlyTargetCents => $composableBuilder(
    column: $table.monthlyTargetCents,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetTargetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetTargetsTable> {
  $$BudgetTargetsTableOrderingComposer({
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

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthlyTargetCents => $composableBuilder(
    column: $table.monthlyTargetCents,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetTargetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetTargetsTable> {
  $$BudgetTargetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get monthlyTargetCents => $composableBuilder(
    column: $table.monthlyTargetCents,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetTargetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetTargetsTable,
          BudgetTarget,
          $$BudgetTargetsTableFilterComposer,
          $$BudgetTargetsTableOrderingComposer,
          $$BudgetTargetsTableAnnotationComposer,
          $$BudgetTargetsTableCreateCompanionBuilder,
          $$BudgetTargetsTableUpdateCompanionBuilder,
          (BudgetTarget, $$BudgetTargetsTableReferences),
          BudgetTarget,
          PrefetchHooks Function({bool profileId})
        > {
  $$BudgetTargetsTableTableManager(_$AppDatabase db, $BudgetTargetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetTargetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetTargetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetTargetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> monthlyTargetCents = const Value.absent(),
              }) => BudgetTargetsCompanion(
                id: id,
                profileId: profileId,
                category: category,
                monthlyTargetCents: monthlyTargetCents,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required String category,
                required int monthlyTargetCents,
              }) => BudgetTargetsCompanion.insert(
                id: id,
                profileId: profileId,
                category: category,
                monthlyTargetCents: monthlyTargetCents,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BudgetTargetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
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
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $$BudgetTargetsTableReferences
                            ._profileIdTable(db),
                        referencedColumn: $$BudgetTargetsTableReferences
                            ._profileIdTable(db)
                            .id,
                      ) as T;
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

typedef $$BudgetTargetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetTargetsTable,
      BudgetTarget,
      $$BudgetTargetsTableFilterComposer,
      $$BudgetTargetsTableOrderingComposer,
      $$BudgetTargetsTableAnnotationComposer,
      $$BudgetTargetsTableCreateCompanionBuilder,
      $$BudgetTargetsTableUpdateCompanionBuilder,
      (BudgetTarget, $$BudgetTargetsTableReferences),
      BudgetTarget,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$CategoryRulesTableCreateCompanionBuilder =
    CategoryRulesCompanion Function({
      Value<int> id,
      required int profileId,
      required RuleField field,
      required String pattern,
      required String category,
      Value<int> priority,
    });
typedef $$CategoryRulesTableUpdateCompanionBuilder =
    CategoryRulesCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<RuleField> field,
      Value<String> pattern,
      Value<String> category,
      Value<int> priority,
    });

final class $$CategoryRulesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoryRulesTable, CategoryRule> {
  $$CategoryRulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('category_rules__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CategoryRulesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryRulesTable> {
  $$CategoryRulesTableFilterComposer({
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

  ColumnWithTypeConverterFilters<RuleField, RuleField, String> get field =>
      $composableBuilder(
        column: $table.field,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoryRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryRulesTable> {
  $$CategoryRulesTableOrderingComposer({
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

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoryRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryRulesTable> {
  $$CategoryRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RuleField, String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<String> get pattern =>
      $composableBuilder(column: $table.pattern, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoryRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryRulesTable,
          CategoryRule,
          $$CategoryRulesTableFilterComposer,
          $$CategoryRulesTableOrderingComposer,
          $$CategoryRulesTableAnnotationComposer,
          $$CategoryRulesTableCreateCompanionBuilder,
          $$CategoryRulesTableUpdateCompanionBuilder,
          (CategoryRule, $$CategoryRulesTableReferences),
          CategoryRule,
          PrefetchHooks Function({bool profileId})
        > {
  $$CategoryRulesTableTableManager(_$AppDatabase db, $CategoryRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<RuleField> field = const Value.absent(),
                Value<String> pattern = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> priority = const Value.absent(),
              }) => CategoryRulesCompanion(
                id: id,
                profileId: profileId,
                field: field,
                pattern: pattern,
                category: category,
                priority: priority,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required RuleField field,
                required String pattern,
                required String category,
                Value<int> priority = const Value.absent(),
              }) => CategoryRulesCompanion.insert(
                id: id,
                profileId: profileId,
                field: field,
                pattern: pattern,
                category: category,
                priority: priority,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoryRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
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
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $$CategoryRulesTableReferences
                            ._profileIdTable(db),
                        referencedColumn: $$CategoryRulesTableReferences
                            ._profileIdTable(db)
                            .id,
                      ) as T;
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

typedef $$CategoryRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryRulesTable,
      CategoryRule,
      $$CategoryRulesTableFilterComposer,
      $$CategoryRulesTableOrderingComposer,
      $$CategoryRulesTableAnnotationComposer,
      $$CategoryRulesTableCreateCompanionBuilder,
      $$CategoryRulesTableUpdateCompanionBuilder,
      (CategoryRule, $$CategoryRulesTableReferences),
      CategoryRule,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$PaychecksTableCreateCompanionBuilder = PaychecksCompanion Function({
  Value<int> id,
  required int profileId,
  required String name,
  required DateTime date,
  required int amountCents,
  Value<bool> received,
});
typedef $$PaychecksTableUpdateCompanionBuilder = PaychecksCompanion Function({
  Value<int> id,
  Value<int> profileId,
  Value<String> name,
  Value<DateTime> date,
  Value<int> amountCents,
  Value<bool> received,
});

final class $$PaychecksTableReferences
    extends BaseReferences<_$AppDatabase, $PaychecksTable, Paycheck> {
  $$PaychecksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('paychecks__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $PaycheckAllocationsTable,
    List<PaycheckAllocation>
  >
  _paycheckAllocationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.paycheckAllocations,
        aliasName: 'paychecks__id__paycheck_allocations__paycheck_id',
      );

  $$PaycheckAllocationsTableProcessedTableManager get paycheckAllocationsRefs {
    final manager = $$PaycheckAllocationsTableTableManager(
      $_db,
      $_db.paycheckAllocations,
    ).filter((f) => f.paycheckId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _paycheckAllocationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PaychecksTableFilterComposer
    extends Composer<_$AppDatabase, $PaychecksTable> {
  $$PaychecksTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get received => $composableBuilder(
    column: $table.received,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> paycheckAllocationsRefs(
    Expression<bool> Function($$PaycheckAllocationsTableFilterComposer f) f,
  ) {
    final $$PaycheckAllocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paycheckAllocations,
      getReferencedColumn: (t) => t.paycheckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaycheckAllocationsTableFilterComposer(
            $db: $db,
            $table: $db.paycheckAllocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PaychecksTableOrderingComposer
    extends Composer<_$AppDatabase, $PaychecksTable> {
  $$PaychecksTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get received => $composableBuilder(
    column: $table.received,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaychecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaychecksTable> {
  $$PaychecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get received =>
      $composableBuilder(column: $table.received, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> paycheckAllocationsRefs<T extends Object>(
    Expression<T> Function($$PaycheckAllocationsTableAnnotationComposer a) f,
  ) {
    final $$PaycheckAllocationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.paycheckAllocations,
          getReferencedColumn: (t) => t.paycheckId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PaycheckAllocationsTableAnnotationComposer(
                $db: $db,
                $table: $db.paycheckAllocations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PaychecksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaychecksTable,
          Paycheck,
          $$PaychecksTableFilterComposer,
          $$PaychecksTableOrderingComposer,
          $$PaychecksTableAnnotationComposer,
          $$PaychecksTableCreateCompanionBuilder,
          $$PaychecksTableUpdateCompanionBuilder,
          (Paycheck, $$PaychecksTableReferences),
          Paycheck,
          PrefetchHooks Function({bool profileId, bool paycheckAllocationsRefs})
        > {
  $$PaychecksTableTableManager(_$AppDatabase db, $PaychecksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaychecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaychecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaychecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<bool> received = const Value.absent(),
              }) => PaychecksCompanion(
                id: id,
                profileId: profileId,
                name: name,
                date: date,
                amountCents: amountCents,
                received: received,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required String name,
                required DateTime date,
                required int amountCents,
                Value<bool> received = const Value.absent(),
              }) => PaychecksCompanion.insert(
                id: id,
                profileId: profileId,
                name: name,
                date: date,
                amountCents: amountCents,
                received: received,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PaychecksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({profileId = false, paycheckAllocationsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (paycheckAllocationsRefs) db.paycheckAllocations,
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
                        if (profileId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.profileId,
                            referencedTable: $$PaychecksTableReferences
                                ._profileIdTable(db),
                            referencedColumn: $$PaychecksTableReferences
                                ._profileIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (paycheckAllocationsRefs)
                        await $_getPrefetchedData<
                          Paycheck,
                          $PaychecksTable,
                          PaycheckAllocation
                        >(
                          currentTable: table,
                          referencedTable: $$PaychecksTableReferences
                              ._paycheckAllocationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PaychecksTableReferences(
                                db,
                                table,
                                p0,
                              ).paycheckAllocationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.paycheckId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PaychecksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaychecksTable,
      Paycheck,
      $$PaychecksTableFilterComposer,
      $$PaychecksTableOrderingComposer,
      $$PaychecksTableAnnotationComposer,
      $$PaychecksTableCreateCompanionBuilder,
      $$PaychecksTableUpdateCompanionBuilder,
      (Paycheck, $$PaychecksTableReferences),
      Paycheck,
      PrefetchHooks Function({bool profileId, bool paycheckAllocationsRefs})
    >;
typedef $$PaycheckAllocationsTableCreateCompanionBuilder =
    PaycheckAllocationsCompanion Function({
      Value<int> id,
      required int profileId,
      required int paycheckId,
      required String target,
      required int amountCents,
      Value<int?> billId,
    });
typedef $$PaycheckAllocationsTableUpdateCompanionBuilder =
    PaycheckAllocationsCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<int> paycheckId,
      Value<String> target,
      Value<int> amountCents,
      Value<int?> billId,
    });

final class $$PaycheckAllocationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PaycheckAllocationsTable,
          PaycheckAllocation
        > {
  $$PaycheckAllocationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('paycheck_allocations__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PaychecksTable _paycheckIdTable(_$AppDatabase db) => db.paychecks
      .createAlias('paycheck_allocations__paycheck_id__paychecks__id');

  $$PaychecksTableProcessedTableManager get paycheckId {
    final $_column = $_itemColumn<int>('paycheck_id')!;

    final manager = $$PaychecksTableTableManager(
      $_db,
      $_db.paychecks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paycheckIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $BillsTable _billIdTable(_$AppDatabase db) =>
      db.bills.createAlias('paycheck_allocations__bill_id__bills__id');

  $$BillsTableProcessedTableManager? get billId {
    final $_column = $_itemColumn<int>('bill_id');
    if ($_column == null) return null;
    final manager = $$BillsTableTableManager(
      $_db,
      $_db.bills,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_billIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaycheckAllocationsTableFilterComposer
    extends Composer<_$AppDatabase, $PaycheckAllocationsTable> {
  $$PaycheckAllocationsTableFilterComposer({
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

  ColumnFilters<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaychecksTableFilterComposer get paycheckId {
    final $$PaychecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paycheckId,
      referencedTable: $db.paychecks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaychecksTableFilterComposer(
            $db: $db,
            $table: $db.paychecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BillsTableFilterComposer get billId {
    final $$BillsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.billId,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableFilterComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaycheckAllocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaycheckAllocationsTable> {
  $$PaycheckAllocationsTableOrderingComposer({
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

  ColumnOrderings<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaychecksTableOrderingComposer get paycheckId {
    final $$PaychecksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paycheckId,
      referencedTable: $db.paychecks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaychecksTableOrderingComposer(
            $db: $db,
            $table: $db.paychecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BillsTableOrderingComposer get billId {
    final $$BillsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.billId,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableOrderingComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaycheckAllocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaycheckAllocationsTable> {
  $$PaycheckAllocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaychecksTableAnnotationComposer get paycheckId {
    final $$PaychecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paycheckId,
      referencedTable: $db.paychecks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaychecksTableAnnotationComposer(
            $db: $db,
            $table: $db.paychecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BillsTableAnnotationComposer get billId {
    final $$BillsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.billId,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableAnnotationComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaycheckAllocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaycheckAllocationsTable,
          PaycheckAllocation,
          $$PaycheckAllocationsTableFilterComposer,
          $$PaycheckAllocationsTableOrderingComposer,
          $$PaycheckAllocationsTableAnnotationComposer,
          $$PaycheckAllocationsTableCreateCompanionBuilder,
          $$PaycheckAllocationsTableUpdateCompanionBuilder,
          (PaycheckAllocation, $$PaycheckAllocationsTableReferences),
          PaycheckAllocation,
          PrefetchHooks Function({bool profileId, bool paycheckId, bool billId})
        > {
  $$PaycheckAllocationsTableTableManager(
    _$AppDatabase db,
    $PaycheckAllocationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaycheckAllocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaycheckAllocationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PaycheckAllocationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<int> paycheckId = const Value.absent(),
                Value<String> target = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<int?> billId = const Value.absent(),
              }) => PaycheckAllocationsCompanion(
                id: id,
                profileId: profileId,
                paycheckId: paycheckId,
                target: target,
                amountCents: amountCents,
                billId: billId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required int paycheckId,
                required String target,
                required int amountCents,
                Value<int?> billId = const Value.absent(),
              }) => PaycheckAllocationsCompanion.insert(
                id: id,
                profileId: profileId,
                paycheckId: paycheckId,
                target: target,
                amountCents: amountCents,
                billId: billId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PaycheckAllocationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({profileId = false, paycheckId = false, billId = false}) {
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
                        if (profileId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.profileId,
                            referencedTable:
                                $$PaycheckAllocationsTableReferences
                                    ._profileIdTable(db),
                            referencedColumn:
                                $$PaycheckAllocationsTableReferences
                                    ._profileIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (paycheckId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.paycheckId,
                            referencedTable:
                                $$PaycheckAllocationsTableReferences
                                    ._paycheckIdTable(db),
                            referencedColumn:
                                $$PaycheckAllocationsTableReferences
                                    ._paycheckIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (billId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.billId,
                            referencedTable:
                                $$PaycheckAllocationsTableReferences
                                    ._billIdTable(db),
                            referencedColumn:
                                $$PaycheckAllocationsTableReferences
                                    ._billIdTable(db)
                                    .id,
                          ) as T;
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

typedef $$PaycheckAllocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaycheckAllocationsTable,
      PaycheckAllocation,
      $$PaycheckAllocationsTableFilterComposer,
      $$PaycheckAllocationsTableOrderingComposer,
      $$PaycheckAllocationsTableAnnotationComposer,
      $$PaycheckAllocationsTableCreateCompanionBuilder,
      $$PaycheckAllocationsTableUpdateCompanionBuilder,
      (PaycheckAllocation, $$PaycheckAllocationsTableReferences),
      PaycheckAllocation,
      PrefetchHooks Function({bool profileId, bool paycheckId, bool billId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$CreditCardsTableTableManager get creditCards =>
      $$CreditCardsTableTableManager(_db, _db.creditCards);
  $$LoansTableTableManager get loans =>
      $$LoansTableTableManager(_db, _db.loans);
  $$BillsTableTableManager get bills =>
      $$BillsTableTableManager(_db, _db.bills);
  $$CreditScoreSnapshotsTableTableManager get creditScoreSnapshots =>
      $$CreditScoreSnapshotsTableTableManager(_db, _db.creditScoreSnapshots);
  $$BudgetEntriesTableTableManager get budgetEntries =>
      $$BudgetEntriesTableTableManager(_db, _db.budgetEntries);
  $$BudgetTargetsTableTableManager get budgetTargets =>
      $$BudgetTargetsTableTableManager(_db, _db.budgetTargets);
  $$CategoryRulesTableTableManager get categoryRules =>
      $$CategoryRulesTableTableManager(_db, _db.categoryRules);
  $$PaychecksTableTableManager get paychecks =>
      $$PaychecksTableTableManager(_db, _db.paychecks);
  $$PaycheckAllocationsTableTableManager get paycheckAllocations =>
      $$PaycheckAllocationsTableTableManager(_db, _db.paycheckAllocations);
}
