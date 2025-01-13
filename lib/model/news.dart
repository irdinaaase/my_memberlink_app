class News {
  final int newsId;
  final String newsTitle;
  final String newsDetails;
  final String newsDate;

  News({
    required this.newsId,
    required this.newsTitle,
    required this.newsDetails,
    required this.newsDate,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      newsId: json['news_id'],
      newsTitle: json['news_title'],
      newsDetails: json['news_details'],
      newsDate: json['news_date'],
    );
  }
}
