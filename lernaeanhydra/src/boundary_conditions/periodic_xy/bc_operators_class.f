      !> @file
      !> class encapsulating subroutines to apply periodic boundary
      !> conditions at the edge of the computational domain
      !
      !> @author 
      !> Julien L. Desmarais
      !
      !> @brief
      !> class encapsulating subroutines to compute the 
      !> gridpoints at the edge of the computational domain
      !
      !> @date
      !> 23_09_2013 - initial version                   - J.L. Desmarais
      !-----------------------------------------------------------------
      module bc_operators_class

        use bc_abstract_class , only : bc_abstract
        use cg_operators_class, only : cg_operators
        use dim2d_eq_class    , only : dim2d_eq
        use field_class       , only : field
        use parameters_input  , only : nx,ny,ne,bc_size
        use parameters_kind   , only : rkind,ikind
        
        implicit none


        private
        public :: bc_operators


        !> @class bc_operators
        !> class encapsulating subroutines to apply
        !> periodic boundary conditions in the x and
        !> y directions at the edge of the computational
        !> domain
        !>
        !> @param period_x
        !> period along the x-direction
        !>
        !> @param period_y
        !> period along the y-direction
        !> 
        !> @param initialize
        !> initialize the period_x and period_y
        !> attributes of the boundary conditions
        !>
        !> @param apply_bc_on_nodes
        !> apply the periodic boundary conditions along the x and y
        !> directions at the edge of the computational domain
        !> for the field
        !>
        !> @param apply_bc_on_fluxes
        !> apply the periodic boundary conditions for the fluxes
        !---------------------------------------------------------------
        type, extends(bc_abstract) :: bc_operators

          integer(ikind) :: period_x
          integer(ikind) :: period_y

          contains

          procedure,   pass :: initialize
          procedure,   pass :: apply_bc_on_nodes
          procedure, nopass :: apply_bc_on_fluxes

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
        !> 24_09_2013 - initial version - J.L. Desmarais
        !
        !>@param this
        !> boundary conditions initialized
        !
        !>@param s
        !> spatial discretisation operators
        !
        !>@param p_model
        !> physical model to know the type of the main variables
        !--------------------------------------------------------------
        subroutine initialize(this, s, p_model)
        
          implicit none

          class(bc_operators), intent(inout) :: this
          type(cg_operators) , intent(in)    :: s
          type(dim2d_eq)     , intent(in)    :: p_model

          
          integer :: neq

          neq     = p_model%get_eq_nb()

          this%period_x = nx-2*bc_size
          this%period_y = ny-2*bc_size

        end subroutine initialize


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
        subroutine apply_bc_on_nodes(this,f_used,s)

          implicit none

          class(bc_operators), intent(in)    :: this
          class(field)       , intent(inout) :: f_used
          type(cg_operators) , intent(in)    :: s


          integer(ikind) :: i,j
          integer        :: k
          integer        :: period_x, period_y

          period_x = nx-2*bc_size 
          period_y = ny-2*bc_size

          !<compute the east and west boundary layers
          !>without the north and south corners
          do k=1, ne
             !DEC$ IVDEP
             do j=1+bc_size, ny-bc_size
                !DEC$ UNROLL(2)
                do i=1, bc_size

                   f_used%nodes(i,j,k)=
     $                  f_used%nodes(i+period_x,j,k)
                   f_used%nodes(i+period_x+bc_size,j,k)=
     $                  f_used%nodes(i+bc_size,j,k)
                   
                end do
             end do
          end do


          !<compute the south and north layers
          !>with the east and west corners
          do k=1, ne
             !DEC$ UNROLL(2)
             do j=1, bc_size
                !DEC$ IVDEP
                do i=1, nx

                   f_used%nodes(i,j,k)=
     $                  f_used%nodes(i,j+period_y,k)
                   f_used%nodes(i,j+period_y+bc_size,k)=
     $                  f_used%nodes(i,j+bc_size,k)

                end do
             end do
          end do

        end subroutine apply_bc_on_nodes


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> subroutine applying the boundary conditions
        !> on the fluxes along the x directions at the
        !> edge of the computational domain
        !
        !> @date
        !> 24_09_2013 - initial version - J.L. Desmarais
        !
        !>@param f_used
        !> object encapsulating the main variables
        !
        !>@param s
        !> space discretization operators
        !
        !>@param flux_x
        !> flux along the x-direction
        !
        !>@param flux_y
        !> flux along the y-direction
        !--------------------------------------------------------------
        subroutine apply_bc_on_fluxes(f_used,s,flux_x,flux_y)

          implicit none

          class(field)                      , intent(in)    :: f_used
          type(cg_operators)                , intent(in)    :: s
          real(rkind), dimension(nx+1,ny,ne), intent(inout) :: flux_x
          real(rkind), dimension(nx,ny+1,ne), intent(inout) :: flux_y

          real(rkind) :: node,flux

          stop 'periodic_xy: apply_bc_on_fluxes not implemented'

          node=f_used%nodes(1,1,1)
          flux=flux_x(1,1,1)
          flux=flux_y(1,1,1)

        end subroutine apply_bc_on_fluxes

      end module bc_operators_class