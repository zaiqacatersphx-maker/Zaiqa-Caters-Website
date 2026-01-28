import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:meal_brand/widgets/mobile_drawer.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        endDrawer: const MobileDrawer(),
        appBar: AppBar(
          title: Text(
            "Dashboard",
            style: GoogleFonts.dmSerifDisplay(color: const Color(0xFF2C5F2D)),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF2C5F2D)),
          centerTitle: true,
          bottom: TabBar(
            labelColor: const Color(0xFF2C5F2D),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF2C5F2D),
            tabs: const [
              Tab(icon: Icon(Icons.people), text: "Customers"),
              Tab(icon: Icon(Icons.restaurant), text: "Orders"),
              Tab(icon: Icon(Icons.menu_book), text: "Menu"),
              Tab(icon: Icon(Icons.calendar_today), text: "Plans"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _CustomersTab(),
            _OrdersTab(),
            _ManageMenuTab(),
            _WeeklyPlansTab(),
          ],
        ),
      ),
    );
  }
}

class _WeeklyPlansTab extends StatefulWidget {
  const _WeeklyPlansTab();

  @override
  State<_WeeklyPlansTab> createState() => _WeeklyPlansTabState();
}

class _WeeklyPlansTabState extends State<_WeeklyPlansTab> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Meal Library List
  List<String> _dishLibrary = [];

  // Zen Plan (Mon-Sun) - Stores Dish Names
  final Map<String, String?> _zenSelection = {
    "Mon": null,
    "Tue": null,
    "Wed": null,
    "Thu": null,
    "Fri": null,
    "Sat": null,
    "Sun": null,
  };

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    await _fetchDishes();
    await _fetchWeeklyMenu();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchDishes() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('dishes')
          .get();
      _dishLibrary =
          snapshot.docs.map((d) => d.data()['name'].toString()).toList()
            ..sort(); // Alphabetical
    } catch (e) {
      debugPrint("Error fetching dishes: $e");
    }
  }

  Future<void> _fetchWeeklyMenu() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('weekly_menu')
          .doc('current_week')
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        // Load Zen Data
        final zenData = data['zen'] as Map<String, dynamic>?;
        if (zenData != null) {
          zenData.forEach((key, value) {
            if (_zenSelection.containsKey(key)) {
              if (!_dishLibrary.contains(value)) {
                _dishLibrary.add(value.toString());
              }
              _zenSelection[key] = value.toString();
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching weekly menu: $e");
    }
  }

  Future<void> _saveWeeklyMenu() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // Convert selections to Map for Firestore (remove nulls if any, though validation handles required)
        final zenMap = _zenSelection.map(
          (key, val) => MapEntry(key, val ?? ""),
        );

        await FirebaseFirestore.instance
            .collection('weekly_menu')
            .doc('current_week')
            .set(
              {'zen': zenMap, 'updatedAt': FieldValue.serverTimestamp()},
              SetOptions(merge: true),
            ); // Merge to avoid deleting other potential data if any

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Weekly Menus Updated!")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error saving: $e")));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dishLibrary.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant_menu, size: 60, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              "No dishes in Meal Library",
              style: GoogleFonts.dmSans(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Switch to Menu Tab
                DefaultTabController.of(context).animateTo(2);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C5F2D),
                foregroundColor: Colors.white,
              ),
              child: const Text("Go to Menu Tab to Add Dishes"),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Manage Weekly Menus",
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 28,
                color: const Color(0xFF2C5F2D),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Select meals from your library.",
              style: GoogleFonts.dmSans(color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),

            // Zen Section
            _buildPlanSection(
              "The Full Zen",
              const Color(0xFFE0F2F1),
              _zenSelection,
            ),
            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveWeeklyMenu,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C5F2D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Save All Changes",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanSection(
    String title,
    Color color,
    Map<String, String?> selectionMap,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C5F2D),
            ),
          ),
          const SizedBox(height: 20),
          ...selectionMap.keys.map((day) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text(
                      "$day:",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectionMap[day],
                      isExpanded: true,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "Select dish...",
                      ),
                      items: _dishLibrary
                          .map(
                            (dish) => DropdownMenuItem(
                              value: dish,
                              child: Text(dish),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          selectionMap[day] = val;
                        });
                      },
                      validator: (val) =>
                          val == null || val.isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ManageMenuTab extends StatefulWidget {
  const _ManageMenuTab();

  @override
  State<_ManageMenuTab> createState() => _ManageMenuTabState();
}

class _ManageMenuTabState extends State<_ManageMenuTab> {
  bool _isFridaySpecials = true; // true = Friday Specials, false = Meal Library

  void _showAddEditItemDialog(
    BuildContext context, {
    DocumentSnapshot? item,
  }) async {
    await showDialog(
      context: context,
      builder: (context) =>
          _AddEditItemDialog(item: item, isFridaySpecial: _isFridaySpecials),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditItemDialog(context),
        backgroundColor: const Color(0xFF2C5F2D),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          _isFridaySpecials ? "Add Special" : "Add Dish",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ToggleButtons(
              isSelected: [_isFridaySpecials, !_isFridaySpecials],
              onPressed: (index) {
                setState(() {
                  _isFridaySpecials = index == 0;
                });
              },
              fillColor: const Color(0xFF2C5F2D),
              selectedColor: Colors.white,
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(10),
              constraints: const BoxConstraints(minHeight: 40, minWidth: 150),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Friday Specials",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Meal Library",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(_isFridaySpecials ? 'special_items' : 'dishes')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data!.docs;

                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      _isFridaySpecials
                          ? "No specials found. Add one!"
                          : "No dishes in library. Add one!",
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final data = item.data() as Map<String, dynamic>;

                    if (_isFridaySpecials) {
                      // Original Special Item Card
                      final isActive = data['isActive'] ?? false;
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: data['image'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: data['image'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                    errorWidget: (_, __, ___) =>
                                        const Icon(Icons.fastfood),
                                  ),
                                )
                              : const Icon(Icons.fastfood),
                          title: Text(data['name'] ?? 'Unnamed Item'),
                          subtitle: Text(
                            "\$${data['price']?.toString() ?? '0.00'}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: isActive,
                                activeColor: const Color(0xFF2C5F2D),
                                onChanged: (val) {
                                  FirebaseFirestore.instance
                                      .collection('special_items')
                                      .doc(item.id)
                                      .update({'isActive': val});
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.grey,
                                ),
                                onPressed: () =>
                                    _showAddEditItemDialog(context, item: item),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      // Simple Dish Card
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFE0F2F1),
                            child: const Icon(
                              Icons.restaurant_menu,
                              color: Color(0xFF2C5F2D),
                            ),
                          ),
                          title: Text(data['name'] ?? 'Unnamed Dish'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.grey),
                            onPressed: () =>
                                _showAddEditItemDialog(context, item: item),
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AddEditItemDialog extends StatefulWidget {
  final DocumentSnapshot? item;
  final bool isFridaySpecial;

  const _AddEditItemDialog({this.item, required this.isFridaySpecial});

  @override
  State<_AddEditItemDialog> createState() => _AddEditItemDialogState();
}

class _AddEditItemDialogState extends State<_AddEditItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      final data = widget.item!.data() as Map<String, dynamic>;
      _nameController.text = data['name'] ?? '';
      _descController.text = data['description'] ?? '';
      _priceController.text = data['price']?.toString() ?? '';
      _imageController.text = data['image'] ?? '';
    }
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final collection = widget.isFridaySpecial ? 'special_items' : 'dishes';

        final Map<String, dynamic> data = {'name': _nameController.text.trim()};

        // Add additional fields only if needed (Friday Special or description for dish)
        if (widget.isFridaySpecial) {
          data['description'] = _descController.text.trim();
          data['price'] = double.tryParse(_priceController.text.trim()) ?? 0.0;
          data['image'] = _imageController.text.trim();
          data['isActive'] = widget.item != null
              ? (widget.item!.data() as Map<String, dynamic>)['isActive']
              : true;
        } else {
          // For Library dishes, maybe simple description?
          data['description'] = _descController.text.trim();
        }

        if (widget.item == null) {
          await FirebaseFirestore.instance.collection(collection).add(data);
        } else {
          await FirebaseFirestore.instance
              .collection(collection)
              .doc(widget.item!.id)
              .update(data);
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        debugPrint("Error saving item: $e");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteItem() async {
    if (widget.item == null) return;
    setState(() => _isLoading = true);
    try {
      final collection = widget.isFridaySpecial ? 'special_items' : 'dishes';
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(widget.item!.id)
          .delete();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Error deleting item: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.item == null
        ? (widget.isFridaySpecial ? "Add Special" : "Add Dish")
        : (widget.isFridaySpecial ? "Edit Special" : "Edit Dish");

    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (val) =>
                    val == null || val.isEmpty ? "Required" : null,
              ),
              if (widget.isFridaySpecial) ...[
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: "Description"),
                  maxLines: 3,
                  validator: (val) =>
                      val == null || val.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  controller: _imageController,
                  decoration: const InputDecoration(labelText: "Image URL"),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Required" : null,
                ),
              ] else ...[
                TextFormField(
                  // Simple description optional for Dishes
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: "Description (Optional)",
                  ),
                  maxLines: 2,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (widget.item != null)
          TextButton(
            onPressed: _isLoading ? null : _deleteItem,
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveItem,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2C5F2D),
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text("Save"),
        ),
      ],
    );
  }
}

class _CustomersTab extends StatelessWidget {
  const _CustomersTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('customers').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final customers = snapshot.data!.docs;

        if (customers.isEmpty) {
          return const Center(child: Text("No customers found."));
        }

        return ListView.builder(
          itemCount: customers.length,
          itemBuilder: (context, index) {
            final data = customers[index].data() as Map<String, dynamic>;
            final name = "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}"
                .trim();
            final email = data['email'] ?? 'No Email';
            final plan = data['plan'] ?? 'No Active Plan';
            final phone = data['phone'] ?? 'No Phone';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFE0F2F1),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : "?",
                    style: const TextStyle(color: Color(0xFF2C5F2D)),
                  ),
                ),
                title: Text(name.isNotEmpty ? name : "Unknown User"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(email),
                    Text("Phone: $phone"),
                    Text(
                      "Plan: $plan",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: plan != 'no' && plan != null
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}

class _OrdersTab extends StatefulWidget {
  const _OrdersTab();

  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  String _filterStatus = 'All'; // All, Pending, Completed, Canceled

  Future<void> _updateStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(docId).update({
        'status': newStatus,
      });
    } catch (e) {
      debugPrint("Error updating status: $e");
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text(
                "Filter by: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: _filterStatus,
                items: ["All", "Pending", "Completed", "Canceled"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _filterStatus = val);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .orderBy('orderDate', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              var orders = snapshot.data!.docs;

              // Client-side filtering because of simplified index requirements
              if (_filterStatus != 'All') {
                orders = orders.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['status'] ?? 'Pending';
                  return status.toString().toLowerCase() ==
                      _filterStatus.toLowerCase();
                }).toList();
              }

              if (orders.isEmpty) {
                return const Center(child: Text("No orders found."));
              }

              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final orderDoc = orders[index];
                  final data = orderDoc.data() as Map<String, dynamic>;
                  final customerName = data['customerName'] ?? 'Guest';
                  final item = data['item'] ?? 'Unknown Item';
                  final price = data['price']?.toString() ?? '0.00';
                  final date = (data['orderDate'] as Timestamp?)?.toDate();
                  final formattedDate = date != null
                      ? DateFormat.yMMMd().add_jm().format(date)
                      : "Unknown Date";
                  final status = data['status'] ?? 'Pending';

                  final itemsList = data['items'] as List<dynamic>?;
                  String displayTitle = item.toString();

                  if (itemsList != null && itemsList.isNotEmpty) {
                    displayTitle = itemsList
                        .map((i) => i['name'].toString())
                        .join(", ");
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(
                          status,
                        ).withOpacity(0.2),
                        child: Icon(
                          Icons.fastfood,
                          color: _getStatusColor(status),
                        ),
                      ),
                      title: Text(
                        "$displayTitle - \$$price",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        "Ordered by: $customerName\nStatus: $status",
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (itemsList != null &&
                                  itemsList.isNotEmpty) ...[
                                const Text(
                                  "Items:",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                ...itemsList.map((i) {
                                  final map = i as Map<String, dynamic>;
                                  return Text(
                                    "- ${map['name']} (\$${map['price']})",
                                  );
                                }),
                                const SizedBox(height: 10),
                              ],
                              Text("Date: $formattedDate"),
                              if (data['address'] != null &&
                                  data['address'].toString().isNotEmpty)
                                Text("Address: ${data['address']}"),
                              if (data['email'] != null)
                                Text("Email: ${data['email']}"),
                              if (data['phone'] != null)
                                Text("Phone: ${data['phone']}"),
                              const SizedBox(height: 20),
                              const Text(
                                "Update Status:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (status != 'Pending')
                                    ElevatedButton.icon(
                                      icon: const Icon(
                                        Icons.hourglass_empty,
                                        size: 16,
                                      ),
                                      label: const Text("Pending"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () =>
                                          _updateStatus(orderDoc.id, "Pending"),
                                    ),
                                  if (status != 'Completed')
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.check, size: 16),
                                      label: const Text("Complete"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () => _updateStatus(
                                        orderDoc.id,
                                        "Completed",
                                      ),
                                    ),
                                  if (status != 'Canceled')
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.close, size: 16),
                                      label: const Text("Cancel"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () => _updateStatus(
                                        orderDoc.id,
                                        "Canceled",
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
