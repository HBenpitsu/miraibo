import 'package:flutter/material.dart';

// <MutableListForm>
/* 
MutableListForm is a abstract widget that are intended to wrapped with another widget.
It is a list of items that can be added, removed, and updated.
However, the update of items cannot be observed by MutableListForm itself, so it provides a function: invokeRebuild
When some items are added or removed, it sets state and rebuild by itself.
And, way to adding items varies by Wrapper widgets, so it requires adderBuilder.
adderBuilder is a function that returns a widget. The returned widget is placed at the bottom of the list.
Delete button feature also varies by Wrapper widgets, so it is optional here.

The instances of Wrapper widgets are:
- MultipleCategorySelector
- CategoryEditor

Although this class can be transfered to category.dart, it is not related to `Category` directly.
That why this class is placed here.

TODO: MAKE THIS ABSTRACT CLASS or MIXIN, and MODIFY THE WRAPPER WIDGETS
*/
class MutableListFormController<T> {
  final List<T> items;
  void Function()? onItemUpdated;
  void _onItemUpdated() {
    if (onItemUpdated != null) {
      onItemUpdated!();
    }
  }

  void Function(T)? onItemAdded;
  void _onItemAdded(T item) {
    if (onItemAdded != null) {
      onItemAdded!(item);
    }
  }

  void Function(T)? onItemRemoved;
  void _onItemRemoved(T item) {
    if (onItemRemoved != null) {
      onItemRemoved!(item);
    }
  }

  void Function()? invokeRebuild;
  void _invokeRebuild() {
    if (invokeRebuild != null) {
      invokeRebuild!();
    }
  }

  String Function(T item)? toLabel;
  String? _toLabel(T item) {
    if (toLabel != null) {
      return toLabel!(item);
    }
    return null;
  }

  MutableListFormController(
      {required this.items,
      this.toLabel,
      this.onItemAdded,
      this.onItemRemoved,
      this.invokeRebuild});

  void addItem(T item) {
    items.add(item);
    _onItemAdded(item);
    _onItemUpdated();
    _invokeRebuild();
  }

  void removeItem(T item) {
    items.remove(item);
    _onItemRemoved(item);
    _onItemUpdated();
    _invokeRebuild();
  }

  void addAllItems(List<T> add) {
    for (T item in add) {
      items.add(item);
      _onItemAdded(item);
    }
    _onItemUpdated();
    _invokeRebuild();
  }

  void removeAllItems(List<T> remove) {
    for (T item in remove) {
      items.remove(item);
      _onItemRemoved(item);
    }
    _onItemUpdated();
    _invokeRebuild();
  }
}

abstract class MutableListForm<T> extends StatefulWidget {
  final MutableListFormController<T> controller;

  final void Function(T)? onItemTapped;
  void _onItemTapped(T item) {
    if (onItemTapped != null) {
      onItemTapped!(item);
    }
  }

  final void Function(T)? onItemRemoved;
  void _onItemRemoved(T item) {
    if (onItemRemoved != null) {
      onItemRemoved!(item);
    }
  }

  final double? width;

  const MutableListForm(
      {super.key,
      required this.controller,
      this.width,
      this.onItemTapped,
      this.onItemRemoved});
}

mixin _MutableListFormState<M extends <T>MutableListForm> extends State<M> {
  @override
  void initState() {
    super.initState();
    // bind methods to controller
    widget.controller.invokeRebuild = () {
      setState(() {});
    };
  }

  void onItemTapped(T item);

  Widget rowContent(BuildContext context, T item) {
    return TextButton(
        onPressed: () {
          onItemTapped(item);
        },
        child: SizedBox(
            height: 50,
            child: Center(
                child: Text(
                    widget.controller._toLabel(item) ?? item.toString()))));
  }

  Widget deleteButton(BuildContext context, item) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: IconButton(
        icon: const Icon(Icons.delete),
        color: Theme.of(context).colorScheme.primary,
        onPressed: () {
          widget.controller.removeItem(item);
          widget._onItemRemoved(item);
        },
      ),
    );
  }

  Widget rowWithDeleteButton(BuildContext context, T item) {
    Row(children: [
        Expanded(child: rowContent(context, item)),
        deleteButton(context, item),
      ]);
  }

  Widget plainRow(BuildContext context, T item) {
      return Padding(
          padding: const EdgeInsets.only(top: 2),
          child: rowContent(context, item));
  }

  Widget itemAdder(BuildContext context);
}
// </MutableListForm>

/*
This is a method that shows an error dialog.
Although it is mere wrapper of showDialog, it is functionized because it was repeated in sorce code.
*/
void showErrorDialog(BuildContext context, String message) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'))
          ],
        );
      });
}
