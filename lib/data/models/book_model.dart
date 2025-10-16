// Modelo de domínio Book usado pelo app (corresponde aos campos usados pela UI).

class Book {
  final String id;
  final String title;
  final List<String> authors;
  final String? thumbnailUrl;
  final String? publishedDate;
  final String? description;
  final String? pageCount;
  final String? categories;
  final bool isFavorite;

  Book({
    required this.id,
    required this.title,
    this.authors = const [],
    this.thumbnailUrl,
    this.publishedDate,
    this.description,
    this.pageCount,
    this.categories,
    this.isFavorite = false,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] as Map<String, dynamic>?;
    final imageLinks = volumeInfo?['imageLinks'] as Map<String, dynamic>?;

    String? categoriesStr;
    if (volumeInfo?['categories'] != null) {
      categoriesStr = (volumeInfo!['categories'] as List).join(', ');
    }

    String? imageUrl = imageLinks?['thumbnail'] as String?;
    if (imageUrl != null && imageUrl.startsWith('http:')) {
      imageUrl = imageUrl.replaceFirst('http:', 'https:');
    }

    return Book(
      id: json['id'] as String? ?? '',
      title: volumeInfo?['title'] as String? ?? 'Sem título',
      authors: volumeInfo?['authors'] != null
          ? List<String>.from(volumeInfo!['authors'] as List)
          : const [],
      thumbnailUrl: imageUrl,
      publishedDate: volumeInfo?['publishedDate'] as String?,
      description: volumeInfo?['description'] as String?,
      pageCount: volumeInfo?['pageCount']?.toString(),
      categories: categoriesStr,
    );
  }

  Book copyWith({
    String? id,
    String? title,
    List<String>? authors,
    String? thumbnailUrl,
    String? publishedDate,
    String? description,
    String? pageCount,
    String? categories,
    bool? isFavorite,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      publishedDate: publishedDate ?? this.publishedDate,
      description: description ?? this.description,
      pageCount: pageCount ?? this.pageCount,
      categories: categories ?? this.categories,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'authors': authors,
      'thumbnailUrl': thumbnailUrl,
      'publishedDate': publishedDate,
      'description': description,
      'pageCount': pageCount,
      'categories': categories,
      'isFavorite': isFavorite,
    };
  }
}
