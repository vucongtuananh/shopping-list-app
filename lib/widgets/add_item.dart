import 'dart:convert';

import 'package:shopping_list_app/data/categories.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class AddItem extends StatefulWidget {
  const AddItem({super.key});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _enteredCategory = categories[Categories.vegetables]!;

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      var url = Uri.https('shopping-list-app-52d8f-default-rtdb.firebaseio.com', 'shopping-list.json');
      http.post(url, headers: {'Content-type': 'application/json'}, body: json.encode({'name': _enteredName, 'quantity': _enteredQuantity, 'category': _enteredCategory.title}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Let's add item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(
                    label: Text("Name"),
                  ),
                  validator: (value) {
                    if (value == null || value == "" || value.trim().length <= 1 || value.trim().length > 50) {
                      return "Must be between 1 and 50 characters";
                    }
                  },
                  onSaved: (newValue) {
                    _enteredName = newValue!;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(label: Text("Quantity")),
                        initialValue: _enteredQuantity.toString(),
                        validator: (value) {
                          if (value == null || value.isEmpty || int.tryParse(value) == null || int.tryParse(value)! <= 0) {
                            return "Must be a valid , positive number !";
                          }
                        },
                        onSaved: (newValue) {
                          _enteredQuantity = int.parse(newValue!);
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 18,
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: _enteredCategory,
                        items: [
                          for (final category in categories.entries)
                            //duyet 1 map dung .ENTRIES
                            DropdownMenuItem(
                                value: category.value,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: category.value.color,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Text(category.value.title)
                                  ],
                                ))
                        ],
                        onChanged: (value) {
                          _enteredCategory = value!;
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          _formKey.currentState!.reset();
                        },
                        child: const Text("Reset")),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(onPressed: _saveItem, child: const Text("Add Item"))
                  ],
                )
              ],
            )),
      ),
    );
  }
}
