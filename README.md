KOKeyboard – iOS keyboard extension
===================================

NOTES BY DAVID HOERL ON HIS FORK
===================================
Oct 26, 2013

- added support for iPhone
- added support for UITextField (so it now supports both UITextField and UITextView)
- added the ability to define different buttons for portrait and landscape. For instance, 5 buttons for a iPhone in portrait, and 7 in landscape.
- added keyclicks using the standard approved API
- rolled in all the open issues from the original repository
- fixed a bug on the cursor control if the TextView had scrolled
- added the abilty to just get an object and set a delegate on it. Needed if you want to create one object and share it

Original
===================================
**KOKeyboard** is an iOS drop-in component that adds a new row of keys to the default on-screen keyboard. It consists of swipe buttons with all common symbols, punctuation and brackets, and a special **navigation key**. It was developed for [Kodiak PHP](http://www.becomekodiak.com/), an app which allows you to write and run PHP code directly on the iPad.

<img src="http://i.imgur.com/N7nQY.png">

Swipe buttons & Navigation key
-------------

A swipe button has 5 symbols on it. If you simply tap it, it will produce the middle symbol. However if you swipe it (tap-and-drag) towards one of the corners, it will produce the symbol in that corner.

The navigation key (the middle one with a circle on it) allows you to navigate in the text by moving the cursor in a direction where you drag. If you drag the navigation key, the cursor will move the same way as you drag. If you double tap and drag it will start selecting text from your current position.

To see the component in action, take a look at the video at [http://www.becomekodiak.com/](http://www.becomekodiak.com/) or try our app called [Kodiak PHP on the App Store](http://itunes.apple.com/us/app/kodiak-php/id542685332?ls=1&mt=8).

Usage
-----

We included a demo project that shows how to use the component.

First you should have a simple UITextView. To use this component, include the header file `KOKeyboardRow.h` in the top of your source code:

	#import "KOKeyboardRow.h"

Then when you have a UITextView, simply call the static method `[KOKeyboardRow applyToTextView:yourTextView]`:

	UITextView *textView = [[UITextView alloc] initWithFrame:self.view.bounds];
	textView.text = @"some text...";
	[self.view addSubview:textView];
	[KOKeyboardRow applyToTextView:textView];

You will see the additional keyboard after the UITextView gets focus, if you want to do that programmatically, just do this:

	[textView becomeFirstResponder];

And that's it!

Copyright and license
---------------------

This product is free and open source and it is distributed under the MIT License. See the file `LICENSE` for the complete text of the license.

Contact
-------

http://www.becomekodiak.com/<br />
http://www.twitter.com/becomekodiak/<br />
info@becomekodiak.com

