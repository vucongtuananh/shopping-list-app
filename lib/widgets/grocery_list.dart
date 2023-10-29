import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/widgets/add_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadItem();
    //this action has been actived here when initial app
  }

  void _loadItem() async {
    final url = Uri.https('shopping-list-app-52d8f-default-rtdb.firebaseio.com', 'shopping-list.json');
    final response = await http.get(url);

    if (response.body == 'null') {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final Map<String, dynamic> listResponse = json.decode(response.body);
    print(response.body);
    final List<GroceryItem> loadItems = [];
    for (final item in listResponse.entries) {
      final categoryLoadItem = categories.entries.firstWhere((cat) => cat.value.title == item.value['category']).value;
      loadItems.add(GroceryItem(id: item.key, name: item.value["name"], quantity: item.value["quantity"], category: categoryLoadItem));
    }
    setState(() {
      _groceryItems = loadItems;
      _isLoading = false;
    });
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(MaterialPageRoute(
      builder: (context) => const AddItem(),
    ));
    // _loadItem();
    if (newItem == null) return;
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) {
    final url = Uri.https('shopping-list-app-52d8f-default-rtdb.firebaseio.com', 'shopping-list/${item.id}.json');
    final response = http.delete(url);
    setState(() {
      _groceryItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'There is not item yet!',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20),
          ),
          Text(
            'Please add a new item!',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemBuilder: (context, index) => Dismissible(
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          key: ValueKey(_groceryItems[index].id),
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text("${_groceryItems[index].quantity}"),
          ),
        ),
        itemCount: _groceryItems.length,
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
