      !> @file
      !> abstract class encapsulating subroutines to compute
      !> the time derivatives of the main variables from the
      !> governing equations using the space discretisation
      !> operators and the physical model
      !
      !> @author 
      !> Julien L. Desmarais
      !
      !> @brief
      !> class encapsulating subroutines to compute
      !> the time derivatives of the main variables
      !> in the governing equations
      !
      !> @date
      !> 13_08_2013 - initial version               - J.L. Desmarais
      !> 14_07_2014 - interface for erymanthianboar - J.L. Desmarais
      !-----------------------------------------------------------------
      module td_operators_abstract_class

        use bc_operators_class, only : bc_operators
        use sd_operators_class, only : sd_operators
        use pmodel_eq_class   , only : pmodel_eq
        use field_class       , only : field
        use parameters_input  , only : nx,ny,ne
        use parameters_kind   , only : rkind

        implicit none


        private
        public :: td_operators_abstract


        !>@class td_operators_abstract
        !> abstract class encapsulating operators to compute
        !> the time derivatives of the main variables from 
        !> the governing equations
        !>
        !>@param compute_time_dev
        !> compute the time derivatives
        !
        !>@param compute_time_dev_nopt
        !> compute the time derivatives without array dimension
        !> optimizations
        !---------------------------------------------------------------
        type, abstract :: td_operators_abstract

          contains
          procedure(time_proc)     , nopass, deferred :: compute_time_dev
          procedure(time_proc_nopt), nopass, deferred :: compute_time_dev_nopt

        end type td_operators_abstract


        abstract interface

          !> @author
          !> Julien L. Desmarais
          !
          !> @brief
          !> interface to compute the time derivatives using the
          !> space discretisation operators and the physical model
          !
          !> @date
          !> 13_08_2013 - initial version - J.L. Desmarais
          !
          !>@param nodes
          !> array with the grid point data
          !
          !>@param dx
          !> grid step along the x-axis
          !
          !>@param dy
          !> grid step along the y-axis
          !
          !>@param s
          !> space discretization operators
          !
          !>@param p_model
          !> physical model
          !
          !>@param bc_used
          !> boundary conditions
          !
          !>@param time_dev
          !> time derivatives
          !--------------------------------------------------------------
          function time_proc(nodes,dx,dy,s,p_model,bc_used)
     $       result(time_dev)

            import bc_operators
            import cg_operators
            import field
            import dim2d_eq
            import rkind
            import nx,ny,ne

            real(rkind), dimension(nx,ny,ne), intent(in)   :: nodes
            real(rkind)                     , intent(in)   :: dx
            real(rkind)                     , intent(in)   :: dy
            type(sd_operators)              , intent(in)   :: s
            type(pmodel_eq)                 , intent(in)   :: p_model
            type(bc_operators)              , intent(in)   :: bc_used
            real(rkind), dimension(nx,ny,ne)               :: time_dev

          end function time_proc


          !> @author
          !> Julien L. Desmarais
          !
          !> @brief
          !> interface to compute the time derivatives using the
          !> space discretisation operators and the physical model
          !> without optimizations for the size of the arrays passed
          !> as arguments
          !
          !> @date
          !> 14_07_2014 - initial version - J.L. Desmarais
          !
          !>@param nodes
          !> array with the grid point data
          !
          !>@param dx
          !> grid step along the x-axis
          !
          !>@param dy
          !> grid step along the y-axis
          !
          !>@param s
          !> space discretization operators
          !
          !>@param p_model
          !> physical model
          !
          !>@param bc_used
          !> boundary conditions
          !
          !>@param time_dev
          !> time derivatives
          !--------------------------------------------------------------
          subroutine time_proc_nopt(
     $     nodes,dx,dy,s,p_model,bc_used,
     $     time_dev)

            import bc_operators
            import cg_operators
            import field
            import dim2d_eq
            import rkind

            real(rkind), dimension(:,:,:), intent(in)   :: nodes
            real(rkind)                  , intent(in)   :: dx
            real(rkind)                  , intent(in)   :: dy
            type(sd_operators)           , intent(in)   :: s
            type(pmodel_eq)              , intent(in)   :: p_model
            type(bc_operators)           , intent(in)   :: bc_used
            real(rkind), dimension(:,:,:)               :: time_dev

          end subroutine time_proc_nopt

        end interface

      end module td_operators_abstract_class