import 'package:flutter/foundation.dart' as dev;
import 'package:flutter_test/flutter_test.dart';
import 'package:miraibo/data/category_data.dart';

void printList(List<Category> list) {
  dev.debugPrint(list.map((e) => e.name).join(','));
}

void main() async {
  test('initial category', () async {
    CategoryTable categoryTable = await CategoryTable.use(null);
    var res = await categoryTable.fetchAll(null);
    printList(res);
  });
  test('new category', () async {
    CategoryTable categoryTable = await CategoryTable.use(null);
    await categoryTable.make('test', null);
    var res = await categoryTable.fetchAll(null);
    printList(res);
  });
  test('rename category', () async {
    CategoryTable categoryTable = await CategoryTable.use(null);
    var category = await categoryTable.make('test', null);
    await category.rename('renamed');
    var res = await categoryTable.fetchAll(null);
    printList(res);
  });

  tearDownAll(() async {
    CategoryTable categoryTable = await CategoryTable.use(null);
    await categoryTable.clear();
  });
}
