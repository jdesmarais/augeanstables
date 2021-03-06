      !> @file
      !> class encapsulating subroutines for the space discretization
      !> using the operators developed by Mattsson and Nordstrom in 
      !> “Summation by parts operators for finite difference
      !> approximations of second derivatives”, J. Comput. Phys.,
      !> Vol 199, pp 503-540, April 2004 (Appendix C.1. First order
      !> accuracy at the boundary)
      !
      !> @author 
      !> Julien L. Desmarais
      !
      !> @brief
      !> class encapsulating subroutines for the space discretisation
      !> scheme using Mattson and Nordstrom's operators
      !
      !> @date
      !> 30_07_2014 - initial version - J.L. Desmarais
      !-----------------------------------------------------------------
      module sd_operators_y_oneside_R1_class

        use sd_operators_fd_module, only :
     $       gradient_y_y_oneside_R0,
     $       gradient_y_interior,
     $       gradient_x_interior

        use interface_primary, only :
     $       get_primary_var,
     $       get_secondary_var

        use parameters_constant, only :
     $       sd_R1_type

        use parameters_kind, only :
     $       ikind,
     $       rkind

        use sd_operators_class, only :
     $       sd_operators

        implicit none

        private
        public :: sd_operators_y_oneside_R1


        !> @class sd_operators_y_oneside_R1
        !> class encapsulating 
        !
        !> @param get_bc_size
        !> get the boundary layer size
        !
        !> @param get_operator_type
        !> get the type of operator
        !
        !> @param f
        !> evaluate data at [i-1/2,j]
        !
        !> @param dfdx
        !> evaluate \f$\frac{\partial}{\partial x}\f$ at [i-1/2,j]
        !
        !> @param dfdy
        !> evaluate \f$\frac{\partial}{\partial y}\f$ at [i-1/2,j]
        !
        !> @param d2fdx2
        !> evaluate \f$\frac{\partial}{\partial x^2}\f$ at [i-1/2,j]
        !
        !> @param d2fdy2
        !> evaluate \f$\frac{\partial}{\partial y^2}\f$ at [i-1/2,j]
        !
        !> @param d2fdxdy
        !> evaluate \f$\frac{\partial}{\partial x \partial y}\f$
        !> at [i-1/2,j]
        !        
        !> @param g
        !> evaluate data at [i,j-1/2]
        !
        !> @param dgdx
        !> evaluate \f$\frac{\partial}{\partial x}\f$ at [i,j-1/2]
        !
        !> @param dgdy
        !> evaluate \f$\frac{\partial}{\partial y}\f$ at [i,j-1/2]
        !
        !> @param d2gdx2
        !> evaluate \f$\frac{\partial}{\partial x^2}\f$ at [i,j-1/2]
        !
        !> @param d2gdy2
        !> evaluate \f$\frac{\partial}{\partial y^2}\f$ at [i,j-1/2]
        !
        !> @param d2gdxdy
        !> evaluate \f$\frac{\partial}{\partial x \partial y}\f$
        !> at [i,j-1/2]
        !---------------------------------------------------------------
        type, extends(sd_operators) :: sd_operators_y_oneside_R1

          contains
          
          procedure, nopass :: get_operator_type

          procedure, nopass :: dgdy_nl => dgdy_y_oneside_R1_nl
          procedure, nopass :: d2gdy2  => d2gdy2_y_oneside_R1

        end type sd_operators_y_oneside_R1

        contains


        !> @author 
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the type of operator
        !
        !> @date
        !> 28_01_2015 - initial version - J.L. Desmarais
        !
        !>@param operator_type
        !> integer identifying the type of operator
        !---------------------------------------------------------------
        function get_operator_type() result(operator_type)

          integer :: operator_type

          operator_type = sd_R1_type

        end function get_operator_type


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ \frac{\partial u}{\partial x} \bigg|_{i-\frac{1}{2}
        !> ,j} = \frac{1}{\Delta x}(- 2 u_{i,j} + 3 u_{i+1,j} - u_{i+2,j})
        !> \f$
        !
        !> @date
        !> 29_07_2014 - initial version  - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@param i
        !> index along x-axis where the data is evaluated
        !
        !>@param j
        !> index along y-axis where the data is evaluated
        !
        !>@param proc
        !> procedure computing the special quantity evaluated at [i,j]
        !> (ex: pressure, temperature,...)
        !
        !>@param dx
        !> grid step along the x-axis
        !
        !>@param dy
        !> grid step along the y-axis
        !
        !>@param var
        !> data evaluated at [i,j]
        !---------------------------------------------------------------
        function dgdy_y_oneside_R1_nl(nodes,i,j,proc,dx,dy) result(var)

          implicit none

          real(rkind), dimension(:,:,:), intent(in) :: nodes
          integer(ikind)               , intent(in) :: i
          integer(ikind)               , intent(in) :: j
          procedure(get_secondary_var)              :: proc
          real(rkind)                  , intent(in) :: dx
          real(rkind)                  , intent(in) :: dy
          real(rkind)                               :: var

          if(rkind.eq.8) then

             !TAG INLINE
             var = 1.0d0/dy*(
     $            -proc(nodes,i,j-1,dx,dy,gradient_x_interior,gradient_y_interior    )
     $            +proc(nodes,i,j  ,dx,dy,gradient_x_interior,gradient_y_y_oneside_R0))
          else
             var = 1.0/dy*(
     $            -proc(nodes,i,j-1,dx,dy,gradient_x_interior,gradient_y_interior    )
     $            +proc(nodes,i,j  ,dx,dy,gradient_x_interior,gradient_y_y_oneside_R0))
          end if

        end function dgdy_y_oneside_R1_nl

        
        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ \frac{\partial^2 u}{\partial y^2}\bigg|
        !> _{i,j-\frac{1}{2}}= \frac{1}{2 {\Delta x}^2}(u_{i,j-2} -
        !> u_{i,j-1} - u_{i,j} + u_{i,j+1}) \f$
        !
        !> @date
        !> 30_07_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@param i
        !> index along x-axis where the data is evaluated
        !
        !>@param j
        !> index along y-axis where the data is evaluated
        !
        !>@param proc
        !> procedure computing the special quantity evaluated at [i,j]
        !> (ex: pressure, temperature,...)
        !
        !>@param dy
        !> grid step along the y-axis
        !
        !>@param var
        !> data evaluated at [i,j]
        !---------------------------------------------------------------
        function d2gdy2_y_oneside_R1(
     $     nodes,i,j,proc,dy)
     $     result(var)

          implicit none

          real(rkind), dimension(:,:,:), intent(in) :: nodes
          integer(ikind)               , intent(in) :: i
          integer(ikind)               , intent(in) :: j
          procedure(get_primary_var)                :: proc
          real(rkind)                  , intent(in) :: dy
          real(rkind)                               :: var

          if(rkind.eq.8) then
             !TAG INLINE
             var = 0.5d0/(dy**2)*(
     $            -2.0d0*proc(nodes,i,j-4)
     $            +7.0d0*proc(nodes,i,j-3)
     $            -7.0d0*proc(nodes,i,j-2)
     $            +proc(nodes,i,j-1)
     $            +proc(nodes,i,j)
     $            )
          else
             var = 0.5/(dy**2)*(
     $            -2.0*proc(nodes,i,j-4)
     $            +7.0*proc(nodes,i,j-3)
     $            -7.0*proc(nodes,i,j-2)
     $            +proc(nodes,i,j-1)
     $            +proc(nodes,i,j)
     $            )
          end if

        end function d2gdy2_y_oneside_R1
        
      end module sd_operators_y_oneside_R1_class
