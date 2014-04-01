      !> @file
      !> class encapsulating subroutines to compute 
      !> boundary layers in case of reflection xy boundary
      !> conditions on a parallel distributed system
      !
      !> @author 
      !> Julien L. Desmarais
      !
      !> @brief
      !> class encapsulating subroutines to compute 
      !> boundary layers in case of reflection xy boundary
      !> conditions on a parallel distributed system
      !
      !> @date
      ! 26_08_2013  - initial version - J.L. Desmarais
      !-----------------------------------------------------------------
      module bc_operators_par_class

        use bc_abstract_par_class, only : bc_abstract_par
        use cg_operators_class   , only : cg_operators
        use dim2d_eq_class       , only : dim2d_eq
        use field_par_class      , only : field_par
                                 
        use parameters_constant  , only :
     $     x_direction,
     $     y_direction,
     $     only_compute_proc,
     $     compute_and_exchange_proc,
     $     only_exchange_proc
        use parameters_input     , only : nx,ny,ne
        use parameters_kind      , only : ikind,rkind

        use reflection_xy_par_module, only : 
     $     only_compute_along_x, only_compute_along_y,
     $     only_exchange,
     $     compute_and_exchange_along_x, compute_and_exchange_along_y


        implicit none

        private
        public  :: bc_operators_par

        !> @class bc_operators_par
        !> class encapsulating subroutines to compute 
        !> boundary layers in case of reflection xy boundary
        !> conditions on a parallel distributed system
        !>
        !> @param apply_bc_on_nodes
        !> subroutine applying the reflection xy boundary
        !> conditions on the grid points
        !>
        !> @param apply_bc_on_fluxes
        !> subroutine applying the reflection xy boundary
        !> conditions on the fluxes
        !---------------------------------------------------------------
        type, extends(bc_abstract_par) :: bc_operators_par

          contains

          procedure, pass :: apply_bc_on_nodes
          procedure, pass :: apply_bc_on_fluxes

        end type bc_operators_par


        contains


          !> @author
          !> Julien L. Desmarais
          !
          !> @brief
          !> subroutine to compute the boundary layers using the
          !> reflection boundary conditions in a distributed
          !> memory system
          !
          !> @date
          !> 26_08_2013 - initial version - J.L. Desmarais
          !
          !>@param f_used
          !> object encapsulating the main variables
          !
          !>@param nodes
          !> main variables of the governing equations
          !
          !>@param s_op
          !> space discretization operators
          !
          !>@param p_model
          !> physical model
          !--------------------------------------------------------------
          subroutine apply_bc_on_nodes(
     $       this, f_used, nodes, s_op, p_model)

            implicit none
            
            class(bc_operators_par)         , intent(in)    :: this
            type(field_par)                 , intent(inout) :: f_used
            real(rkind), dimension(nx,ny,ne), intent(inout) :: nodes
            type(cg_operators)              , intent(in)    :: s_op
            type(dim2d_eq)                  , intent(in)    :: p_model
            
            
            !compute the boundary layers along the x-direction
            select case(this%proc_x_choice)
            
              case(only_compute_proc)
                 call only_compute_along_x(nodes,p_model)
            
              case(compute_and_exchange_proc)
                 call compute_and_exchange_along_x(
     $                this,f_used,nodes,p_model,
     $                this%exchange_id(x_direction))
            
              case(only_exchange_proc)
                 call only_exchange(this,f_used,nodes,x_direction)
                 
            end select
            
            
            !compute the boundary layers along the y-direction
            select case(this%proc_y_choice)
            
              case(only_compute_proc)
                 call only_compute_along_y(nodes,p_model)
            
              case(compute_and_exchange_proc)
                 call compute_and_exchange_along_y(
     $                this,f_used,nodes,p_model,
     $                this%exchange_id(y_direction))
            
              case(only_exchange_proc)
                 call only_exchange(this,f_used,nodes,y_direction)
                 
            end select

          end subroutine apply_bc_on_nodes


          !> @author
          !> Julien L. Desmarais
          !
          !> @brief
          !> subroutine to compute the reflection boundary layers
          !> of the fluxes in a distributed memory system
          !
          !> @date
          !> 25_09_2013 - initial version - J.L. Desmarais
          !
          !>@param f_used
          !> object encapsulating the main variables
          !
          !>@param s_op
          !> space discretization operators
          !
          !>@param p_model
          !> physical model
          !
          !>@param flux_x
          !> fluxes along the x-direction
          !
          !>@param flux_y
          !> fluxes along the y-direction
          !--------------------------------------------------------------
          subroutine apply_bc_on_fluxes(
     $       this, f_used, s_op,
     $       flux_x, flux_y)

            implicit none

            class(bc_operators_par)           , intent(in)    :: this
            type(field_par)                   , intent(in)    :: f_used
            type(cg_operators)                , intent(in)    :: s_op
            real(rkind), dimension(nx+1,ny,ne), intent(inout) :: flux_x
            real(rkind), dimension(nx,ny+1,ne), intent(inout) :: flux_y


            !these variables are only used to make sure that there
            !are no warning about unused subroutine arguments
            !as the subroutine is not meant to be used for reflection
            !boundary conditions
            integer :: proc_choice
            real(rkind) :: node, flux
            
            stop 'reflection_xy_par: apply_bc_on_fluxes not implemented'

            proc_choice=this%proc_x_choice
            node=f_used%nodes(1,1,1)
            flux=flux_x(1,1,1)
            flux=flux_y(1,1,1)

          end subroutine apply_bc_on_fluxes

      end module bc_operators_par_class