// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 1;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      name: fields[0] as String?,
      email: fields[1] as String?,
      phone: fields[2] as String?,
      allergies: (fields[3] as List).cast<String>(),
      medicalConditions: (fields[4] as List).cast<String>(),
      foodPreferences: (fields[5] as List).cast<String>(),
      dailyBudget: fields[6] as double?,
      isPremium: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.allergies)
      ..writeByte(4)
      ..write(obj.medicalConditions)
      ..writeByte(5)
      ..write(obj.foodPreferences)
      ..writeByte(6)
      ..write(obj.dailyBudget)
      ..writeByte(7)
      ..write(obj.isPremium);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
