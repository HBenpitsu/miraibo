import 'dart:io';
import 'dart:math';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:function_tree/function_tree.dart';

import 'package:miraibo/ui/component/general_widget.dart';
import 'package:miraibo/util/date_time.dart';

/* 
This file defines a set of custom widgets that are mainly used in ticket config sections.
category.dart also contains widgets that are used in ticket configurators,
but they are separated because `category` represents a distinct domain
*/

/* 
<date picker>
For DatePicker, there is already a method called showDatePicker in flutter.
Therefore, this class is a mere button that calls showDatePicker.
But, there's some additional features:
- controller-management
- button instance that allows not-selected state
At first, the button's text is 'unselected' or something designated by nullLabel.
When the date is selected, the button's text is updated to selected date.
*/
class DatePickButtonController {
  DateTime? _selected;
  DateTime? get selected => _selected;
  set selected(DateTime? value) {
    _selected = value;
    _onDateSelected(value);
  }

  void Function(DateTime?)? onDateSelected;
  void _onDateSelected(DateTime? date) {
    if (onDateSelected != null) {
      onDateSelected!(date);
    }
  }

  DatePickButtonController({DateTime? initialDate, this.onDateSelected})
      : _selected = initialDate;
}

class DatePickButton extends StatefulWidget {
  final DatePickButtonController controller;
  final String nullLabel;
  final FocusNode? focusNode;
  const DatePickButton(
      {super.key,
      required this.controller,
      this.focusNode,
      this.nullLabel = 'unselected'});

  @override
  State<DatePickButton> createState() => _DatePickButtonState();
}

class _DatePickButtonState extends State<DatePickButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        focusNode: widget.focusNode,
        onPressed: () {
          showDatePicker(
                  context: context,
                  initialDate: widget.controller.selected ?? today(),
                  firstDate: widget.controller.selected == null
                      ? today().subtract(const Duration(days: 365 * 200))
                      : widget.controller.selected!
                          .subtract(const Duration(days: 365 * 200)),
                  lastDate: widget.controller.selected == null
                      ? today().add(const Duration(days: 365 * 200))
                      : widget.controller.selected!
                          .add(const Duration(days: 365 * 200)))
              .then((value) {
            if (value != null) {
              setState(() {
                widget.controller.selected = value;
              });
            }
          });
        },
        child: widget.controller.selected == null
            ? Text(widget.nullLabel)
            : Text(
                '${widget.controller.selected!.year}/${widget.controller.selected!.month}/${widget.controller.selected!.day}'));
  }
}
// </date picker>

/* 
<MoneyForm>
MoneyForm is a widget that aim to get the information of amount of money.
The most important part of this is TextField.
Not to confuse users with the sign of the amount, it has a toggle button to switch between 'income' and 'outcome'.
It also provides simple expression evaluation.
*/
class MoneyformController {
  int _amount;
  int get amount => _amount;
  set amount(int value) {
    _amount = value;
    _onAmountChanged(value);
  }

  void Function(int)? onAmountChanged;
  void _onAmountChanged(int amount) {
    if (onAmountChanged != null) {
      onAmountChanged!(amount);
    }
  }

  MoneyformController({int amount = 0, this.onAmountChanged})
      : _amount = amount;
}

class Moneyform extends StatefulWidget {
  final MoneyformController controller;
  final double? width;
  final FocusNode? focusNode;
  const Moneyform(
      {super.key, required this.controller, this.focusNode, this.width});

  @override
  State<Moneyform> createState() => _MoneyformState();
}

class _MoneyformState extends State<Moneyform> {
  late TextEditingController amountCtl;
  int sign = -1;

  @override
  void initState() {
    super.initState();
    amountCtl = TextEditingController();
    amountCtl.text = widget.controller.amount.toString();
  }

  double widthOfAmount() {
    return widget.width ?? min(200, MediaQuery.of(context).size.width * 0.8);
  }

  double widthOfExpression() {
    return widget.width ?? min(300, MediaQuery.of(context).size.width * 0.9);
  }

  Widget toggle() {
    if (sign == 1) {
      return TextButton(
          onPressed: () {
            setState(() {
              sign = -1;
            });
            widget.controller.amount = -widget.controller.amount.abs();
          },
          child: const Text('income'));
    } else {
      return TextButton(
          onPressed: () {
            setState(() {
              sign = 1;
            });
            widget.controller.amount = widget.controller.amount.abs();
          },
          child: const Text('outcome'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            width: widthOfAmount(),
            child: Row(
              children: [
                Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: SizedBox(width: 85, child: toggle())),
                Expanded(
                    child: TextField(
                  focusNode: widget.focusNode,
                  controller: amountCtl,
                  onTap: () {
                    amountCtl.selection = TextSelection(
                        baseOffset: 0, extentOffset: amountCtl.text.length);
                  },
                  onChanged: (value) {
                    int amount = int.tryParse(value) ?? 0;
                    if (amount < 0) {
                      amount = 0;
                    }
                    widget.controller.amount = sign * amount;
                    amountCtl.text = amount.toString();
                  },
                  keyboardType: TextInputType.number,
                )),
              ],
            )),
        SizedBox(
            width: widthOfExpression(),
            child: TextFormField(
                decoration:
                    const InputDecoration(prefixIcon: Icon(Icons.calculate)),
                initialValue: widget.controller.amount.toString(),
                onChanged: (value) {
                  try {
                    var amount = value.interpret().toInt();
                    setState(() {
                      widget.controller.amount = amount.abs();
                      amountCtl.text = amount.abs().toString();
                      sign = amount.sign;
                    });
                  } catch (e) {
                    developer.log(e.toString());
                  }
                })),
      ],
    );
  }
}
// </MoneyForm>

/* 
<InfinitePeriodSelector>
InfinitePeriodSelector is a widget that allows users to select a period with free edges.
To unselect start date means that selected period virtually starts from very beginning of the human history.
To unselect end date means that selected period never ends (= do not have time limit).
It is composed of two DatePickButtons.
// If the start date is after the end date, the end date is set to the start date to keep it consistent, vise versa.
*/
class InfinitePeriodSelectorController {
  DateTime? _start;
  DateTime? get start => _start;
  set start(DateTime? value) {
    _start = value;
    if (_end != null && _start != null && _end!.isBefore(_start!)) {
      _end = _start;
    }
    _onPeriodChanged();
  }

  DateTime? _end;
  DateTime? get end => _end;
  set end(DateTime? value) {
    _end = value;
    if (_end != null && _start != null && _end!.isBefore(_start!)) {
      _start = _end;
    }
    _onPeriodChanged();
  }

  void Function()? onPeriodChanged;
  void _onPeriodChanged() {
    if (onPeriodChanged != null) {
      onPeriodChanged!();
    }
  }

  InfinitePeriodSelectorController(
      {DateTime? start, DateTime? end, this.onPeriodChanged})
      : _start = start,
        _end = end;
}

class InfinitePeriodSelector extends StatefulWidget {
  final InfinitePeriodSelectorController controller;
  final FocusNode? focusNode;
  const InfinitePeriodSelector(
      {super.key, required this.controller, this.focusNode});

  @override
  State<InfinitePeriodSelector> createState() => _InfinitePeriodSelectorState();
}

class _InfinitePeriodSelectorState extends State<InfinitePeriodSelector> {
  static double buttonHeight = 40;
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(
        // start date
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'start date: ',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(
            height: buttonHeight,
            child: DatePickButton(
                focusNode: widget.focusNode,
                nullLabel: 'unlimited',
                controller: DatePickButtonController(
                    initialDate: widget.controller.start,
                    onDateSelected: (date) {
                      setState(() {
                        widget.controller.start = date;
                      });
                    })),
          ),
          SizedBox(width: 4), //padding
          SizedBox(
            height: buttonHeight,
            child: IconButton.filled(
                onPressed: () {
                  setState(() {
                    widget.controller.start = null;
                  });
                },
                icon: const Icon(Icons.autorenew)),
          ),
        ],
      ),
      SizedBox(
        height: 5,
      ), //spacing
      Row(
        // end date
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '  end date: ',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(
            height: buttonHeight,
            child: DatePickButton(
                nullLabel: 'unlimited',
                controller: DatePickButtonController(
                    initialDate: widget.controller.end,
                    onDateSelected: (date) {
                      setState(() {
                        widget.controller.end = date;
                      });
                    })),
          ),
          SizedBox(width: 4), //padding
          SizedBox(
            height: buttonHeight,
            child: IconButton.filled(
                onPressed: () {
                  setState(() {
                    widget.controller.end = null;
                  });
                },
                icon: const Icon(Icons.autorenew)),
          )
        ],
      )
    ]);
  }
}
// </InfinitePeriodSelector>

// <FinitePeriodSelector>
// FinitePeriodSelector is a widget that allows users to select a period with fixed edges.
// It is composed of two DatePickButtons.
// If the start date is after the end date, the end date is set to the start date to keep it consistent, vise versa.
class FinitePeriodSelectorController {
  DateTime _start;
  DateTime get start => _start;
  set start(DateTime value) {
    _start = value;
    if (_end.isBefore(_start)) {
      _end = _start;
    }
    _onPeriodChanged();
  }

  DateTime _end;
  DateTime get end => _end;
  set end(DateTime value) {
    _end = value;
    if (_end.isBefore(_start)) {
      _start = _end;
    }
    _onPeriodChanged();
  }

  void Function()? onPeriodChanged;
  void _onPeriodChanged() {
    if (onPeriodChanged != null) {
      onPeriodChanged!();
    }
  }

  FinitePeriodSelectorController(
      {DateTime? start, DateTime? end, this.onPeriodChanged})
      : _start = start ?? today(),
        _end = end ?? today();
}

class FinitePeriodSelector extends StatefulWidget {
  final FinitePeriodSelectorController controller;
  final FocusNode? focusNode;
  const FinitePeriodSelector(
      {super.key, required this.controller, this.focusNode});

  @override
  State<FinitePeriodSelector> createState() => _FinitePeriodSelectorState();
}

class _FinitePeriodSelectorState extends State<FinitePeriodSelector> {
  static double buttonHeight = 40;
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(
        // start date
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'start date: ',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(
            height: buttonHeight,
            child: DatePickButton(
                focusNode: widget.focusNode,
                controller: DatePickButtonController(
                    initialDate: widget.controller.start,
                    onDateSelected: (date) {
                      setState(() {
                        if (date != null) {
                          widget.controller.start = date;
                        }
                      });
                    })),
          ),
        ],
      ),
      SizedBox(
        height: 5,
      ), //spacing
      Row(
        // end date
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '  end date: ',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(
            height: buttonHeight,
            child: DatePickButton(
                controller: DatePickButtonController(
                    initialDate: widget.controller.end,
                    onDateSelected: (date) {
                      setState(() {
                        if (date != null) {
                          widget.controller.end = date;
                        }
                      });
                    })),
          ),
        ],
      )
    ]);
  }
}
// </FinitePeriodSelector>

/* 
<PictureSelector>
PictureSelectorSection is a content of the window where use select and preview a picture.
It uses ImagePicker.
It allows users to select a picture from the gallery or take a picture with a camera.
It also allows users to detach the selected picture.

PictureSelectButton opens the window described above.
*/
class PictureSelectorController {
  File? _picture;
  File? get picture => _picture;
  set picture(File? value) {
    _picture = value;
    _onChanged();
  }

  void Function()? onChanged;
  void _onChanged() {
    if (onChanged != null) {
      onChanged!();
    }
  }

  PictureSelectorController({File? picture, this.onChanged})
      : _picture = picture;
}

class PictureSelectorSection extends StatefulWidget {
  final PictureSelectorController controller;
  const PictureSelectorSection({super.key, required this.controller});

  @override
  State<PictureSelectorSection> createState() => _PictureSelectorSectionState();
}

class _PictureSelectorSectionState extends State<PictureSelectorSection> {
  late ImagePicker picker;
  late Future<void> cameraCtlInitialized;

  @override
  void initState() {
    super.initState();
    picker = ImagePicker();
    picker.supportsImageSource(ImageSource.gallery);
  }

  Widget pictureFrame(BuildContext context) {
    if (widget.controller.picture == null) {
      return SizedBox(
          width: 300,
          height: 500,
          child: const Center(child: Text('no picture selected')));
    } else {
      return SizedBox(
          width: 300,
          height: 500,
          child: Image.file(widget.controller.picture!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Spacer(),
            ElevatedButton(
                onPressed: () async {
                  if (!picker.supportsImageSource(ImageSource.camera)) {
                    showErrorDialog(context,
                        'This action is not supported for this device');
                    return;
                  }
                  XFile? picture;
                  picture = await picker.pickImage(source: ImageSource.camera);
                  if (picture == null) {
                    return;
                  } else {
                    setState(() {
                      // convert XFile to File
                      widget.controller.picture = File(picture!.path);
                    });
                  }
                },
                child: const Icon(Icons.add_a_photo)),
            const Spacer(),
            ElevatedButton(
                onPressed: () async {
                  if (!picker.supportsImageSource(ImageSource.gallery)) {
                    showErrorDialog(context,
                        'This action is not supported for this device');
                    return;
                  }

                  XFile? picture;
                  try {
                    picture =
                        await picker.pickImage(source: ImageSource.gallery);
                  } catch (e) {
                    if (e is RangeError) {
                      return;
                    } else {
                      rethrow;
                    }
                  }

                  if (picture == null) {
                    return;
                  } else {
                    setState(() {
                      // convert XFile to File
                      widget.controller.picture = File(picture!.path);
                    });
                  }
                },
                child: const Icon(Icons.add_photo_alternate)),
            const Spacer(),
            ElevatedButton(
                onPressed: () async {
                  setState(() {
                    widget.controller.picture = null;
                  });
                },
                child: const Text('detach')),
            const Spacer(),
          ],
        ),
        pictureFrame(context),
        Row(
          children: [
            const Spacer(),
          ],
        )
      ],
    ));
  }
}

class PictureSelectButton extends StatelessWidget {
  final PictureSelectorController controller;
  final FocusNode? focusNode;
  const PictureSelectButton(
      {super.key, required this.controller, this.focusNode});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        focusNode: focusNode,
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Select Picture'),
                  content: PictureSelectorSection(controller: controller),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'))
                  ],
                );
              });
        },
        child: const Text('Select Picture'));
  }
}
// </PictureSelector>
