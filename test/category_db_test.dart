import 'package:flutter_test/flutter_test.dart';

import '../lib/data/category_data.dart';

void printList(List<Category> list) {
  print(list.map((e) => e.name).join(','));
}

void main() async {
  test('category db works?', () async {
    CategoryTable categoryTable = await CategoryTable.use(null);
    var res;
    res = await categoryTable.fetchAll(null);
    printList(res);

    Category newCat = await Category.make('New Category');
    res = await categoryTable.fetchAll(null);
    printList(res);

    await newCat.rename('Renamed Category');

    res = await categoryTable.fetchAll(null);
    printList(res);

    await newCat.integrateWith(res.first);

    res = await categoryTable.fetchAll(null);
    printList(res);

    await categoryTable.clear();
  });
}
