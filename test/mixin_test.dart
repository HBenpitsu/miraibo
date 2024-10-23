import 'dart:developer';

abstract class SuperClass {
  void x() {}
}

mixin Mixin1 on SuperClass {
  @override
  void x() {
    super.x();
    log('mixin1Method');
  }
}

mixin Mixin2 on SuperClass {
  @override
  void x() {
    super.x();
    log('mixin2Method');
  }
}

class SubClass extends SuperClass with Mixin1, Mixin2 {
  void subMethod() {
    x();
  }
}
