      !> @file
      !> class encapsulating subroutines for the space discretization
      !> using one-side operators in the x-direction with no grid point
      !> on the left side
      !
      !> @author 
      !> Julien L. Desmarais
      !
      !> @brief
      !> class encapsulating subroutines for the space discretisation
      !> using operators that are 1st order accurate in the x-direction
      !> with no grid point on the left side and operators that are 2nd
      !> order accurate in the y-direction
      !
      !> @date
      !> 29_07_2014 - Initial version - J.L. Desmarais
      !-----------------------------------------------------------------
      module sd_operators_y_oneside_R0_class

        use sd_operators_fd_module, only : gradient_y_y_oneside_R1,
     $                                     gradient_y_y_oneside_R0,
     $                                     gradient_x_interior,
     $                                     gradient_y_interior
        use interface_primary     , only : get_primary_var,
     $                                     get_secondary_var
        use parameters_kind       , only : ikind, rkind
        use sd_operators_class    , only : sd_operators

        implicit none

        private
        public :: sd_operators_y_oneside_R0


        !> @class sd_operators_y_oneside_R0
        !> class encapsulating 
        !
        !> @param get_bc_size
        !> get the boundary layer size
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
        type, extends(sd_operators) :: sd_operators_y_oneside_R0

          contains

          procedure, nopass :: dfdx_nl     => dfdx_y_oneside_R0_nl
          procedure, nopass :: dfdy        => dfdy_y_oneside_R0
          procedure, nopass :: d2fdy2      => d2fdy2_y_oneside_R0
          procedure, nopass :: d2fdxdy     => d2fdxdy_y_oneside_R0

          procedure, nopass :: g           => g_y_oneside_R0
          procedure, nopass :: dgdx        => dgdx_y_oneside_R0
          procedure, nopass :: dgdy        => dgdy_y_oneside_R0
          procedure, nopass :: dgdy_nl     => dgdy_y_oneside_R0_nl
          procedure, nopass :: d2gdx2      => d2gdx2_y_oneside_R0
          procedure, nopass :: d2gdy2      => d2gdy2_y_oneside_R0
          procedure, nopass :: d2gdxdy     => d2gdxdy_y_oneside_R0

        end type sd_operators_y_oneside_R0

        contains

        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ \frac{\partial u}{\partial x}\bigg|_{i-\frac{1}{2}
        !> ,j}= \frac{1}{\Delta x}(-u_{i-1,j}+u_{i,j})\f$
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
        function dfdx_y_oneside_R0_nl(
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
             var = 1.0d0/dx*(
     $            -proc(nodes,i-1,j,dx,dy,gradient_x_interior,gradient_y_y_oneside_R0)
     $            +proc(nodes,i  ,j,dx,dy,gradient_x_interior,gradient_y_y_oneside_R0)
     $            )
          else
             var = 1./dx*(
     $            -proc(nodes,i-1,j,dx,dy,gradient_x_interior,gradient_y_y_oneside_R0)
     $            +proc(nodes,i  ,j,dx,dy,gradient_x_interior,gradient_y_y_oneside_R0)
     $            )
          end if

        end function dfdx_y_oneside_R0_nl


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ \frac{\partial u}{\partial y}|_{i-\frac{1}{2}
        !> ,j}= \frac{1}{\Delta y} (-u_{i-\frac{1}{2},j-1}
        !> +u_{i-\frac{1}{2},j})\f$
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
        function dfdy_y_oneside_R0(
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

             var = 1.0d0/(12.0d0*dy)*(
     $            +       proc(nodes,i-2,j-1)
     $            - 7.0d0*proc(nodes,i-1,j-1)
     $            - 7.0d0*proc(nodes,i  ,j-1)
     $            +       proc(nodes,i+1,j-1)
     $            -       proc(nodes,i-2,j  )
     $            + 7.0d0*proc(nodes,i-1,j  )
     $            + 7.0d0*proc(nodes,i  ,j  )
     $            -       proc(nodes,i+1,j  ))
          else

             var = 1.0/(12.0*dy)*(
     $            +     proc(nodes,i-2,j-1)
     $            - 7.0*proc(nodes,i-1,j-1)
     $            - 7.0*proc(nodes,i  ,j-1)
     $            +     proc(nodes,i+1,j-1)
     $            -     proc(nodes,i-2,j  )
     $            + 7.0*proc(nodes,i-1,j  )
     $            + 7.0*proc(nodes,i  ,j  )
     $            -     proc(nodes,i+1,j  ))
          end if

        end function dfdy_y_oneside_R0


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ \frac{\partial^2 u}{\partial y^2}
        !> \bigg|_{i-\frac{1}{2},j}= \frac{1}{{\Delta y}^2}(
        !> u_{i-\frac{1}{2},j-2}- 2 u_{i-\frac{1}{2},j-1}
        !> + u_{i-\frac{1}{2},j}) \f$
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
        function d2fdy2_y_oneside_R0(
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
             var = 1.0d0/(12.d0*dy**2) * (
     $            -       proc(nodes,i-2,j-2)
     $            + 7.0d0*proc(nodes,i-1,j-2)
     $            + 7.0d0*proc(nodes,i  ,j-2)
     $            -       proc(nodes,i+1,j-2)
     $            - 2.0d0*(
     $               -       proc(nodes,i-2,j-1)
     $               + 7.0d0*proc(nodes,i-1,j-1)
     $               + 7.0d0*proc(nodes,i  ,j-1)
     $               -       proc(nodes,i+1,j-1)
     $            )
     $            -       proc(nodes,i-2,j)
     $            + 7.0d0*proc(nodes,i-1,j)
     $            + 7.0d0*proc(nodes,i  ,j)
     $            -       proc(nodes,i+1,j)
     $            )
          else

             var = 1.0/(12.0*dy**2) * (
     $            -     proc(nodes,i-2,j-2)
     $            + 7.0*proc(nodes,i-1,j-2)
     $            + 7.0*proc(nodes,i  ,j-2)
     $            -     proc(nodes,i+1,j-2)
     $            - 2.0*(
     $               -     proc(nodes,i-2,j-1)
     $               + 7.0*proc(nodes,i-1,j-1)
     $               + 7.0*proc(nodes,i  ,j-1)
     $               -     proc(nodes,i+1,j-1)
     $            )
     $            -     proc(nodes,i-2,j)
     $            + 7.0*proc(nodes,i-1,j)
     $            + 7.0*proc(nodes,i  ,j)
     $            -     proc(nodes,i+1,j)
     $            )
          end if

        end function d2fdy2_y_oneside_R0


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ \frac{\partial^2 u}{\partial x \partial y}
        !> \bigg|_{i-\frac{1}{2},j} = \frac{1}{\Delta y}
        !> (-\frac{\partial u}{\partial x}\bigg|_{i+\frac{1}{2},j-1} +
        !> \frac{\partial u}{\partial x}\bigg|_{i+\frac{1}{2},j}) \f$
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
        !>@param dx
        !> grid step along the x-axis
        !
        !>@param dy
        !> grid step along the y-axis
        !
        !>@param var
        !> data evaluated at [i,j]
        !---------------------------------------------------------------
        function d2fdxdy_y_oneside_R0(
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
     $            - proc(nodes,i  ,j-1)
     $            - proc(nodes,i-1,j  )
     $            + proc(nodes,i  ,j  ))*
     $            1.0d0/(dx*dy)
          else
             var =(
     $              proc(nodes,i-1,j-1)
     $            - proc(nodes,i  ,j-1)
     $            - proc(nodes,i-1,j  )
     $            + proc(nodes,i  ,j  ))*
     $            1.0/(dx*dy)
          end if

        end function d2fdxdy_y_oneside_R0

        
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ u_{i,j-\frac{1}{2}}=
        !> \frac{1}{12} \left( - u_{i,j-4} + u_{i,j-3}
        !> -5 u_{i,j-2} + 17 u_{i,j-1} \right) \f$
        !
        !> @date
        !> 30_07_2014 - initial version  - J.L. Desmarais
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
        function g_y_oneside_R0(nodes,i,j,proc) result(var)

          implicit none

          real(rkind), dimension(:,:,:), intent(in) :: nodes
          integer(ikind)               , intent(in) :: i
          integer(ikind)               , intent(in) :: j
          procedure(get_primary_var)                :: proc
          real(rkind)                               :: var

          if(rkind.eq.8) then

             !TAG INLINE
             var = 1.0d0/12.0d0*(
     $            -       proc(nodes,i,j-4)
     $            +       proc(nodes,i,j-3)
     $            - 5.0d0*proc(nodes,i,j-2)
     $            +17.0d0*proc(nodes,i,j-1))
          else
             var = 1.0/12.0*(
     $            -     proc(nodes,i,j-4)
     $            +     proc(nodes,i,j-3)
     $            - 5.0*proc(nodes,i,j-2)
     $            +17.0*proc(nodes,i,j-1))
          end if

        end function g_y_oneside_R0


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ \frac{\partial u}{\partial y} \bigg|_{i
        !> ,j-\frac{1}{2}} = \frac{1}{\Delta y}(u_{i,j-3} - 3 u_{i,j-2} +
        !> 2 u_{i,j-1}) \f$
        !
        !> @date
        !> 30_07_2014 - initial version  - J.L. Desmarais
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
        function dgdy_y_oneside_R0(nodes,i,j,proc,dy) result(var)

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
     $                   proc(nodes,i,j-3)
     $            -3.0d0*proc(nodes,i,j-2)
     $            +2.0d0*proc(nodes,i,j-1))
          else
             var = 1.0/dy*(
     $                 proc(nodes,i,j-3)
     $            -3.0*proc(nodes,i,j-2)
     $            +2.0*proc(nodes,i,j-1))
          end if

        end function dgdy_y_oneside_R0


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ \frac{\partial u}{\partial y}\bigg|
        !> _{i,j-\frac{1}{2}}= \frac{1}{2 \Delta x}
        !> (-u_{i-1,j-\frac{1}{2}}+u_{i+1,j-\frac{1}{2}})\f$
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
        !>@param dx
        !> grid step along the x-axis
        !
        !>@param var
        !> data evaluated at [i,j]
        !---------------------------------------------------------------
        function dgdx_y_oneside_R0(nodes,i,j,proc,dx)
     $     result(var)

          implicit none

          real(rkind), dimension(:,:,:), intent(in) :: nodes
          integer(ikind)               , intent(in) :: i
          integer(ikind)               , intent(in) :: j
          real(rkind)                  , intent(in) :: dx
          procedure(get_primary_var)                :: proc
          real(rkind)                               :: var

          !TAG INLINE
          if(rkind.eq.8) then
             !TAG INLINE
             var = 1.0d0/(24.0d0*dx)*(
     $            +       proc(nodes,i-1,j-4)
     $            -       proc(nodes,i-1,j-3)
     $            + 5.0d0*proc(nodes,i-1,j-2)
     $            -17.0d0*proc(nodes,i-1,j-1)
     $            -       proc(nodes,i+1,j-4)
     $            +       proc(nodes,i+1,j-3)
     $            - 5.0d0*proc(nodes,i+1,j-2)
     $            +17.0d0*proc(nodes,i+1,j-1))
          else
             var = 1.0/(24.0*dx)*(
     $            +     proc(nodes,i-1,j-4)
     $            -     proc(nodes,i-1,j-3)
     $            + 5.0*proc(nodes,i-1,j-2)
     $            -17.0*proc(nodes,i-1,j-1)
     $            -     proc(nodes,i+1,j-4)
     $            +     proc(nodes,i+1,j-3)
     $            - 5.0*proc(nodes,i+1,j-2)
     $            +17.0*proc(nodes,i+1,j-1))
          end if

        end function dgdx_y_oneside_R0


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ \frac{\partial u}{\partial y} \bigg|_{i
        !> ,j-\frac{1}{2}} = \frac{1}{\Delta y}(u_{i,j-3} - 3 u_{i,j-2} +
        !>  2 u_{i,j-1}) \f$
        !
        !> @date
        !> 30_07_2014 - initial version  - J.L. Desmarais
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
        function dgdy_y_oneside_R0_nl(nodes,i,j,proc,dx,dy) result(var)

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
     $                   proc(nodes,i,j-3,dx,dy,gradient_x_interior,gradient_y_interior    )
     $            -3.0d0*proc(nodes,i,j-2,dx,dy,gradient_x_interior,gradient_y_y_oneside_R1)
     $            +2.0d0*proc(nodes,i,j-1,dx,dy,gradient_x_interior,gradient_y_y_oneside_R0))
          else
             var = 1.0/dy*(
     $                 proc(nodes,i,j-3,dx,dy,gradient_x_interior,gradient_y_interior    )
     $            -3.0*proc(nodes,i,j-2,dx,dy,gradient_x_interior,gradient_y_y_oneside_R1)
     $            +2.0*proc(nodes,i,j-1,dx,dy,gradient_x_interior,gradient_y_y_oneside_R0))
          end if

        end function dgdy_y_oneside_R0_nl


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ \frac{\partial^2 u}{\partial y^2}\bigg|
        !> _{i,j-\frac{1}{2}}= \frac{1}{2 {\Delta y}^2}(- 2 u_{i,j-5} +
        !> 5 u_{i,j-4} - u_{i,j-3} - 5 u_{i,j-2} + 3 u_{i,j-1}) \f$
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
        function d2gdy2_y_oneside_R0(
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
     $            -2.0d0*proc(nodes,i,j-5)
     $            +5.0d0*proc(nodes,i,j-4)
     $            -      proc(nodes,i,j-3)
     $            -5.0d0*proc(nodes,i,j-2)
     $            +3.0d0*proc(nodes,i,j-1)
     $            )
          else
             var = 0.5/(dy**2)*(
     $            -2.0*proc(nodes,i,j-5)
     $            +5.0*proc(nodes,i,j-4)
     $            -    proc(nodes,i,j-3)
     $            -5.0*proc(nodes,i,j-2)
     $            +3.0*proc(nodes,i,j-1)
     $            )
          end if

        end function d2gdy2_y_oneside_R0


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ \frac{\partial^2 u}{\partial x^2}
        !> \bigg|_{i,j-\frac{1}{2}}= \frac{1}{{\Delta x}^2}(
        !> u_{i-1,j-\frac{1}{2}} - 2 u_{i,j-\frac{1}{2}} +
        !> u_{i+1,j-\frac{1}{2}}) \f$
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
        !>@param dx
        !> grid step along the x-axis
        !
        !>@param var
        !> data evaluated at [i,j]
        !---------------------------------------------------------------
        function d2gdx2_y_oneside_R0(
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
             var = (1.0d0/(12.0d0*dx**2))*
     $            (
     $            -       proc(nodes,i-1,j-4)
     $            +       proc(nodes,i-1,j-3)
     $            - 5.0d0*proc(nodes,i-1,j-2)
     $            + 17.d0*proc(nodes,i-1,j-1)
     $            -2.0d0*(
     $               -       proc(nodes,i,j-4)
     $               +       proc(nodes,i,j-3)
     $               - 5.0d0*proc(nodes,i,j-2)
     $               + 17.d0*proc(nodes,i,j-1)
     $            )
     $            -       proc(nodes,i+1,j-4)
     $            +       proc(nodes,i+1,j-3)
     $            - 5.0d0*proc(nodes,i+1,j-2)
     $            + 17.d0*proc(nodes,i+1,j-1)
     $            )
          else

             var = (1.0/(12.0*dx**2))*
     $            (
     $            -     proc(nodes,i-1,j-4)
     $            +     proc(nodes,i-1,j-3)
     $            - 5.0*proc(nodes,i-1,j-2)
     $            + 17.*proc(nodes,i-1,j-1)
     $            -2.0*(
     $               -     proc(nodes,i,j-4)
     $               +     proc(nodes,i,j-3)
     $               - 5.0*proc(nodes,i,j-2)
     $               + 17.*proc(nodes,i,j-1)
     $            )
     $            -     proc(nodes,i+1,j-4)
     $            +     proc(nodes,i+1,j-3)
     $            - 5.0*proc(nodes,i+1,j-2)
     $            + 17.*proc(nodes,i+1,j-1)
     $            )
          end if

        end function d2gdx2_y_oneside_R0


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
        !>@param dx
        !> grid step along the x-axis
        !
        !>@param dy
        !> grid step along the y-axis
        !
        !>@param var
        !> data evaluated at [i,j]
        !---------------------------------------------------------------
        function d2gdxdy_y_oneside_R0(
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
             var =(     - proc(nodes,i-1,j-3)
     $            + 3.0d0*proc(nodes,i-1,j-2)
     $            - 2.0d0*proc(nodes,i-1,j-1)
     $                  + proc(nodes,i+1,j-3)
     $            - 3.0d0*proc(nodes,i+1,j-2)
     $            + 2.0d0*proc(nodes,i+1,j-1))*
     $            0.5d0/(dy*dx)
          else
             var =(   - proc(nodes,i-1,j-3)
     $            + 3.0*proc(nodes,i-1,j-2)
     $            - 2.0*proc(nodes,i-1,j-1)
     $                + proc(nodes,i+1,j-3)
     $            - 3.0*proc(nodes,i+1,j-2)
     $            + 2.0*proc(nodes,i+1,j-1))*
     $            0.5/(dy*dx)
          end if

        end function d2gdxdy_y_oneside_R0
        
      end module sd_operators_y_oneside_R0_class
