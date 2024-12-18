class Receipt {
  final String id; // Unique identifier
  final String date;
  final String ms;
  final List<Item> items;

  Receipt({
    required this.id,
    required this.date,
    required this.ms,
    required this.items,
  });

  // Convert Receipt to JSON (for saving in local storage or Firebase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'ms': ms,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  // Create Receipt from JSON
  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'],
      date: json['date'],
      ms: json['ms'],
      items: (json['items'] as List).map((item) => Item.fromJson(item)).toList(),
    );
  }
}

// Model for individual items in the receipt
class Item {
  final String qty;
  final String particular;
  final String rate;
  final String amount;

  Item({
    required this.qty,
    required this.particular,
    required this.rate,
    required this.amount,
  });

  // Convert Item to JSON
  Map<String, dynamic> toJson() {
    return {
      'qty': qty,
      'particular': particular,
      'rate': rate,
      'amount': amount,
    };
  }

  // Create Item from JSON
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      qty: json['qty'],
      particular: json['particular'],
      rate: json['rate'],
      amount: json['amount'],
    );
  }
}
