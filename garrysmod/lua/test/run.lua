include "main.lua"

local results = gmtest.TestFile("test/test.lua")


local bad_color = Color(255, 128, 0)
local good_color = Color(0, 255, 0)
local info_color = Color(255, 255, 255)

local function tabs(level)
  return string.rep("  ", level)
end
local function HumanizeIterator(results, level, info)
  info = info or {
    name_stack = {},
    failures = {},
  }

  local tab0 = tabs(level)

  for _, result in ipairs(results) do
    table.insert(info.name_stack, result.name)

    MsgC(result.ok and good_color or bad_color, string.format("%s%s\n", tab0, table.concat(info.name_stack, " ")))

    if (result.err) then
      table.insert(info.failures, {
        name = table.concat(info.name_stack, " "),
        err = result.err,
      })
    end

    if (result[1]) then
      HumanizeIterator(result, level + 1, info)
    end

    table.remove(info.name_stack)
  end

  return info
end

local function Humanize(results)
  local info = HumanizeIterator(results, 1)

  MsgN( "\n\n" )
  MsgC(info_color, string.format("Passed: %d\n", results.passed))
  MsgC(info_color, string.format("Failed: %d\n", results.failed))
  MsgN( "\n" )

  for _, failure in ipairs(info.failures) do
    MsgC(bad_color, string.format("Failed: %s\n", failure.name))
    MsgC(bad_color, string.format("%s\n", failure.err.err))
    MsgN( "\n" )
  end
end

Humanize(results)

