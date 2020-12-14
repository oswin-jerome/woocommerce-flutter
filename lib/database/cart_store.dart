import 'package:hive/hive.dart';
part 'cart.g.dart';

@HiveType(typeId: 0)
class Cart extends HiveObject {
  @HiveField(0)
  int id;
  @HiveField(1)
  int count;
  @HiveField(2)
  Map product;
}
