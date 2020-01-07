local common = {}

-- Naive data serializer
function common.serialize(data)
  local str = ""
  if type(data) == "table" then
    if #data > 0 then
      str = str .. "{"
      for _, value in ipairs(data) do
        str = str .. common.serialize(value) .. ","
      end
      str = string.sub(str, 1, -2) .. "}"
    else
      str = str .. "{"
      local keys = {}
      for key, _ in pairs(data) do
        table.insert(keys, key)
      end
      table.sort(keys)
      for _, key in ipairs(keys) do
         str = str .. key .. "=" .. common.serialize(data[key]) .. ","
      end
      str = string.sub(str, 1, -2) .. "}"
    end
  else
    str = str .. tostring(data)
  end
  return str
end

return common
