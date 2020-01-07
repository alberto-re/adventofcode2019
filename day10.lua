--- Day 10: Monitoring Station ---

package.path = "../?.lua;" .. package.path
local common = require("common")

local function distance_between(from, to)
  return math.abs(from["x"] - to["x"]) + math.abs(from["y"] - to["y"])
end

assert(distance_between({ x = 1, y = 1 }, { x = 2, y = 2 }) == 2)
assert(distance_between({ x = 1, y = 3 }, { x = 0, y = 5 }) == 3)
assert(distance_between({ x = -2, y = 0 }, { x = 2, y = 1 }) == 5)

local function parse(text)
  local asteroids = {}
  local y = 0
  for line in text:gmatch("[^\r\n]+") do
    for i = 1, #line do
      local c = line:sub(i, i)
      if c == "#" then
        local x = i - 1
        table.insert(asteroids, { x = x, y = y })
      end
    end
    y = y + 1
  end
  return asteroids
end

local case =
    ".##\n" ..
    "...\n" ..
    "#.#"

assert(common.serialize(parse(case)) == "{{x=1,y=0},{x=2,y=0},{x=0,y=2},{x=2,y=2}}")

local function convert_degrees_to_clockwise(degrees)
  if degrees >= 0 and degrees <= 90 then
    return - degrees + 90
  elseif degrees > 90 and degrees <= 180 then
    return 450 - degrees
  elseif degrees < 0 and degrees >= - 180 then
    return - degrees + 90
  elseif degrees == 180 then
    return 270
  else
    return - degrees + 180
  end
end

assert(convert_degrees_to_clockwise(90) == 0)
assert(convert_degrees_to_clockwise(120) == 330)
assert(convert_degrees_to_clockwise(0) == 90)
assert(convert_degrees_to_clockwise(-90) == 180)
assert(convert_degrees_to_clockwise(-180) == 270)

local function find_best_place(asteroids)
  local best_asteroid_seen = 0
  local best_asteroid = { x = nil, y = nil }
  local best_asteroid_relative_coordinates = {}
  for _, station in ipairs(asteroids) do
    local relative_coordinates = {}
    for _, asteroid in ipairs(asteroids) do
      if station["x"] ~= asteroid["x"] or station["y"] ~= asteroid["y"] then
        local distance = distance_between(station, asteroid)
        local y = station["y"] - asteroid["y"]
        local x = station["x"] - asteroid["x"]
        local arctan = math.atan(y, - x)
        local degrees = arctan * (180 / math.pi)
        local degrees_clockwise = convert_degrees_to_clockwise(degrees)
        if relative_coordinates[degrees_clockwise] == nil then
          relative_coordinates[degrees_clockwise] = {}
        end
        table.insert(relative_coordinates[degrees_clockwise], {
          distance = distance, coordinates = asteroid, arctan = arctan, degrees = degrees })
      end
    end

    local seen = 0
    for _ in pairs(relative_coordinates) do
      seen = seen + 1
    end
    if seen > best_asteroid_seen then
      best_asteroid_seen = seen
      best_asteroid = station
      best_asteroid_relative_coordinates = relative_coordinates
    end

  end

  return best_asteroid_seen, best_asteroid, best_asteroid_relative_coordinates
end

local function calculate_vaporization_order(distances)
  local monotone_to_distances = {}
  local monotone_key_list = {}

  local function distance_comparator(a, b)
    return a["distance"] < b["distance"]
  end

  for key, _ in pairs(distances) do
    table.sort(distances[key], distance_comparator)
    monotone_to_distances[key] = distances[key]
    table.insert(monotone_key_list, key)
  end

  table.sort(monotone_key_list)

  local vaporization_order = {}
  local index = 1

  repeat
    local removed = false
    for _, value in ipairs(monotone_key_list) do
      if #monotone_to_distances[value] > 0 then
        local next_asteroid = table.remove(monotone_to_distances[value], 1)
        table.insert(vaporization_order, next_asteroid["coordinates"])
        removed = true
        index = index + 1
      end
    end
  until removed == false

  return vaporization_order
end

local function main()

  local input =
    ".#..#\n" ..
    ".....\n" ..
    "#####\n" ..
    "....#\n" ..
    "...##"

  local max_seen, best_location = find_best_place(parse(input))
  assert(best_location["x"] == 3 and best_location["y"] == 4)
  assert(max_seen == 8)

  input =
    "......#.#.\n" ..
    "#..#.#....\n" ..
    "..#######.\n" ..
    ".#.#.###..\n" ..
    ".#..#.....\n" ..
    "..#....#.#\n" ..
    "#..#....#.\n" ..
    ".##.#..###\n" ..
    "##...#..#.\n" ..
    ".#....####"

  max_seen, best_location = find_best_place(parse(input))
  assert(best_location["x"] == 5 and best_location["y"] == 8)
  assert(max_seen == 33)

  input =
    "#.#...#.#.\n" ..
    ".###....#.\n" ..
    ".#....#...\n" ..
    "##.#.#.#.#\n" ..
    "....#.#.#.\n" ..
    ".##..###.#\n" ..
    "..#...##..\n" ..
    "..##....##\n" ..
    "......#...\n" ..
    ".####.###."

  max_seen, best_location = find_best_place(parse(input))
  assert(best_location["x"] == 1 and best_location["y"] == 2)
  assert(max_seen == 35)

  input =
    ".#..##.###...#######\n" ..
    "##.############..##.\n" ..
    ".#.######.########.#\n" ..
    ".###.#######.####.#.\n" ..
    "#####.##.#.##.###.##\n" ..
    "..#####..#.#########\n" ..
    "####################\n" ..
    "#.####....###.#.#.##\n" ..
    "##.#################\n" ..
    "#####.##.###..####..\n" ..
    "..######..##.#######\n" ..
    "####.##.####...##..#\n" ..
    ".#####..#.######.###\n" ..
    "##...#.##########...\n" ..
    "#.##########.#######\n" ..
    ".####.#.###.###.#.##\n" ..
    "....##.##.###..#####\n" ..
    ".#.#.###########.###\n" ..
    "#.#.#.#####.####.###\n" ..
    "###.##.####.##.#..##"

  local relative_coordinates
  max_seen, best_location, relative_coordinates = find_best_place(parse(input))
  assert(best_location["x"] == 11 and best_location["y"] == 13)
  assert(max_seen == 210)

  local vaporization_order = calculate_vaporization_order(relative_coordinates)
  assert(vaporization_order[1]["x"] == 11 and vaporization_order[1]["y"] == 12)
  assert(vaporization_order[2]["x"] == 12 and vaporization_order[2]["y"] == 1)
  assert(vaporization_order[3]["x"] == 12 and vaporization_order[3]["y"] == 2)
  assert(vaporization_order[10]["x"] == 12 and vaporization_order[10]["y"] == 8)
  assert(vaporization_order[20]["x"] == 16 and vaporization_order[20]["y"] == 0)
  assert(vaporization_order[50]["x"] == 16 and vaporization_order[50]["y"] == 9)
  assert(vaporization_order[100]["x"] == 10 and vaporization_order[100]["y"] == 16)
  assert(vaporization_order[199]["x"] == 9 and vaporization_order[199]["y"] == 6)
  assert(vaporization_order[200]["x"] == 8 and vaporization_order[200]["y"] == 2)
  assert(vaporization_order[201]["x"] == 10 and vaporization_order[201]["y"] == 9)
  assert(vaporization_order[299]["x"] == 11 and vaporization_order[299]["y"] == 1)
  assert(#vaporization_order == 299)

  local f = io.open(os.getenv("PWD") .. "/input/day10.txt", "r")
  input = f:read("*all")
  f:close()

  max_seen, best_location, relative_coordinates = find_best_place(parse(input))
  vaporization_order = calculate_vaporization_order(relative_coordinates)

  print("part 1:", max_seen, best_location["x"] .. "," .. best_location["y"])
  print("part 2:", vaporization_order[200]["x"] * 100 + vaporization_order[200]["y"])
end

main()
