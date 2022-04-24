# frozen_string_literal: true

# This script reads the `build_order.txt` file thats placed in the same dir as this script file
# and concatenates the file conentents, in order, into a "codingame.rb" file in the same dir.

# Call by running `$ ruby codingame_concatenator.rb` in console

require "pry"

concatenable_file_list_path = Pathname.new("./build_order.txt")
output_path = Pathname.new("./codingame.rb")

File.open(output_path, "w") do |file|
  file.write("# Created at #{Time.now} \n")

  File.readlines(concatenable_file_list_path).each do |addable_file_path|
    addable_path = addable_file_path.chomp
    next if addable_path.to_s == ""

    contents = File.read(Pathname.new("./#{ addable_file_path.chomp }"))
    file.write("#{ contents }\n")
  end
end

puts(
  "Concatenated contents of files mentioned in #{ concatenable_file_list_path } "\
  "into #{ output_path }"
)
