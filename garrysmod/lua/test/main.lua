gmtest = gmtest or {
  Suite = include "suite.lua",
}

local test = gmtest

function test.GenerateSuite(func, parent)
  local suite = test.Suite(debug.getinfo(func, "S").short_src, parent)
  suite:Generate(func)
  return suite
end

--[[
  TestFile( filename )
    filename: string
    returns: bool, string
      bool: true if the test passed, false if it failed
      string: error message if the test failed
]]
function test.TestFile( filename )
  local f = file.Open( filename, "r", "LUA" )
  if ( not f ) then
    return false, "File not found"
  end

  local contents = f:Read()
  f:Close()

  local func = CompileString( contents, filename, false )

  if ( type( func ) == "string" ) then
    return false, func
  end

  local suite = test.GenerateSuite( func )

  local results = suite:Run()

  return results
end

function test.TestFolder( foldername )
end

function test.RunAll()
end
