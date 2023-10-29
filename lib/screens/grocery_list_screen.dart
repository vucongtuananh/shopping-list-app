import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/screens/add_item.dart';
import 'package:http/http.dart' as http;

class GroceryListItem extends StatefulWidget {
  const GroceryListItem({super.key});

  @override
  State<GroceryListItem> createState() => _GroceryListItemState();
}

class _GroceryListItemState extends State<GroceryListItem> {
  List<GroceryItem> _groceries = [];
  bool _loading = true;
  void _addItem() async {
    final newData = await Navigator.push<GroceryItem>(
      context,
      MaterialPageRoute(builder: (context) => const AddItem()),
    );
    if (newData == null) return;
    setState(() {
      _groceries.add(newData);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  void _loadItem() async {
    var url = Uri.https("test-for-list-app-default-rtdb.firebaseio.com", "/app.json");
    final response = await http.get(url);

    final Map<String, dynamic> listResponse = json.decode(response.body);
    List<GroceryItem> listCategories = [];
    for (var item in listResponse.entries) {
      final Category category = categories.entries.firstWhere((e) => e.value.title == item.value["category"]).value;
      listCategories.add(GroceryItem(id: item.key, name: item.value["name"], quantity: int.parse(item.value["quantity"]), category: category));
    }
    setState(() {
      _groceries = listCategories;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("There is no item yet!", style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.onBackground)),
        Text("Please add a new item!", style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.onBackground))
      ],
    ));
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_groceries.isNotEmpty) {
      content = ListView.builder(
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(_groceries[index].id),
            child: ListTile(
              leading: Container(
                width: 12,
                height: 12,
                color: _groceries[index].category.color,
              ),
              subtitle: Text(_groceries[index].category.title),
              title: Text(_groceries[index].name),
              trailing: Text(_groceries[index].quantity.toString()),
            ),
          );
        },
        itemCount: _groceries.length,
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text("Your groceries"),
          actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
        ),
        body: content);
  }
}
