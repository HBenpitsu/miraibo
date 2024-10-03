import 'package:flutter/material.dart';
import 'package:miraibo/general_widget.dart';

import 'data_types.dart';

List<Category> categoryListMock = [
  Category.make('food'),
  Category.make('transportation'),
  Category.make('electricity'),
];

class SingleCategorySelectorController {
  void Function(Category)? onUpdate;
  void _onUpdate(Category value) {
    if (onUpdate != null) {
      onUpdate!(value);
    }
  }

  Category? Function()? _category;
  Category? get selected => _category == null ? null : _category!();

  final Category? initiallySelectedCategory;

  SingleCategorySelectorController(
      {this.initiallySelectedCategory, this.onUpdate});
}

class SingleCategorySelector extends StatelessWidget {
  final SingleCategorySelectorController controller;
  const SingleCategorySelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    Category? selected;
    controller._category = () => selected;
    return FutureBuilder(
      future: Category.fetchAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return DropdownMenu<Category>(
            initialSelection: controller.initiallySelectedCategory,
            dropdownMenuEntries: [
              for (Category category in snapshot.data as List<Category>)
                DropdownMenuEntry<Category>(
                    value: category, label: category.name)
            ],
            onSelected: (value) {
              if (value != null) {
                selected = value;
                controller._onUpdate(value);
              }
            },
          );
        }
      },
    );
    // return DropdownMenu<Category>(
    //   dropdownMenuEntries: [
    //     for (Category category in categoryListMock)
    //       DropdownMenuEntry<Category>(value: category, label: category.name)
    //   ],
    //   onSelected: (value) {
    //     onUpdate!(value!);
    //   },
    //   initiallySelected: initiallySelectedCategory,
    // );
  }
}

class MultipleCategorySelectorController {
  void Function()? onUpdate;
  void _onUpdated() {
    if (onUpdate != null) {
      onUpdate!();
    }
  }

  List<Category> Function()? _categories;
  List<Category> get selectedCategories => _categories!();

  bool Function()? _allCategoriesSelected;
  bool get allCategoriesSelected => _allCategoriesSelected!();

  late bool Function()? _isInitialized;
  bool get isInitialized => _isInitialized == null ? false : _isInitialized!();

  final List<Category> initiallySelectedCategories;
  final bool allCategoriesInitiallySelected;

  MultipleCategorySelectorController(
      {this.initiallySelectedCategories = const [],
      this.allCategoriesInitiallySelected = true,
      this.onUpdate});
}

class MultipleCategorySelector extends StatefulWidget {
  final double width;
  final MultipleCategorySelectorController controller;
  const MultipleCategorySelector(
      {super.key, required this.width, required this.controller});

  @override
  State<MultipleCategorySelector> createState() =>
      _MultipleCategorySelectorState();
}

class _MultipleCategorySelectorState extends State<MultipleCategorySelector> {
  late final Future<void> optionsFetched;
  List<Category>? options;
  late final MutableListFormController<Category> mutableListCtl;
  bool allCategoriesSelected = false;

  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    // initialize controller
    mutableListCtl = MutableListFormController<Category>(
      items: [],
      toLabel: (item) => item.name,
    );
    optionsFetched = Future(() async {
      options = await Category.fetchAll();
      for (Category category in widget.controller.initiallySelectedCategories) {
        options!.remove(category);
      }
      isInitialized = true;
    });
    // bind methods with controller
    mutableListCtl.onItemUpdated = () {
      if (isInitialized) {
        widget.controller._onUpdated();
      }
    };
    widget.controller._isInitialized = () => isInitialized;
    widget.controller._categories = () => mutableListCtl.items;
    widget.controller._allCategoriesSelected = () => allCategoriesSelected;
    // apply initial values
    mutableListCtl.addAllItems(widget.controller.initiallySelectedCategories);
    allCategoriesSelected = widget.controller.allCategoriesInitiallySelected;
  }

  List<DropdownMenuEntry<Category>> generateDropdownMenuEntries() {
    return [
      for (Category category in options!)
        DropdownMenuEntry<Category>(value: category, label: category.name)
    ];
  }

  Widget adderBuilder(BuildContext context) {
    var dropDownCtl = TextEditingController();
    return DropdownMenu<Category>(
      controller: dropDownCtl,
      width: widget.width,
      dropdownMenuEntries: generateDropdownMenuEntries(),
      onSelected: (value) {
        if (value != null) {
          mutableListCtl.addItem(value);
          options!.remove(value);
          dropDownCtl.clear();
        }
      },
    );
  }

  void showRenameDialog(BuildContext context, Category item) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Rename Category'),
            content: TextField(
              controller: TextEditingController(text: item.name),
              onChanged: (value) {
                item.rename(value);
              },
            ),
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
          return SizedBox(
              width: widget.width,
              child: Column(
                children: [
                  SwitchListTile(
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
                        width: widget.width,
                        deleteButton: true,
                        controller: mutableListCtl,
                        adderBuilder: adderBuilder,
                        onItemTapped: (Category item) {
                          showRenameDialog(context, item);
                        },
                        onItemRemoved: (Category item) {
                          options!.add(item);
                      })
                ],
              ));
        }
      },
    );
  }
}

class CategoryEditorSection extends StatefulWidget {
  final double width;
  const CategoryEditorSection({super.key, required this.width});

  @override
  State<CategoryEditorSection> createState() => _CategoryEditorSectionState();
}

class _CategoryEditorSectionState extends State<CategoryEditorSection> {
  late final MutableListFormController<Category> mutableListCtl;
  late final TextEditingController textCtl;
  late final Future<void> categoriesFetched;

  @override
  void initState() {
    super.initState();
    categoriesFetched = Future(() async {
      mutableListCtl = MutableListFormController<Category>(
        items: await Category.fetchAll(),
        toLabel: (item) => item.name,
      );
    });
    textCtl = TextEditingController(text: '');
  }

  List<DropdownMenuEntry<Category>> generateDropdownMenuEntries(
      Category focused) {
    return [
      for (Category category in mutableListCtl.items)
        if (category != focused)
          DropdownMenuEntry<Category>(value: category, label: category.name)
    ];
  }

  Widget adderBuilder(BuildContext context) {
    var focusNode = FocusNode();
    return Row(children: [
      Expanded(
          child: TextField(
        focusNode: focusNode,
        controller: textCtl,
        onSubmitted: (value) {
          if (value.isEmpty) return;
          mutableListCtl.addItem(Category.make(value));
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
            mutableListCtl.addItem(Category.make(textCtl.text));
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
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    replaced.integrateWith(replaceWith);
                    mutableListCtl.removeItem(replaced);
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
    showDialog(
        context: context,
        builder: (context) {
          Category? selected;
          return AlertDialog(
            title: const Text('Category Edit'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: TextEditingController(text: item.name),
                onChanged: (value) {
                  item.rename(value);
                },
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
                                generateDropdownMenuEntries(item))),
                  ])),
            ]),
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
        return MutableListForm(
            controller: mutableListCtl,
            width: widget.width,
            deleteButton: false,
            onItemTapped: (Category item) {
              showCategoryEditorWindow(context, item);
            },
            adderBuilder: adderBuilder);
      },
    );
  }
}
