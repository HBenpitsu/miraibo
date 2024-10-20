import 'package:flutter/material.dart';

// <MutableListForm>
/* 
MutableListForm is a abstract widget that are intended to wrapped with another widget.
It is a list of items that can be added, removed, and updated.
However, the update of items cannot be observed by MutableListForm itself, so it provides a function: invokeRebuild
When some items are added or removed, it sets state and rebuild by itself.
And, way to adding items varies by Wrapper widgets, so it requires [itemAdder].
[itemAdder] is a function that returns a widget. The returned widget is placed at the bottom of the list.

The instances of Wrapper widgets are:
- MultipleCategorySelector
- CategoryEditor

*/
class MutableListFormController<T> {
  final List<T> items;

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
      {List<T>? items,
      this.toLabel,
      this.onItemAdded,
      this.onItemRemoved,
      this.invokeRebuild})
      : items = items == null
            ? <T>[]
            : [...items]; // to make items mutable, copy it

  void addItem(T item) {
    items.add(item);
    _onItemAdded(item);
    _invokeRebuild();
  }

  void removeItem(T item) {
    items.remove(item);
    _onItemRemoved(item);
    _invokeRebuild();
  }

  void addAllItems(List<T> add) {
    for (T item in add) {
      items.add(item);
      _onItemAdded(item);
    }
    _invokeRebuild();
  }

  void removeAllItems(List<T> remove) {
    for (T item in remove) {
      items.remove(item);
      _onItemRemoved(item);
    }
    _invokeRebuild();
  }
}

class MutableListForm<T> extends StatefulWidget {
  final MutableListFormController<T> controller;
  final void Function(T item) onItemTapped;
  final Widget Function(BuildContext context)? itemContent;
  final Widget Function(BuildContext context) itemAdder;

  const MutableListForm(
      {super.key,
      required this.controller,
      required this.onItemTapped,
      this.itemContent,
      required this.itemAdder});

  @override
  State<MutableListForm<T>> createState() => MutableListFormState<T>();
}

class MutableListFormState<T> extends State<MutableListForm<T>> {
  void bindRebuildCallback() {
    widget.controller.invokeRebuild = () {
      setState(() {});
    };
  }

  @override
  void initState() {
    super.initState();
    // bind methods to controller
    bindRebuildCallback();
  }

  // <components>

  Widget itemContent(BuildContext context, T val) {
    if (widget.itemContent != null) {
      return widget.itemContent!(context);
    }
    return Text(widget.controller._toLabel(val) ?? val.toString());
  }

  Widget item(BuildContext context, T val) {
    return Padding(
        padding: const EdgeInsets.only(top: 2),
        child: TextButton(
            onPressed: () {
              widget.onItemTapped(val);
            },
            style: ButtonStyle(
              shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0))),
            ),
            child: SizedBox(
                height: 50, child: Center(child: itemContent(context, val)))));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (T val in widget.controller.items) item(context, val),
        widget.itemAdder(context),
      ],
    );
  }
  // </components>
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
