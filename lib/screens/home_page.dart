import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../database/database_helper.dart';
import 'contact_form.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Contact> contacts = [];

  final searchController = TextEditingController();

  bool favoritesOnly = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadContacts();
    searchController.addListener(loadContacts);
  }

  @override
  void dispose() {
    searchController.removeListener(loadContacts);
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadContacts() async {
    final data = await DatabaseHelper.instance.getContacts(
      search: searchController.text.trim(),
      favoritesOnly: favoritesOnly,
    );

    if (!mounted) return;

    setState(() {
      contacts = data;
      isLoading = false;
    });
  }

  Future<void> openForm({Contact? contact}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactForm(contact: contact),
      ),
    );

    if (result == true) {
      loadContacts();
    }
  }

  Future<void> deleteContact(int id) async {
    await DatabaseHelper.instance.deleteContact(id);
    loadContacts();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact deleted successfully'),
      ),
    );
  }

  Future<void> toggleFavorite(Contact contact) async {
    final updatedContact = contact.copyWith(
      isFavorite: !contact.isFavorite,
    );

    await DatabaseHelper.instance.updateContact(updatedContact);
    loadContacts();
  }

  void confirmDelete(Contact contact) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Contact'),
          content: Text(
            'Are you sure you want to delete ${contact.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteContact(contact.id!);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contact Manager',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            tooltip: 'Favorite Contacts',
            onPressed: () {
              setState(() {
                favoritesOnly = !favoritesOnly;
              });
              loadContacts();
            },
            icon: Icon(
              favoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search contact by name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () {
                    searchController.clear();
                  },
                  icon: const Icon(Icons.clear),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  favoritesOnly ? 'Favorite Contacts' : 'All Contacts',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Total: ${contacts.length}',
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : contacts.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.contacts,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'No contacts found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => openForm(),
                    child: const Text('Add Contact'),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),

                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.indigo,
                      child: Text(
                        contact.name.isNotEmpty
                            ? contact.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),

                    title: Text(
                      contact.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text('ID: ${contact.id}'),
                          Text('Phone: ${contact.phone}'),
                          Text('Email: ${contact.email}'),
                          Text('Address: ${contact.address}'),
                        ],
                      ),
                    ),

                    isThreeLine: true,

                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          openForm(contact: contact);
                        } else if (value == 'delete') {
                          confirmDelete(contact);
                        } else if (value == 'favorite') {
                          toggleFavorite(contact);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                        PopupMenuItem(
                          value: 'favorite',
                          child: Text(
                            contact.isFavorite
                                ? 'Remove Favorite'
                                : 'Add Favorite',
                          ),
                        ),
                      ],
                    ),

                    onTap: () {
                      openForm(contact: contact);
                    },


                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => openForm(),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
