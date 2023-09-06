# Smart Scripting
Script which monitors for new lines and determines if certain formatting should happen if requirements are met

## Features:
- Customizable options in editor settings
- Hot key (Shift + Enter) inserts new lines and centers caret between start and ending (Insert New Function Spacing Hotkey)
- Press enter and meet a threshold and the line clears and the threshold minus one inserts after it (Enter Count Threshold)
- Able to detect upcoming (static) functions to change formatting behavior (Find Upcoming Function)

## Upcoming:
- Introductary screen with don't show again option (only works if we have persistence)
- Make hard coded data that shouldn't be hard coded, dynamically coded
- Ability fo find upcoming (static) functions in classes
- Persistence of settings
- Hot Key at end of Func line customization to create new lines either above or below
- Ability to allow to insert pass when below function or if next line blank but set for above you can still have pass inserted to the function body
- Fix inserting lines at or near end of file

## Development Pace and Priorities:

I wanted to take a moment and note that I know this don't seem like much now, but I have so much planned on my head that I'd like to put on the Upcoming section, but I need to work out the kinks with spacing and then I have a bunch of features in mind that can rapidly be implemented. So my current priority is finishing up the most basic thing this script does and that is spacing. I have more customization options for this I'd think I'll be implementing so you can choose behavior as well. I hope you'll stick around to see and provide feedback on the great things we can accomplish! :)

## How to Configure?

You can configure the plugin by going to Editor > Editor Settings... > Editor Plugins > Scripts > Smart Indent and customize the settings

### What customizations are supported?
All customizations currently work, although some pieces that are supposed to depend on that information is still hard coded, so line spacing results may not be quite as expected in all cases.

## Are any features only partially working?

Yes! Unfortunately thresholds of certain values don't format fully as intended in regards to amount of lines to insert and a fix will be coming in time. Also some values are hard coded into these other dynamic parts of code and so results may not be fully what is expected at this time.

## Any major known issues I might run into?

You should use this at your own risk. throughout development I've ran into some cases where a line of code may go missing. Undo of course brought it back, but just be aware.
