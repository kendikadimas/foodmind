// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_post.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CommunityPostAdapter extends TypeAdapter<CommunityPost> {
  @override
  final int typeId = 2;

  @override
  CommunityPost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CommunityPost(
      id: fields[0] as String,
      authorName: fields[1] as String,
      authorEmail: fields[2] as String,
      content: fields[3] as String,
      location: fields[4] as String?,
      budget: fields[5] as double?,
      allergies: (fields[6] as List).cast<String>(),
      medicalConditions: (fields[7] as List).cast<String>(),
      preferences: (fields[8] as List).cast<String>(),
      createdAt: fields[9] as DateTime,
      responses: (fields[10] as List).cast<PostResponse>(),
      likesCount: fields[11] as int,
      likedBy: (fields[12] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, CommunityPost obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.authorName)
      ..writeByte(2)
      ..write(obj.authorEmail)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.location)
      ..writeByte(5)
      ..write(obj.budget)
      ..writeByte(6)
      ..write(obj.allergies)
      ..writeByte(7)
      ..write(obj.medicalConditions)
      ..writeByte(8)
      ..write(obj.preferences)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.responses)
      ..writeByte(11)
      ..write(obj.likesCount)
      ..writeByte(12)
      ..write(obj.likedBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommunityPostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PostResponseAdapter extends TypeAdapter<PostResponse> {
  @override
  final int typeId = 3;

  @override
  PostResponse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PostResponse(
      id: fields[0] as String,
      authorName: fields[1] as String,
      authorEmail: fields[2] as String,
      content: fields[3] as String,
      recommendedFood: fields[4] as String?,
      restaurantName: fields[5] as String?,
      location: fields[6] as String?,
      estimatedPrice: fields[7] as double?,
      createdAt: fields[8] as DateTime,
      likesCount: fields[9] as int,
      likedBy: (fields[10] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, PostResponse obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.authorName)
      ..writeByte(2)
      ..write(obj.authorEmail)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.recommendedFood)
      ..writeByte(5)
      ..write(obj.restaurantName)
      ..writeByte(6)
      ..write(obj.location)
      ..writeByte(7)
      ..write(obj.estimatedPrice)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.likesCount)
      ..writeByte(10)
      ..write(obj.likedBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostResponseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
