--- Day 3: Crossed Wires ---

local function tosteps(str)
  local list = {}
  for step in string.gmatch(str, "([^,]+)") do
    table.insert(list, step)
  end
  return list
end

assert(table.concat(tosteps("R75,D30,R83,U83,L12,D49,R71,U7,L72")) ==
       table.concat({ "R75", "D30", "R83", "U83", "L12", "D49", "R71", "U7", "L72" }))

local function manhattan(x, y)
  return math.abs(x[1] - y[1]) + math.abs(x[2] - y[2])
end

assert(manhattan({ 1, 1 }, { 3, 3 }) == 4)
assert(manhattan({ 0, 0 }, { 6, 6 }) == 12)

local function move(point, direction)
  if direction == "U" then
    return { point[1], point[2] + 1 }
  elseif direction == "D" then
    return { point[1], point[2] - 1 }
  elseif direction == "R" then
    return { point[1] + 1, point[2] }
  elseif direction == "L" then
    return { point[1] - 1, point[2] }
  end
end

assert(table.concat(move({ 1, 2 }, "U")) == table.concat({ 1, 3 }))
assert(table.concat(move({ -1, -7 }, "R")) == table.concat({ 0, -7 }))

local function visited(steps)
  local locations = {}
  local cur_location = { 0, 0 }
  local moves = 0
  for i = 1, #steps do
    local dir, len = string.sub(steps[i], 1, 1), string.sub(steps[i], 2)
    for _ = 1, len do
      moves = moves + 1
      cur_location = move(cur_location, dir)
      locations[cur_location[1] .. "_" .. cur_location[2]] = { cur_location, moves }
    end
  end
  return locations
end

local function closest_intersection(wire1, wire2)
  local steps1, steps2 = tosteps(wire1), tosteps(wire2)
  local visited1, visited2 = visited(steps1), visited(steps2)
  local min_distance = 999999

  for key, value in pairs(visited1) do
    if visited2[key] ~= nil then
      local distance = manhattan(value[1], { 0, 0 })
      if distance < min_distance then
        min_distance = distance
      end
    end
  end

  return min_distance
end

assert(closest_intersection("R75,D30,R83,U83,L12,D49,R71,U7,L72", "U62,R66,U55,R34,D71,R55,D58,R83") == 159)
assert(closest_intersection(
  "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51", "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7") == 135)

local function fewest_combined_steps(wire1, wire2)
  local steps1, steps2 = tosteps(wire1), tosteps(wire2)
  local visited1, visited2 = visited(steps1), visited(steps2)
  local min_steps = 999999

  for key, value in pairs(visited1) do
    if visited2[key] ~= nil then
      local combined = value[2] +  visited2[key][2]
      if combined < min_steps then
        min_steps = combined
      end
    end
  end

  return min_steps
end

assert(fewest_combined_steps("R75,D30,R83,U83,L12,D49,R71,U7,L72", "U62,R66,U55,R34,D71,R55,D58,R83") == 610)
assert(fewest_combined_steps(
  "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51", "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7") == 410)

local function main()
  local f = io.open(os.getenv("PWD") .. "/input/day03.txt", "r")
  local wire1, wire2 = f:read("*line"), f:read("*line")
  f:close()

  print("part 1: " .. closest_intersection(wire1, wire2))
  print("part 2: " .. fewest_combined_steps(wire1, wire2))
end

main()