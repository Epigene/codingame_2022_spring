require "set"
require "benchmark"

STDOUT.sync = true # DO NOT REMOVE

def debug(message)
  STDERR.puts(message)
end

MAX_X = 17_630
MAX_Y = 9000

HERO_MOVESPEED = 800 # 566, 566 in a 45% angle
HERO_ATTACKRANGE = 800

MONSTER_MOVESPEED = 400 # half that of a hero

LAWN_RADIOUS = 5000
BASE_RADIUS = 300

def mound
  return @mound if defined?(@mound)

  if BASE_X.zero?
    [4101, 4101]
  else
    [MAX_X - 4101, MAX_Y - 4101]
  end
end
