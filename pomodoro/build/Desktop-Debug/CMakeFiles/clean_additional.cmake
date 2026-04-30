# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles/apppomodoro_autogen.dir/AutogenUsed.txt"
  "CMakeFiles/apppomodoro_autogen.dir/ParseCache.txt"
  "apppomodoro_autogen"
  )
endif()
