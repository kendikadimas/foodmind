// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FoodHistoryAdapter extends TypeAdapter<FoodHistory> {
  @override
  final int typeId = 0;

  @override
  FoodHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodHistory(
      mainFood: fields[0] as String,
      alternatives: (fields[1] as List).cast<String>(),
      reasoning: (fields[2] as List).cast<String>(),
      taste: fields[3] as String,
      style: fields[4] as String,
      weather: fields[5] as String,
      timestamp: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FoodHistory obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.mainFood)
      ..writeByte(1)
      ..write(obj.alternatives)
      ..writeByte(2)
      ..write(obj.reasoning)
      ..writeByte(3)
      ..write(obj.taste)
      ..writeByte(4)
      ..write(obj.style)
      ..writeByte(5)
      ..write(obj.weather)
      ..writeByte(6)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
