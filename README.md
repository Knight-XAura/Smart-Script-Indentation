# Smart Script Indentation
Script which monitors for new lines and determines if certain formatting should happen if requirements are met

# Features:
- Hot key (Shift + Enter) to take current line and add spacing before and after and set caret position to the center.
- Press enter so many times before a timeout period and the line you are now on clears and adds so many new lines after automatically
- Customize the timeout period for enter presses
- Able to detect upcoming (static) functions to change formatting behavior
- Ability to customize threshold for amount of times pressing enter

# Upcoming:
- Ability to customize threshold for detecting upcoming lines with (static) funcunctions to determine changes to formatting for consistency in the middle of your script
- Ability fo find upcoming (static) functions in classes
- More consistent formatting with Hot Key
- Persistence of settings
- Hot Key at end of Func line customization to create new lines either above or below
- Ability toallow to insert pass when below function or if next line blank but set for above you can still have pass inserted to the function body

# How to Configure?
  You can configure the application (with what's currently supported) by going to Editor > Editor Settings... > Editor Settings > Scripts > Smart Indent and customize the settings

## What customizations are supported?
  At this time only Action Timeout, Enter Count Threshold, Hot Key, Find Next Func work when customized. 
  
  Keep an eye on this list for changes or for this to disappear all together to indicate everything is customizable!

# Are any features only partially working?

Yes! Unfortunately thresholds of certain values don't format fully as intended in regards to amount of lines to insert and a fix will be coming in time. Also some values are hard coded into these other dynamic parts of code and so results may not be fully what is expected at this time.

# Any major known issues I might run into?

You should use this at your own risk. There is an issue in some cases right now where a line of code may go missing. Undo will bring it back, but just be aware. I know while testing a few times I didn't even notice that missing line til I had an error because of it causing syntax errors.
