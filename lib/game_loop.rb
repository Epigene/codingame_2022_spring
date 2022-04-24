# game loop
loop do
  line = gets
  # debug(line)
  # health: Your base health
  # mana: Ignore in the first league; Spend ten mana to cast a spell
  my_health, my_mana = line.split.map(&:to_i)

  line = gets
  # debug(line)
  # health: Your base health
  # mana: Ignore in the first league; Spend ten mana to cast a spell
  opp_health, opp_mana = line.split.map(&:to_i)

  lines = []

  entity_count = gets.to_i # Amount of heros and monsters you can see

  entity_count.times do
    line = gets
    debug(line)
    lines << line
  end

  params = {
    health: my_health, mana: my_mana, opp_health: opp_health, opp_mana: opp_mana, lines: lines
  }

  decider.call(params).select { |command| puts(command) }
  #=> puts as many commands as I have heroes.
end
