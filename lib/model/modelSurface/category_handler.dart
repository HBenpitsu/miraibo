import 'package:miraibo/model/modelSurface/view_obj.dart' as view_obj;
import 'package:miraibo/model/transactions/category.dart';
import 'package:miraibo/model/infra/persistent_db_table_definitions.dart'
    as dat;

class CategoryHandler {
  Future<List<view_obj.Category>> all() async {
    var res = await FetchAllCategories().execute();
    return res.map((e) => view_obj.Category(id: e.id, name: e.name)).toList();
  }

  Future<view_obj.Category> first() async {
    var res = await FetchFirstCategory().execute();
    return view_obj.Category(id: res.id, name: res.name);
  }

  Future<void> replace(
      view_obj.Category replaced, view_obj.Category replaceWith) async {
    await ReplaceCategory(dat.Category(id: replaced.id, name: replaced.name),
            dat.Category(id: replaceWith.id, name: replaceWith.name))
        .execute();
  }

  Future<view_obj.Category> find(int id) async {
    var res = await FindCategory(id).execute();
    return view_obj.Category(id: res.id, name: res.name);
  }

  Future<view_obj.Category> make(String name) async {
    var id = await SaveCategory(dat.Category(name: name)).execute();
    return view_obj.Category(id: id, name: name);
  }

  Future<void> save(view_obj.Category category) async {
    await SaveCategory(dat.Category(id: category.id, name: category.name))
        .execute();
  }
}
