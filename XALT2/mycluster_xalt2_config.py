# This is the config file for specifying tables necessary to configure XALT:

# The patterns listed here are the hosts that can track executable with XALT.
# Typical usage is that compute nodes track executable with XALT while login
# nodes do not.

import sys

# Note that linking an executable is everywhere and is independent of
# hostname_patterns

hostname_patterns = [
  ['KEEP', r'compute.*']                    # match all compute nodes
  ]

#------------------------------------------------------------
# This "table" is use to filter executables by their path
# The value on the left is either KEEP or SKIP.  If the value
# is KEEP then if the path matches the regular expression then
# the executable is acceptable as far as the path test goes.
# If the value on the left is SKIP then if the path matches
# the regular expression then executable is not acceptable so
# no XALT tracking is done for that path.

# This "table" is used to generate a flex routine that processes
# the paths. So the regular express must follow flex rules.
# In particular, in order to match the pattern must match the whole path
# No partial matches allowed.  Also do not use $ to match the
# end of the string.  Finally slash is a special character and must
# be quoted with a backslash.

# The path are conceptionally matched from the first regular 
# expression to the last.  Once a match is found no other later
# matches are checked. The upshot of this is that if you want to
# track say /usr/bin/ddt, but ignore everything in /usr, then keep
# /usr/bin/ddt first and skip /usr/.* after.

# If a path does not match any patterns it is marked as KEEP.

# There are special scalar programs that must generate a start record.
# These are marked as SPSR

path_patterns = [
    ['PKGS',  r'.*\/python[0-9.]*'],
    ['PKGS',  r'.*\/R'],
    ['PKGS',  r'.*\/test_record_pkg'],
    ['PKGS',  r'.*\/get_XALT_env'],
  ]


# Here are patterns for non-mpi programs to produce a start-record.
# Normally non-mpi programs (a.k.a.) scalar executables only produce
# an end-record, but programs like R and python that can have optional data
# such as R and python must have a start-record.

scalar_prgm_start_record = [
    r'/python[0-9][^/][^/]*$',
    r'/R$'
    ]
    
#------------------------------------------------------------
# XALT filter environment variables.  Those variables
# which pass through the filter are save in an SQL table that is
# searchable via sql commands.  The environment variables are passed
# to this filter routine as:
#
#      env_key=env_value
#
# So the regular expression patterns must match the whole string.


# The value on the left is either KEEP or SKIP.  If the value
# is KEEP then if the environment string matches the regular
# expression then the variable is stored. If the value on the left
# is SKIP then if the variable matches it is not stored.

# Order of the list matters.  The first match is used even if a
# later pattern would also match.  The upshot is that special pattern
# matches should appear first and general ones later.

# If the environment string does not match any pattern then it is
# marked as SKIP.


env_patterns = [
    [ 'KEEP', r'^OMP_NUM_THREADS=.*' ],
    [ 'KEEP', r'^OMP.*'],
    [ 'KEEP', r'^PATH=.*'],
    [ 'KEEP', r'^PYTHON.*'],
    [ 'KEEP', r'^R_.*'],
  ]

#------------------------------------------------------------
# XALT samples almost all  executions (both MPI and scalar) 
# based on this table below.  Note that an MPI execution is where
# the number of tasks is greater than 1.  There is no check to
# see if there are MPI libraries in the executable.  Note that
# the number of tasks are MPI tasks not threads.

# Any time there are a number of short rapid executions these
# have to be sampled. However, there are MPI executions with large
# number of tasks that are always recorded.  This is to allow the
# tracking of long running MPI tasks that never produce an end
# record. By default MPI_ALWAYS_RECORD = 2.  Namely that all MPI tasks are
# recorded.

MPI_ALWAYS_RECORD = 2

#
# The array of array used by interval_array has the following
# structure:
#
#   interval_array = [
#                     [ t_0,     probability_0],
#                     [ t_1,     probability_1],
#                     ...
#                     [ t_n,     probability_n],
#                     [ 1.0e308, 1.0],
#                      
#
# The first number is the left edge of the time range.  The
# second number is the probability of being sampled. Where a
# probability of 1.0 means a 100% chance of being recorded and a
# value of 0.01 means a 1% chance of being recorded. 
#
# So a table that looks like this:
#     interval_array = [
#                       [ 0.0,                0.0001 ],
#                       [ 300.0,              0.01   ],
#                       [ 600.0,              1.0    ],   
#                       [ sys.float_info.max, 1.0    ]
#     ]
#
# would say that program with execution time that is between
# 0.0 and 300.0 seconds has a 0.01% chance of being recorded.
# Execution times between 300.0 and 600.0 seconds have a 1% 
# chance of being recorded and and programs that take longer
# than 600 seconds will always be recorded.
#
# The absolute minimum table would look like:
#
#     interval_array = [
#                       [ 0.0,                1.0 ],
#                       [ sys.float_info.max, 1.0 ]
#     ]
#
# which says to record every scalar (non-mpi) program no matter
# the execution time.
#
# Note that scalar execution only uses this table IFF
# $XALT_SCALAR_AND_SPSR_SAMPLING equals yes

interval_array = [
    [ 0.0,                1.0 ],
    [ sys.float_info.max, 1.0 ]
]
mpi_interval_array = [
    [ 0.0,                1.0 ],
    [ sys.float_info.max, 1.0 ]
]

#------------------------------------------------------------
# Python pattern for python package tracking
# NOTE: This is likely to be an added feature in XALT3, not implemented yet

# Note that sys, os, re, and subprocess can not be tracked due to the way that python tracking works.

#python_pkg_patterns = [
#  { 'k_s' : 'KEEP', 'kind' : 'path', 'patt' : r".*/site-packages/"      },  # KEEP all built-in packages
#  { 'k_s' : 'KEEP', 'kind' : 'name', 'patt' : r"^_"         },  # KEEP names that start with a underscore
#  { 'k_s' : 'KEEP', 'kind' : 'name', 'patt' : r".*\."       },  # KEEP all names that are divided with periods: a.b.c
#  { 'k_s' : 'KEEP', 'kind' : 'path', 'patt' : r".*/.local/" },  # KEEP all packages installed by users
#  { 'k_s' : 'KEEP', 'kind' : 'path', 'patt' : r"^/home"      },  # KEEP all other packages in user locations
#  { 'k_s' : 'KEEP', 'kind' : 'path', 'patt' : r"^/data"      },  # KEEP all other packages in user locations
#]
