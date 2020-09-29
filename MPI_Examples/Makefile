BINARIES=hello_world
MPICXX=mpic++

all: ${BINARIES}

hello_world: hello_world.cpp
	${MPICXX} -o hello_world hello_world.cpp
clean:
	rm -f ${BINARIES}
