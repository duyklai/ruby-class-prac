require "csv"
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'

# Home-made parser (OLD CODE)
# lines = File.readlines "event_attendees.csv"
# lines.each_with_index do |line, index|
#     next if index == 0
#     columns = line.split(",")
#     name = columns[2]
#     puts name
# end

# Method to clean up/display zipcode nicely/properly
def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5,"0")[0..4]
end

# Method to clean up phone numbers
def clean_phone_number(phone_number)
    phone_number = phone_number.to_s.delete('^0-9')
    if phone_number.length == 10 || (phone_number.length == 11 && phone_number[0] == "1")
        phone_number = phone_number.rjust(11,"1")
        return "(#{phone_number[1..3]}) #{phone_number[4..6]} #{phone_number[7..10]}"
    else
        return "Invalid phone number"
    end
end

# Method to return the array full of information concerning the matching zipcode and legislators
def legislators_by_zipcode(zipcode)
    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  
    begin
      civic_info.representative_info_by_address(
        address: zipcode,
        levels: 'country',
        roles: ['legislatorUpperBody', 'legislatorLowerBody']
      ).officials # Return the original array of legislators (used for form)

        # Used for when we need to print to screen
        #legislators = legislators.officials
        #legislators_names = legislators.map(&:name).join(", ")
    rescue
      "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
    end
end

# Method to save the erb template output to file matching the attendee's id
def save_thank_you_letters(id, form_letter)
    Dir.mkdir("output") unless Dir.exists?("output")
    filename = "output/thanks_#{id}.html"
    File.open(filename, 'w') do |file|
        file.puts form_letter
    end
end

# Method for getting the most popular hour when registration happens
def popular_hours(hash)
    hash.max_by {|k,v| v}
end

# Method for getting the most popular day of the week when registration happens
def popular_week_day(hash)
    # Array for selecting day of the week
    week_days = %w{Sunday Monday Tuesday Wednesday Thursday Friday Saturday}
    wday_arr = hash.max_by {|k,v| v}
    wday_arr[0] = week_days[wday_arr[0].to_i]
    return wday_arr
end

puts "EventManager Initialized!"

template_letter = File.read("form_letter.erb")
erb_template = ERB.new template_letter
hour_hash = Hash.new(0) # Hash to count common hours on event_attendees.csv
wday_hash = Hash.new(0) # Hash to count common days of the week on event_attendees.csv

# Using ruby's CSV parser
contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol
contents.each do |row|
    id = row[0]
    name = row[:first_name]
    zip = clean_zipcode(row[:zipcode])
    phone_number = clean_phone_number(row[:homephone])
    # Requires full array of info for erb template to utilize fetching legislator's name AND links
    legislators = legislators_by_zipcode(zip)

    # Collecting data on time of registration (time and day of week)
    datetime = DateTime.strptime(row[:regdate], '%m/%d/%y %k:%M')
    hour_hash[datetime.hour] += 1
    wday_hash[datetime.wday] += 1

    # Used for ERB template
    form_letter = erb_template.result(binding)
    # Printing all thank you letters to output/thanks_#id.html
    save_thank_you_letters(id, form_letter)

    # Used for basic HTML form (form_letter.html); utilizing .gsub AND/OR .gsub! (OLD CODE)
    # personal_letter = template_letter.gsub('FIRST_NAME', name)
    # personal_letter.gsub!('LEGISLATORS', legislators)

    #puts "#{name} at #{zip} phone: #{phone_number}"
end

puts "Popular hour at #{popular_hours(hour_hash)[0]}:00 with count of #{popular_hours(hour_hash)[1]}"
puts "Popular day is #{popular_week_day(wday_hash)[0]} with count of #{popular_week_day(wday_hash)[1]}"
