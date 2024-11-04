import 'package:miraibo/type/view_obj.dart' as view_obj;
import 'package:miraibo/model/transaction/category.dart';
import 'package:miraibo/type/model_obj.dart' as model_obj;

class CategoryHandler {
  Future<List<view_obj.Category>> all() async {
    var res = await FetchAllCategories().execute();
    return res.map((e) => view_obj.Category(id: e.id, name: e.name)).toList();
  }

  Future<void> replace(
      view_obj.Category replaced, view_obj.Category replaceWith) async {
    await ReplaceCategory(
            model_obj.Category(id: replaced.id, name: replaced.name),
            model_obj.Category(id: replaceWith.id, name: replaceWith.name))
        .execute();
  }

  Future<view_obj.Category> find(int id) async {
    var res = await FindCategory(id).execute();
    return view_obj.Category(id: res.id, name: res.name);
  }

  Future<view_obj.Category> make(String name) async {
    var id = await SaveCategory(model_obj.Category(name: name)).execute();
    return view_obj.Category(id: id, name: name);
  }

  Future<void> save(view_obj.Category category) async {
    await SaveCategory(model_obj.Category(id: category.id, name: category.name))
        .execute();
  }
}
