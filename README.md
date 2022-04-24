# Condinbot
Not a gem! A sandbox where to develop bots for codingame in TDD manner, in separate, testable files.

## Use
1. Place files in `lib/`, and require them in `lib/codinbot.rb` like you normally would.
2. Write specs in `spec/`
3. Configure `build_order.txt` contents.
4. When you're ready to sync to codingame, run `$ ruby codingame_concatenator.rb` which will update `condingame.rb` file with the conecatenaton results.

## Challenge notes (2022 Spring)
* Probably a good idea to prevent heroes from going too close to the edge of the arena. 566 is the maximum, 100-200 probably effective and safe.
* When attacking the closest threat, it's probably a good idea to trail it a bit (again, 566 units is max), to reduce the time
  necessary to reach the next target.

## License

The code is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
