// File: lib/community/models/community_model.dart

class Community {
  int pk;
  String communityName;
  String description;
  String location;
  String sportsType;
  int memberCount;
  int maxMember;
  String? imageUrl;
  String contactPerson;
  String createdBy;

  Community({
    required this.pk,
    required this.communityName,
    required this.description,
    required this.location,
    required this.sportsType,
    required this.memberCount,
    required this.maxMember,
    this.imageUrl,
    required this.contactPerson,
    required this.createdBy,
  });

  factory Community.fromJson(Map<String, dynamic> json) => Community(
    pk: json["pk"],
    communityName: json["community_name"],
    description: json["description"],
    location: json["location"],
    sportsType: json["sports_type"],
    memberCount: json["member_count"],
    maxMember: json["max_member"],
    // Handle URL gambar, bisa null atau string kosong
    imageUrl: json["image_url"] != null && json["image_url"] != "" ? json["image_url"] : null,
    contactPerson: json["contact_person"],
    createdBy: json["created_by"],
  );
}

class CommunityPost {
  int pk;
  String user;
  String content;
  String createdAt;

  CommunityPost({
    required this.pk,
    required this.user,
    required this.content,
    required this.createdAt,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) => CommunityPost(
    pk: json["pk"],
    user: json["user"]["username"], // Mengambil username dari nested object user
    content: json["content"],
    createdAt: json["created_at"],
  );
}