      !> @file
      !> module containing the constants used in the
      !> program: they will be propagated at compilation
      !> time
      !
      !> @author 
      !> Julien L. Desmarais
      !
      !> @brief
      !> definition of the constant used in the whole program
      !
      !> @date
      !> 08_08_2013 - initial version                   - J.L. Desmarais
      !-----------------------------------------------------------------
      module parameters_constant

        !<program version
        character*(*) , parameter :: prog_version = 'lerneanhydra V1.0'

        !<main variable types
        integer, parameter :: scalar=0
        integer, parameter :: vector_x=1
        integer, parameter :: vector_y=2

        !<boundary conditions choice
        integer, parameter :: periodic_xy_choice=0

        !<i/o management choice
        integer, parameter :: netcdf_choice=0

      end module parameters_constant
