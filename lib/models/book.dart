class Book {
  final String id;
  final String? title;
  final List<String>? authors;
  final String? description;
  final String? thumbnail;
  final List<String>? categories;

  Book({
    required this.id,
    this.title,
    this.authors,
    this.description,
    this.thumbnail,
    this.categories,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      authors: json['authors'] != null 
          ? List<String>.from(json['authors'])
          : null,
      description: json['description'],
      thumbnail: json['thumbnail'],
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : null,
    );
  }
}
