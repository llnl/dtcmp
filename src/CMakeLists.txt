add_library(dtcmp)
add_library(dtcmp::dtcmp ALIAS dtcmp)

target_sources(dtcmp
PRIVATE
    dtcmp.c
    dtcmp_util.c
    dtcmp_ops.c
    dtcmp_uniqify.c
    dtcmp_search_binary.c
    dtcmp_partitionz.c
    dtcmp_partitionz_list.c
    dtcmp_partition_local.c
    dtcmp_merge_2way.c
    dtcmp_merge_kway_heap.c
    dtcmp_select_local_ends.c
    dtcmp_select_local_randpartition.c
    dtcmp_selectv_rand.c
    dtcmp_selectv_medianofmedians.c
    dtcmp_is_sorted.c
    dtcmp_sort_local_insertionsort.c
    dtcmp_sort_local_randquicksort.c
    dtcmp_sort_local_mergesort.c
    dtcmp_sort_local_qsort.c
    dtcmp_sort_allgather.c
    dtcmp_sort_bitonic.c
    dtcmp_sort_samplesort.c
    dtcmp_sortv_allgather.c
    dtcmp_sortv_sortgather_scatter.c
    dtcmp_sortv_cheng.c
    dtcmp_sortz_samplesort.c
    dtcmp_rankv_sort.c
    dtcmp_seg_exscan.c
PUBLIC
FILE_SET HEADERS
FILES
    dtcmp.h
PRIVATE
FILE_SET private_header
TYPE HEADERS
FILES
    dtcmp_internal.h
    dtcmp_ops.h
)
# dtcmp.h includes mpi.h, lwgrp is only used internally
target_link_libraries(dtcmp
PUBLIC
    MPI::MPI_C
PRIVATE
    LWGRP::LWGRP
)

if(DTCMP_ENABLE_TESTS)
    add_executable(dtcmp_exe main.c)
    target_link_libraries(dtcmp_exe PRIVATE dtcmp LWGRP::LWGRP)

    add_executable(test_segscan test_segscan.c)
    target_link_libraries(test_segscan PRIVATE dtcmp)

    add_executable(dtcmp_tests tests.c)
    target_link_libraries(dtcmp_tests PRIVATE dtcmp LWGRP::LWGRP)

    set(DTCMP_TEST_NUM_PROCS "1;2;3;4" CACHE STRING "List of MPI rank counts used to run DTCMP tests")

    foreach(num_procs IN LISTS DTCMP_TEST_NUM_PROCS)
        if(num_procs GREATER MPIEXEC_MAX_NUMPROCS)
            continue()
        endif()

        add_test(NAME test_segscan_np${num_procs}
            COMMAND ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} ${num_procs}
                    ${MPIEXEC_PREFLAGS} $<TARGET_FILE:test_segscan> ${MPIEXEC_POSTFLAGS}
        )
        # tests.c always exits 0
        add_test(NAME dtcmp_tests_np${num_procs}
            COMMAND ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} ${num_procs}
                    ${MPIEXEC_PREFLAGS} $<TARGET_FILE:dtcmp_tests> ${MPIEXEC_POSTFLAGS}
        )
        set_tests_properties(test_segscan_np${num_procs} dtcmp_tests_np${num_procs} PROPERTIES
            PROCESSORS ${num_procs}
            LABELS mpi
        )
        set_tests_properties(dtcmp_tests_np${num_procs} PROPERTIES
            FAIL_REGULAR_EXPRESSION "ERROR DETECTED;Invalid size"
        )
    endforeach()
endif()
