include($ENV{DEVKITPRO}/cmake/WiiU.cmake)

set(WUPS_ROOT ${DEVKITPRO}/wups)

find_program(WUPS_RPL2WPS_EXE NAMES rpl2wps HINTS "${DEVKITPRO}/wups/bin")

function(wps_add_executable target)

    set(elf_target "${target}")
    set(wps_target "${target}_wps")
    add_executable(${elf_target} ${ARGN})

    __dkp_target_derive_name(RPL_TEMP ${elf_target} ".rpl")
    __dkp_target_derive_name(WPS_OUTPUT ${elf_target} ".wps")

    if(DEFINED WUPS_RUNTIME_OUTPUT_DIRECTORY)
        get_filename_component(WPS_OUTPUT_NAME "${WPS_OUTPUT}" NAME)
        set(WPS_OUTPUT "${WUPS_RUNTIME_OUTPUT_DIRECTORY}/${WPS_OUTPUT_NAME}")
    endif()

    get_filename_component(WPS_OUTPUT_DIR "${WPS_OUTPUT}" DIRECTORY)

    add_custom_command(
        OUTPUT "${RPL_TEMP}"
        COMMAND ${WUT_ELF2RPL_EXE}
        "--rpl"
        "$<TARGET_FILE:${elf_target}>"
        "${RPL_TEMP}"
        DEPENDS "${elf_target}" "$<TARGET_FILE:${elf_target}>"
        COMMENT "Generating RPL"
        VERBATIM
    )

    add_custom_command(
        OUTPUT "${WPS_OUTPUT}"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${WPS_OUTPUT_DIR}"
        COMMAND ${WUPS_RPL2WPS_EXE}
        "${RPL_TEMP}"
        "${WPS_OUTPUT}"
        DEPENDS "${RPL_TEMP}"
        COMMENT "Generating WPS"
        VERBATIM
    )

    add_custom_target(${wps_target} ALL
        DEPENDS "${WPS_OUTPUT}"
    )
    add_dependencies(${wps_target} ${elf_target})

endfunction()