//%attributes = {"folder":"Developer Quick Open","lang":"en"}
/*

# Overview

Quick Open is a development tool with the major goal of quickly opening forms, methods, classes,
etc. in 4D and is inspired by Xcode's Quickly Open or macOS' Spotlight features. Beyond that, it
also handles the creation and opening of documentation and a few smaller things.

The Quick Open window can be opened in two ways:

1. By directly calling DevQuickOpen_OpenWindow from your own code. For example, a button.

2. By hitting Option-Space. This, of course, means an event handler must be running. The event
   handler can be started by calling DevQuickOpen_BeginHandler. This might be done in On Startup
   if running in interpreted or at some other point when you know you are dropping into developer
   mode.

If you prefer a different shortcut to Option-Space, you will need to make the change in
DevQuickOpen_EventHandler.

This code has been written to work in v18.x with the following in mind:

- v18.x itself isn't "aware" of markdown documentation, but this code will create and open
  such documentation in the right places on the file system so once you move into the v18 R
  releases which understand the markdown documentation it will just work.

- In v18.x it isn't possible to programatically open the form editor, but that changes in
  v18 R5. So if you are running in R5 or later, uncomment out the FORM EDIT line in
  DevQuickOpen_HandleSelected.

- In v18.x it wasn't possible to copy a object or collection into a shared object or collection.
  Various workarounds are used, including a method called SOBJ_CopyCollectionTo which is called
  in DevQuickOpen_Worker. If you are running a later R release where this isn't necessary
  anymore, that method can be dropped and replaced with a simply .copy().


# Features

The Quick Open window has the following features:

- Use a shortcut (Option-Space) to open the window
- Start typing any part of the name of a form, class, method, database method, trigger, or DevDoc
- A list of entries will appear, sorted by relevance
- You can keep typing or use the up/down arrow keys to select an item to open it.
- Hitting enter/return will open the item.
- Hitting Option-Enter/Return will open the item's markdown documentation, creating it if necessary.
- Hitting Esc clears the search. Hitting it again closes the window.
- You can right-click on an item for additional options.
- The list will show a paperclip for items that have documentation.
- The list shows the folder path to items. One thing this is useful for is finding what folder an
  item is in if misplaced.


# "Public" Methods

The following methods are "public" in the sense that they are meant to be called from your own code:

- DevQuickOpen_BeginHandler is used to start the event handler. This might be the only method you call.
- DevQuickOpen_EndHandler can be used to stop the event handler if needed.
- DevQuickOpen_IsHandlerRunning can be used if you need to detect whether this handler is running.
- DevQuickOpen_OpenWindow can be used to invoke the Quick Open window programatically if you want.


# DevDocs

What are DevDocs? 4D now has the ability to associate a markdown document with each form, method,
class, etc. which is great for specific information about those items. But another type of more
general documentation about a project is often helpful—documentation that isn't attached to
something as specific as a method or class. For this I use a DevDocs folder. This folder can be
created in the project at the same level as 4D's Documentation folder. It is suggested that there
be an index.md file inside and then whatever other markdown files you want in any hierarchy you
want.

Doing it this way lets this documentation be under source control of the project. Markdown allows
things like linking to other markdown documents in the hierarchy, adding pictures, etc. Tim Nevels
showed us a great markdown editor named Typora which works exceptionally well for this kind of
documentation.

Quick Open takes the DevDocs folder into account if you are using it, searching by filename to
include DevDocs in the search results. Right-clicking an item offers additional DevDoc features.
You can imagine that even more could be added.


# Internal Code Flow

When the event handler is invoked, it checks to see if the chosen shortcut has been hit. If so, it
filters the event and opens the Quick Open window in a new process. The Quick Open window will first
stop the event handler so that it isn't possible to stack up. It will be restarted when the window is
closed.

Next, the Quick Open window will make sure a shared object is initialized in Storage in case this is
the first time it is run. The window used this shared object as a place to pass information between
the window and the worker which gathers all the items as well as to keep some state between each
opening of the window. Once this is done, the window fires off a worker to load all the items. In
the meantime, it opens the window.

If the window has already opened, it will be ready to show items that were listed the last time the
window was used. Likely this will include what you are looking for. You can simply start using the
window. At the same time, the worker is gathering up the list again and will notify the window when
it is done. At this moment the window will silently swap out the new list for the old list and any
search results will be updated. This look seamless to the user.

For many projects, this extra step may not be necessary as the gathering of the items probably takes
less time that for you to start typing. However, it can scale to large projects where it might take
more time. Note that the search field will display a yellow dot on the right side during the time the
worker is gathering information. On smaller projects you may never see this dot, but if you can't
find something you are looking for, the yellow dot can indicate what is going on.

If you are working in a really large project where this process is taking too long, consider modifying
the threshold in DevQuickOpen_Worker. The way it is set by default requires the list to be re-built
every time the window is invoked. You can change it so that is will only be rebuilt if it has been
x seconds since the last rebuild.


# Shared Object Keys

Storage.devQuickOpen is the shared object.
  - masterList. A collection of objects, each with the following keys:
    - type (Class, Method, Form, DB Method, Trigger, DevDoc)
    - name
    - folder (just the folder it is in—not the hierarchy. For DevDocs, this will be the relative path
      to the .md file. It is relative to the DevDocs folder and always starts with a "/". Examples:
      index.md at the top level of DevDocs: "/". example.md in a subfolder: "/subfolder/".
    - hasDocs (True if the item already has an associated .md file)
  - lastRefresh is when the last refresh happened, in milliseconds.
  - isRefreshing helps the window know if a refresh is still happening by the worker.
  - refreshMilliseconds tells us how long the refresh took.
  - winRef lets the worker know what window to send the finished refreshing message to.

Some of these keys aren't really used right now. For example, I originally intended to display how
many milliseconds the refresh took in the window. In the end I decided I didn't want to clutter it
up. But Storage.devQuickOpen.refreshMilliseconds is always there in case I change my mind.


# Form Object

The Form object uses the following keys to track state:

- Form.search holds the search term being entered.
- Form.masterList is a collection of all the items. Is a copy of Storage.devQuickOpen.masterList.
- Form.lbResults is an object with the following keys used by the listbox:
  - Form.lbResults.display is the collection actually displayed. Will be a subset of Form.masterList.
  - Form.lbResults.currentItem
  - Form.lbResults.itemPosition
- Form.isExpanded helps us track whether the window is showing the list or not


# Future Features

It is easy to imagine lots of features that could be added to this window, many through right-clicking
items or another button added beside the search field. For example:

- Templates could be defined for new documentation for classes, methods, etc.
- Templates could be defined for creating new methods and forms on the fly as well.
- Full text searching of DevDocs. Or the code. Or Regex
- It could be aware of what windows were open in the dev environment and rank these higher or do
  something else to make this a window "switcher" as well.
- More DevDoc related features could be added.

*/
