      program test_bf_layer_prog

        use bf_layer_class               , only : bf_layer
        use bf_layer_update_grdpts_module, only : update_grdpts
        use parameters_constant          , only : N,S,E,W,N_E,N_W,S_E,S_W
        use parameters_kind              , only : rkind, ikind
        use parameters_input             , only : nx,ny,ne,bc_size

        implicit none

        type(bf_layer), dimension(8) :: table_bf_layer_tested

        real(rkind)   , dimension(nx,ny,ne) :: nodes
        integer(ikind), dimension(2,2)      :: alignment
        integer(ikind)                      :: i,j,k
        integer       , dimension(8)        :: bf_layer_loc
        character(2)  , dimension(8)        :: bf_layer_char
        character(len=21)                   :: sizes_filename, nodes_filename, grdid_filename
        integer(ikind), dimension(2,2)      :: border_changes
        logical       , dimension(4)        :: neighbors
        integer(ikind), dimension(2,2)      :: selected_grdpts
        integer       , dimension(2)        :: match_table

        integer, dimension(8,2,2) :: test_border_changes
        integer, dimension(8,2,2) :: test_selected_grdpts

        call srand(10)

        do k=1, ne
           do j=1, ny
              do i=1, nx
                 nodes(i,j,k) = RAND() !(k-1)*1000 + (j-1)*100 + (i-1)
              end do
           end do
        end do

        !print the nodes
        call print_sizes(nodes,'interior_sizes.dat')
        call print_nodes(nodes,'interior_nodes.dat')

        !buffer layers tested
        bf_layer_loc  = [N,S,E,W,N_E,N_W,S_E,S_W]
        bf_layer_char = ['N_','S_','E_','W_','NE','NW','SE','SW']

        !alignment
        alignment(1,1) = bc_size+3
        alignment(1,2) = bc_size+7
        alignment(2,1) = bc_size+3
        alignment(2,2) = bc_size+7

        !neighbors
        neighbors(1) = .true.
        neighbors(2) = .true.
        neighbors(3) = .true.
        neighbors(4) = .true.

        !border changes
        call ini_border_changes(test_border_changes)
        
        !selected grid points
        call ini_selected_grdpts(test_selected_grdpts)        


        !tests on all the buffer layers
        do i=1, size(bf_layer_loc,1)

           !test allocation
           write(sizes_filename,'(A2,''_sizes.dat'')') bf_layer_char(i)
           write(nodes_filename,'(A2,''_nodes.dat'')') bf_layer_char(i)
           write(grdid_filename,'(A2,''_grdpt_id.dat'')') bf_layer_char(i)
        
           call bf_layer_test_allocation(
     $               table_bf_layer_tested(i),
     $               bf_layer_loc(i),
     $               alignment,
     $               nodes,
     $               neighbors,
     $               sizes_filename,
     $               nodes_filename,
     $               grdid_filename)

           !test reallocation
           write(sizes_filename,'(A2,''_sizes2.dat'')') bf_layer_char(i)
           write(nodes_filename,'(A2,''_nodes2.dat'')') bf_layer_char(i)
           write(grdid_filename,'(A2,''_grdpt_id2.dat'')') bf_layer_char(i)

           border_changes(1,1) = test_border_changes(bf_layer_loc(i),1,1)
           border_changes(1,2) = test_border_changes(bf_layer_loc(i),1,2)
           border_changes(2,1) = test_border_changes(bf_layer_loc(i),2,1)
           border_changes(2,2) = test_border_changes(bf_layer_loc(i),2,2)

           call bf_layer_test_reallocation(
     $          table_bf_layer_tested(i),
     $          border_changes,
     $          match_table,
     $          sizes_filename,
     $          nodes_filename,
     $          grdid_filename)

           !test new interior gridpoints
           write(sizes_filename,'(A2,''_sizes3.dat'')') bf_layer_char(i)
           write(nodes_filename,'(A2,''_nodes3.dat'')') bf_layer_char(i)
           write(grdid_filename,'(A2,''_grdpt_id3.dat'')') bf_layer_char(i)
           
           selected_grdpts(1,1) = test_selected_grdpts(bf_layer_loc(i),1,1)
           selected_grdpts(1,2) = test_selected_grdpts(bf_layer_loc(i),1,2)
           selected_grdpts(2,1) = test_selected_grdpts(bf_layer_loc(i),2,1)
           selected_grdpts(2,2) = test_selected_grdpts(bf_layer_loc(i),2,2)

           call bf_layer_test_update_grdpts(
     $          table_bf_layer_tested(i),
     $          selected_grdpts,
     $          match_table,
     $          sizes_filename,
     $          nodes_filename,
     $          grdid_filename)
           
        end do


        contains

        subroutine print_nodes(nodes, filename)

          implicit none

          real(rkind), dimension(:,:,:), intent(in) :: nodes
          character(*)                 , intent(in) :: filename

          integer :: ios
          
          open(unit=1,
     $          file=filename,
     $          action="write", 
     $          status="unknown",
     $          form='unformatted',
     $          access='sequential',
     $          position='rewind',
     $          iostat=ios)

           if(ios.eq.0) then
              write(unit=1, iostat=ios) nodes
              close(unit=1)
           else
              stop 'file opening pb'
           end if

        end subroutine print_nodes


        subroutine print_sizes(nodes, filename)

          implicit none

          real(rkind), dimension(:,:,:), intent(in) :: nodes
          character(*)                 , intent(in) :: filename

          integer :: ios
          
          open(unit=1,
     $          file=filename,
     $          action="write", 
     $          status="unknown",
     $          form='unformatted',
     $          access='sequential',
     $          position='rewind',
     $          iostat=ios)

           if(ios.eq.0) then
              write(unit=1, iostat=ios) size(nodes,1),
     $             size(nodes,2),
     $             size(nodes,3)
              close(unit=1)
           else
              stop 'file opening pb'
           end if

        end subroutine print_sizes


        subroutine bf_layer_test_allocation(
     $     bf_layer_tested,
     $     bf_layer_loc,
     $     alignment,
     $     nodes,
     $     neighbors,
     $     sizes_filename,
     $     nodes_filename,
     $     grdid_filename)

          implicit none

          class(bf_layer)                  , intent(inout) :: bf_layer_tested
          integer                          , intent(in)    :: bf_layer_loc
          integer        , dimension(2,2)  , intent(in)    :: alignment
          logical        , dimension(4)    , intent(in)    :: neighbors
          real(rkind)    , dimension(:,:,:), intent(in)    :: nodes
          character(*)                     , intent(in)    :: sizes_filename
          character(*)                     , intent(in)    :: nodes_filename
          character(*)                     , intent(in)    :: grdid_filename

          call bf_layer_tested%ini([bf_layer_loc,1])
          call bf_layer_tested%allocate_bf_layer(
     $         alignment, nodes, neighbors)
          call bf_layer_tested%print_sizes(sizes_filename)
          call bf_layer_tested%print_nodes(nodes_filename)
          call bf_layer_tested%print_grdpts_id(grdid_filename)

        end subroutine bf_layer_test_allocation


        subroutine bf_layer_test_reallocation(
     $     bf_layer_tested,
     $     border_changes,
     $     match_table,
     $     sizes_filename,
     $     nodes_filename,
     $     grdid_filename)

          implicit none

          class(bf_layer)                  , intent(inout) :: bf_layer_tested
          integer     , dimension(2,2)     , intent(in)    :: border_changes
          integer     , dimension(2)       , intent(inout) :: match_table
          character(*)                     , intent(in)    :: sizes_filename
          character(*)                     , intent(in)    :: nodes_filename
          character(*)                     , intent(in)    :: grdid_filename

          call bf_layer_tested%reallocate_bf_layer(
     $         border_changes,
     $         match_table)
          call bf_layer_tested%print_sizes(sizes_filename)
          call bf_layer_tested%print_nodes(nodes_filename)
          call bf_layer_tested%print_grdpts_id(grdid_filename)
          
        end subroutine bf_layer_test_reallocation


        subroutine bf_layer_test_update_grdpts(
     $     bf_layer_tested,
     $     selected_grdpts,
     $     match_table,
     $     sizes_filename,
     $     nodes_filename,
     $     grdid_filename)

          implicit none

          class(bf_layer)                  , intent(inout) :: bf_layer_tested
          integer     , dimension(:,:)     , intent(in)    :: selected_grdpts
          integer     , dimension(2)       , intent(in)    :: match_table
          character(*)                     , intent(in)    :: sizes_filename
          character(*)                     , intent(in)    :: nodes_filename
          character(*)                     , intent(in)    :: grdid_filename

          call update_grdpts(bf_layer_tested,
     $         selected_grdpts,
     $         match_table)
          call bf_layer_tested%print_sizes(sizes_filename)
          call bf_layer_tested%print_nodes(nodes_filename)
          call bf_layer_tested%print_grdpts_id(grdid_filename)
          
        end subroutine bf_layer_test_update_grdpts


        subroutine ini_border_changes(border_changes)
        
          implicit none

          integer, dimension(:,:,:), intent(inout) :: border_changes

          border_changes(N,1,1) = 0
          border_changes(N,1,2) = 0
          border_changes(N,2,1) = 0
          border_changes(N,2,2) = 2

          border_changes(S,1,1) = -1
          border_changes(S,1,2) = 0
          border_changes(S,2,1) = -1
          border_changes(S,2,2) = 0

          border_changes(E,1,1) = 0
          border_changes(E,1,2) = 1
          border_changes(E,2,1) = 0
          border_changes(E,2,2) = 0

          border_changes(W,1,1) = -1
          border_changes(W,1,2) = 0
          border_changes(W,2,1) = 0
          border_changes(W,2,2) = 0

          border_changes(N_E,1,1) = 0
          border_changes(N_E,1,2) = 2
          border_changes(N_E,2,1) = 0
          border_changes(N_E,2,2) = 1

          border_changes(N_W,1,1) = -1
          border_changes(N_W,1,2) = 0
          border_changes(N_W,2,1) = 0
          border_changes(N_W,2,2) = 1

          border_changes(S_E,1,1) = 0
          border_changes(S_E,1,2) = 2
          border_changes(S_E,2,1) = -2
          border_changes(S_E,2,2) = 0

           border_changes(S_W,1,1) = -1
           border_changes(S_W,1,2) = 0
           border_changes(S_W,2,1) = -1
           border_changes(S_W,2,2) = 0

        end subroutine ini_border_changes

        subroutine ini_selected_grdpts(selected_grdpts)

          implicit none

          integer, dimension(:,:,:), intent(inout) :: selected_grdpts

          selected_grdpts(N,1,1) = 4
          selected_grdpts(N,1,2) = 3
          selected_grdpts(N,2,1) = 4
          selected_grdpts(N,2,2) = 4

          selected_grdpts(S,1,1) = 4
          selected_grdpts(S,1,2) = 3
          selected_grdpts(S,2,1) = 4
          selected_grdpts(S,2,2) = 2

          selected_grdpts(E,1,1) = 3
          selected_grdpts(E,1,2) = 3
          selected_grdpts(E,2,1) = 4
          selected_grdpts(E,2,2) = 3

          selected_grdpts(W,1,1) = 3
          selected_grdpts(W,1,2) = 3
          selected_grdpts(W,2,1) = 2
          selected_grdpts(W,2,2) = 4

          selected_grdpts(N_E,1,1) = 3
          selected_grdpts(N_E,1,2) = 3
          selected_grdpts(N_E,2,1) = 4
          selected_grdpts(N_E,2,2) = 4
          
          selected_grdpts(N_W,1,1) = 3
          selected_grdpts(N_W,1,2) = 3
          selected_grdpts(N_W,2,1) = 3
          selected_grdpts(N_W,2,2) = 4

          selected_grdpts(S_E,1,1) = 3
          selected_grdpts(S_E,1,2) = 3
          selected_grdpts(S_E,2,1) = 4
          selected_grdpts(S_E,2,2) = 2

          selected_grdpts(S_W,1,1) = 3
          selected_grdpts(S_W,1,2) = 3
          selected_grdpts(S_W,2,1) = 2
          selected_grdpts(S_W,2,2) = 2

        end subroutine ini_selected_grdpts

      end program test_bf_layer_prog
