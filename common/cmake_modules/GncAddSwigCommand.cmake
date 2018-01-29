# Copyright (c) 2010, Christian Stimming
# Copyright (c) 2018, Geert Janssens

# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.

macro (GNC_ADD_SWIG_COMMAND _target _output _input)

    add_custom_command (
        OUTPUT ${_output}
        DEPENDS ${_input} ${CMAKE_SOURCE_DIR}/common/base-typemaps.i ${ARGN}
        COMMAND ${SWIG_EXECUTABLE} -guile ${SWIG_ARGS} -Linkage module -I${CMAKE_SOURCE_DIR}/libgnucash/engine -I${CMAKE_SOURCE_DIR}/common  -o ${_output} ${_input}
    )

    add_custom_target(${_target} DEPENDS ${_output})

    if (BUILDING_FROM_VCS)
        set(BUILD_SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR})
    else()
        set(BUILD_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
    endif()

    # Add the output file _output to the dist tarball
    file(RELATIVE_PATH generated ${BUILD_SOURCE_DIR} ${_output})
    dist_add_generated(${generated})
endmacro (GNC_ADD_SWIG_COMMAND)


# gnc_add_swig_python_command is used to generate python swig wrappers
# it will only really generate the wrappers when building from git
# when building from tarball it will set up everything so the version of the wrapper
# from the tarball will be used instead
# - _target is the name of a global target that will be set for this wrapper file,
#    this can be used elsewhere to create a depencency on this wrapper
# - _out_var will be set to the full path to the generated wrapper file
#   when building from git, it points to the actually generated file
#   however when building from a tarball, it will point to the version from the tarball instead
# - _py_out_var is the same but for the python module that's generated together with the wrapper
# - _output is the name of the wrapper file to generate (or to look up in the tarball)
# - _py_output is the name of the python module associated with this wrapper
# - input it the swig interface file (*.i) to generate this wrapper from
# Any additional parameters will be used as dependencies for this wrapper target
macro (gnc_add_swig_python_command _target _out_var _py_out_var _output _py_output _input)

    if (BUILDING_FROM_VCS)
        set(SW_CURR_BUILD_SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR})
        set(SW_BUILD_SOURCE_DIR ${CMAKE_BINARY_DIR})
    else()
        set(SW_CURR_BUILD_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
        set(SW_BUILD_SOURCE_DIR ${CMAKE_SOURCE_DIR})
    endif()

    set(outfile ${SW_CURR_BUILD_SOURCE_DIR}/${_output})
    set(${_out_var} ${outfile}) # This variable is set for convenience to use in the calling CMakeLists.txt

    set(py_outfile ${SW_CURR_BUILD_SOURCE_DIR}/${_py_output})
    set(${_py_out_var} ${py_outfile}) # This variable is set for convenience to use in the calling CMakeLists.txt

    if (BUILDING_FROM_VCS)
        set (DEFAULT_SWIG_PYTHON_FLAGS
            -python
            -Wall -Werror
            ${SWIG_ARGS}
        )
        set (DEFAULT_SWIG_PYTHON_C_INCLUDES
            ${GLIB2_INCLUDE_DIRS}
            ${CMAKE_SOURCE_DIR}/common
            ${CMAKE_SOURCE_DIR}/libgnucash/engine
            ${CMAKE_SOURCE_DIR}/libgnucash/app-utils
        )

        set (PYTHON_SWIG_FLAGS ${DEFAULT_SWIG_PYTHON_FLAGS})
        foreach (dir ${DEFAULT_SWIG_PYTHON_C_INCLUDES})
            list (APPEND PYTHON_SWIG_FLAGS "-I${dir}")
        endforeach (dir)
        add_custom_command(OUTPUT ${outfile} ${py_outfile}
            COMMAND ${SWIG_EXECUTABLE} ${PYTHON_SWIG_FLAGS} -o ${outfile} ${_input}
            DEPENDS ${_input} ${CMAKE_SOURCE_DIR}/common/base-typemaps.i ${ARGN}
        )
        add_custom_target(${_target} ALL DEPENDS ${outfile} ${py_outfile} ${CMAKE_SOURCE_DIR}/common/base-typemaps.i ${_input} ${ARGN})
    endif()

    # Add the output files _output and _py_output to the dist tarball
    dist_add_generated(${_output} ${_py_output})
endmacro()
