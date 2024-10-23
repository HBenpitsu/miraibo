import 'package:flutter/material.dart';
import 'package:miraibo/component/general_widget.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../data/category_data.dart';

/* 
In this file, we define the category related components
including SingleCategorySelector, MultipleCategorySelector, CategoryEditorSection

SingleCategorySelector is a dropdown menu that allows user to select one category.
MultipleCategorySelector is a mutable list form of categories that allows user to select multiple categories.
Mutable list form is a list of items that can be added, removed, and updated. It is implemented in general_widget.dart.
Two above components are used in ticket configurators.

CategoryEditorSection is a mutable list form of categories that allows user to rename, add, and integrate categories.
This component is used in the utils page for category management.
*/

/* 
<SingleCategorySelector>
SingleCategorySelector is a dropdown menu that allows user to select one category.
*/
class SingleCategorySelectorController {
  void Function(Category)? onUpdate;
  void _onUpdate(Category value) {
    if (onUpdate != null) {
      onUpdate!(value);
    }
  }

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  void Function()? onInitialized;
  void _onInitialized() {
    _isInitialized = true;
    if (onInitialized != null) {
      onInitialized!();
    }
  }

  Category? Function()? _category;
  Category? get selected => _category == null ? null : _category!();

  final Category? initiallySelectedCategory;

  SingleCategorySelectorController(
      {this.initiallySelectedCategory, this.onUpdate, this.onInitialized});
}

class SingleCategorySelector extends StatefulWidget {
  final SingleCategorySelectorController controller;
  final FocusNode? focusNode;
  const SingleCategorySelector(
      {super.key, required this.controller, this.focusNode});

  @override
  State<SingleCategorySelector> createState() => _SingleCategorySelectorState();
}

class _SingleCategorySelectorState extends State<SingleCategorySelector> {
  Category? selected;
  late Future<List<Category>> optionsFetched;

  @override
  void initState() {
    super.initState();
    widget.controller._isInitialized = false;
    widget.controller._category = () => selected;
    optionsFetched = Future(() async {
      var categoryTable = await CategoryTable.use();
      return categoryTable.fetchAll(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: optionsFetched,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          widget.controller._onInitialized();
          return DropdownMenu<Category>(
            focusNode: widget.focusNode,
            initialSelection: widget.controller.initiallySelectedCategory,
            dropdownMenuEntries: [
              for (Category category in snapshot.data as List<Category>)
                DropdownMenuEntry<Category>(
                    value: category, label: category.name)
            ],
            onSelected: (value) {
              if (value != null) {
                selected = value;
                widget.controller._onUpdate(value);
              }
            },
          );
        }
      },
    );
  }
}
// </SingleCategorySelector>

/* 
<MultipleCategorySelector>
MultipleCategorySelector is a mutable list form of categories that allows user to select multiple categories.
Mutable list form is a list of items that can be added, removed, and updated. It is implemented in general_widget.dart.

itemAdder: 
a dropdown menu that allows user to add a category to selection.
When a category is added, it is removed from the dropdown menu.

onItemTapped:
When an item is tapped, it is removed from the selection.

It also provides 'all categories' option, which allows user to select all categories at once.
When 'all categories' is selected, it hides the rest part.
*/
class MultipleCategorySelectorController {
  void Function()? onUpdate;
  void _onUpdated() {
    if (onUpdate != null) {
      onUpdate!();
    }
  }

  late List<Category> Function() _categories;
  List<Category> get selectedCategories => _categories();

  late bool Function() _allCategoriesSelected;
  bool get allCategoriesSelected => _allCategoriesSelected();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  void Function()? onInitialized;
  void _onInitialized() {
    _isInitialized = true;
    if (onInitialized != null) {
      onInitialized!();
    }
  }

  final List<Category> initiallySelectedCategories;
  final bool allCategoriesInitiallySelected;

  MultipleCategorySelectorController(
      {this.initiallySelectedCategories = const [],
      this.allCategoriesInitiallySelected = true,
      this.onUpdate,
      this.onInitialized});
}

class MultipleCategorySelector extends StatefulWidget {
  final MultipleCategorySelectorController controller;
  final FocusNode? focusNode;
  final double? width;

  const MultipleCategorySelector(
      {super.key, this.width, required this.controller, this.focusNode});

  @override
  State<MultipleCategorySelector> createState() =>
      _MultipleCategorySelectorState();
}

class _MultipleCategorySelectorState extends State<MultipleCategorySelector> {
  late List<Category> options;
  late final MutableListFormController<Category> mutableListCtl;
  bool allCategoriesSelected = false;
  bool isInitialized = false;

  late final Future<void> optionsInitialized;
  Future<void> initializeOptions() async {
    var categoryTable = await CategoryTable.use();
    options = await categoryTable.fetchAll(null);
    for (Category category in widget.controller.initiallySelectedCategories) {
      options.remove(category);
    }
    isInitialized = true;
    widget.controller._onInitialized();
  }

  @override
  void initState() {
    super.initState();
    // apply initial values
    allCategoriesSelected = widget.controller.allCategoriesInitiallySelected;
    optionsInitialized = initializeOptions();
    // initialize controller
    mutableListCtl = MutableListFormController<Category>(
      items: widget.controller.initiallySelectedCategories,
      toLabel: (item) => item.name,
    );
    mutableListCtl.onItemAdded = (item) {
      options.remove(item);
      widget.controller._onUpdated();
    };
    mutableListCtl.onItemRemoved = (item) {
      options.add(item);
      widget.controller._onUpdated();
    };
    // bind properties to controller
    widget.controller._categories = () => mutableListCtl.items;
    widget.controller._allCategoriesSelected = () => allCategoriesSelected;
  }

  List<DropdownMenuEntry<Category>> dropdownMenuEntries() {
    return [
      for (Category category in options)
        DropdownMenuEntry<Category>(value: category, label: category.name)
    ];
  }

  Widget itemAdder(BuildContext context) {
    var dropDownCtl = TextEditingController();
    return DropdownMenu<Category>(
      width: widget.width,
      controller: dropDownCtl,
      dropdownMenuEntries: dropdownMenuEntries(),
      onSelected: (value) {
        if (value != null) {
          mutableListCtl.addItem(value);
          dropDownCtl.clear();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: optionsInitialized,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return SizedBox(
              width: widget.width,
              child: Column(
                children: [
                  SwitchListTile(
                      focusNode: widget.focusNode,
                      title: Text('All Categories',
                          style: Theme.of(context).textTheme.bodyLarge),
                      value: allCategoriesSelected,
                      onChanged: (ipt) {
                        setState(() {
                          allCategoriesSelected = ipt;
                        });
                        widget.controller._onUpdated();
                      }),
                  if (!allCategoriesSelected)
                    MutableListForm(
                      controller: mutableListCtl,
                      onItemTapped: (item) {
                        mutableListCtl.removeItem(item);
                      },
                      itemAdder: itemAdder,
                    )
                ],
              ));
        }
      },
    );
  }
}
// </MultipleCategorySelector>

/* 
<CategoryEditorSection>
CategoryEditorSection is a mutable list form of categories that allows user to rename, add, and integrate categories.
It does not provide category deletion feature. Because all tickets should belong to a single category.
Instead, it provides category integration feature, which allows user to integrate two categories and to decrease the number of categories.

itemAdder: 
a text field and a button that allows user to make a new category.

onItemTapped:
When an item is tapped, it opens a dialog that allows user to rename, integrate the category with another category.
*/
class CategoryEditorSection extends StatefulWidget {
  final FocusNode? focusNode;
  final double? width;
  const CategoryEditorSection({super.key, this.width, this.focusNode});

  @override
  State<CategoryEditorSection> createState() => _CategoryEditorSectionState();
}

class _CategoryEditorSectionState extends State<CategoryEditorSection> {
  late final MutableListFormController<Category> mutableListCtl;
  late final TextEditingController textCtl;
  late final Future<void> categoriesFetched;

  Future<void> initializeMutableList() async {
    var categoryTable = await CategoryTable.use();
    mutableListCtl = MutableListFormController<Category>(
      items: await categoryTable.fetchAll(null),
      toLabel: (item) => item.name,
    );
  }

  @override
  void initState() {
    super.initState();
    categoriesFetched = initializeMutableList();
    textCtl = TextEditingController(text: '');
  }

  List<DropdownMenuEntry<Category>> dropdownMenuEntriesToIntegration(
      Category focused) {
    return [
      for (Category category in mutableListCtl.items)
        if (category != focused)
          DropdownMenuEntry<Category>(value: category, label: category.name)
    ];
  }

  Widget itemAdder(BuildContext context) {
    var focusNode = widget.focusNode ?? FocusNode();
    return Row(children: [
      Expanded(
          child: TextField(
        focusNode: focusNode,
        controller: textCtl,
        onSubmitted: (value) {
          if (value.isEmpty) return;
          mutableListCtl.addItem(Category.saveInFuture(value));
          textCtl.clear();
          // do not lose focus
          focusNode.requestFocus();
        },
      )),
      Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: IconButton(
          icon: const Icon(Icons.add),
          color: Theme.of(context).colorScheme.primary,
          onPressed: () {
            if (textCtl.text.isEmpty) return;
            mutableListCtl.addItem(Category.saveInFuture(textCtl.text));
            textCtl.clear();
          },
        ),
      )
    ]);
  }

  void showIntegrateConfirmationDialog(
      BuildContext context, Category replaced, Category replaceWith) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('CAUTION!'),
            content: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'This action is irreversible.',
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                      'Are you sure you want to integrate \'${replaced.name}\' with \'${replaceWith.name}\'?',
                      textAlign: TextAlign.start),
                  Text(
                      '\'${replaced.name}\' will be replaced with \'${replaceWith.name}\' and \'${replaced.name}\' disappears forever.',
                      textAlign: TextAlign.start),
                ]),
            actions: [
              TextButton(
                  onPressed: () {
                    // close category editor and confirmation dialog at once
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    replaced.integrateWith(replaceWith);
                    mutableListCtl.removeItem(replaced);
                    // close category editor and confirmation dialog at once
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK')),
            ],
          );
        });
  }

  void showIntegrateImpossibleDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Integrate Impossible'),
            content: const Text(
                'Before integration, you should select some category.'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK')),
            ],
          );
        });
  }

  void showCategoryEditorWindow(BuildContext context, Category item) {
    var textCtl = TextEditingController(text: item.name);
    showDialog(
        context: context,
        builder: (context) {
          Category? selected;
          return AlertDialog(
            title: const Text('Category Edit'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: textCtl,
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(children: [
                    Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: ElevatedButton(
                            onPressed: () {
                              if (selected == null) {
                                showIntegrateImpossibleDialog(context);
                              } else {
                                showIntegrateConfirmationDialog(
                                    context, item, selected!);
                              }
                            },
                            child: const Text('integrate with'))),
                    Expanded(
                        child: DropdownMenu<Category>(
                            onSelected: (value) {
                              selected = value;
                            },
                            dropdownMenuEntries:
                                dropdownMenuEntriesToIntegration(item))),
                  ])),
            ]),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (mutableListCtl.invokeRebuild != null) {
                      mutableListCtl.invokeRebuild!();
                    }
                    item.rename(textCtl.text);
                  },
                  child: const Text('OK')),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: categoriesFetched,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        return SizedBox(
            width: widget.width,
            child: MutableListForm(
                controller: mutableListCtl,
                onItemTapped: (Category item) {
                  showCategoryEditorWindow(context, item);
                },
                itemAdder: itemAdder));
      },
    );
  }
}
// </CategoryEditorSection>
