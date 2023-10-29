import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';
import 'dart:convert';

import 'package:shopping_list_app/models/grocery_item.dart';

class AddItem extends StatefulWidget {
  const AddItem({super.key});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  var _name = '';

  var _quantity = 1;

  var _category = categories[Categories.vegetables]!;

  var _formKey = GlobalKey<FormState>();

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      var url = Uri.https("test-for-list-app-default-rtdb.firebaseio.com", "/app.json");
      final response = await http.post(url,
          body: json.encode({
            "name": _name,
            "quantity": _quantity.toString(),
            "category": _category!.title,
          }),
          headers: {'Content': 'application'});
      var resBody = json.decode(response.body);
      print(resBody);
      if (!context.mounted) {
        return;
      }
      Navigator.pop(context, GroceryItem(id: resBody['name'], name: _name, quantity: _quantity, category: _category));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add item"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                onSaved: (newValue) {
                  _name = newValue!;
                },
                maxLength: 50,
                decoration: const InputDecoration(label: Text("Name")),
                validator: (value) {
                  if (value == null || value == "") {
                    return "no oke bro";
                  }
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      onSaved: (newValue) {
                        _quantity = int.parse(newValue!);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty || int.tryParse(value) == null || int.tryParse(value)! <= 0) {
                          return "no ok bro ";
                        }
                      },
                      initialValue: "1",
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(label: Text("Quantity")),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: DropdownButtonFormField(
                    items: [
                      for (var item in categories.entries)
                        DropdownMenuItem(
                            value: item.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  color: item.value.color,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(item.value.title)
                              ],
                            ))
                    ],
                    onChanged: (value) {
                      _category = value!;
                    },
                  )),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => _formKey.currentState!.reset(), child: const Text("Clear")),
                  ElevatedButton(onPressed: _saveItem, child: const Text("Submit"))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
