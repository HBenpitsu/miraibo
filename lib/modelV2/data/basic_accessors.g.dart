// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic_accessors.dart';

// ignore_for_file: type=lint
mixin _$CategoryAccessorMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $LogsTable get logs => attachedDatabase.logs;
  $DisplaysTable get displays => attachedDatabase.displays;
  $DisplayCategoryLinksTable get displayCategoryLinks =>
      attachedDatabase.displayCategoryLinks;
  $SchedulesTable get schedules => attachedDatabase.schedules;
  $EstimationsTable get estimations => attachedDatabase.estimations;
  $EstimationCategoryLinksTable get estimationCategoryLinks =>
      attachedDatabase.estimationCategoryLinks;
  $EstimationCachesTable get estimationCaches =>
      attachedDatabase.estimationCaches;
}
mixin _$EstimationAccessorMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $EstimationsTable get estimations => attachedDatabase.estimations;
  $EstimationCategoryLinksTable get estimationCategoryLinks =>
      attachedDatabase.estimationCategoryLinks;
  $EstimationCachesTable get estimationCaches =>
      attachedDatabase.estimationCaches;
}
mixin _$ScheduleAccessorMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $SchedulesTable get schedules => attachedDatabase.schedules;
  $EstimationsTable get estimations => attachedDatabase.estimations;
  $RepeatCachesTable get repeatCaches => attachedDatabase.repeatCaches;
  $LogsTable get logs => attachedDatabase.logs;
}
mixin _$DisplayAccessorMixin on DatabaseAccessor<AppDatabase> {
  $DisplaysTable get displays => attachedDatabase.displays;
  $CategoriesTable get categories => attachedDatabase.categories;
  $DisplayCategoryLinksTable get displayCategoryLinks =>
      attachedDatabase.displayCategoryLinks;
}
mixin _$LogAccessorMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $LogsTable get logs => attachedDatabase.logs;
}
