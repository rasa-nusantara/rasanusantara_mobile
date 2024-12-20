import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:rasanusantara_mobile/restaurant.dart';
import 'package:rasanusantara_mobile/review/screens/review_page.dart';
import 'package:rasanusantara_mobile/menu_management/menu_management_screen.dart';

class AdminDetail extends StatefulWidget {
  final Restaurant restaurant;

  const AdminDetail({
    Key? key,
    required this.restaurant,
  }) : super(key: key);

  @override
  State<AdminDetail> createState() => _AdminDetailState();
}

class _AdminDetailState extends State<AdminDetail> {
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = Provider.of<CookieRequest>(context, listen: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  child: Image.network(
                    widget.restaurant.image.isNotEmpty
                        ? widget.restaurant.image
                        : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRhdkA-pOR1l5lRdCAtAAA2XSt2qg-WxQcg5A&s',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.restaurant,
                            color: Colors.grey,
                            size: 50,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.orange,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.restaurant.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.restaurant.location.isNotEmpty
                        ? widget.restaurant.location
                        : "Lokasi tidak tersedia",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Colors.amber, size: 20),
                      Text(
                        ' ${widget.restaurant.rating}',
                        style: const TextStyle(fontFamily: 'Montserrat'),
                      ),
                      Text(
                        ' • Rp${widget.restaurant.averagePrice}',
                        style: const TextStyle(fontFamily: 'Montserrat'),
                      ),
                    ],
                  ),
                  if (widget.restaurant.menuItems.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: widget.restaurant.menuItems
                          .expand((menuItem) =>
                              menuItem.categories) // Gabungkan semua kategori
                          .toSet() // Hapus kategori duplikat
                          .map((category) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.shade200,
                                Colors.orange,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    'Daftar Menu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.restaurant.menuItems.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '• ${item.name}',
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      )),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Reservasi',
                            style: TextStyle(fontFamily: 'Montserrat'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            // Navigate to MenuManagementScreen and wait for the result
                            final shouldRefresh = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MenuManagementScreen(
                                  restaurantId: widget.restaurant.id,
                                ),
                              ),
                            );

                            // Check if shouldRefresh is true and refresh the page
                            if (shouldRefresh == true) {
                              setState(() {
                                // Show loading indicator
                                _isLoading = true;
                              });

                              // Fetch updated restaurant data
                              try {
                                final request = Provider.of<CookieRequest>(
                                    context,
                                    listen: false);
                                final response = await request.get(
                                  'http://127.0.0.1:8000/json/${widget.restaurant.id}/',
                                );

                                print(
                                    'Response body: $response'); // Debugging output

                                // Parsing list of menu items
                                final updatedMenuItems = (response as List)
                                    .map((menuItem) =>
                                        MenuItem.fromJson(menuItem))
                                    .toList();

                                setState(() {
                                  widget.restaurant.menuItems =
                                      updatedMenuItems;
                                  _isLoading = false; // Stop loading indicator
                                });
                              } catch (e) {
                                print('Error: $e'); // Debugging error
                                setState(() {
                                  _isLoading =
                                      false; // Stop loading indicator even on error
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Gagal memperbarui data restaurant: $e'),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade900,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Edit Menu',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
