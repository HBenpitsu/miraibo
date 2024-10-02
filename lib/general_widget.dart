import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:ui';

// <CustomScroll>
class MyPageScrollPhysics extends ScrollPhysics {
  final double pageWidthInPixel;
  const MyPageScrollPhysics({super.parent, required this.pageWidthInPixel});

  @override
  MyPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return MyPageScrollPhysics(
        parent: buildParent(ancestor), pageWidthInPixel: pageWidthInPixel);
  }

  double _getPage(ScrollMetrics position) {
    return position.pixels / pageWidthInPixel;
  }

  double _getPixels(double pageIdx) {
    return pageIdx * pageWidthInPixel;
  }

  double _getTargetPixels(
      ScrollMetrics position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return _getPixels(page.roundToDouble());
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final Tolerance tolerance = toleranceFor(position);
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  const MyCustomScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
// </CustomScroll>

// <MutableListForm>
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

class MutableListForm<T> extends StatefulWidget {
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

  final bool deleteButton;

  final Widget Function(BuildContext) adderBuilder;

  final double width;

  const MutableListForm(
      {super.key,
      required this.controller,
      required this.deleteButton,
      required this.adderBuilder,
      required this.width,
      this.onItemTapped,
      this.onItemRemoved});

  @override
  State<MutableListForm<T>> createState() => _MutableListFormState<T>();
}

class _MutableListFormState<T> extends State<MutableListForm<T>> {
  @override
  void initState() {
    super.initState();
    // bind methods to controller
    widget.controller.invokeRebuild = () {
      setState(() {});
    };
  }

  Widget rowContent(BuildContext context, T item) {
    return TextButton(
        onPressed: () {
          widget._onItemTapped(item);
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

  Widget row(BuildContext context, T item) {
    if (widget.deleteButton) {
      return Row(children: [
        Expanded(child: rowContent(context, item)),
        deleteButton(context, item),
      ]);
    } else {
      return Padding(
          padding: const EdgeInsets.only(top: 2),
          child: rowContent(context, item));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: widget.width,
        child: Column(
          children: [
            for (T item in widget.controller.items) row(context, item),
            widget.adderBuilder(context)
          ],
        ));
  }
}
// </MutableListForm>

class DatePickButtonController {
  DateTime _selected;
  DateTime get selected => _selected;

  void Function(DateTime)? onDateSelected;
  void _onDateSelected(DateTime date) {
    if (onDateSelected != null) {
      onDateSelected!(date);
    }
  }

  DatePickButtonController({DateTime? initialDate, this.onDateSelected})
      : _selected = initialDate ?? DateTime.now();

  void setDate(DateTime date) {
    _selected = date;
    _onDateSelected(date);
  }
}

class DatePickButton extends StatelessWidget {
  final DatePickButtonController controller;
  const DatePickButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          showDatePicker(
                  context: context,
                  initialDate: controller.selected,
                  firstDate: controller.selected
                      .subtract(const Duration(days: 365 * 200)),
                  lastDate:
                      controller.selected.add(const Duration(days: 365 * 200)))
              .then((value) {
            if (value != null) {
              controller.setDate(value);
            }
          });
        },
        child: Text(
            '${controller.selected.year}-${controller.selected.month}-${controller.selected.day}'));
  }
}

class TogglePanelController<T> {
  final List<T> values;
  final int initialIndex;

  int _selected;
  T get selected => values[_selected];

  void increment() {
    _selected++;
    if (_selected >= values.length) {
      _selected = 0;
    }
    _onChanged(selected);
  }

  void Function(T)? onChanged;
  void _onChanged(T value) {
    if (onChanged != null) {
      onChanged!(value);
    }
  }

  TogglePanelController({
    required this.values,
    this.onChanged,
    this.initialIndex = 0,
  }) : _selected = initialIndex;
}

class TapToggleWidgets<T> extends StatefulWidget {
  final TogglePanelController<T> controller;
  final List<Widget> children;
  const TapToggleWidgets({
    super.key,
    required this.children,
    required this.controller,
  });

  @override
  State<TapToggleWidgets> createState() => _TapToggleWidgetsState();
}

class _TapToggleWidgetsState extends State<TapToggleWidgets> {
  @override
  Widget build(BuildContext context) {
    return Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: SizedBox(
            height: 30,
            width: 75,
            child: InkWell(
                borderRadius: BorderRadius.circular(12),
                focusColor: Theme.of(context).colorScheme.primaryFixedDim,
                splashColor: Theme.of(context).colorScheme.primaryFixedDim,
                onTap: () {
                  setState(() {
                    widget.controller.increment();
                  });
                },
                child: widget.children[widget.controller._selected])));
  }
}

class MoneyformController {
  int _amount;
  int get amount => _amount;

  void Function(int)? onAmountChanged;
  void _onAmountChanged(int amount) {
    if (onAmountChanged != null) {
      onAmountChanged!(amount);
    }
  }

  void setAmount(int amount) {
    _amount = amount;
    _onAmountChanged(amount);
  }

  MoneyformController({int amount = 0, this.onAmountChanged})
      : _amount = amount;
}

class Moneyform extends StatelessWidget {
  final MoneyformController controller;
  final double? width;
  const Moneyform({super.key, required this.controller, this.width});

  @override
  Widget build(BuildContext context) {
    final TextEditingController txtCtl = TextEditingController();
    txtCtl.text = controller.amount.toString();
    var calculatedWidth =
        width ?? min(200, MediaQuery.of(context).size.width * 0.8);
    var tapToggleCtl = TogglePanelController<int>(
      values: [1, -1],
      onChanged: (value) {
        controller.setAmount(controller.amount.abs() * value);
      },
    );
    return SizedBox(
        width: calculatedWidth,
        child: Row(
          children: [
            TapToggleWidgets<int>(
              controller: tapToggleCtl,
              children: [
                Center(
                    child: Text('income',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary))),
                Center(
                    child: Text('outcome',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary)))
              ],
            ),
            Expanded(
                child: TextField(
              controller: txtCtl,
              onChanged: (value) {
                int amount = int.tryParse(value) ?? 0;
                if (amount < 0) {
                  amount = 0;
                }
                controller.setAmount(tapToggleCtl.selected * amount);
                txtCtl.text = amount.toString();
              },
              keyboardType: TextInputType.number,
            )),
            // sizedSpacer
            const SizedBox(width: 50),
          ],
        ));
  }
}
