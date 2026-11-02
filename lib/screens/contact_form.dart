import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../database/database_helper.dart';

class ContactForm extends StatefulWidget {
  final Contact? contact;

  const ContactForm({
    super.key,
    this.contact,
  });

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();

  bool isFavorite = false;

  @override
  void initState() {
    super.initState();

    if (widget.contact != null) {
      nameController.text = widget.contact!.name;
      phoneController.text = widget.contact!.phone;
      emailController.text = widget.contact!.email;
      addressController.text = widget.contact!.address;
      isFavorite = widget.contact!.isFavorite;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    final contact = Contact(
      id: widget.contact?.id,
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      address: addressController.text.trim(),
      isFavorite: isFavorite,
    );

    if (widget.contact == null) {
      await DatabaseHelper.instance.insertContact(contact);
    } else {
      await DatabaseHelper.instance.updateContact(contact);
    }

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  Widget buildField(
      String label,
      TextEditingController controller,
      IconData icon,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.contact != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Contact' : 'Add Contact'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(
                Icons.account_circle,
                size: 90,
                color: Colors.indigo,
              ),

              const SizedBox(height: 20),

              buildField(
                'Name',
                nameController,
                Icons.person,
              ),

              buildField(
                'Phone Number',
                phoneController,
                Icons.phone,
              ),

              buildField(
                'Email',
                emailController,
                Icons.email,
              ),

              buildField(
                'Address',
                addressController,
                Icons.location_on,
              ),

              SwitchListTile(
                title: const Text('Favorite Contact'),
                secondary: const Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
                value: isFavorite,
                onChanged: (value) {
                  setState(() {
                    isFavorite = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: saveContact,
                  icon: const Icon(Icons.save),
                  label: Text(
                    isEditing ? 'Update Contact' : 'Save Contact',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
