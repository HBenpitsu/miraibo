# directory-policy

To keep the project organized, we need to arrange files in a consistent way. The specific method for organizing files in the `lib` directory and the abstractions of these directories are explained below.

## directories

### page

The `page` directory contains `Page` UI definitions. Data handling code is separated into the `data_handler` directory. A `Page` is a concept or widget in this application. The `Page` widget is directly attached to the outermost `TabView` of this app, which is the second largest container in the app.

Instances of `Page` include:

- Scheduling Page
- Ticket Page
- Data Page
- Utils Page

For more details, check the `component-structure.md` document.

This app displays a single `Page` at a time, and the displayed `Page` will be changed according to Tab paging Controller.

### component

The `component` directory contains UI definitions of widgets used across various `Pages` or widgets which belongs to `component` directory. Note that 'UI definition' includes the definition of motion, such as scroll behavior, not just appearance.

`ticket_configurator.dart` contains a function to pop up modal bottom sheet and definitions of the content of its sheet. They can be called in scheduling-, data- and ticket-page. Ticket_configurator is to create, edit and delete data which is shown in `ticket` form. It should be noticed that this file focuses on UI-definition and actual data handling is transfered into files in `data_handler` directory.

`ticket.dart` contains a `Ticket` widget. Tickets are to show the data in simple, consistent, and scallable way. They are basically cards which show some information and listen to gesture events.

### data_handlers

In this directory, main purpose of code is to handle data.

Handling data basically means:

- saving new data
- fetching existing data
- updating existing data
- deleting existing data

As applied tasks, it also includes:

- searching values to be shown
- calculating values to be shown
- summarizing data and make represents

There are defenition of data structure too, because data-structure is highly related to updating, searching and so on.
