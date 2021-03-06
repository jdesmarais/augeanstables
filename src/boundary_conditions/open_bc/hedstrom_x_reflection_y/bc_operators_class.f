      !> @file
      !> class encapsulating subroutines to apply open boundary
      !> conditions at the edge of the computational domain in
      !> the x-direction and reflection boundary conditions in
      !> the y-direction
      !
      !> @author 
      !> Julien L. Desmarais
      !
      !> @brief
      !> class encapsulating subroutines to apply open boundary
      !> conditions at the edge of the computational domain in
      !> the x-direction and reflection boundary conditions in
      !> the y-direction
      !
      !> @date
      !> 04_08_2014 - initial version - J.L. Desmarais
      !-----------------------------------------------------------------
      module bc_operators_class

        use bc_operators_openbc_normal_class, only :
     $     bc_operators_openbc_normal

        use hedstrom_xy_module, only :
     $       compute_timedev_xlayer,
     $       compute_timedev_ylayer,
     $       compute_timedev_xlayer_local,
     $       compute_timedev_ylayer_local,
     $       compute_timedev_corner_local

        use interface_primary, only :
     $       gradient_x_proc,
     $       gradient_y_proc

        use openbc_operators_module, only :
     $       incoming_left,
     $       incoming_right,
     $       compute_fluxes_at_the_edges_2ndorder

        use pmodel_eq_class, only :
     $       pmodel_eq

        use parameters_constant, only :
     $       bc_nodes_choice,
     $       bc_timedev_choice,
     $       N,S,E,W,
     $       left

        use parameters_input, only :
     $       nx,ny,ne,bc_size

        use parameters_kind, only :
     $       rkind,ikind

        use reflection_xy_module, only :
     $       reflection_y_prefactor

        use sd_operators_fd_module, only :
     $       gradient_x_x_oneside_L0,
     $       gradient_x_x_oneside_L1,
     $       gradient_x_x_oneside_R1,
     $       gradient_x_x_oneside_R0,
     $       gradient_y_y_oneside_L0,
     $       gradient_y_y_oneside_L1,
     $       gradient_y_y_oneside_R1,
     $       gradient_y_y_oneside_R0

        use sd_operators_x_oneside_L0_class, only :
     $       sd_operators_x_oneside_L0

        use sd_operators_x_oneside_L1_class, only :
     $       sd_operators_x_oneside_L1

        use sd_operators_x_oneside_R1_class, only :
     $       sd_operators_x_oneside_R1

        use sd_operators_x_oneside_R0_class, only :
     $       sd_operators_x_oneside_R0

        
        implicit none


        private
        public :: bc_operators



        !> @class bc_operators
        !> class encapsulating subroutines to apply
        !> open boundary conditions in the x and
        !> y directions at the edge of the computational
        !> domain
        !
        !> @param ini
        !> initialize the bc_type attribute of the
        !> boundary conditions
        !
        !> @param apply_bc_on_timedev
        !> apply the open boundary conditions for the time derivatives
        !---------------------------------------------------------------
        type, extends(bc_operators_openbc_normal) :: bc_operators

          integer, dimension(ne) :: prefactor_y

          contains

          procedure, pass :: ini
          procedure, pass :: apply_bc_on_nodes
          procedure, pass :: apply_bc_on_timedev => apply_bc_on_timedev_2ndorder

          procedure, pass :: apply_bc_on_timedev_x_edge
          procedure, pass :: apply_bc_on_timedev_y_edge
          procedure, pass :: apply_bc_on_timedev_xy_corner

        end type bc_operators        
      

        contains

        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> subroutine initializing the main attributes
        !> of the boundary conditions
        !
        !> @date
        !> 04_08_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> boundary conditions initialized
        !
        !>@param p_model
        !> physical model to know the type of the main variables
        !--------------------------------------------------------------
        subroutine ini(this,p_model)
        
          implicit none

          class(bc_operators), intent(inout) :: this
          type(pmodel_eq)    , intent(in)    :: p_model
          
          integer :: neq

          neq = p_model%get_eq_nb()

          this%bc_type(N) = bc_nodes_choice
          this%bc_type(S) = bc_nodes_choice
          this%bc_type(E) = bc_timedev_choice
          this%bc_type(W) = bc_timedev_choice

          this%prefactor_y = reflection_y_prefactor(p_model)

        end subroutine ini


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> subroutine applying the boundary conditions
        !> along the x and y directions at the edge of the
        !> computational domain
        !
        !> @date
        !> 24_09_2013 - initial version - J.L. Desmarais
        !
        !>@param f
        !> object encapsulating the main variables
        !
        !>@param s
        !> space discretization operators
        !--------------------------------------------------------------
        subroutine apply_bc_on_nodes(this,nodes)

          implicit none

          class(bc_operators)             , intent(in)    :: this
          real(rkind), dimension(nx,ny,ne), intent(inout) :: nodes


          integer(ikind) :: i,j
          integer        :: k

          !< compute the reflection b.c. in N and S boundary layers
          do k=1, ne
             do j=1, bc_size
                !DEC$ IVDEP
                do i=1, nx
                   
                   nodes(i,j,k) = 
     $                  this%prefactor_y(k)*nodes(i,2*bc_size+1-j,k)
                   nodes(i,ny-bc_size+j,k) = 
     $                  this%prefactor_y(k)*nodes(i,ny-bc_size-j+1,k)
                   
                end do
             end do
          end do

        end subroutine apply_bc_on_nodes


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> subroutine applying the boundary conditions
        !> on the time derivatives with space operators
        !> that are 2nd order accurate in the interior
        !> and 1st order accurate at the boundary
        !
        !> @date
        !> 04_08_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array of grid point data
        !
        !>@param dx
        !> space step along the x-axis
        !
        !>@param dy
        !> space step along the y-axis
        !
        !>@param p_model
        !> governing equations of the physical model
        !
        !>@param flux_x
        !> fluxes along the x-direction
        !
        !>@param flux_y
        !> fluxes along the y-direction
        !
        !>@param timedev
        !> time derivatives
        !-------------------------------------------------------------
        subroutine apply_bc_on_timedev_2ndorder(
     $     this,
     $     p_model,
     $     t,nodes,x_map,y_map,
     $     flux_x,flux_y,
     $     timedev)
        
          implicit none
        
          class(bc_operators)               , intent(in)    :: this
          type(pmodel_eq)                   , intent(in)    :: p_model
          real(rkind)                       , intent(in)    :: t
          real(rkind), dimension(nx,ny,ne)  , intent(in)    :: nodes
          real(rkind), dimension(nx)        , intent(in)    :: x_map
          real(rkind), dimension(ny)        , intent(in)    :: y_map
          real(rkind), dimension(nx+1,ny,ne), intent(inout) :: flux_x
          real(rkind), dimension(nx,ny+1,ne), intent(inout) :: flux_y
          real(rkind), dimension(nx,ny,ne)  , intent(inout) :: timedev


          type(sd_operators_x_oneside_L0) :: s_x_L0
          type(sd_operators_x_oneside_L1) :: s_x_L1
          type(sd_operators_x_oneside_R1) :: s_x_R1
          type(sd_operators_x_oneside_R0) :: s_x_R0


          real(rkind)    :: dx,dy,flux
          integer(ikind) :: i,j
          integer(ikind) :: j_min, j_max

          real(rkind)    :: t_s


          dx = x_map(2)-x_map(1)
          dy = y_map(2)-y_map(1)


          !prevent unsed parameter warnings while being
          !supress by the compiler afterwards
          !--------------------------------------------
          t_s  = t
          flux = flux_x(1,1,1)


          !compute the fluxes at the edge of the
          !computational domain
          !--------------------------------------------
          !E+W_edge
          j_min = bc_size+1
          j_max = ny-bc_size+1
          
          call this%compute_fluxes_for_bc_x_edge(
     $         p_model,
     $         nodes,
     $         s_x_L0, s_x_L1,
     $         s_x_R1, s_x_R0,
     $         dx, dy,
     $         j_min, j_max, i,
     $         E+W,
     $         flux_y)


          !apply the boundary conditions on the west
          !and east layers
          !--------------------------------------------
          do j=bc_size+1, ny-bc_size

             i=1
             call compute_timedev_xlayer(
     $            t,x_map,y_map, nodes, i,j, dx,dy, p_model, flux_y,
     $            gradient_x_x_oneside_L0, incoming_left,
     $            timedev)

             i=bc_size
             call compute_timedev_xlayer(
     $            t,x_map,y_map, nodes, i,j, dx,dy, p_model, flux_y,
     $            gradient_x_x_oneside_L1, incoming_left,
     $            timedev)

             i=nx-1
             call compute_timedev_xlayer(
     $            t,x_map,y_map, nodes, i,j, dx,dy, p_model, flux_y,
     $            gradient_x_x_oneside_R1, incoming_right,
     $            timedev)

             i=nx
             call compute_timedev_xlayer(
     $            t,x_map,y_map, nodes, i,j, dx,dy, p_model, flux_y,
     $            gradient_x_x_oneside_R0, incoming_right,
     $            timedev)

          end do
        
        end subroutine apply_bc_on_timedev_2ndorder


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute the time derivatives at (i,j) resulting
        !> of the application of the boundary condition on
        !> and x edge: W_edge or E_edge
        !
        !> @date
        !> 21_10_2014 - initial version - J.L. Desmarais
        !
        !>@param p_model
        !> object encapsulating the physical model
        !
        !>@param t
        !> simulation time for boundary conditions depending
        !> on time
        !
        !>@param nodes
        !> object encapsulating the main variables
        !
        !>@param dx
        !> grid size along the x-axis
        !
        !>@param dy
        !> grid size along the y-axis
        !
        !>@param i
        !> grid point index along the x-axis
        !
        !>@param j
        !> grid point index along the y-axis
        !
        !>@param flux_y
        !> fluxes along the y-direction
        !
        !>@param side_x
        !> edge side to determine the boundary normal vector
        !
        !>@param gradient_x
        !> procedure to compute the gradient along the x-direction
        !> at (i,j)
        !
        !>@param timedev
        !> time derivatives of the grid points
        !--------------------------------------------------------------
        function apply_bc_on_timedev_x_edge(
     $     this,
     $     p_model, t,
     $     nodes, x_map, y_map, i,j,
     $     flux_y,
     $     side_x,
     $     gradient_x)
     $     result(timedev)

          implicit none

          class(bc_operators)          , intent(in) :: this
          type(pmodel_eq)              , intent(in) :: p_model
          real(rkind)                  , intent(in) :: t
          real(rkind), dimension(:,:,:), intent(in) :: nodes
          real(rkind), dimension(:)    , intent(in) :: x_map
          real(rkind), dimension(:)    , intent(in) :: y_map
          integer(ikind)               , intent(in) :: i
          integer(ikind)               , intent(in) :: j
          real(rkind), dimension(:,:,:), intent(in) :: flux_y
          logical                      , intent(in) :: side_x
          procedure(gradient_x_proc)                :: gradient_x
          real(rkind), dimension(ne)                :: timedev

          integer, dimension(4) :: bc_s
          real(rkind)           :: t_s
          real(rkind)           :: dx,dy

          bc_s = this%bc_type
          t_s  = t
          dx   = x_map(2)-x_map(1)
          dy   = y_map(2)-y_map(1)

          if(side_x.eqv.left) then

             timedev = compute_timedev_xlayer_local(
     $            p_model,
     $            t,x_map,y_map, nodes, dx, dy, i,j,
     $            flux_y,
     $            incoming_left,
     $            gradient_x)

          else

             timedev = compute_timedev_xlayer_local(
     $            p_model,
     $            t,x_map,y_map, nodes, dx, dy, i,j,
     $            flux_y,
     $            incoming_right,
     $            gradient_x)

          end if

        end function apply_bc_on_timedev_x_edge


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute the time derivatives at (i,j) resulting
        !> of the application of the boundary condition on
        !> an y edge: N_edge or S_edge
        !
        !> @date
        !> 21_10_2014 - initial version - J.L. Desmarais
        !
        !>@param p_model
        !> object encapsulating the physical model
        !
        !>@param t
        !> simulation time for boundary conditions depending
        !> on time
        !
        !>@param nodes
        !> object encapsulating the main variables
        !
        !>@param dx
        !> grid size along the x-axis
        !
        !>@param dy
        !> grid size along the y-axis
        !
        !>@param i
        !> grid point index along the x-axis
        !
        !>@param j
        !> grid point index along the y-axis
        !
        !>@param flux_x
        !> fluxes along the y-direction
        !
        !>@param side_y
        !> edge side to determine the boundary normal vector
        !
        !>@param gradient_y
        !> procedure to compute the gradient along the y-direction
        !> at (i,j)
        !
        !>@param timedev
        !> time derivatives of the grid points
        !--------------------------------------------------------------
        function apply_bc_on_timedev_y_edge(
     $     this, 
     $     p_model, t,
     $     nodes, x_map, y_map, i,j,
     $     flux_x,
     $     side_y,
     $     gradient_y)
     $     result(timedev)

          implicit none

          class(bc_operators)          , intent(in) :: this
          type(pmodel_eq)              , intent(in) :: p_model
          real(rkind)                  , intent(in) :: t
          real(rkind), dimension(:,:,:), intent(in) :: nodes
          real(rkind), dimension(:)    , intent(in) :: x_map
          real(rkind), dimension(:)    , intent(in) :: y_map
          integer(ikind)               , intent(in) :: i
          integer(ikind)               , intent(in) :: j
          real(rkind), dimension(:,:,:), intent(in) :: flux_x
          logical                      , intent(in) :: side_y
          procedure(gradient_y_proc)                :: gradient_y
          real(rkind), dimension(ne)                :: timedev

          integer, dimension(4) :: bc_s
          real(rkind) :: dx
          real(rkind) :: dy 
          logical     :: side_s

          print '(''hedstrom_x_reflection_y/bc_operators_class'')'
          print '(''apply_bc_on_timedev_y_edge'')' 
          stop 'not implemented'

          bc_s    = this%bc_type
          dx      = x_map(2) - x_map(1)
          dy      = y_map(2) - y_map(1)
          side_s  = side_y

          timedev = compute_timedev_ylayer_local(
     $            p_model,
     $            t,x_map,y_map, nodes, dx, dy, i,j,
     $            flux_x,
     $            incoming_right,
     $            gradient_y)

        end function apply_bc_on_timedev_y_edge


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute the time derivatives at (i,j) resulting
        !> of the application of the boundary condition on
        !> a corner: SE_corner, SW_corner, NE_corner, NW_corner
        !
        !> @date
        !> 21_10_2014 - initial version - J.L. Desmarais
        !
        !>@param p_model
        !> object encapsulating the physical model
        !
        !>@param t
        !> simulation time for boundary conditions depending
        !> on time
        !
        !>@param nodes
        !> object encapsulating the main variables
        !
        !>@param dx
        !> grid size along the x-axis
        !
        !>@param dy
        !> grid size along the y-axis
        !
        !>@param i
        !> grid point index along the x-axis
        !
        !>@param j
        !> grid point index along the y-axis
        !
        !>@param flux_x
        !> fluxes along the y-direction
        !
        !>@param side_y
        !> edge side to determine the boundary normal vector
        !
        !>@param gradient_y
        !> procedure to compute the gradient along the y-direction
        !> at (i,j)
        !
        !>@param timedev
        !> time derivatives of the grid points
        !--------------------------------------------------------------
        function apply_bc_on_timedev_xy_corner(
     $     this,
     $     p_model, t,
     $     nodes, x_map, y_map, i,j,
     $     side_x, side_y,
     $     gradient_x, gradient_y)
     $     result(timedev)

          implicit none

          class(bc_operators)          , intent(in) :: this
          type(pmodel_eq)              , intent(in) :: p_model
          real(rkind)                  , intent(in) :: t
          real(rkind), dimension(:,:,:), intent(in) :: nodes
          real(rkind), dimension(:)    , intent(in) :: x_map
          real(rkind), dimension(:)    , intent(in) :: y_map
          integer(ikind)               , intent(in) :: i
          integer(ikind)               , intent(in) :: j
          logical                      , intent(in) :: side_x
          logical                      , intent(in) :: side_y
          procedure(gradient_x_proc)                :: gradient_x
          procedure(gradient_y_proc)                :: gradient_y
          real(rkind), dimension(ne)                :: timedev

          integer, dimension(4) :: bc_s
          real(rkind)           :: t_s
          real(rkind)           :: dx
          real(rkind)           :: dy          
          logical               :: side_s

          print '(''hedstrom_x_reflection_y/bc_operators_class'')'
          print '(''apply_bc_on_timedev_xy_corner'')' 
          stop 'not implemented'

          bc_s   = this%bc_type
          t_s    = t
          dx     = x_map(2)-x_map(1)
          dy     = y_map(2)-y_map(1)
          side_s = side_x.and.side_y

          timedev = compute_timedev_corner_local(
     $         p_model,
     $         t,x_map,y_map, nodes, dx, dy, i,j,
     $         incoming_left,
     $         incoming_left,
     $         gradient_x,
     $         gradient_y)

        end function apply_bc_on_timedev_xy_corner

      end module bc_operators_class
