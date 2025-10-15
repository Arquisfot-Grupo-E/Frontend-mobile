import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../models/review.dart';
import '../../services/graphql_service.dart';
import '../../widgets/review_card.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;

  const BookDetailScreen({
    super.key,
    required this.bookId,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  List<Review> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);

    final client = GraphQLProvider.of(context).value;
    final result = await client.query(
      QueryOptions(
        document: gql(GraphQLService.reviewsForBookQuery),
        variables: {
          'bookId': widget.bookId,
        },
      ),
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${result.exception.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final reviewsData = result.data?['reviewsForBook'] as List<dynamic>?;
    if (reviewsData != null) {
      setState(() {
        _reviews = reviewsData.map((json) => Review.fromJson(json)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reseñas del Libro'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _reviews.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.rate_review,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay reseñas aún',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '¡Sé el primero en opinar!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadReviews,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reviews.length,
                    itemBuilder: (context, index) {
                      return ReviewCard(review: _reviews[index]);
                    },
                  ),
                ),
    );
  }
}
