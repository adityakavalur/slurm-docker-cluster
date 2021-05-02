help([[
This module loads XALT2 - v2.10.2
]])
local base = "/data/xalt2/xalt/xalt/"

whatis("Usage tracking: XALT")
setenv("XALT_EXECUTABLE_TRACKING","yes")
setenv("XALT_DIR",base)

prepend_path("PATH",pathJoin(base,"bin"))
prepend_path("COMPILER_PATH",pathJoin(base,"bin"))
prepend_path("LD_PRELOAD",pathJoin(base,"lib64/libxalt_init.so"))

