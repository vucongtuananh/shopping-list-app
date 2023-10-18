import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/dummy_items.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/widgets/add_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(MaterialPageRoute(
      builder: (context) => const AddItem(),
    ));
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) {
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
