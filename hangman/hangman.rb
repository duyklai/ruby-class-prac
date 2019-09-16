class Hangman
  def initialize(filename)
    @filename = filename
    @chosen_word = ""
    @mistakes = 0
    @board = []
    @won = false
    @incorrect_guess = ""
    # For the very first launch on of hangman.rb
    Dir.mkdir("saved_games") unless File.exists?("saved_games")
  end

  # Method to display the board
  def display_board
    dash_field = "" # Temp string variable to output the current state of the game
    @board.each do |letter|
      dash_field += letter + " "
    end
    p dash_field    
  end

  # Method to set up the first time with choosing the random word, fill the board with "_" of the length of the chosen_word, put the initial message, and display the board
  def first_turn
    chosen_random_word
    @chosen_word.length.times {@board << "_"}
    puts mistakes_message
    display_board
    puts ""
  end

  # Method for choosing a random word from file between length 5 and 12, inclusive
  def chosen_random_word()
    word_found = false
    while !word_found
      word = File.readlines(@filename).sample
      word.gsub!("\n", "")
      if word.length.between?(5,12)
        @chosen_word = word
        word_found = true
      end
    end
  end # End of method chosen_random_word

  # Method for telling the player what has been drawn so far (mistakes counter)
  def mistakes_message()
    case @mistakes
    when 0
        "There is a suspicious noose over there..."
    when 1
        "A circle appeared and is attached to the noose now..."
    when 2
        "Now there is a vertical line attached to the circle..."
    when 3
        "Two lines just popped out the middle line! It's a person!"
    when 4
        "The body has two legs now... He struggling! Quickly!"
    when 5
        "You couldn't save him... He's dead!"
    else 
    end
  end

  # Method for checking if the board is filled in with letters (no "_" to be found),then declare won
  def check_status
    if @board.none? {|word| word == "_"}
        @won = true
    end
  end

  # Method for saving the game object to a file; able to load up later
  # Using Marshal because file does not need to be human read-able
  def save_game
    saved_games_list = Dir.glob("saved_games/*")

    # Gets save name from player
    print "Insert save file name: "
    save_name = gets.chomp
    filename = "saved_games/saved_game_file-#{save_name}.txt"

    # If save name choosen already exists, ask about override
    if saved_games_list.include?(filename)
      puts "#{save_name} already exists. Would you like to override(Y/N)?"
      begin
        choice = gets.chomp.downcase.match(/^[yn]{1}$/)[0]
      rescue
        puts "Please input a valid choice"
        retry
      end

      # Dump game object into the .txt file with the save name choosen
      game_object = Marshal::dump(self)
      File.open(filename, "w") do |file|
        file.write(game_object)
      end
    else # If the save name file does not exist
      save_file = File.new(filename, "w") # Create it and save the game
      game_object = Marshal::dump(self)
      save_file.puts (game_object)
      save_file.close()
    end # End of if saved_games_list.include?(filename)
  end # End of method save_game

  # Method to start the game
  def play_game
    while !@won && @mistakes < 5 # If not won yet and still under 5 mistakes, keep playing
      if @incorrect_guess != "" # Only output previous guesses if they were any
        puts "Your previous incorrect guesses were: " + @incorrect_guess
      end

      begin # Checking for valid letter input
        print "Enter a letter for your guess: "
        guess = gets.match(/^[A-Za-z]$|^save$/)[0]
      rescue
        puts "Your guess is not a letter, try again."
        puts ""
        retry # Retry until the player inputs a letter
      end # End of begin clause

      # If players inputted save
      if guess == "save"
        puts ""
        save_game()
        puts "Saving game..."
        puts ""
        next # Save the game state and refresh the turn
      end

      # If the chosen_word includes the guessed word
      if @chosen_word.downcase.include?(guess)
        # Find all the indexes of the guessed word
        temp_arr = @chosen_word.length.times.select {|index| @chosen_word[index].downcase == guess.downcase} # Ignores case-sensitivity 
        temp_arr.each {|index| @board[index] = @chosen_word[index]}
      else
        @mistakes += 1
        @incorrect_guess += guess.upcase + " "
        puts "Your guess was incorrect. " + mistakes_message
      end 

      check_status
      sleep 1 # Gives impression of checking result; can be removed
      display_board unless @mistakes >= 5
      puts ""
    end # End of while loop for the game

    # Printing win or loss messages
    if @won
        puts "Congratulation! You have guessed the word!"
    else
        puts "The word was #{@chosen_word}. Better luck next time!"
    end
  end # End of method play_game
end # End of class Hangman

# Game introduction/instruction
puts "                  ===================================="
puts "                         WELCOME TO HANGMAN"
puts "                  ====================================\n\n"
puts "This is a one player guessing game. A word will be chosen at random from our dictionary (5-12 letters long)."
puts "You, the player, will take a guess each turn. You have 5 guesses before the hangman is drawn and executed."
puts "You can choose to save the game at any time by typing \"save\" as your guess. You can load your save at a later time"
puts "\n\n"

play = false
while !play
  game = nil # Declaring the variable for later used; will be Hangman object
  loop do
    # Menu of the game
    puts "1) Start game"
    puts "2) Load game"
    begin
      print "What would you like to do? "
      ready = gets.match(/^[1-2]$/)[0]
    rescue
      puts ""
      retry # Retry until the player inputs valid option
    end
    puts "" # End of Menu

    if ready == "1" # New game
      dictionary = "5desk.txt" # File name for word bank
      game = Hangman.new(dictionary)
      game.first_turn # Run first turn set-up
      break # Break out of menu loop
    elsif ready == "2" # Loading game
      saved_games_list = Dir.glob("saved_games/*")

      if saved_games_list.empty? # If there are no previous saves
        puts "There are no saved files"
        puts "Returning to menu..."
        sleep 1 # Simulate small loading time
        puts ""
      else
        # Print out all of the previous game files in the directory
        saved_games_list.each_with_index do |file, index|
          puts "#{index+1}) #{File.basename(file,".txt")}"
        end
        puts ""

        print "Choose a save file: "
        # Makes sure player picks one of the file presented
        begin
          choice = gets.chomp.to_i
          if !choice.between?(1, saved_games_list.length)
            raise 'Error'
          end
        rescue
          puts "Not a valid option, try again."
          retry
        end

        # Load the binary file into back into game object
        selected_saved_game = saved_games_list[choice-1]
        game = Marshal::load(File.binread(selected_saved_game.to_s))
        game.display_board # Display the board so the player can catch back up
        puts ""
        break
      end # End of saved_games_list.empty? 
    end # End of "ready" check
  end # End of loop (menu looping)

  # Resume OR start new game, depending on player's choice
  game.play_game
        
  # Checking for playing again
  puts "Play again? (Y/N)"
  begin
    choice = gets.chomp.downcase.match(/^[yn]{1}$/)[0]
  rescue
    puts "Please input a valid choice"
    retry
  end

  if choice == 'n'
    play = true
    puts "Thanks for playing!\n"
  else
    puts "\n\n"
  end
end