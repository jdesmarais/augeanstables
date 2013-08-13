      !> @file
      !> test file for the module 'dim2d_fluxes'
      !
      !> @author 
      !> Julien L. Desmarais
      !
      !> @brief
      !> test the primary variable operators by comparing the
      !> results with previous computations
      !
      !> @date
      ! 09_08_2013 - initial version - J.L. Desmarais
      !-----------------------------------------------------------------
      program test_dim2d_fluxes

        use dim2d_fluxes_module
        use field_class        , only : field
        use dim2d_parameters   , only : viscous_r,re,pr,we,cv_r
        use parameters_kind    , only : ikind, rkind
        use cg_operators_class , only : cg_operators

        implicit none
        
        
        !<operators tested
        type(field)               :: field_tested
        integer(ikind), parameter :: nx=4
        integer(ikind), parameter :: ny=4
        integer       , parameter :: ne=4
        type(cg_operators)        :: s
        
        !<CPU recorded times
        real    :: time1, time2

        !<test parameters
        logical, parameter        :: detailled=.true.
        integer(ikind)            :: i,j
        real(rkind)               :: prog_data
        real(rkind), dimension(8) :: test_data
        logical                   :: test_validated


        !<get the initial CPU time
        call CPU_TIME(time1)

        !<allocate the tables for the field
        call field_tested%allocate_tables(nx,ny,ne)


        !<initialize the tables for the field
        field_tested%dx=0.5
        field_tested%dy=0.6

        !<initialize the mass density
        field_tested%nodes(1,1,1)=0.5d0
        field_tested%nodes(2,1,1)=0.2d0
        field_tested%nodes(3,1,1)=1.2d0
        field_tested%nodes(4,1,1)=5.0d0

        field_tested%nodes(1,2,1)=2.0d0
        field_tested%nodes(2,2,1)=4.2d0
        field_tested%nodes(3,2,1)=11.0d0
        field_tested%nodes(4,2,1)=10.6d0

        field_tested%nodes(1,3,1)=-14.2d0
        field_tested%nodes(2,3,1)= 23.0d0
        field_tested%nodes(3,3,1)=  9.8d0
        field_tested%nodes(4,3,1)=  3.4d0

        field_tested%nodes(1,4,1)= 2.45d0
        field_tested%nodes(2,4,1)= 0.2d0
        field_tested%nodes(3,4,1)= 9.0d0
        field_tested%nodes(4,4,1)= 5.4d0

        !<initialize the momentum_x
        field_tested%nodes(1,1,2)= 9.5d0
        field_tested%nodes(2,1,2)= 9.8d0
        field_tested%nodes(3,1,2)= 8.8d0
        field_tested%nodes(4,1,2)= 5.0d0

        field_tested%nodes(1,2,2)= 8.0d0
        field_tested%nodes(2,2,2)= 5.8d0
        field_tested%nodes(3,2,2)=-1.0d0
        field_tested%nodes(4,2,2)=-0.6d0

        field_tested%nodes(1,3,2)= 24.2d0
        field_tested%nodes(2,3,2)=-13.0d0
        field_tested%nodes(3,3,2)= 0.2d0
        field_tested%nodes(4,3,2)= 6.6d0

        field_tested%nodes(1,4,2)= 7.55d0
        field_tested%nodes(2,4,2)= 9.8d0
        field_tested%nodes(3,4,2)= 1.0d0
        field_tested%nodes(4,4,2)= 4.6d0

        !<initialize the momentum_y
        field_tested%nodes(1,1,3)=-8.5d0
        field_tested%nodes(2,1,3)=-9.4d0
        field_tested%nodes(3,1,3)=-6.4d0
        field_tested%nodes(4,1,3)= 5.0d0

        field_tested%nodes(1,2,3)=-4.0d0
        field_tested%nodes(2,2,3)= 2.6d0
        field_tested%nodes(3,2,3)= 23.0d0
        field_tested%nodes(4,2,3)= 21.8d0

        field_tested%nodes(1,3,3)=-52.6d0
        field_tested%nodes(2,3,3)= 59.0d0
        field_tested%nodes(3,3,3)= 19.4d0
        field_tested%nodes(4,3,3)= 0.20d0

        field_tested%nodes(1,4,3)=-2.65d0
        field_tested%nodes(2,4,3)=-9.40d0
        field_tested%nodes(3,4,3)= 17.0d0
        field_tested%nodes(4,4,3)= 6.20d0

        !<initialize the total energy
        field_tested%nodes(1,1,4)=-1.5d0
        field_tested%nodes(2,1,4)=-1.8d0
        field_tested%nodes(3,1,4)=-0.8d0
        field_tested%nodes(4,1,4)= 3.0d0

        field_tested%nodes(1,2,4)= 0.0d0
        field_tested%nodes(2,2,4)= 2.2d0
        field_tested%nodes(3,2,4)= 9.0d0
        field_tested%nodes(4,2,4)= 8.6d0

        field_tested%nodes(1,3,4)=-16.2d0
        field_tested%nodes(2,3,4)= 21.0d0
        field_tested%nodes(3,3,4)= 7.8d0
        field_tested%nodes(4,3,4)= 1.4d0

        field_tested%nodes(1,4,4)= 0.45d0
        field_tested%nodes(2,4,4)=-1.8d0
        field_tested%nodes(3,4,4)= 7.0d0
        field_tested%nodes(4,4,4)= 3.4d0
        
        !<test the operators defined dim2d_fluxes
        i=2 !<index tested in the data along the x-axis
        j=2 !<index tested in the data along the y-axis

        !<test_data initialization
        test_data(1) =  2.183333d0  !<flux_x_mass
        test_data(2) = -251.30268d0 !<flux_x_momentum_x
        test_data(3) =  29.27583d0  !<flux_x_momentum_y
        test_data(4) =  262.74627d0 !<flux_x_total_energy
        test_data(5) =  37.5d0      !<flux_y_mass
        test_data(6) =  118.44843d0 !<flux_y_momentum_x
        test_data(7) = -678.96843d0 !<flux_y_momentum_y
        test_data(8) =-3721.23864d0 !<flux_y_total_energy

        !< print the dim2d parameters used for the test
        if(detailled) then
           call print_variables_for_test(
     $          field_tested%nodes,field_tested%dx, field_tested%dy)
        else
           print '(''WARNING: this test is designed for:'')'
           print '(''viscous_r: '', F16.6)', -1.5
           print '(''re:        '', F16.6)',  5
           print '(''pr:        '', F16.6)',  20
           print '(''we:        '', F16.6)',  10
           print '(''cv_r:      '', F16.6)',  2.5
           print '(''it allows to see errors easily'')'
        end if


        !<test of the operators
        if(detailled) then

           !DEC$ FORCEINLINE RECURSIVE
           prog_data  = flux_x_mass_density(field_tested,s,i,j)
           test_validated = is_test_validated(prog_data, test_data(1))
           print '(''test flux_x_mass_density: '',1L)', test_validated

           !DEC$ FORCEINLINE RECURSIVE
           prog_data  = flux_x_momentum_x(field_tested,s,i,j)
           test_validated = is_test_validated(prog_data, test_data(2))
           print '(''test flux_x_momentum_x: '',1L)', test_validated

           !DEC$ FORCEINLINE RECURSIVE
           prog_data  = flux_x_momentum_y(field_tested,s,i,j)
           test_validated = is_test_validated(prog_data, test_data(3))
           print '(''test flux_x_momentum_y: '',1L)', test_validated

           !DEC$ FORCEINLINE RECURSIVE
           prog_data  = flux_x_total_energy(field_tested,s,i,j)
           test_validated = is_test_validated(prog_data, test_data(4))
           print '(''test flux_x_total_energy: '',1L)', test_validated

           !DEC$ FORCEINLINE RECURSIVE
           prog_data  = flux_y_mass_density(field_tested,s,i,j)
           test_validated = is_test_validated(prog_data, test_data(5))
           print '(''test flux_y_mass_density: '',1L)', test_validated

           !DEC$ FORCEINLINE RECURSIVE
           prog_data  = flux_y_momentum_x(field_tested,s,i,j)
           test_validated = is_test_validated(prog_data, test_data(6))
           print '(''test flux_y_momentum_x: '',1L)', test_validated

           !DEC$ FORCEINLINE RECURSIVE
           prog_data  = flux_y_momentum_y(field_tested,s,i,j)
           test_validated = is_test_validated(prog_data,test_data(7))
           print '(''test flux_y_momentum_y: '',1L)', test_validated

           !DEC$ FORCEINLINE RECURSIVE
           prog_data  = flux_y_total_energy(field_tested,s,i,j)
           test_validated = is_test_validated(prog_data, test_data(8))
           print '(''test flux_y_total_energy: '',1L)', test_validated


        else

           test_validated=
     $          is_test_validated(
     $          flux_x_mass_density(
     $          field_tested,s,
     $          i,j),
     $          test_data(1))
           
           test_validated=test_validated.and.
     $          is_test_validated(
     $          flux_x_momentum_x(
     $          field_tested,s,
     $          i,j),
     $          test_data(2))

           test_validated=test_validated.and.
     $          is_test_validated(
     $          flux_x_momentum_y(
     $          field_tested,s,
     $          i,j),
     $          test_data(3))

           test_validated=test_validated.and.
     $          is_test_validated(
     $          flux_x_total_energy(
     $          field_tested,s,
     $          i,j),
     $          test_data(4))

           test_validated=
     $          is_test_validated(
     $          flux_y_mass_density(
     $          field_tested,s,
     $          i,j),
     $          test_data(5))
           
           test_validated=test_validated.and.
     $          is_test_validated(
     $          flux_y_momentum_x(
     $          field_tested,s,
     $          i,j),
     $          test_data(6))

           test_validated=test_validated.and.
     $          is_test_validated(
     $          flux_y_momentum_y(
     $          field_tested,s,
     $          i,j),
     $          test_data(7))

           test_validated=test_validated.and.
     $          is_test_validated(
     $          flux_y_total_energy(
     $          field_tested,s,
     $          i,j),
     $          test_data(8))

           print '(''test_validated: '', 1L)', test_validated

        end if


        !<get the last CPU time
        call CPU_TIME(time2)
        print *, 'time elapsed: ', time2-time1


        contains

        function is_test_validated(var,cst) result(test_validated)

          implicit none

          real(rkind), intent(in) :: var
          real(rkind), intent(in) :: cst
          logical                 :: test_validated

          if(detailled) then
             print *, int(var*1e5)
             print *, int(cst*1e5)
          end if
          
          test_validated=(
     $         int(var*10000.)-
     $         sign(int(abs(cst*10000.)),int(cst*10000.))).eq.0
          
        end function is_test_validated


        subroutine print_variables_for_test(nodes,dx,dy)

          implicit none

          real(rkind), dimension(:,:,:), intent(in) :: nodes
          real(rkind)                  , intent(in) :: dx
          real(rkind)                  , intent(in) :: dy


          print '(''mass:       '', 1X, 4F8.3)', nodes(1:4,4,1)
          print '(''            '', 1X, 4F8.3)', nodes(1:4,3,1)
          print '(''            '', 1X, 4F8.3)', nodes(1:4,2,1)
          print '(''            '', 1X, 4F8.3)', nodes(1:4,1,1)
          print '('''')'
          
          print '(''momentum_x: '', 1X, 4F8.3)', nodes(1:4,4,2)
          print '(''            '', 1X, 4F8.3)', nodes(1:4,3,2)
          print '(''            '', 1X, 4F8.3)', nodes(1:4,2,2)
          print '(''            '', 1X, 4F8.3)', nodes(1:4,1,2)
          print '('''')'
          
          print '(''momentum_y: '', 1X, 4F8.3)', nodes(1:4,4,3)
          print '(''            '', 1X, 4F8.3)', nodes(1:4,3,3)
          print '(''            '', 1X, 4F8.3)', nodes(1:4,2,3)
          print '(''            '', 1X, 4F8.3)', nodes(1:4,1,3)
          print '('''')'

          print '(''energy:     '', 1X, 4F8.3)', nodes(1:4,4,4)
          print '(''            '', 1X, 4F8.3)', nodes(1:4,3,4)
          print '(''            '', 1X, 4F8.3)', nodes(1:4,2,4)
          print '(''            '', 1X, 4F8.3)', nodes(1:4,1,4)
          print '('''')'

          print '(''dx: '', 1X, F8.3)', dx
          print '(''dy: '', 1X, F8.3)', dy
          print '('''')'

          print '(''Re:        '', 1X, F12.3)', re
          print '(''We:        '', 1X, F12.3)', we
          print '(''Pr:        '', 1X, F12.3)', pr
          print '(''viscous_r: '', 1X, F12.3)', viscous_r
          print '(''cv_r:      '', 1X, F12.3)', cv_r
          print '('''')'
        
        end subroutine print_variables_for_test


      end program test_dim2d_fluxes
