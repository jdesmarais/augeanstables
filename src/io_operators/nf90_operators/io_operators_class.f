      !> @file
      !> class encapsulating subroutines to
      !> write netcdf files
      !
      !> @author 
      !> Julien L. Desmarais
      !
      !> @brief
      !> class encapsulating subroutines to
      !> write netcdf files
      !
      !> @date
      !> 14_08_2013 - initial version - J.L. Desmarais
      !-----------------------------------------------------------------
      module io_operators_class

        use io_operators_abstract_class, only :
     $       io_operators_abstract

        use io_operators_module, only :
     $       get_filename,
     $       get_timestep

        use netcdf

        use nf90_operators_module, only :
     $       nf90_open_file,
     $       nf90_write_header,
     $       nf90_def_var_model,
     $       nf90_put_var_model,
     $       nf90_close_file

        use nf90_operators_read_module, only :
     $       nf90_open_file_for_reading,
     $       nf90_get_varid,
     $       nf90_get_var_model

        use parameters_input, only :
     $       nx,ny,ne

        use parameters_kind, only :
     $       rkind

        use pmodel_eq_class, only :
     $       pmodel_eq

        implicit none

        private
        public :: io_operators


        !> @class io_operators
        !> abstract class encapsulating subroutines to
        !> handle errors when manipulating netcdf files
        !>
        !> @param nb_timesteps_written
        !> attribute saving the total number of timesteps
        !> already written previously to name the output file
        !> correctly
        !>
        !> @param initialize
        !> initialize the counter to identify the netcdf file
        !> written
        !>
        !> @param write_data
        !> write the data encapsulated in field-type objects
        !> on netcdf output files
        !---------------------------------------------------------------
        type, extends(io_operators_abstract) :: io_operators

          contains

          procedure, pass :: write_data
          procedure, pass :: read_data

        end type io_operators


        contains        


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> subroutine to write data encapsulated in field_used
        !> on netcdf output files
        !
        !> @date
        !> 14_08_2013 - initial version - J.L. Desmarais
        !
        !>@param field_used
        !> object encapsulating the main variables
        !
        !>@param p_model
        !> physical model
        !
        !>@param time
        !> reduced simulation time
        !--------------------------------------------------------------
        subroutine write_data(
     $       this, nodes, x_map, y_map, p_model, time,
     $       rank)

          implicit none

          class(io_operators)             , intent(inout) :: this
          real(rkind), dimension(nx,ny,ne), intent(in)    :: nodes
          real(rkind), dimension(nx)      , intent(in)    :: x_map
          real(rkind), dimension(ny)      , intent(in)    :: y_map
          type(pmodel_eq)                 , intent(in)    :: p_model
          real(rkind)                     , intent(in)    :: time
          integer, optional               , intent(in)    :: rank

          integer                :: ncid
          integer, dimension(3)  :: coord_id
          integer, dimension(ne) :: data_id
          character(len=16)      :: filename


          !<get the name for the netcdf file
          if(present(rank)) then
             call get_filename(filename, this%nb_timesteps_written, rank=rank)
          else
             call get_filename(filename, this%nb_timesteps_written)
          end if


          !<create the netcdf file
          call nf90_open_file(filename,ncid)


          !<write the header of the file
          !DEC$ FORCEINLINE RECURSIVE
          call nf90_write_header(ncid,p_model)


          !<define the variables saved in the file
          call nf90_def_var_model(ncid,p_model,coord_id,data_id)


          !<put the variables in the file
          call nf90_put_var_model(ncid, coord_id, data_id,
     $         time, nodes, x_map, y_map)


          !<close the netcdf file
          call nf90_close_file(ncid)
          

          !<increment the internal counter
          call this%increment_counter()          

        end subroutine write_data


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> subroutine to read data encapsulated in field_used
        !> on netcdf output files
        !
        !> @date
        !> 05_12_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> interior grid points
        !
        !>@param x_map
        !> interior x-coordinate map
        !
        !>@param y_map
        !> interior y-coordinate map
        !
        !>@param p_model
        !> physical model
        !
        !>@param time
        !> reduced simulation time
        !--------------------------------------------------------------
        subroutine read_data(
     $     this,
     $     filename,
     $     nodes,
     $     x_map,
     $     y_map,
     $     p_model,
     $     time)

          implicit none

          class(io_operators)             , intent(inout) :: this
          character*(*)                   , intent(in)    :: filename
          real(rkind), dimension(nx,ny,ne), intent(out)   :: nodes
          real(rkind), dimension(nx)      , intent(out)   :: x_map
          real(rkind), dimension(ny)      , intent(out)   :: y_map
          type(pmodel_eq)                 , intent(in)    :: p_model
          real(rkind)                     , intent(out)   :: time

          integer                :: ncid
          integer, dimension(3)  :: coordinates_id
          integer, dimension(ne) :: data_id


          !0) extract the timestep written by the input file
          this%nb_timesteps_written = get_timestep(trim(filename))

          
          !1) open the file for reading
          call nf90_open_file_for_reading(filename,ncid)


          !2) get the varid for the variables saved inside
          !   the netcdf file
          call nf90_get_varid(ncid,p_model,coordinates_id,data_id)


          !3) get the data saved in the netcdf file
          call nf90_get_var_model(
     $         ncid,
     $         coordinates_id,
     $         data_id,
     $         time,
     $         nodes,
     $         x_map,
     $         y_map)


          !4) close the netcdf file
          call nf90_close_file(ncid)

        end subroutine read_data

      end module io_operators_class
