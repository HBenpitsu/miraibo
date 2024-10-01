import 'package:flutter/material.dart';
import 'package:miraibo/general_widget.dart';

import 'data_types.dart';

List<Category> categoryListMock = [
  Category.make('food'),
  Category.make('transportation'),
  Category.make('electricity'),
];

class MultipleCategorySelectorController {
  void Function()? onUpdate;
  void _onUpdated() {
    if (onUpdate != null) {
      onUpdate!();
    }
  }

  List<Category> Function()? _categories;
  List<Category> get categories => _categories!();

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
  final double? width;
  final MultipleCategorySelectorController controller;
  const MultipleCategorySelector(
      {super.key, this.width, required this.controller});

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

  List<DropdownMenuEntry> generateDropdownMenuEntries() {
    return [
      for (Category category in options!)
        DropdownMenuEntry(value: category, label: category.name)
    ];
  }

  Widget adderBuilder(BuildContext context) {
    Category? selected;
    return Row(children: [
      Expanded(
          child: DropdownMenu(
        width: widget.width ?? MediaQuery.of(context).size.width * 0.8,
        dropdownMenuEntries: generateDropdownMenuEntries(),
        onSelected: (value) {
          selected = value;
        },
      )),
      Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: IconButton(
          icon: const Icon(Icons.add),
          color: Theme.of(context).colorScheme.primary,
          onPressed: () {
            if (selected != null) {
              mutableListCtl.addItem(selected!);
              options!.remove(selected);
            }
          },
        ),
      )
    ]);
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
          return Column(
            children: [
              SizedBox(
                  width:
                      widget.width ?? MediaQuery.of(context).size.width * 0.8,
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text('All Categories',
                        style: Theme.of(context).textTheme.bodyLarge),
                    Switch(
                        value: allCategoriesSelected,
                        onChanged: (ipt) {
                          setState(() {
                            allCategoriesSelected = ipt;
                            widget.controller._onUpdated();
                          });
                        }),
                  ])),
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
          );
        }
      },
    );
  }
}

class CategoryEditorSection extends StatefulWidget {
  const CategoryEditorSection({super.key});

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
    return Row(children: [
      Expanded(child: TextField(controller: textCtl)),
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
            deleteButton: false,
            onItemTapped: (Category item) {
              showCategoryEditorWindow(context, item);
            },
            adderBuilder: adderBuilder);
      },
    );
  }
}
