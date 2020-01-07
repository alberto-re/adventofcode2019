--- Day 6: Universal Orbit Map ---

package.path = "../?.lua;" .. package.path
local common = require("common")

local function extract_orbits(map_data)
  local orbits = {}
  for _, line in ipairs(map_data) do
    local sep_idx = string.find(line, ")")
    local center, orbiting = string.sub(line, 1, sep_idx -1), string.sub(line, sep_idx + 1)
    if orbits[center] == nil then
      orbits[center] = {}
    end
    orbits[center][orbiting] = true
  end
  return orbits
end

local case_1 = extract_orbits({ "AAA)BBB", "AAA)CCC", "BBB)CCC" })
local case_1_exp = "{AAA={BBB=true,CCC=true},BBB={CCC=true}}"
assert(common.serialize(case_1) == case_1_exp)
local case_2 = extract_orbits({ "AAA)BBB", "AAA)CCC", "BBB)CCC", "AAA)DDD", "CCC)DDD", "CCC)EEE" })
local case_2_exp = "{AAA={BBB=true,CCC=true,DDD=true},BBB={CCC=true},CCC={DDD=true,EEE=true}}"
assert(common.serialize(case_2) == case_2_exp)

local function checksum(direct_orbits)
  local total_orbits = {}

  -- Recursively finds all orbits of an object
  local function recur_orbits(center, origin)
    for object, _ in pairs(direct_orbits[center]) do
      if origin == nil then
        origin = center
      end
      total_orbits[origin .. object] = true
      if direct_orbits[object] ~= nil then
        recur_orbits(object, origin)
      end
    end
  end

  for object, _ in pairs(direct_orbits) do
    recur_orbits(object)
  end

  local total_number = 0
  for _, _ in pairs(total_orbits) do
    total_number = total_number + 1
  end
  return total_number
end

assert(checksum(case_1) == 3)
assert(checksum(case_2) == 9)

local function adjacency_list(map_data)
  local orbits = {}
  for _, line in ipairs(map_data) do
    local sep_idx = string.find(line, ")")
    local center, orbiting = string.sub(line, 1, sep_idx -1), string.sub(line, sep_idx + 1)
    if orbits[center] == nil then
      orbits[center] = {}
    end
    if orbits[orbiting] == nil then
      orbits[orbiting] = {}
    end
    orbits[center][orbiting] = true
    orbits[orbiting][center] = true
  end
  return orbits
end

assert(
  common.serialize(adjacency_list({ "AAA)BBB", "AAA)CCC", "BBB)CCC" })) ==
  "{AAA={BBB=true,CCC=true},BBB={AAA=true,CCC=true},CCC={AAA=true,BBB=true}}"
)

local function orbital_transfers(direct_orbits, you, goal)

  -- Finds the object start is orbiting around
  local function find_center(orbiting_object)
    for object, _ in pairs(direct_orbits) do
      if direct_orbits[object][orbiting_object] ~= nil then
        return object
      end
    end
  end

  local function BFS(starting_vertex)
    local frontier = {}
    local discovered = {}
    discovered[starting_vertex] = true
    table.insert(frontier, { edge=starting_vertex, distance=1 })
    while #frontier > 0 do
      local current = table.remove(frontier)
      for object, _ in pairs(direct_orbits[current["edge"]]) do
        if object == goal then
          return current["distance"] - 1
        else
          if discovered[object] == nil then
            discovered[object] = true
            table.insert(frontier, { edge=object, distance=current["distance"] + 1 })
          end
        end
      end
    end
  end

  return BFS(find_center(you))
end

local test_map = { "COM)B", "B)C", "C)D", "D)E", "E)F", "B)G", "G)H", "D)I", "E)J", "J)K", "K)L", "K)YOU", "I)SAN" }
assert(orbital_transfers(adjacency_list(test_map), "YOU", "SAN") == 4)

local function main()
  local f = io.open(os.getenv("PWD") .. "/input/day06.txt", "r")
  local map_data = {}
  for line in f:lines() do
    table.insert(map_data, line)
  end
  f:close()

  print("part 1: " .. checksum(extract_orbits(map_data)))
  print("part 2: " .. orbital_transfers(adjacency_list(map_data), "YOU", "SAN"))
end

main()
