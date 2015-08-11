      !> @file
      !> class encapsulating subroutines to compute the initial
      !> conditions and the conditions enforced at the edge of
      !> the computational domain for a bubble next to a wall
      !> approximated by a spherical cap
      !
      !> @author 
      !> Julien L. Desmarais
      !
      !> @brief
      !> class encapsulating subroutines to compute the initial
      !> conditions and the conditions enforced at the edge of
      !> the computational domain for a bubble next to a wall
      !> approximated by a spherical cap
      !
      !> @date
      !> 18_06_2015 - initial version - J.L. Desmarais
      !-----------------------------------------------------------------
      module ic_class

        use dim2d_dropbubble_module, only :
     $       mass_density_ellipsoid,
     $       total_energy_ellipsoid

        use dim2d_parameters, only :
     $       cv_r, we

        use dim2d_prim_module, only :
     $       speed_of_sound

        use dim2d_state_eq_module, only :
     $       get_mass_density_liquid,
     $       get_mass_density_vapor,
     $       get_interface_length

        use ic_abstract_class, only :
     $       ic_abstract

        use parameters_constant, only :
     $       liquid,
     $       vapor,
     $       x_direction,
     $       y_direction,
     $       parabolic_profile,
     $       linear_profile

        use parameters_input, only :
     $       nx,ny,ne,
     $       T0,
     $       flow_direction,
     $       flow_x_side,
     $       flow_y_side,
     $       flow_velocity,
     $       flow_profile,
     $       phase_at_center,
     $       wall_micro_contact_angle,
     $       wall_heater_micro_contact_angle,
     $       x_min,
     $       x_max,
     $       y_min,
     $       y_max

        use parameters_kind, only :
     $       ikind,
     $       rkind

        implicit none

        private
        public :: ic

        !flow velocities for the different flow configurations
        real(rkind), parameter :: u0_x_flow  = flow_velocity*flow_x_side
        real(rkind), parameter :: u0_y_flow  = 0.0d0
        real(rkind), parameter :: u0_xy_flow = 0.5d0*SQRT(2.0d0)*flow_velocity*flow_x_side

        real(rkind), parameter :: v0_x_flow  = 0.0d0
        real(rkind), parameter :: v0_y_flow  = flow_velocity*flow_y_side
        real(rkind), parameter :: v0_xy_flow = 0.5d0*SQRT(2.0d0)*flow_velocity*flow_y_side

        !> @class ic
        !> class encapsulating operators to set the initial
        !> conditions and the conditions enforced at the edge of the
        !> computational domain for phase separation
        !
        !> @param apply_initial_conditions
        !> set the initial conditions
        !
        !> @param get_mach_ux_infty
        !> get the mach number along the x-direction in the far field
        !
        !> @param get_mach_uy_infty
        !> get the mach number along the y-direction in the far field
        !
        !> @param get_u_in
        !> get the x-component of the velocity at the edge of the
        !> computational domain
        !
        !> @param get_v_in
        !> get the y-component of the velocity at the edge of the
        !> computational domain
        !
        !> @param get_T_in
        !> get the temperature at the edge of the computational
        !> domain
        !
        !> @param get_P_out
        !> get the pressure at the edge of the computational domain
        !---------------------------------------------------------------
        type, extends(ic_abstract) :: ic

          character(18) :: name = 'bubble_spherecap  '

          contains

          procedure, nopass :: apply_ic
          procedure, nopass :: get_mach_ux_infty
          procedure, nopass :: get_mach_uy_infty
          procedure, nopass :: get_u_in
          procedure, nopass :: get_v_in
          procedure, nopass :: get_T_in
          procedure, nopass :: get_P_out
          procedure,   pass :: get_far_field

        end type ic

        contains


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> subroutine computing the initial conditions
        !> for a steady state
        !
        !> @date
        !> 12_12_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@param x_map
        !> map of x-coordinates
        !
        !>@param y_map
        !> map of y-coordinates
        !---------------------------------------------------------------
        subroutine apply_ic(nodes,x_map,y_map)

          implicit none

          real(rkind), dimension(:,:,:), intent(inout) :: nodes
          real(rkind), dimension(:)    , intent(in)    :: x_map
          real(rkind), dimension(:)    , intent(in)    :: y_map          

          
          !local variables for the droplet/bubble
          real(rkind)    :: xc,yc,a,b
          real(rkind)    :: dliq,dvap,li
          real(rkind)    :: dout

          !local variables for the vortices
          real(rkind)    :: velocity_x, velocity_y

          !local variables for the initialization
          integer(ikind) :: i,j
          real(rkind)    :: x,y
          
          real(rkind)    :: pi
          real(rkind)    :: Vtotal
          real(rkind)    :: theta


          !get the mass densities corresponding to the
          !liquid and vapor phases for the initial
          !temperature field
          dliq = get_mass_density_liquid(T0)
          dvap = get_mass_density_vapor(T0)

          !get the interface length corresponding
          !to the initial temperature field
          li = get_interface_length(T0)

          ! total volume of the spherical cap
          pi     = ACOS(-1.0d0)
          Vtotal = pi*(3.0*li)**2

          !set the major and minor axes of the bubble ellipse
          theta = pi*wall_heater_micro_contact_angle/180.0d0
          a=SQRT(Vtotal/((pi-theta)+COS(theta)*SIN(theta)))
          b=a

          !set the center of the droplet
          xc=0.0d0
          yc=a*COS(theta)

          if(phase_at_center.eq.liquid) then
             dout = dvap
          else
             dout = dliq
          end if

          !initialize the mass, momentum and total energy fields
          do j=1, size(y_map,1)
             do i=1, size(x_map,1)

                ! coordinates
                x = x_map(i)
                y = y_map(j)

                ! velocities
                velocity_x = get_velocity_x(x,y)
                velocity_y = get_velocity_y(x,y)

                ! spherical cap approximation
                nodes(i,j,1) =
     $               mass_density_ellipsoid(
     $               x,y,xc,yc,a,b,li,dliq,dvap,phase_at_center)

                nodes(i,j,2) =
     $               nodes(i,j,1)*velocity_x

                nodes(i,j,3) =
     $               nodes(i,j,1)*velocity_y
                
                nodes(i,j,4) = total_energy_ellipsoid(
     $               x,y,xc,yc,a,b,li,dliq,dvap,
     $               nodes(i,j,1),T0)

             end do
          end do

        end subroutine apply_ic


        !get the variable enforced at the edge of the
        !computational domain
        function get_mach_ux_infty(side) result(var)

          implicit none

          logical, intent(in) :: side
          real(rkind)         :: var

          logical     :: side_s
          real(rkind) :: velocity_x
          real(rkind) :: c

          side_s = side

          velocity_x = get_velocity_x(x_max,y_max)
          c          = get_speed_of_sound()

          var = velocity_x/c

        end function get_mach_ux_infty


        !get the variable enforced at the edge of the
        !computational domain
        function get_mach_uy_infty(side) result(var)

          implicit none

          logical, intent(in) :: side
          real(rkind)         :: var

          logical     :: side_s
          real(rkind) :: velocity_y
          real(rkind) :: c

          side_s = side

          velocity_y = get_velocity_y(x_max,y_max)
          c          = get_speed_of_sound()

          var = velocity_y/c

        end function get_mach_uy_infty


        !get the x-component of the velocity enforced
        !at the edge of the computational domain
        function get_u_in(t,x,y) result(var)

          implicit none

          real(rkind), intent(in) :: t
          real(rkind), intent(in) :: x
          real(rkind), intent(in) :: y
          real(rkind)             :: var
          
          real(rkind) :: t_s,x_s,y_s

          t_s    = t
          x_s    = x
          y_s    = y

          var = get_velocity_x(x,y)

        end function get_u_in


        !get the y-component of the velocity enforced
        !at the edge of the computational domain
        function get_v_in(t,x,y) result(var)

          implicit none

          real(rkind), intent(in) :: t
          real(rkind), intent(in) :: x
          real(rkind), intent(in) :: y
          real(rkind)             :: var
          
          real(rkind) :: t_s,x_s,y_s

          t_s    = t
          x_s    = x
          y_s    = y

          var = get_velocity_y(x,y)

        end function get_v_in

      
        !get the temperature enforced at the edge of the
        !computational domain
        function get_T_in(t,x,y) result(var)

          implicit none

          real(rkind), intent(in) :: t
          real(rkind), intent(in) :: x
          real(rkind), intent(in) :: y
          real(rkind)             :: var
          
          
          real(rkind) :: t_s,x_s,y_s

          t_s = t
          x_s = x
          y_s = y
          

          var = T0

        end function get_T_in


        !get the pressure enforced at the edge of the
        !computational domain
        function get_P_out(t,x,y) result(var)

          implicit none

          real(rkind), intent(in) :: t
          real(rkind), intent(in) :: x
          real(rkind), intent(in) :: y
          real(rkind)             :: var
          
          
          real(rkind) :: t_s,x_s,y_s
          real(rkind) :: mass

          t_s = t
          x_s = x
          y_s = y

          mass = get_mass_far_field(T0)

          if(rkind.eq.8) then
             var = 8.0d0*mass*T0/(3.0d0-mass) - 3.0d0*mass**2
          else
             var = 8.0*mass*T0/(3.0-mass) - 3.0*mass**2
          end if

        end function get_P_out


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the governing variables imposed in the far field
        !
        !> @date
        !> 03_12_2014 - initial version - J.L. Desmarais
        !
        !>@param t
        !> time
        !
        !>@param x
        !> x-coordinate
        !
        !>@param y
        !> y-coordinate
        !
        !>@return var
        !> governing variables in the far-field
        !--------------------------------------------------------------
        function get_far_field(this,t,x,y) result(var)

          implicit none

          class(ic)     , intent(in) :: this
          real(rkind)   , intent(in) :: t
          real(rkind)   , intent(in) :: x
          real(rkind)   , intent(in) :: y
          real(rkind), dimension(ne) :: var


          real(rkind) :: t_s,x_s,y_s
          real(rkind) :: mass
          real(rkind) :: velocity_x
          real(rkind) :: velocity_y
          real(rkind) :: temperature

          character(19) :: name_s
          
          t_s = t
          x_s = x
          y_s = y
          name_s = this%name

          velocity_x  = get_velocity_x(x,y)
          velocity_y  = get_velocity_y(x,y)
          temperature = T0

          mass = get_mass_far_field(temperature)

          if(rkind.eq.8) then

             var(1) = mass
             var(2) = mass*velocity_x
             var(3) = mass*velocity_y
             var(4) = 0.5d0*mass*(velocity_x**2+velocity_y**2) +
     $                mass*(8.0d0/3.0d0*cv_r*temperature-3.0d0*mass)

          else

             var(1) = mass
             var(2) = mass*velocity_x
             var(3) = mass*velocity_y
             var(4) = 0.5*mass*(velocity_x**2+velocity_y**2) +
     $                mass*(8.0/3.0*cv_r*temperature-3.0*mass)

          end if

        end function get_far_field


        function get_velocity_x(x,y) result(velocity_x)

          implicit none

          real(rkind), intent(in) :: x
          real(rkind), intent(in) :: y
          real(rkind)             :: velocity_x


          select case(flow_profile)

            case(parabolic_profile)

               select case(flow_direction)

                 case(x_direction)
                    velocity_x = u0_x_flow*((y-y_min)/(y_max-y_min))**2

                 case(y_direction)
                    velocity_x = u0_y_flow*((x-x_min)/(x_max-x_min))**2

                 case default
                    print '(''bubble_spherical_cap/ic_class.f'')'
                    print '(''get_velocity_x'')'
                    print '(''flow_direction not recognized'')'
                    print '(''flow_direction: '',I2)', flow_direction
                    stop ''
                 end select

            case(linear_profile)

               select case(flow_direction)

                 case(x_direction)
                    velocity_x = u0_x_flow*((y-y_min)/(y_max-y_min))

                 case(y_direction)
                    velocity_x = u0_y_flow*((x-x_min)/(x_max-x_min))

                 case default
                    print '(''bubble_spherical_cap/ic_class.f'')'
                    print '(''get_velocity_x'')'
                    print '(''flow_direction not recognized'')'
                    print '(''flow_direction: '',I2)', flow_direction
                    stop ''
               end select
               
            case default

               print '(''bubble_spherical_cap/ic_class.f'')'
               print '(''get_velocity_x'')'
               print '(''flow_profile not recognized'')'
               print '(''flow_profile: '',I2)', flow_profile
               stop ''

          end select
          
        end function get_velocity_x

        
        function get_velocity_y(x,y) result(velocity_y)

          implicit none

          real(rkind), intent(in) :: x
          real(rkind), intent(in) :: y
          real(rkind)             :: velocity_y
          

          select case(flow_profile)

            case(parabolic_profile)

               select case(flow_direction)

                 case(x_direction)
                    velocity_y = v0_x_flow*((y-y_min)/(y_max-y_min))**2

                 case(y_direction)
                    velocity_y = v0_y_flow*((x-x_min)/(x_max-x_min))**2

                 case default
                    print '(''bubble_nucleation_at_wall/ic_class.f'')'
                    print '(''get_velocity_y'')'
                    print '(''flow_direction not recognized'')'
                    print '(''flow_direction: '',I2)', flow_direction
                    stop ''
               end select

            case(linear_profile)

               select case(flow_direction)

                 case(x_direction)
                    velocity_y = v0_x_flow*((y-y_min)/(y_max-y_min))

                 case(y_direction)
                    velocity_y = v0_y_flow*((x-x_min)/(x_max-x_min))

                 case default
                    print '(''bubble_nucleation_at_wall/ic_class.f'')'
                    print '(''get_velocity_y'')'
                    print '(''flow_direction not recognized'')'
                    print '(''flow_direction: '',I2)', flow_direction
                    stop ''
               end select
               
            case default

               print '(''bubble_spherical_cap/ic_class.f'')'
               print '(''get_velocity_y'')'
               print '(''flow_profile not recognized'')'
               print '(''flow_profile: '',I2)', flow_profile
               stop ''

          end select

        end function get_velocity_y


        function get_mass_far_field(temperature)
     $     result(mass)

          implicit none

          real(rkind), intent(in) :: temperature
          real(rkind)             :: mass

          select case(phase_at_center)
            case(vapor)
               mass = get_mass_density_liquid(temperature)
            case(liquid)
               mass = get_mass_density_vapor(temperature)
            case default
               print '(''bubble_next_to_wall/ic_class'')'
               print '(''get_speed_of_sound'')'
               print '(''phase at center not recognized'')'
               print '(''phase_at_center: '',I2)', phase_at_center
               stop ''
          end select

        end function get_mass_far_field


        function get_speed_of_sound()
     $     result(c)

          implicit none

          real(rkind) :: c

          real(rkind), dimension(ne) :: nodes
          real(rkind)                :: mass

          mass = get_mass_far_field(T0)

          if(rkind.eq.8) then
             nodes(1) = mass
             nodes(2) = 0.0d0
             nodes(3) = 0.0d0
             nodes(4) = mass*(8.0d0/3.0d0*cv_r*T0-3.0d0*mass)
             
          else
             nodes(1) = mass
             nodes(2) = 0.0
             nodes(3) = 0.0
             nodes(4) = mass*(8.0/3.0*cv_r*T0-3.0*mass)

          end if

          c = speed_of_sound(nodes)

        end function get_speed_of_sound

      end module ic_class