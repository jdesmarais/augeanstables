      !> @file
      !> test file for the module 'dim2d_prim'
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
      program test_dim2d_prim

        use check_data_module, only :
     $       is_test_validated,
     $       is_vector_validated,
     $       is_matrix_validated

        use dim2d_prim_module

        use dim2d_parameters, only :
     $       viscous_r,
     $       re,
     $       pr,
     $       we,
     $       cv_r

        use parameters_input, only :
     $       nx,ny,ne

        use parameters_kind, only :
     $       ikind,
     $       rkind

        use sd_operators_fd_module, only :
     $       gradient_x_interior,
     $       gradient_y_interior

        implicit none
        
        
        !<operators tested
        real(rkind), dimension(nx,ny,ne) :: nodes
        real(rkind) :: dx
        real(rkind) :: dy
        
        !<CPU recorded times
        real    :: time1, time2

        !<test parameters
        logical, parameter            :: detailled=.false.
        integer(ikind)                :: i,j
        real(rkind)                   :: computed_data
        real(rkind), dimension(22)    :: test_data
        real(rkind), dimension(ne,ne) :: test_jacPrimCons
        real(rkind), dimension(ne,ne) :: test_jacConsPrim
        real(rkind), dimension(ne)    :: test_x_timedev_lodi
        real(rkind), dimension(ne)    :: test_y_timedev_lodi
        real(rkind), dimension(ne)    :: test_timedev_lodi
        logical                       :: global, local


        !test the inputs
        call test_inputs()

        !< initialize data
        call initialize_data(
     $       nodes,dx,dy,i,j,
     $       test_data,
     $       test_jacPrimCons,
     $       test_jacConsPrim,
     $       test_x_timedev_lodi,
     $       test_y_timedev_lodi,
     $       test_timedev_lodi)
        
        !< dim2d_parameters
        if(detailled) then
           print '(''viscous_r: '', F16.6)', viscous_r
           print '(''re:        '', F16.6)', re
           print '(''pr:        '', F16.6)', pr
           print '(''we:        '', F16.6)', we
           print '(''cv_r:      '', F16.6)', cv_r
        end if


        global = .true.

        local = is_test_validated(
     $          mass_density(
     $          nodes,
     $          i,j),
     $          test_data(1),
     $          detailled)
        call print_screen(global,local,detailled,'mass density')


        local = is_test_validated(
     $          momentum_x(
     $          nodes,
     $          i,j),
     $          test_data(2),
     $          detailled)
        call print_screen(global,local,detailled,'momentum_x')

        
        local = is_test_validated(
     $          momentum_y(
     $          nodes,
     $          i,j),
     $          test_data(3),
     $          detailled)
        call print_screen(global,local,detailled,'momentum_y')

        
        local = is_test_validated(
     $          total_energy(
     $          nodes,
     $          i,j),
     $          test_data(4),
     $          detailled)
        call print_screen(global,local,detailled,'total energy')


        local = is_test_validated(
     $          velocity_x(
     $          nodes,
     $          i,j),
     $          test_data(5),
     $          detailled)
        call print_screen(global,local,detailled,'velocity_x')


        local = is_test_validated(
     $          velocity_y(
     $          nodes,
     $          i,j),
     $          test_data(6),
     $          detailled)
        call print_screen(global,local,detailled,'velocity_y')

        local = is_test_validated(
     $          classical_pressure(
     $          nodes,
     $          i,j),
     $          test_data(7),
     $          detailled)
        call print_screen(global,local,detailled,'classical_pressure')

        local = is_test_validated(
     $          temperature_eff(
     $          nodes,
     $          i,j,dx,dy,
     $          gradient_x_interior,
     $          gradient_y_interior),
     $          test_data(8),
     $          detailled)
        call print_screen(global,local,detailled,'temperature_eff')

        local = is_test_validated(
     $          qx_transport_x(
     $          nodes,
     $          i,j),
     $          test_data(9),
     $          detailled)
        call print_screen(global,local,detailled,'temperature_eff')

        local = is_test_validated(
     $          qy_transport_x(
     $          nodes,
     $          i,j),
     $          test_data(10),
     $          detailled)
        call print_screen(global,local,detailled,'qy_transport_x')

        computed_data = qx_transport_y(nodes,i,j)
        local = is_test_validated(
     $          computed_data,
     $          test_data(11),
     $          detailled)
        call print_screen(global,local,detailled,'qx_transport_y')

        local = is_test_validated(
     $          qy_transport_y(
     $          nodes,
     $          i,j),
     $          test_data(12),
     $          detailled)
        call print_screen(global,local,detailled,'qy_transport_y')

        local = is_test_validated(
     $          energy_transport_x(
     $          nodes,
     $          i,j),
     $          test_data(13),
     $          detailled)
        call print_screen(global,local,detailled,'qy_transport_y')

        local = is_test_validated(
     $          energy_transport_y(
     $          nodes,
     $          i,j),
     $          test_data(14),
     $          detailled)
        call print_screen(global,local,detailled,'energy_transport_y')

        local = is_test_validated(
     $          capillarity_pressure(
     $          nodes,
     $          i,j),
     $          test_data(15),
     $          detailled)
        call print_screen(global,local,detailled,'capillarity pressure')

        local = is_test_validated(
     $          capillarity_pressure_xwork(
     $          nodes,
     $          i,j),
     $          test_data(16),
     $          detailled)
        call print_screen(global,local,detailled,'cap pressure xwork')

        local = is_test_validated(
     $          capillarity_pressure_ywork(
     $          nodes,
     $          i,j),
     $          test_data(17),
     $          detailled)
        call print_screen(global,local,detailled,'cap pressure ywork')

        local = is_test_validated(
     $          classical_pressure_xwork(
     $          nodes,
     $          i,j),
     $          test_data(18),
     $          detailled)
        call print_screen(global,local,detailled,'pressure xwork')

        local = is_test_validated(
     $       classical_pressure_ywork(
     $       nodes,
     $       i,j),
     $       test_data(19),
     $       detailled)

        call print_screen(global,local,detailled,'pressure ywork')

        local = is_test_validated(
     $       speed_of_sound(nodes(i,j,:)),
     $       test_data(20),
     $       detailled)

        call print_screen(global,local,detailled,'speed_of_sound')

        local = is_test_validated(
     $       classical_temperature_eff(
     $       nodes,
     $       i,j),
     $       test_data(21),
     $       detailled)

        call print_screen(global,local,detailled,
     $       'classical_temperature_eff')

        local = is_test_validated(
     $       capillarity_temperature_eff(
     $       nodes,
     $       i,j,dx,dy,
     $       gradient_x_interior,
     $       gradient_y_interior
     $       ),
     $       test_data(22),
     $       detailled)

        call print_screen(global,local,detailled,
     $       'capillarity_temperature_eff')

        local = is_matrix_validated(
     $       compute_jacobian_prim_to_cons(nodes(i,j,:)),
     $       test_jacPrimCons,
     $       detailled)

        call print_screen(global,local,detailled,'jacPrimCons')

        local = is_matrix_validated(
     $       compute_jacobian_cons_to_prim(nodes(i,j,:)),
     $       test_jacConsPrim,
     $       detailled)

        call print_screen(global,local,detailled,'jacConsPrim')

        local = is_vector_validated(
     $       compute_x_timedev_from_LODI_vector_dim2d(
     $          nodes(i,j,:),
     $          [-3.0d0, 2.1d0, 4.5d0, 9.6d0]),
     $       test_x_timedev_LODI,
     $       detailled)

        call print_screen(global,local,detailled,'x_timedev_from_LODI')

        local = is_vector_validated(
     $       compute_y_timedev_from_LODI_vector_dim2d(
     $          nodes(i,j,:),
     $          [7.8d0, 6.23d0, -8.9d0, 1.2d0]),
     $       test_y_timedev_LODI,
     $       detailled)

        call print_screen(global,local,detailled,'y_timedev_from_LODI')

        local = is_vector_validated(
     $       compute_timedev_from_LODI_vectors_dim2d(
     $          nodes(i,j,:),
     $          [-3.0d0, 2.1d0, 4.5d0, 9.6d0],
     $          [7.8d0, 6.23d0, -8.9d0, 1.2d0]),
     $       test_timedev_LODI,
     $       detailled)

        call print_screen(global,local,detailled,'timedev_from_LODI')


        print '(''test_validated: '', 1L)', global

        !<get the last CPU time
        call CPU_TIME(time2)
        print *, 'time elapsed: ', time2-time1


        contains        


        subroutine print_screen(global,local,verbose,test_name)
          
          implicit none

          logical      , intent(inout) :: global
          logical      , intent(in)    :: local
          logical      , intent(in)    :: verbose
          character*(*), intent(in)    :: test_name

          if(verbose) then
             print *, test_name
             print '(''validated :'', 1L)', local
          end if

          global = global.and.local

        end subroutine print_screen


        subroutine initialize_data(
     $     nodes,dx,dy,i,j,
     $     test_data,
     $     test_jacPrimCons,
     $     test_jacConsPrim,
     $     test_x_timedev_lodi,
     $     test_y_timedev_lodi,
     $     test_timedev_lodi)

          implicit none

          real(rkind), dimension(nx,ny,ne), intent(inout) :: nodes
          real(rkind)                     , intent(out) :: dx
          real(rkind)                     , intent(out) :: dy
          integer                         , intent(out) :: i,j
          real(rkind), dimension(22)      , intent(out) :: test_data
          real(rkind), dimension(ne,ne)   , intent(out) :: test_jacPrimCons
          real(rkind), dimension(ne,ne)   , intent(out) :: test_jacConsPrim
          real(rkind), dimension(ne)      , intent(out) :: test_x_timedev_lodi
          real(rkind), dimension(ne)      , intent(out) :: test_y_timedev_lodi
          real(rkind), dimension(ne)      , intent(out) :: test_timedev_lodi

          !<initialize the tables for the field
          dx=0.5
          dy=0.6
          
          !<initialize the mass density
          nodes(1,1,1)=0.5d0
          nodes(2,1,1)=0.2d0
          nodes(3,1,1)=1.2d0
          nodes(4,1,1)=5.0d0
          
          nodes(1,2,1)=2.0d0
          nodes(2,2,1)=4.2d0
          nodes(3,2,1)=11.0d0
          nodes(4,2,1)=10.6d0
          
          nodes(1,3,1)=-14.2d0
          nodes(2,3,1)= 23.0d0
          nodes(3,3,1)=  9.8d0
          nodes(4,3,1)=  3.4d0
          
          nodes(1,4,1)= 2.45d0
          nodes(2,4,1)= 0.2d0
          nodes(3,4,1)= 9.0d0
          nodes(4,4,1)= 5.4d0
          
          !<initialize the momentum_x
          nodes(1,1,2)= 9.5d0
          nodes(2,1,2)= 9.8d0
          nodes(3,1,2)= 8.8d0
          nodes(4,1,2)= 5.0d0
          
          nodes(1,2,2)= 8.0d0
          nodes(2,2,2)= 5.8d0
          nodes(3,2,2)=-1.0d0
          nodes(4,2,2)=-0.6d0
          
          nodes(1,3,2)=-24.2d0
          nodes(2,3,2)=-13.0d0
          nodes(3,3,2)= 0.2d0
          nodes(4,3,2)= 6.6d0
          
          nodes(1,4,2)= 7.55d0
          nodes(2,4,2)= 9.8d0
          nodes(3,4,2)= 1.0d0
          nodes(4,4,2)= 4.6d0
          
          !<initialize the momentum_y
          nodes(1,1,3)=-8.5d0
          nodes(2,1,3)=-9.4d0
          nodes(3,1,3)=-6.4d0
          nodes(4,1,3)= 5.0d0
          
          nodes(1,2,3)=-4.0d0
          nodes(2,2,3)= 2.6d0
          nodes(3,2,3)= 23.0d0
          nodes(4,2,3)= 21.8d0
          
          nodes(1,3,3)=-52.6d0
          nodes(2,3,3)= 59.0d0
          nodes(3,3,3)= 19.4d0
          nodes(4,3,3)= 0.20d0
          
          nodes(1,4,3)=-2.65d0
          nodes(2,4,3)=-9.40d0
          nodes(3,4,3)= 17.0d0
          nodes(4,4,3)= 6.20d0
          
          !<initialize the total energy
          nodes(1,1,4)=-1.5d0
          nodes(2,1,4)=-1.8d0
          nodes(3,1,4)=-0.8d0
          nodes(4,1,4)= 3.0d0
          
          nodes(1,2,4)= 0.0d0
          nodes(2,2,4)= 2.2d0
          nodes(3,2,4)= 9.0d0
          nodes(4,2,4)= 8.6d0
          
          nodes(1,3,4)=-16.2d0
          nodes(2,3,4)= 21.0d0
          nodes(3,3,4)= 7.8d0
          nodes(4,3,4)= 1.4d0
          
          nodes(1,4,4)= 0.45d0
          nodes(2,4,4)=-1.8d0
          nodes(3,4,4)= 7.0d0
          nodes(4,4,4)= 3.4d0
          
          !<test the operators defined dim2d_prim
          i=2 !<index tested in the data along the x-axis
          j=2 !<index tested in the data along the y-axis
          
          !<test_data initialization
          test_data(1) =  4.2d0        !<mass
          test_data(2) =  5.8d0        !<momentum_x
          test_data(3) =  2.6d0        !<momentum_y
          test_data(4) =  2.2d0        !<total_energy
          test_data(5) =  1.380952d0   !<velocity_x
          test_data(6) =  0.619048d0   !<velocity_y
          test_data(7) = -103.23047d0  !<classical pressure
          test_data(8) =  6.71678d0    !<temperature_eff
          test_data(9) =  8.009524d0   !<qx_transport_x
          test_data(10)=  3.590476d0   !<qy_transport_y
          test_data(11)=  3.590476d0   !<qx_transport_y
          test_data(12)=  1.609524d0   !<qy_transport_y
          test_data(13)=  3.038095d0   !<energy transport_x
          test_data(14)=  1.361905d0   !<energy transport_y
          test_data(15)= -0.833333d0   !<capillarity_pressure
          test_data(16)= -1.15079d0    !<capillarity_pressure_xwork
          test_data(17)= -0.51587d0    !<capillarity_pressure_ywork
          test_data(18)= -142.55637d0  !<classic pressure work along x-axis
          test_data(19)= -63.90458d0   !<classic pressure work along y-axis
          test_data(20)= 4.089669525d0 !<speed of sound
          test_data(21)= 11.97868481d0 !<classical temperature effective
          test_data(22)= 52.61904762d0 !<capillarity temperature effective
          
          
          !< jacobian matrix primitive -> conservative
          test_jacConsPrim = reshape((/
     $         1.0d0        , 0.0d0, 0.0d0,  0.0d0,
     $         1.380952381d0, 4.2d0, 0.0d0,  0.0d0,
     $         0.619047619d0, 0.0d0, 4.2d0,  0.0d0,
     $        -7.329478458d0, 5.8d0, 2.6d0, -1.0d0
     $         /), (/4,4/))

          !< jacobian matrix conservative -> primitive
          test_jacPrimCons = reshape((/
     $         1.0d0        , 0.0d0     , 0.0d0     ,  0.0d0,
     $        -0.328798186d0, 0.238095d0, 0.0d0     ,  0.0d0,
     $        -0.147392290d0, 0.0d0     , 0.238095d0,  0.0d0,
     $        -9.619727891d0, 1.380952d0, 0.619048d0, -1.0d0
     $         /), (/4,4/))

          !< test timedev from lodi
          test_x_timedev_lodi = [-0.547072222d0, -1.379002951d0,  12.26133624d0,  17.99869951d0]
          test_y_timedev_lodi = [-0.142298567d0, -32.95650754d0,  -1.32290819d0, -48.81143723d0]
          test_timedev_lodi   = [-0.689370789d0,  -34.3355105d0,  10.93842805d0, -30.81273772d0]

        end subroutine initialize_data


        subroutine test_inputs()
        
          implicit none

          logical :: test_parameters

          !<if nx<4, ny<4 then the test cannot be done
          if((nx.lt.4).or.(ny.lt.4).or.(ne.ne.4)) then
             stop 'nx and ny must be greater than 4 for the test'
          end if

          test_parameters=.true.
          test_parameters=test_parameters.and.(viscous_r.eq.-1.5d0)
          test_parameters=test_parameters.and.(re.eq.5d0)
          test_parameters=test_parameters.and.(pr.eq.20.0d0)
          test_parameters=test_parameters.and.(we.eq.10.0d0)
          test_parameters=test_parameters.and.(cv_r.eq.2.5d0)
          if(.not.test_parameters) then

             !< print the dim2d parameters used for the test
             print '(''WARNING: this test is designed for:'')'
             print '(''viscous_r: '', F16.6)', -1.5
             print '(''re:        '', F16.6)', 5.
             print '(''pr:        '', F16.6)', 20.
             print '(''we:        '', F16.6)', 10.
             print '(''cv_r:      '', F16.6)', 2.5
             print '(''it allows to see errors easily'')'
             print '('''')'

             stop 'dim2d_parameters not adapted for test'
          end if

        end subroutine test_inputs

      end program test_dim2d_prim
