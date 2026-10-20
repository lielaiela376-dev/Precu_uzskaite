import 'package:flutter/material.dart';

void main() {
  runApp(const SecondHandApp());
}

class SecondHandApp extends StatelessWidget {
  const SecondHandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lietoto Preču Uzskaite',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const InventoryScreen(),
    );
  }
}

class Item {
  String name;
  String category;
  double buyPrice;
  double sellPrice;
  String condition;
  bool isSold;

  Item({
    required this.name,
    required this.category,
    required this.buyPrice,
    required this.sellPrice,
    required this.condition,
    this.isSold = false,
  });
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final List<Item> _items = [];

  void _addItem(Item item) {
    setState(() {
      _items.add(item);
    });
  }

  void _toggleSoldStatus(int index) {
    setState(() {
      _items[index].isSold = !_items[index].isSold;
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final buyPriceController = TextEditingController();
    final sellPriceController = TextEditingController();
    String selectedCondition = 'Lietots (labs)';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pievienot jaunu preci'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Preces nosaukums')),
                TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Kategorija (piem., Apģērbs)')),
                TextField(controller: buyPriceController, decoration: const InputDecoration(labelText: 'Iepirkuma cena (€)'), keyboardType: TextInputType.number),
                TextField(controller: sellPriceController, decoration: const InputDecoration(labelText: 'Plānotā pārdošanas cena (€)'), keyboardType: TextInputType.number),
                DropdownButtonFormField<String>(
                  value: selectedCondition,
                  items: ['Jauns', 'Lietots (labs)', 'Lietots (ar defektu)']
                      .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) selectedCondition = value;
                  },
                  decoration: const InputDecoration(labelText: 'Stāvoklis'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Atcelt')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _addItem(Item(
                    name: nameController.text,
                    category: categoryController.text.isNotEmpty ? categoryController.text : 'Dažādi',
                    buyPrice: double.tryParse(buyPriceController.text) ?? 0.0,
                    sellPrice: double.tryParse(sellPriceController.text) ?? 0.0,
                    condition: selectedCondition,
                  ));
                  Navigator.pop(context);
                }
              },
              child: const Text('Saglabāt'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalProfit = _items.where((i) => i.isSold).fold(0, (sum, i) => sum + (i.sellPrice - i.buyPrice));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preču Uzskaite Pārdošanai'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Kopējā peļņa no pārdotajām:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${totalProfit.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
              ],
            ),
          ),
          Expanded(
            child: _items.isEmpty
                ? const Center(child: Text('Nav pievienota neviena prece. Spied "+" lai pievienotu.'))
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      double expectedProfit = item.sellPrice - item.buyPrice;
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          title: Text(item.name, style: TextStyle(decoration: item.isSold ? TextDecoration.lineThrough : null)),
                          subtitle: Text('Stāvoklis: ${item.condition}\nIepirkums: ${item.buyPrice} € | Pārdošana: ${item.sellPrice} €\nPeļņa: ${expectedProfit.toStringAsFixed(2)} €'),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(item.isSold ? Icons.undo : Icons.check, color: item.isSold ? Colors.orange : Colors.green),
                                onPressed: () => _toggleSoldStatus(index),
                                tooltip: item.isSold ? 'Atjaunot kā pieejamu' : 'Atzīmēt kā pārdotu',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteItem(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
