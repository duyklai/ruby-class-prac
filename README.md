# Ruby Practice: Classes
These two projects were focused on utilizing classes, IO, and serialization. The Event Manager project was about reading from a ".csv" file and performing extraction (attendee's name, zip, phone) and extrapolation (most popular time, most popular weekday) on that data. *Event Manager* also has output capabilities, utilizing erb template and outputting .html (thank you) files for event attendees. All these files will be included in the directory. The `event_manager.rb` file is in under `$lib/event_manager.rb`

The Hangman project was about making the Hangman game as well as implementing a save system. Player can start a game of Hangman and choose to save their game state and resume at a later time. The game reads in data (words) from a file in the root of the directory (5desk.txt). The game will randomly chooses a word from the word bank between length 5 to 12 letters long. You can change the word bank by changing the variable `dictionary` in the code and adding the text file to the root. Included is the instruction when you run the .rb file by `ruby hangman.rb`

![alt text](https://github.com/duyklai/ruby-class-prac/blob/master/images/hangman.jpg "Hangman 1")

![alt text](https://github.com/duyklai/ruby-class-prac/blob/master/images/hangman2.jpg "Hangman 2")