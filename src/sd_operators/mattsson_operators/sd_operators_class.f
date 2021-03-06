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
      !> 29_07_2014 - initial version - J.L. Desmarais
      !-----------------------------------------------------------------
      module sd_operators_class

        use sd_operators_fd_module, only :
     $       gradient_x_interior,
     $       gradient_y_interior

        use interface_primary, only :
     $       get_primary_var,
     $       get_secondary_var

        use parameters_constant, only :
     $       sd_interior_type

        use parameters_kind, only :
     $       ikind,
     $       rkind

        use sd_operators_abstract_class, only :
     $       sd_operators_abstract

        implicit none

        private
        public :: sd_operators


        !> @class sd_operators
        !> class encapsulating Mattson and Nordstrom's spatial
        !> discretization operators
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
        type, extends(sd_operators_abstract) :: sd_operators

          contains

          procedure, nopass :: get_bc_size => get_bc_size_mattsson
          procedure, nopass :: get_operator_type

          procedure, nopass :: f           => f_mattsson
          procedure, nopass :: dfdx        => dfdx_mattsson
          procedure, nopass :: dfdx_nl     => dfdx_mattsson_nl
          procedure, nopass :: dfdy        => dfdy_mattsson
          procedure, nopass :: d2fdx2      => d2fdx2_mattsson
          procedure, nopass :: d2fdy2      => d2fdy2_mattsson
          procedure, nopass :: d2fdxdy     => d2fdxdy_mattsson

          procedure, nopass :: g           => g_mattsson
          procedure, nopass :: dgdx        => dgdx_mattsson
          procedure, nopass :: dgdy        => dgdy_mattsson
          procedure, nopass :: dgdy_nl     => dgdy_mattsson_nl
          procedure, nopass :: d2gdx2      => d2gdx2_mattsson
          procedure, nopass :: d2gdy2      => d2gdy2_mattsson
          procedure, nopass :: d2gdxdy     => d2gdxdy_mattsson

        end type sd_operators

        contains

        !> @author 
        !> Julien L. Desmarais
        !
        !> @brief
        !> give the boundary layer size
        !
        !> @date
        !> 30_07_2012 - initial version - J.L. Desmarais
        !
        !>@param bc_size
        !> boundary layer size
        !---------------------------------------------------------------
        function get_bc_size_mattsson() result(bc_size_op)
          integer :: bc_size_op
          bc_size_op = 2
        end function get_bc_size_mattsson


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

          operator_type = sd_interior_type

        end function get_operator_type


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ u_{i-\frac{1}{2},j}=
        !>\frac{1}{2}(u_{i-1,j} + u_{i,j})\f$
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
        !>@param var
        !> data evaluated at [i,j]
        !---------------------------------------------------------------
        function f_mattsson(nodes,i,j,proc) result(var)

          implicit none

          real(rkind), dimension(:,:,:), intent(in) :: nodes
          integer(ikind)               , intent(in) :: i
          integer(ikind)               , intent(in) :: j
          procedure(get_primary_var)                :: proc
          real(rkind)                               :: var

          if(rkind.eq.8) then

             !TAG INLINE
             var = 0.5d0*(
     $            +proc(nodes,i-1,j)
     $            +proc(nodes,i  ,j)
     $            )
          else
             var = 0.5*(
     $            +proc(nodes,i-1,j)
     $            +proc(nodes,i  ,j)
     $            )
          end if

        end function f_mattsson


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ \frac{\partial u}{\partial x}\big|_{i-\frac{1}{2}
        !> ,j}= \frac{1}{\Delta x}(-u_{i-1,j}+u_{i,j})\f$
        !
        !> @date
        !> 07_08_2013 - initial version  - J.L. Desmarais
        !> 11_07_2014 - interface change - J.L. Desmarais
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
        !>@param var
        !> data evaluated at [i,j]
        !---------------------------------------------------------------
        function dfdx_mattsson(
     $     nodes,i,j,proc,dx)
     $     result(var)

          implicit none

          real(rkind), dimension(:,:,:), intent(in) :: nodes
          integer(ikind), intent(in) :: i
          integer(ikind), intent(in) :: j
          procedure(get_primary_var) :: proc
          real(rkind)   , intent(in) :: dx
          real(rkind)                :: var

          if(rkind.eq.8) then

             !TAG INLINE
             var = 1.d0/dx*(
     $            -proc(nodes,i-1,j)
     $            +proc(nodes,i  ,j))
          else
             var = 1./dx*(
     $            -proc(nodes,i-1,j)
     $            +proc(nodes,i  ,j))
          end if

        end function dfdx_mattsson


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ \frac{\partial u}{\partial x}\big|_{i-\frac{1}{2}
        !> ,j}= \frac{1}{\Delta x}(-u_{i-1,j}+u_{i,j})\f$
        !
        !> @date
        !> 07_08_2013 - initial version  - J.L. Desmarais
        !> 11_07_2014 - interface change - J.L. Desmarais
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
        function dfdx_mattsson_nl(
     $     nodes,i,j,proc,dx,dy)
     $     result(var)

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
             var = 1.d0/dx*(
     $            -proc(nodes,i-1,j,dx,dy,gradient_x_interior,gradient_y_interior)
     $            +proc(nodes,i  ,j,dx,dy,gradient_x_interior,gradient_y_interior))
          else
             var = 1./dx*(
     $            -proc(nodes,i-1,j,dx,dy,gradient_x_interior,gradient_y_interior)
     $            +proc(nodes,i  ,j,dx,dy,gradient_x_interior,gradient_y_interior))
          end if

        end function dfdx_mattsson_nl


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ \frac{\partial u}{\partial y}\big|
        !> _{i-\frac{1}{2},j}= \frac{1}{2 \Delta y}
        !> (-u_{i-\frac{1}{2},j-1}+u_{i-\frac{1}{2},j+1})\f$
        !
        !> @date
        !> 08_08_2013 - initial version - J.L. Desmarais
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
        function dfdy_mattsson(
     $     nodes,i,j,proc,dy)
     $     result(var)

          implicit none

          real(rkind), dimension(:,:,:), intent(in) :: nodes
          integer(ikind)               , intent(in) :: i
          integer(ikind)               , intent(in) :: j
          real(rkind)                  , intent(in) :: dy
          procedure(get_primary_var)                :: proc
          real(rkind)                               :: var

          !TAG INLINE
          if(rkind.eq.8) then
             !TAG INLINE
             var = 1.0d0/(2.0d0*dy)*(
     $            - 0.5d0*proc(nodes,i-1,j-1)
     $            - 0.5d0*proc(nodes,i  ,j-1)
     $            + 0.5d0*proc(nodes,i-1,j+1)
     $            + 0.5d0*proc(nodes,i  ,j+1))
          else
             var = 1.0/(2.0*dy)*(
     $            - 0.5*proc(nodes,i-1,j-1)
     $            - 0.5*proc(nodes,i  ,j-1)
     $            + 0.5*proc(nodes,i-1,j+1)
     $            + 0.5*proc(nodes,i  ,j+1))
          end if

        end function dfdy_mattsson


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ \frac{\partial^2 u}{\partial x^2}\big|
        !> _{i-\frac{1}{2},j}= \frac{1}{2 {\Delta x}^2}(u_{i-2,j} -
        !> u_{i-1,j} - u_{i,j} + u_{i+1,j}) \f$
        !
        !> @date
        !> 08_08_2013 - initial version - J.L. Desmarais
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
        !>@param var
        !> data evaluated at [i,j]
        !---------------------------------------------------------------
        function d2fdx2_mattsson(
     $     nodes,i,j,proc,dx)
     $     result(var)

          implicit none

          real(rkind), dimension(:,:,:), intent(in) :: nodes
          integer(ikind)               , intent(in) :: i
          integer(ikind)               , intent(in) :: j
          procedure(get_primary_var)                :: proc
          real(rkind)                  , intent(in) :: dx
          real(rkind)                               :: var

          if(rkind.eq.8) then
             !TAG INLINE
             var = 0.5d0/(dx**2)*(
     $            +proc(nodes,i-2,j)
     $            -proc(nodes,i-1,j)
     $            -proc(nodes,i  ,j)
     $            +proc(nodes,i+1,j)
     $            )
          else
             var = 1./(2.*(dx**2))*(
     $            +proc(nodes,i-2,j)
     $            -proc(nodes,i-1,j)
     $            -proc(nodes,i  ,j)
     $            +proc(nodes,i+1,j)
     $            )
          end if

        end function d2fdx2_mattsson


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ \frac{\partial^2 u}{\partial y^2}
        !> \big|_{i-\frac{1}{2},j}= \frac{1}{{\Delta y}^2}(
        !> u_{i-\frac{1}{2},j-1} - 2 u_{i-\frac{1}{2},j} +
        !> u_{i-\frac{1}{2},j+1}) \f$
        !
        !> @date
        !> 08_08_2013 - initial version - J.L. Desmarais
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
        function d2fdy2_mattsson(
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
             var = (1.0d0/(dy**2))*
     $            (
     $            + 0.5d0*proc(nodes,i-1,j-1)
     $            + 0.5d0*proc(nodes,i  ,j-1)
     $            - 2.0d0*(
     $            + 0.5d0*proc(nodes,i-1,j)
     $            + 0.5d0*proc(nodes,i  ,j)
     $            )
     $            + 0.5d0*proc(nodes,i-1,j+1)
     $            + 0.5d0*proc(nodes,i  ,j+1)
     $            )
          else
             var = (1.0/(dy**2))*
     $            (
     $            + 0.5*proc(nodes,i-1,j-1)
     $            + 0.5*proc(nodes,i  ,j-1)
     $            - 2.0*(
     $            + 0.5*proc(nodes,i-1,j)
     $            + 0.5*proc(nodes,i  ,j)
     $            )
     $            + 0.5*proc(nodes,i-1,j+1)
     $            + 0.5*proc(nodes,i  ,j+1)
     $            )
          end if
        end function d2fdy2_mattsson


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ \frac{\partial^2 u}{\partial x \partial y}
        !> \bigg|_{i-\frac{1}{2},j} = \frac{1}{2 \Delta y}
        !> (-\frac{\partial u}{\partial x}\big|_{i-\frac{1}{2},j-1} +
        !> \frac{\partial u}{\partial x}\bigg|_{i-\frac{1}{2},j+1}) \f$
        !
        !> @date
        !> 08_08_2013 - initial version - J.L. Desmarais
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
        function d2fdxdy_mattsson(
     $     nodes,i,j,proc,dx,dy)
     $     result(var)

          implicit none

          real(rkind), dimension(:,:,:), intent(in) :: nodes
          integer(ikind)               , intent(in) :: i
          integer(ikind)               , intent(in) :: j
          procedure(get_primary_var)                :: proc
          real(rkind)                  , intent(in) :: dx
          real(rkind)                  , intent(in) :: dy
          real(rkind)                               :: var

          if(rkind.eq.8) then

             !TAG INLINE
             var =( proc(nodes,i-1,j-1)
     $            - proc(nodes,i  ,j-1)
     $            - proc(nodes,i-1,j+1)
     $            + proc(nodes,i  ,j+1))*
     $            0.5d0/(dy*dx)
          else
             var =( proc(nodes,i-1,j-1)
     $            - proc(nodes,i  ,j-1)
     $            - proc(nodes,i-1,j+1)
     $            + proc(nodes,i  ,j+1))
     $            /(2*dy*dx)
          end if

        end function d2fdxdy_mattsson


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ u_{i,j-\frac{1}{2}}=
        !>\frac{1}{2}(u_{i,j-1} + u_{i,j}) \f$
        !
        !> @date
        !> 07_08_2013 - initial version  - J.L. Desmarais
        !> 11_07_2014 - interface change - J.L. Desmarais
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
        !>@param var
        !> data evaluated at [i,j]
        !---------------------------------------------------------------
        function g_mattsson(
     $     nodes,i,j,proc)
     $     result(var)

          implicit none

          real(rkind), dimension(:,:,:), intent(in) :: nodes
          integer(ikind)               , intent(in) :: i
          integer(ikind)               , intent(in) :: j
          procedure(get_primary_var)                :: proc
          real(rkind)                               :: var

          if(rkind.eq.8) then

             !TAG INLINE
             var = 0.5d0*(
     $            +proc(nodes,i,j-1)
     $            +proc(nodes,i,j  )
     $            )
          else
             var = 0.5d0*(
     $            +proc(nodes,i,j-1)
     $            +proc(nodes,i,j  )
     $            )
          end if

        end function g_mattsson    

      
        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ \frac{\partial u}{\partial x}|_{i
        !> ,j-\frac{1}{2}}= \frac{1}{2 \Delta x} (-u_{i-1,j-\frac{1}{2}}
        !> +u_{i+1,j-\frac{1}{2}})\f$
        !
        !> @date
        !> 08_08_2013 - initial version - J.L. Desmarais
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
        !>@param var
        !> data evaluated at [i,j]
        !---------------------------------------------------------------
        function dgdx_mattsson(
     $     nodes,i,j,proc,dx)
     $     result(var)

          implicit none

          real(rkind), dimension(:,:,:), intent(in) :: nodes
          integer(ikind)               , intent(in) :: i
          integer(ikind)               , intent(in) :: j
          procedure(get_primary_var)                :: proc
          real(rkind)                  , intent(in) :: dx
          real(rkind)                               :: var

          if(rkind.eq.8) then

             !TAG INLINE
             var = 0.25d0/dx*(
     $            - proc(nodes,i-1,j-1)
     $            - proc(nodes,i-1,j  )
     $            + proc(nodes,i+1,j-1)
     $            + proc(nodes,i+1,j  )
     $            )
          else
             var = 0.25/dx*(
     $            - proc(nodes,i-1,j-1)
     $            - proc(nodes,i-1,j  )
     $            + proc(nodes,i+1,j-1)
     $            + proc(nodes,i+1,j  )
     $            )
          end if

        end function dgdx_mattsson


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ \frac{\partial u}{\partial y}\bigg|_{i
        !> ,j-\frac{1}{2}}= \frac{1}{\Delta y}(-u_{i,j-1}+u_{i,j})\f$
        !
        !> @date
        !> 08_08_2013 - initial version - J.L. Desmarais
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
        function dgdy_mattsson(
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
             var = 1.0d0/dy*(
     $            -proc(nodes,i,j-1)
     $            +proc(nodes,i,j  )
     $            )
          else
             var = 1./dy*(
     $            -proc(nodes,i,j-1)
     $            +proc(nodes,i,j  )
     $            )
          end if

        end function dgdy_mattsson


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ \frac{\partial u}{\partial y}\bigg|_{i
        !> ,j-\frac{1}{2}}= \frac{1}{\Delta y}(-u_{i,j-1}+u_{i,j})\f$
        !
        !> @date
        !> 08_08_2013 - initial version - J.L. Desmarais
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
        function dgdy_mattsson_nl(
     $     nodes,i,j,proc,dx,dy)
     $     result(var)

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
     $            -proc(nodes,i,j-1,dx,dy,gradient_x_interior,gradient_y_interior)
     $            +proc(nodes,i,j  ,dx,dy,gradient_x_interior,gradient_y_interior)
     $            )
          else
             var = 1./dy*(
     $            -proc(nodes,i,j-1,dx,dy,gradient_x_interior,gradient_y_interior)
     $            +proc(nodes,i,j  ,dx,dy,gradient_x_interior,gradient_y_interior)
     $            )
          end if

        end function dgdy_mattsson_nl        

      
        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ \frac{\partial^2 u}{\partial x^2}
        !> \bigg|_{i,j-\frac{1}{2}}= \frac{1}{{\Delta x}^2}(
        !> u_{i-1,j-\frac{1}{2}}- 2 u_{i,j-\frac{1}{2}}
        !> + u_{i+1,j-\frac{1}{2}}) \f$
        !
        !> @date
        !> 08_08_2013 - initial version - J.L. Desmarais
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
        !>@param var
        !> data evaluated at [i,j]
        !---------------------------------------------------------------
        function d2gdx2_mattsson(
     $     nodes,i,j,proc,dx)
     $     result(var)

          implicit none

          real(rkind), dimension(:,:,:), intent(in) :: nodes
          integer(ikind)               , intent(in) :: i
          integer(ikind)               , intent(in) :: j
          procedure(get_primary_var)                :: proc
          real(rkind)                  , intent(in) :: dx
          real(rkind)                               :: var

          if(rkind.eq.8) then

             !TAG INLINE
             var = 0.5d0/(dx**2) * (
     $            +proc(nodes,i-1,j-1)
     $            +proc(nodes,i-1,j  )
     $            - 2.0d0*(
     $            +proc(nodes,i,j-1)
     $            +proc(nodes,i,j  )
     $            )
     $            +proc(nodes,i+1,j-1)
     $            +proc(nodes,i+1,j  )
     $            )
          else
             var = 0.5/(dx**2) * (
     $            +proc(nodes,i-1,j-1)
     $            +proc(nodes,i-1,j  )
     $            - 2.0*(
     $            +proc(nodes,i,j-1)
     $            +proc(nodes,i,j  )
     $            )
     $            +proc(nodes,i+1,j-1)
     $            +proc(nodes,i+1,j  )
     $            )
          end if

        end function d2gdx2_mattsson


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ \frac{\partial^2 u}{\partial y^2}\bigg|
        !> _{i,j-\frac{1}{2}}= \frac{1}{2 {\Delta y}^2}(u_{i,j-2} -
        !> u_{i,j-1} - u_{i,j} + u_{i,j+1}) \f$
        !
        !> @date
        !> 08_08_2013 - initial version - J.L. Desmarais
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
        function d2gdy2_mattsson(
     $     nodes,i,j,proc,dy)
     $     result(var)

          implicit none

          real(rkind), dimension(:,:,:), intent(in) :: nodes
          integer(ikind)               , intent(in) :: i
          integer(ikind)               , intent(in) :: j
          procedure(get_primary_var)                :: proc
          real(rkind)                  , intent(in) :: dy
          real(rkind)                               :: var

          !TAG INLINE
          if(rkind.eq.8) then
             var = 0.5d0/(dy**2)*(
     $            + proc(nodes,i,j-2)
     $            - proc(nodes,i,j-1)
     $            - proc(nodes,i,j  )
     $            + proc(nodes,i,j+1)
     $            )
          else
             var = 1./(2.*dy**2)*(
     $            + proc(nodes,i,j-2)
     $            - proc(nodes,i,j-1)
     $            - proc(nodes,i,j  )
     $            + proc(nodes,i,j+1)
     $            )
          end if

        end function d2gdy2_mattsson


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ \frac{\partial^2 u}{\partial x \partial y}
        !> \bigg|_{i,j-\frac{1}{2}} = \frac{1}{2 \Delta x}
        !> (-\frac{\partial u}{\partial y}\bigg|_{i-1,j-\frac{1}{2}} +
        !> \frac{\partial u}{\partial y}\bigg|_{i+1,j-\frac{1}{2}}) \f$
        !
        !> @date
        !> 08_08_2013 - initial version - J.L. Desmarais
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
        function d2gdxdy_mattsson(
     $     nodes,i,j,proc,dx,dy)
     $     result(var)

          implicit none

          real(rkind), dimension(:,:,:), intent(in) :: nodes
          integer(ikind)               , intent(in) :: i
          integer(ikind)               , intent(in) :: j
          procedure(get_primary_var)                :: proc
          real(rkind)                  , intent(in) :: dx
          real(rkind)                  , intent(in) :: dy
          real(rkind)                               :: var

          if(rkind.eq.8) then

             !TAG INLINE
             var =(
     $              proc(nodes,i-1,j-1)
     $            - proc(nodes,i-1,j  )
     $            - proc(nodes,i+1,j-1)
     $            + proc(nodes,i+1,j  ))*
     $            0.5d0/(dx*dy)
          else
             var =(
     $              proc(nodes,i-1,j-1)
     $            - proc(nodes,i-1,j  )
     $            - proc(nodes,i+1,j-1)
     $            + proc(nodes,i+1,j  ))
     $            /(2*dx*dy)
          end if

        end function d2gdxdy_mattsson
        
      end module sd_operators_class
