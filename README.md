# Smart Script Indentation
Script which monitors for new lines and determines if certain formatting should happen if requirements are met

# Features:
- Hot key (Shift + Enter) to take current line and add spacing before and after and set caret position to the center.
- Press enter so many times before a timeout period and the line you are now on clears and adds so many new lines after automatically
- Customize the timeout period for enter presses
- Able to detect upcoming (static) functions to change formatting behavior
- Ability to customize threshold for amount of new lines above and below cursor

# Upcoming:
- Make hard coded data that shouldn't be hard coded, dynamically coded
- Ability fo find upcoming (static) functions in classes
- Persistence of settings
- Hot Key at end of Func line customization to create new lines either above or below
- Ability to allow to insert pass when below function or if next line blank but set for above you can still have pass inserted to the function body

# How to Configure?
  You can configure the plugin by going to Editor > Editor Settings... > Editor Settings > Scripts > Smart Indent and customize the settings

## What customizations are supported?
  All customizations currently work, although some pieces that are supposed to depend on that information is still hard coded, so line spacing results may not be quite as expected in all cases.

# Are any features only partially working?

Yes! Unfortunately thresholds of certain values don't format fully as intended in regards to amount of lines to insert and a fix will be coming in time. Also some values are hard coded into these other dynamic parts of code and so results may not be fully what is expected at this time.

# Any major known issues I might run into?

You should use this at your own risk. throughout development I've ran into some cases where a line of code may go missing. Undo of course brought it back, but just be aware.
