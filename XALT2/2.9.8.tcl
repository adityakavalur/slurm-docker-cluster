#%Module1.0#####################################################################
##
## modules modulefile
##
module-whatis XALT2 - v2.9.8 is loaded

setenv       XALT_EXECUTABLE_TRACKING yes
setenv       XALT_DIR                 /data/xalt2/xalt/xalt
prepend-path PATH                     $env(XALT_DIR)/bin
prepend-path COMPILER_PATH            $env(XALT_DIR)/bin
prepend-path LD_PRELOAD               $env(XALT_DIR)/lib64/libxalt_init.so
