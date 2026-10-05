// lab3.dart - Campus Cafe Order System
// Name: Aitzaz Ul Hassan Roll no: 04072313026
const String rollNo = '04072313026'; // e.g. '2100672347'
// ===== Seeded settings (generated from YOUR roll number). Do not edit. =====
final int seed = int.parse(rollNo.substring(rollNo.length - 2));
final int t = seed ~/ 10; // tens digit
final int u = seed % 10; // units digit
const List<String> menu = [
  'Chai',
  'Latte',
  'Mocha',
  'Samosa',
  'Brownie',
  'Sandwich',
  'Cold Coffee',
  'Fries',
  'Pakora',
  'Zinger Wrap',
];
int priceOf(int i) => 100 + 7 * i + 3 * t; // price of menu[i], in rupees
final int priceFloor = 60 + 5 * t;
final int taxPercent = 5 + t;
final int bigOrderLimit = 450 + 20 * t;
final int balanceCap = 600 + 20 * t;
final int couponPercent = 5 + t + u;

// ===========================================================================
class Dish {
  // late promises Dart that name and price are assigned before they are read.
  // Without it, a non-nullable field with no value does not compile.
  late String name;
  late int price;
  // Self-check: item1 and item2 are separate objects, each with its own
  // copy of name and price, so discounting item2 does not change item1.
}

class MenuItem {
  //  price cannot be final because the constructor body
  // reassigns it (raises it to priceFloor when it is too low),
  // and a final field can only be assigned once.
  String name;
  int price;

  // Think: the floor check is in the body of the main constructor only.
  // MenuItem.free() is a separate constructor that sets price = 0 in its
  // initializer list and never runs the main constructor's body, so the
  // floor is never applied.

  MenuItem(this.name, this.price) {
    if (this.price < priceFloor) {
      this.price = priceFloor;
    }
  }
  MenuItem.free(this.name) : price = 0;

  MenuItem.fromString(String text)
    : name = text.split(':')[0],
      price = int.parse(text.split(':')[1]);
}

// Think: the underscore makes _instance and _internal private to this file.
// If they were public, other code could call OrderLog._internal() to create
// extra logs, or overwrite _instance, which would break the one-shared-log rule.

class OrderLog {
  static OrderLog? _instance;
  final List<String> entries = [];

  OrderLog._internal(); // private named constructor

  factory OrderLog() {
    _instance ??= OrderLog._internal();
    return _instance!;
  }

  void add(String msg) => entries.add(msg);
}

//  writing tax = total * taxPercent ~/ 100 gives an error because
// the initializer list runs before the object exists, so fields like
// total are not available yet. Only constructor parameters can be used,
// so I recompute from item.price * qty instead.
class OrderLine {
  final MenuItem item;
  final int qty;
  final int total;
  final int tax;

  OrderLine(this.item, this.qty)
    : total = item.price * qty,
      tax = (item.price * qty * taxPercent) ~/ 100,
      assert(qty > 0, 'qty must be positive');

  //  line.grand = 5 fails because grand is a getter only, so it is
  // read-only and there is no setter to handle an assignment. To make it
  // legal I would have to add a setter: set grand(int v) { ... }

  int get grand => total + tax;
  bool get isBigOrder => grand > bigOrderLimit;
  String get label => '${item.name} x$qty';
}

OrderLine mainOrder() {
  return OrderLine(MenuItem(menu[u], priceOf(u)), 2 + (t + u) % 5);
}
//  besides silently clamping, a setter could throw an exception
// (e.g. ArgumentError) so the caller knows the value was invalid, or log
// a warning, or ignore the bad value and keep the old balance.

class StudentCard {
  final String owner;
  int _balance;

  StudentCard(this.owner) : _balance = 0;

  int get balance => _balance;

  set balance(int v) {
    if (v < 0) {
      _balance = 0;
    } else if (v > balanceCap) {
      _balance = balanceCap;
    } else {
      _balance = v;
    }
  }
}

void main() {
  print('Seed: $seed (t=$t, u=$u)');
  step1();
  step2();
  step3();
  step4();
  step5();
  step6();
  step7();
  step8();
  step9();
  step10();
}

void step1() {
  print('--- Step 1 ---');

  var item1 = Dish();
  item1.name = menu[u];
  item1.price = priceOf(u);

  var item2 = Dish();
  item2.name = menu[(u + 1) % 10];
  item2.price = priceOf((u + 1) % 10);
  item2.price = item2.price - u;

  print('Step 1: ${item1.name} Rs ${item1.price}');
  print('Step 1: ${item2.name} Rs ${item2.price}');
}

void step2() {
  print('--- Step 2 ---');
  var a = MenuItem(menu[u], priceOf(u));
  var b = MenuItem('Test Special', 15 * u);

  print('Step 2: ${a.name} Rs ${a.price}');
  print('Step 2: Test Special Rs ${b.price}');
}

void step3() {
  print('--- Step 3 ---');
  var freebie = MenuItem.free('Water');

  var i = (u + 2) % 10;
  var parsed = MenuItem.fromString('${menu[i]}:${priceOf(i)}');

  print('Step 3: ${freebie.name} Rs ${freebie.price}');
  print('Step 3: ${parsed.name} Rs ${parsed.price}');
  print('Step 3: floor=$priceFloor, free price=${freebie.price}');
}

void step4() {
  print('--- Step 4 ---');
  var log1 = OrderLog();
  var log2 = OrderLog();

  for (var i = 1; i <= u + 2; i++) {
    var msg = 'order #${100 * t + i}';
    if (i.isOdd) {
      log1.add(msg);
    } else {
      log2.add(msg);
    }
  }

  print('Step 4: same object? ${identical(log1, log2)}');
  print('Step 4: entries = ${log1.entries.length}');
  print('Step 4: last = ${log2.entries.last}');
}

void step5() {
  print('--- Step 5 ---');

  var line = mainOrder();

  print('Step 5: ${line.item.name} x${line.qty}');
  print('Step 5: total=${line.total} tax=${line.tax}');

  try {
    OrderLine(line.item, 0);
    print('Step 5: assert did NOT fire');
  } on AssertionError {
    print('Step 5: assert fired');
  }
}

void step6() {
  print('--- Step 6 ---');
  var line = mainOrder();

  print('Step 6: grand=${line.grand}');
  print('Step 6: big order? ${line.isBigOrder} (limit $bigOrderLimit)');
  print('Step 6: label=${line.label}');
}

void step7() {
  print('--- Step 7 ---');
  var card = StudentCard('S$seed');

  card.balance = seed * 10 + 50;
  print('Step 7: topped up -> ${card.balance}');

  card.balance = -seed - 1;
  print('Step 7: bad value -> ${card.balance}');

  card.balance = balanceCap - u;
  print('Step 7: reset -> ${card.balance}');

  card.balance = card.balance - mainOrder().grand; // pay the main order
  print('Step 7: paid order -> ${card.balance}');
}

void step8() {
  print('--- Step 8 ---');
}

void step9() {
  print('--- Step 9 ---');
}

void step10() {
  print('--- Step 10 ---');
}
