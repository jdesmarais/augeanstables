      !> @file
      !> module encapsulating the subroutines needed to reallocate 
      !> the attributes of a bf_layer object
      !
      !> @author
      !> Julien L. Desmarais
      !
      !> @brief
      !> module encapsulating the subroutines needed to reallocate 
      !> the attributes of a bf_layer object
      !> \image html  bf_layer_reallocate_module.png
      !> \image latex bf_layer_reallocate_module.eps
      !
      !> @warning
      !> the x_map and y_map are not correcly initialized if the
      !> buffer layer does not have any grid point in common with
      !> the interior domain
      !
      !> @date
      ! 27_06_2014 - documentation update   - J.L. Desmarais
      ! 24_10_2014 - adding x_map and y_map - J.L. Desmarais
      !-----------------------------------------------------------------
      module bf_layer_reallocate_module

        use bf_layer_allocate_module, only :
     $       get_additional_blocks_N,
     $       get_additional_blocks_S,
     $       get_additional_blocks_E,
     $       get_additional_blocks_W,
     $       get_match_interior

        use parameters_bf_layer, only :
     $       interior_pt,
     $       bc_interior_pt,
     $       bc_pt,
     $       no_pt,
     $       align_N,
     $       align_S,
     $       align_E,
     $       align_W

        use parameters_constant, only :
     $       x_direction,
     $       y_direction

        use parameters_input, only :
     $       nx,ny,ne,
     $       bc_size

        use parameters_kind, only :
     $       ikind,
     $       rkind

        implicit none

        private
        public :: reallocate_bf_layer_N,
     $            reallocate_bf_layer_S,
     $            reallocate_bf_layer_E,
     $            reallocate_bf_layer_W

        contains

        
        subroutine reallocate_bf_layer_N(
     $       bf_x_map, interior_x_map,
     $       bf_y_map, interior_y_map,
     $       bf_nodes, interior_nodes,
     $       bf_grdpts_id,
     $       bf_alignment, final_alignment)

          implicit none
          
          real(rkind)   , dimension(:)       , allocatable, intent(inout) :: bf_x_map
          real(rkind)   , dimension(nx)                   , intent(in)    :: interior_x_map
          real(rkind)   , dimension(:)       , allocatable, intent(inout) :: bf_y_map
          real(rkind)   , dimension(ny)                   , intent(in)    :: interior_y_map
          real(rkind)   , dimension(:,:,:)   , allocatable, intent(inout) :: bf_nodes
          real(rkind)   , dimension(nx,ny,ne)             , intent(in)    :: interior_nodes
          integer       , dimension(:,:)     , allocatable, intent(inout) :: bf_grdpts_id
          integer(ikind), dimension(2,2)                  , intent(inout) :: bf_alignment
          integer(ikind), dimension(2,2)                  , intent(in)    :: final_alignment


          integer(ikind), dimension(2,2) :: border_changes
          logical                        :: reallocation_needed
          integer(ikind)                 :: i_match, i_max, j_max
          integer(ikind)                 :: i_min1, i_min3, i_min4, i_min6
          integer(ikind)                 :: outside_i_max1, outside_i_max2
          integer(ikind)                 :: interior_i_max1, interior_i_max2
          integer(ikind)                 :: interior_i_max11, interior_i_max13
          integer(ikind)                 :: interior_i_max21, interior_i_max23
          integer(ikind)                 :: i_min11, i_min13, i_min21, i_min23
          integer(ikind), dimension(2)   :: new_sizes



          call get_border_changes_and_new_alignment_N(
     $         border_changes, final_alignment, bf_alignment)


          reallocation_needed = is_reallocation_needed(border_changes)


          if(reallocation_needed) then


             call get_match(
     $            x_direction,
     $            bf_alignment, border_changes,
     $            size(bf_nodes,1), size(bf_nodes,2),
     $            i_min1, i_min3, i_min4, i_min6,
     $            i_match, i_max, j_max,
     $            outside_i_max1, outside_i_max2,
     $            interior_i_max1, interior_i_max2,
     $            interior_i_max11, interior_i_max13,
     $            i_min11, i_min13,
     $            interior_i_max21, interior_i_max23,
     $            i_min21, i_min23)

             new_sizes = get_new_sizes(border_changes, size(bf_nodes,1), size(bf_nodes,2))

             call reallocate_nodes_N(
     $            bf_x_map, interior_x_map,
     $            bf_y_map, interior_y_map,
     $            bf_nodes, interior_nodes,
     $            i_min1, i_min3, i_min4,
     $            i_match, i_max, j_max,
     $            interior_i_max1, interior_i_max2,
     $            bf_alignment, new_sizes)

             call reallocate_grdpts_id_N(
     $            bf_grdpts_id,
     $            i_min1, i_min3, i_min4, i_min6,
     $            i_match, i_max, j_max,
     $            outside_i_max1, outside_i_max2,
     $            interior_i_max1, interior_i_max2,
     $            interior_i_max11, interior_i_max13,
     $            i_min11, i_min13,
     $            interior_i_max21, interior_i_max23,
     $            i_min21, i_min23,
     $            bf_alignment ,new_sizes)

          end if

        end subroutine reallocate_bf_layer_N


        subroutine reallocate_bf_layer_S(
     $     bf_x_map, interior_x_map,
     $     bf_y_map, interior_y_map,
     $     bf_nodes, interior_nodes,
     $     bf_grdpts_id,
     $     bf_alignment, final_alignment)

          implicit none
          
          real(rkind)   , dimension(:)       , allocatable, intent(inout) :: bf_x_map
          real(rkind)   , dimension(nx)                   , intent(in)    :: interior_x_map
          real(rkind)   , dimension(:)       , allocatable, intent(inout) :: bf_y_map
          real(rkind)   , dimension(ny)                   , intent(in)    :: interior_y_map
          real(rkind)   , dimension(:,:,:)   , allocatable, intent(inout) :: bf_nodes
          real(rkind)   , dimension(nx,ny,ne)             , intent(in)    :: interior_nodes
          integer       , dimension(:,:)     , allocatable, intent(inout) :: bf_grdpts_id
          integer(ikind), dimension(2,2)                  , intent(inout) :: bf_alignment
          integer(ikind), dimension(2,2)                  , intent(in)    :: final_alignment


          integer(ikind), dimension(2,2) :: border_changes
          logical                        :: reallocation_needed
          integer(ikind)                 :: i_match, i_max, j_max
          integer(ikind)                 :: i_min1, i_min3, i_min4, i_min6
          integer(ikind)                 :: outside_i_max1, outside_i_max2
          integer(ikind)                 :: interior_i_max1, interior_i_max2
          integer(ikind)                 :: interior_i_max11, interior_i_max13
          integer(ikind)                 :: interior_i_max21, interior_i_max23
          integer(ikind)                 :: i_min11, i_min13, i_min21, i_min23
          integer(ikind), dimension(2)   :: new_sizes

          
          call get_border_changes_and_new_alignment_S(
     $         border_changes, final_alignment, bf_alignment)


          reallocation_needed = is_reallocation_needed(border_changes)


          if(reallocation_needed) then

             call get_match(
     $            x_direction,
     $            bf_alignment, border_changes,
     $            size(bf_nodes,1), size(bf_nodes,2),
     $            i_min1, i_min3, i_min4, i_min6,
     $            i_match, i_max, j_max,
     $            outside_i_max1, outside_i_max2,
     $            interior_i_max1, interior_i_max2,
     $            interior_i_max11, interior_i_max13,
     $            i_min11, i_min13,
     $            interior_i_max21, interior_i_max23,
     $            i_min21, i_min23)

             new_sizes = get_new_sizes(border_changes, size(bf_nodes,1), size(bf_nodes,2))

             call reallocate_nodes_S(
     $            bf_x_map, interior_x_map,
     $            bf_y_map, interior_y_map,
     $            bf_nodes, interior_nodes,
     $            i_min1, i_min3, i_min4,
     $            i_match, i_max,
     $            interior_i_max1, interior_i_max2,
     $            bf_alignment, new_sizes)

             call reallocate_grdpts_id_S(
     $            bf_grdpts_id,
     $            i_min1, i_min3, i_min4, i_min6,
     $            i_match, i_max, j_max,
     $            outside_i_max1, outside_i_max2,
     $            interior_i_max1, interior_i_max2,
     $            interior_i_max11, interior_i_max13,
     $            i_min11, i_min13,
     $            interior_i_max21, interior_i_max23,
     $            i_min21, i_min23,
     $            bf_alignment ,new_sizes)

          end if

        end subroutine reallocate_bf_layer_S


        subroutine reallocate_bf_layer_E(
     $     bf_x_map, interior_x_map,
     $     bf_y_map, interior_y_map,
     $     bf_nodes, interior_nodes,
     $     bf_grdpts_id,
     $     bf_alignment, final_alignment)

          implicit none
          
          real(rkind)   , dimension(:)       , allocatable, intent(inout) :: bf_x_map
          real(rkind)   , dimension(nx)                   , intent(in)    :: interior_x_map
          real(rkind)   , dimension(:)       , allocatable, intent(inout) :: bf_y_map
          real(rkind)   , dimension(ny)                   , intent(in)    :: interior_y_map
          real(rkind)   , dimension(:,:,:)   , allocatable, intent(inout) :: bf_nodes
          real(rkind)   , dimension(nx,ny,ne)             , intent(in)    :: interior_nodes
          integer       , dimension(:,:)     , allocatable, intent(inout) :: bf_grdpts_id
          integer(ikind), dimension(2,2)                  , intent(inout) :: bf_alignment
          integer(ikind), dimension(2,2)                  , intent(in)    :: final_alignment


          integer(ikind), dimension(2,2) :: border_changes
          logical                        :: reallocation_needed
          integer(ikind)                 :: j_match, i_max, j_max
          integer(ikind)                 :: j_min1, j_min3, j_min4, j_min6
          integer(ikind)                 :: outside_j_max1, outside_j_max2
          integer(ikind)                 :: interior_j_max1, interior_j_max2
          integer(ikind)                 :: interior_j_max11, interior_j_max13
          integer(ikind)                 :: interior_j_max21, interior_j_max23
          integer(ikind)                 :: j_min11, j_min13, j_min21, j_min23
          integer(ikind), dimension(2)   :: new_sizes


          call get_border_changes_and_new_alignment_E(
     $         border_changes, final_alignment, bf_alignment)

          reallocation_needed = is_reallocation_needed(border_changes)


          if(reallocation_needed) then

             call get_match(
     $            y_direction,
     $            bf_alignment, border_changes,
     $            size(bf_nodes,1), size(bf_nodes,2),
     $            j_min1, j_min3, j_min4, j_min6,
     $            j_match, i_max, j_max,
     $            outside_j_max1, outside_j_max2,
     $            interior_j_max1, interior_j_max2,
     $            interior_j_max11, interior_j_max13,
     $            j_min11, j_min13,
     $            interior_j_max21, interior_j_max23,
     $            j_min21, j_min23)

             new_sizes = get_new_sizes(border_changes, size(bf_nodes,1), size(bf_nodes,2))

             call reallocate_nodes_E(
     $            bf_x_map, interior_x_map,
     $            bf_y_map, interior_y_map,
     $            bf_nodes, interior_nodes,
     $            j_min1, j_min3, j_min4,
     $            j_match, i_max, j_max,
     $            interior_j_max1, interior_j_max2,
     $            bf_alignment, new_sizes)

             call reallocate_grdpts_id_E(
     $            bf_grdpts_id,
     $            j_min1, j_min3, j_min4, j_min6,
     $            j_match, i_max, j_max,
     $            outside_j_max1, outside_j_max2,
     $            interior_j_max1, interior_j_max2,
     $            interior_j_max11, interior_j_max13,
     $            j_min11, j_min13,
     $            interior_j_max21, interior_j_max23,
     $            j_min21, j_min23,
     $            bf_alignment ,new_sizes)

          end if

        end subroutine reallocate_bf_layer_E


        !> reallocate the western buffer layer
        subroutine reallocate_bf_layer_W(
     $     bf_x_map, interior_x_map,
     $     bf_y_map, interior_y_map,
     $     bf_nodes, interior_nodes,
     $     bf_grdpts_id,
     $     bf_alignment, final_alignment)

          implicit none
          
          real(rkind)   , dimension(:)       , allocatable, intent(inout) :: bf_x_map
          real(rkind)   , dimension(nx)                   , intent(in)    :: interior_x_map
          real(rkind)   , dimension(:)       , allocatable, intent(inout) :: bf_y_map
          real(rkind)   , dimension(ny)                   , intent(in)    :: interior_y_map
          real(rkind)   , dimension(:,:,:)   , allocatable, intent(inout) :: bf_nodes
          real(rkind)   , dimension(nx,ny,ne)             , intent(in)    :: interior_nodes
          integer       , dimension(:,:)     , allocatable, intent(inout) :: bf_grdpts_id
          integer(ikind), dimension(2,2)                  , intent(inout) :: bf_alignment
          integer(ikind), dimension(2,2)                  , intent(in)    :: final_alignment


          integer(ikind), dimension(2,2) :: border_changes
          logical                        :: reallocation_needed
          integer(ikind)                 :: j_match, i_max, j_max
          integer(ikind)                 :: j_min1, j_min3, j_min4, j_min6
          integer(ikind)                 :: outside_j_max1, outside_j_max2
          integer(ikind)                 :: interior_j_max1, interior_j_max2
          integer(ikind)                 :: interior_j_max11, interior_j_max13
          integer(ikind)                 :: interior_j_max21, interior_j_max23
          integer(ikind)                 :: j_min11, j_min13, j_min21, j_min23

          integer(ikind), dimension(2)   :: new_sizes


          call get_border_changes_and_new_alignment_W(
     $         border_changes, final_alignment, bf_alignment)

          reallocation_needed = is_reallocation_needed(border_changes)

          
          if(reallocation_needed) then

             call get_match(
     $            y_direction,
     $            bf_alignment, border_changes,
     $            size(bf_nodes,1), size(bf_nodes,2),
     $            j_min1, j_min3, j_min4, j_min6,
     $            j_match, i_max, j_max,
     $            outside_j_max1, outside_j_max2,
     $            interior_j_max1, interior_j_max2,
     $            interior_j_max11, interior_j_max13,
     $            j_min11, j_min13,
     $            interior_j_max21, interior_j_max23,
     $            j_min21, j_min23)

             new_sizes = get_new_sizes(border_changes, size(bf_nodes,1), size(bf_nodes,2))

             call reallocate_nodes_W(
     $            bf_x_map, interior_x_map,
     $            bf_y_map, interior_y_map,
     $            bf_nodes, interior_nodes,
     $            j_min1, j_min3, j_min4,
     $            j_match, j_max,
     $            interior_j_max1, interior_j_max2,
     $            bf_alignment, new_sizes)

             call reallocate_grdpts_id_W(
     $            bf_grdpts_id,
     $            j_min1, j_min3, j_min4, j_min6,
     $            j_match, j_max,
     $            outside_j_max1, outside_j_max2,
     $            interior_j_max1, interior_j_max2,
     $            interior_j_max11, interior_j_max13,
     $            j_min11, j_min13,
     $            interior_j_max21, interior_j_max23,
     $            j_min21, j_min23,
     $            bf_alignment ,new_sizes)

          end if

        end subroutine reallocate_bf_layer_W


        !< reallocate nodes for northern buffer layers
        subroutine reallocate_nodes_N(
     $     bf_x_map, interior_x_map,
     $     bf_y_map, interior_y_map,
     $     bf_nodes, interior_nodes,
     $     i_min1, i_min3, i_min4,
     $     i_match, i_max, j_max,
     $     interior_i_max1, interior_i_max2,
     $     bf_alignment, new_sizes)

          implicit none

          real(rkind)   , dimension(:)       , allocatable, intent(inout) :: bf_x_map
          real(rkind)   , dimension(nx)                   , intent(in)    :: interior_x_map
          real(rkind)   , dimension(:)       , allocatable, intent(inout) :: bf_y_map
          real(rkind)   , dimension(ny)                   , intent(in)    :: interior_y_map
          real(rkind)   , dimension(:,:,:)   , allocatable, intent(inout) :: bf_nodes
          real(rkind)   , dimension(nx,ny,ne)             , intent(in)    :: interior_nodes
          integer(ikind)                                  , intent(in)    :: i_min1
          integer(ikind)                                  , intent(in)    :: i_min3
          integer(ikind)                                  , intent(in)    :: i_min4
          integer(ikind)                                  , intent(in)    :: i_match
          integer(ikind)                                  , intent(in)    :: i_max
          integer(ikind)                                  , intent(in)    :: j_max
          integer(ikind)                                  , intent(in)    :: interior_i_max1
          integer(ikind)                                  , intent(in)    :: interior_i_max2
          integer(ikind), dimension(2,2)                  , intent(in)    :: bf_alignment
          integer(ikind), dimension(2)                    , intent(in)    :: new_sizes

          real(rkind), dimension(:)    , allocatable :: new_x_map
          real(rkind), dimension(:)    , allocatable :: new_y_map
          real(rkind), dimension(:,:,:), allocatable :: new_nodes
          integer(ikind) :: i,j
          integer        :: k

          allocate(new_x_map(new_sizes(1)))
          allocate(new_y_map(new_sizes(2)))
          allocate(new_nodes(new_sizes(1),new_sizes(2),ne))


          !x_map
          call create_map_from_interior(
     $         new_x_map, bf_x_map, interior_x_map,
     $         i_min1, interior_i_max1,
     $         i_min3, i_max, i_match,
     $         i_min4, interior_i_max2,
     $         bf_alignment(1,1))

          
          !y_map
          call create_map_right(
     $         new_y_map,
     $         bf_y_map,
     $         interior_y_map,
     $         ny,
     $         j_max)
          

          !nodes
          do k=1, ne
             do j=1, 2*bc_size
                do i=1, interior_i_max1
                   new_nodes(i_min1+i,j,k) = interior_nodes(
     $                  bf_alignment(1,1)-(bc_size+1)+i_min1+i,
     $                  ny-(2*bc_size)+j,
     $                  k)
                end do

                do i=1, i_max
                   new_nodes(i_min3+i,j,k) = bf_nodes(i_match+i,j,k)
                end do

                do i=1, interior_i_max2
                   new_nodes(i_min4+i,j,k) = interior_nodes(
     $                  bf_alignment(1,1)-(bc_size+1)+i_min4+i,
     $                  ny-(2*bc_size)+j,
     $                  k)
                end do
             end do
          
             do j=2*bc_size+1, j_max
                 do i=1, i_max
                   new_nodes(i_min3+i,j,k) = bf_nodes(i_match+i,j,k)
                end do
             end do
          end do

          call MOVE_ALLOC(new_x_map,bf_x_map)
          call MOVE_ALLOC(new_y_map,bf_y_map)
          call MOVE_ALLOC(new_nodes,bf_nodes)

        end subroutine reallocate_nodes_N


        !< reallocate gridpts_id for northern buffer layers
        subroutine reallocate_grdpts_id_N(
     $     bf_grdpts_id,
     $     i_min1, i_min3, i_min4, i_min6,
     $     i_match, i_max, j_max,
     $     outside_i_max1, outside_i_max2,
     $     interior_i_max1, interior_i_max2,
     $     interior_i_max11, interior_i_max13,
     $     i_min11, i_min13,
     $     interior_i_max21, interior_i_max23,
     $     i_min21, i_min23,
     $     bf_alignment, new_sizes)

          implicit none

          
          integer       , dimension(:,:)     , allocatable, intent(inout) :: bf_grdpts_id
          integer(ikind)                                  , intent(in)    :: i_min1
          integer(ikind)                                  , intent(in)    :: i_min3
          integer(ikind)                                  , intent(in)    :: i_min4
          integer(ikind)                                  , intent(in)    :: i_min6
          integer(ikind)                                  , intent(in)    :: i_match
          integer(ikind)                                  , intent(in)    :: i_max
          integer(ikind)                                  , intent(in)    :: j_max
          integer(ikind)                                  , intent(in)    :: outside_i_max1
          integer(ikind)                                  , intent(in)    :: outside_i_max2
          integer(ikind)                                  , intent(in)    :: interior_i_max1
          integer(ikind)                                  , intent(in)    :: interior_i_max2
          integer(ikind)                                  , intent(in)    :: interior_i_max11
          integer(ikind)                                  , intent(in)    :: interior_i_max13
          integer(ikind)                                  , intent(in)    :: i_min11
          integer(ikind)                                  , intent(in)    :: i_min13
          integer(ikind)                                  , intent(in)    :: interior_i_max21
          integer(ikind)                                  , intent(in)    :: interior_i_max23
          integer(ikind)                                  , intent(in)    :: i_min21
          integer(ikind)                                  , intent(in)    :: i_min23
          integer(ikind), dimension(2,2)                  , intent(in)    :: bf_alignment
          integer(ikind), dimension(2)                    , intent(in)    :: new_sizes


          integer, dimension(:,:), allocatable :: new_grdpts_id
          
          integer(ikind) :: i,j

          integer, dimension(bc_size, 2*bc_size) :: border_W1
          integer, dimension(bc_size, 2*bc_size) :: border_E1
          integer, dimension(bc_size, 2*bc_size) :: border_W2
          integer, dimension(bc_size, 2*bc_size) :: border_E2
          integer, dimension(2*bc_size)          :: interior_profile

          allocate(new_grdpts_id(new_sizes(1),new_sizes(2)))
          
          !get the special border for the left and right
          !as well as the interior profile
          call get_additional_blocks_N(
     $         bf_alignment(1,1)-bc_size+i_min1,
     $         bf_alignment(1,1)-bc_size+i_min13,
     $         border_W1, border_E1, interior_profile)

          call get_additional_blocks_N(
     $         bf_alignment(1,1)-bc_size+i_min4,
     $         bf_alignment(1,1)-bc_size+i_min23,
     $         border_W2, border_E2, interior_profile)


          !fill the blocks according to Fig.1

          do j=1, 2*bc_size
             !block 1
             do i=1, outside_i_max1
                new_grdpts_id(i,j) = no_pt
             end do

             !block 2
             do i=1, interior_i_max11
                new_grdpts_id(i_min1+i,j) = border_W1(i,j)
             end do

             !block 3
             do i=1, interior_i_max1-(interior_i_max11+interior_i_max13)
                new_grdpts_id(i_min11+i,j) = interior_profile(j)
             end do

             !block 4
             do i=1, interior_i_max13
                new_grdpts_id(i_min13+i,j) = border_E1(i,j)
             end do

             !block 5
             do i=1, i_max
                new_grdpts_id(i_min3+i,j) = bf_grdpts_id(i_match+i,j)
             end do

             !block 6
             do i=1, interior_i_max21
                new_grdpts_id(i_min4+i,j) = border_W2(i,j)
             end do

             !block 7
             do i=1, interior_i_max2-(interior_i_max21+interior_i_max23)
                new_grdpts_id(i_min21+i,j) = interior_profile(j)
             end do

             !block 8
             do i=1, interior_i_max23
                new_grdpts_id(i_min23+i,j) = border_E2(i,j)
             end do

             !block 9
             do i=1, outside_i_max2
                new_grdpts_id(i_min6+i,j) = no_pt
             end do
          end do
          
          do j=2*bc_size+1, j_max
             !block 10
             do i=1, outside_i_max1+interior_i_max1
                new_grdpts_id(i,j) = no_pt
             end do

             !block 11
             do i=1, i_max
                new_grdpts_id(i_min3+i,j) = bf_grdpts_id(i_match+i,j)
             end do

             !block 12
             do i=1, interior_i_max2+outside_i_max2
                new_grdpts_id(i_min4+i,j) = no_pt
             end do
          end do

          !block 13
          do j=j_max+1, size(new_grdpts_id,2)
             do i=1, size(new_grdpts_id,1)
                new_grdpts_id(i,j) = no_pt
             end do
          end do

          call MOVE_ALLOC(new_grdpts_id,bf_grdpts_id)

        end subroutine reallocate_grdpts_id_N


        !< reallocate nodes for southern buffer layers
        subroutine reallocate_nodes_S(
     $     bf_x_map, interior_x_map,
     $     bf_y_map, interior_y_map,
     $     bf_nodes, interior_nodes,
     $     i_min1, i_min3, i_min4,
     $     i_match, i_max,
     $     interior_i_max1, interior_i_max2,
     $     bf_alignment, new_sizes)

          implicit none

          real(rkind)   , dimension(:)       , allocatable, intent(inout) :: bf_x_map
          real(rkind)   , dimension(nx)                   , intent(in)    :: interior_x_map
          real(rkind)   , dimension(:)       , allocatable, intent(inout) :: bf_y_map
          real(rkind)   , dimension(ny)                   , intent(in)    :: interior_y_map
          real(rkind)   , dimension(:,:,:)   , allocatable, intent(inout) :: bf_nodes
          real(rkind)   , dimension(nx,ny,ne)             , intent(in)    :: interior_nodes
          integer(ikind)                                  , intent(in)    :: i_min1
          integer(ikind)                                  , intent(in)    :: i_min3
          integer(ikind)                                  , intent(in)    :: i_min4
          integer(ikind)                                  , intent(in)    :: i_match
          integer(ikind)                                  , intent(in)    :: i_max
          integer(ikind)                                  , intent(in)    :: interior_i_max1
          integer(ikind)                                  , intent(in)    :: interior_i_max2
          integer(ikind), dimension(2,2)                  , intent(in)    :: bf_alignment
          integer(ikind), dimension(2)                    , intent(in)    :: new_sizes

          real(rkind), dimension(:)    , allocatable :: new_x_map
          real(rkind), dimension(:)    , allocatable :: new_y_map
          real(rkind), dimension(:,:,:), allocatable :: new_nodes
          integer(ikind) :: i,j,j_min,j_start
          integer        :: k

          allocate(new_x_map(new_sizes(1)))
          allocate(new_y_map(new_sizes(2)))
          allocate(new_nodes(new_sizes(1),new_sizes(2),ne))
          
          !match indices
          j_min = size(new_nodes,2)-size(bf_nodes,2)
          if(j_min.lt.0) then
             j_start = 0
          else
             j_start = j_min
          end if

          !x_map copy
          call create_map_from_interior(
     $         new_x_map, bf_x_map, interior_x_map,
     $         i_min1, interior_i_max1,
     $         i_min3, i_max, i_match,
     $         i_min4, interior_i_max2,
     $         bf_alignment(1,1))

          !y_map copy
          call create_map_left(
     $         new_y_map, bf_y_map, interior_y_map,
     $         j_start, j_min)

          !nodes          
          do k=1, ne

             do j=j_start+1, size(new_nodes,2)-(2*bc_size)
                 do i=1, i_max
                   new_nodes(i_min3+i,j,k) = bf_nodes(i_match+i,j-j_min,k)
                end do
             end do

             do j=size(new_nodes,2)-(2*bc_size)+1, size(new_nodes,2)
                do i=1, interior_i_max1
                   new_nodes(i_min1+i,j,k) = interior_nodes(
     $                  bf_alignment(1,1)-(bc_size+1)+i_min1+i,
     $                  j-(size(new_nodes,2)-2*bc_size),
     $                  k)
                end do

                do i=1, i_max
                   new_nodes(i_min3+i,j,k) = bf_nodes(i_match+i,j-j_min,k)
                end do

                do i=1, interior_i_max2
                   new_nodes(i_min4+i,j,k) = interior_nodes(
     $                  bf_alignment(1,1)-(bc_size+1)+i_min4+i,
     $                  j-(size(new_nodes,2)-2*bc_size),
     $                  k)
                end do
             end do
             
          end do

          call MOVE_ALLOC(new_x_map,bf_x_map)
          call MOVE_ALLOC(new_y_map,bf_y_map)
          call MOVE_ALLOC(new_nodes,bf_nodes)

        end subroutine reallocate_nodes_S


        !< reallocate gridpts_id for northern buffer layers
        subroutine reallocate_grdpts_id_S(
     $     bf_grdpts_id,
     $     i_min1, i_min3, i_min4, i_min6,
     $     i_match, i_max, j_max,
     $     outside_i_max1, outside_i_max2,
     $     interior_i_max1, interior_i_max2,
     $     interior_i_max11, interior_i_max13,
     $     i_min11, i_min13,
     $     interior_i_max21, interior_i_max23,
     $     i_min21, i_min23,
     $     bf_alignment, new_sizes)

          implicit none

          integer       , dimension(:,:)     , allocatable, intent(inout) :: bf_grdpts_id
          integer(ikind)                                  , intent(in)    :: i_min1
          integer(ikind)                                  , intent(in)    :: i_min3
          integer(ikind)                                  , intent(in)    :: i_min4
          integer(ikind)                                  , intent(in)    :: i_min6
          integer(ikind)                                  , intent(in)    :: i_match
          integer(ikind)                                  , intent(in)    :: i_max
          integer(ikind)                                  , intent(in)    :: j_max
          integer(ikind)                                  , intent(in)    :: outside_i_max1
          integer(ikind)                                  , intent(in)    :: outside_i_max2
          integer(ikind)                                  , intent(in)    :: interior_i_max1
          integer(ikind)                                  , intent(in)    :: interior_i_max2
          integer(ikind)                                  , intent(in)    :: interior_i_max11
          integer(ikind)                                  , intent(in)    :: interior_i_max13
          integer(ikind)                                  , intent(in)    :: i_min11
          integer(ikind)                                  , intent(in)    :: i_min13
          integer(ikind)                                  , intent(in)    :: interior_i_max21
          integer(ikind)                                  , intent(in)    :: interior_i_max23
          integer(ikind)                                  , intent(in)    :: i_min21
          integer(ikind)                                  , intent(in)    :: i_min23

          integer(ikind), dimension(2,2)                  , intent(in)    :: bf_alignment
          integer(ikind), dimension(2)                    , intent(in)    :: new_sizes


          integer, dimension(:,:), allocatable :: new_grdpts_id
          
          integer(ikind) :: i,j,j_min,j_match_profile,j_start

          integer, dimension(bc_size, 2*bc_size) :: border_W1
          integer, dimension(bc_size, 2*bc_size) :: border_E1
          integer, dimension(bc_size, 2*bc_size) :: border_W2
          integer, dimension(bc_size, 2*bc_size) :: border_E2
          integer, dimension(2*bc_size)          :: interior_profile


          allocate(new_grdpts_id(new_sizes(1),new_sizes(2)))

          j_min           = size(new_grdpts_id,2)-j_max
          j_match_profile = size(new_grdpts_id,2)-(2*bc_size)
          if(j_min.lt.0) then
             j_start = 0
          else
             j_start = j_min
          end if

          !get the special border for the left and right
          !as well as the interior profile
          call get_additional_blocks_S(
     $         bf_alignment(1,1)-bc_size+i_min1,
     $         bf_alignment(1,1)-bc_size+i_min13,
     $         border_W1, border_E1, interior_profile)

          call get_additional_blocks_S(
     $         bf_alignment(1,1)-bc_size+i_min4,
     $         bf_alignment(1,1)-bc_size+i_min23,
     $         border_W2, border_E2, interior_profile)


          !fill the blocks according to Fig.2

          !block 13
          do j=1, j_min
             do i=1, size(new_grdpts_id,1)
                new_grdpts_id(i,j) = no_pt
             end do
          end do


          do j=j_start+1, size(new_grdpts_id,2)-(2*bc_size)
             !block 10
             do i=1, outside_i_max1+interior_i_max1
                new_grdpts_id(i,j) = no_pt
             end do

             !block 11
             do i=1, i_max
                new_grdpts_id(i_min3+i,j) = bf_grdpts_id(i_match+i,j-j_min)
             end do

             !block 12
             do i=1, interior_i_max2+outside_i_max2
                new_grdpts_id(i_min4+i,j) = no_pt
             end do
          end do


          do j=size(new_grdpts_id,2)-(2*bc_size)+1, size(new_grdpts_id,2)
             !block 1
             do i=1, outside_i_max1
                new_grdpts_id(i,j) = no_pt
             end do

             !block 2
             do i=1, interior_i_max11
                new_grdpts_id(i_min1+i,j) = border_W1(i,j-j_match_profile)
             end do

             !block 3
             do i=1, interior_i_max1-(interior_i_max11+interior_i_max13)
                new_grdpts_id(i_min11+i,j) = interior_profile(j-j_match_profile)
             end do

             !block 4
             do i=1, interior_i_max13
                new_grdpts_id(i_min13+i,j) = border_E1(i,j-j_match_profile)
             end do             

             !block 5
             do i=1, i_max
                new_grdpts_id(i_min3+i,j) = bf_grdpts_id(i_match+i,j-j_min)
             end do

             !block 6
             do i=1, interior_i_max21
                new_grdpts_id(i_min4+i,j) = border_W2(i,j-j_match_profile)
             end do

             !block 7
             do i=1, interior_i_max2-(interior_i_max21+interior_i_max23)
                new_grdpts_id(i_min21+i,j) = interior_profile(j-j_match_profile)
             end do

             !block 8
             do i=1, interior_i_max23
                new_grdpts_id(i_min23+i,j) = border_E2(i,j-j_match_profile)
             end do

             !block 9
             do i=1, outside_i_max2
                new_grdpts_id(i_min6+i,j) = no_pt
             end do
          end do          

          call MOVE_ALLOC(new_grdpts_id,bf_grdpts_id)

        end subroutine reallocate_grdpts_id_S


        !< reallocate nodes for eastern buffer layers
        subroutine reallocate_nodes_E(
     $     bf_x_map, interior_x_map,
     $     bf_y_map, interior_y_map,
     $     bf_nodes, interior_nodes,
     $     j_min1, j_min3, j_min4,
     $     j_match, i_max, j_max,
     $     interior_j_max1, interior_j_max2,
     $     bf_alignment, new_sizes)

          implicit none

          real(rkind)   , dimension(:)       , allocatable, intent(inout) :: bf_x_map
          real(rkind)   , dimension(nx)                   , intent(in)    :: interior_x_map
          real(rkind)   , dimension(:)       , allocatable, intent(inout) :: bf_y_map
          real(rkind)   , dimension(ny)                   , intent(in)    :: interior_y_map
          real(rkind)   , dimension(:,:,:)   , allocatable, intent(inout) :: bf_nodes
          real(rkind)   , dimension(nx,ny,ne)             , intent(in)    :: interior_nodes
          integer(ikind)                                  , intent(in)    :: j_min1
          integer(ikind)                                  , intent(in)    :: j_min3
          integer(ikind)                                  , intent(in)    :: j_min4
          integer(ikind)                                  , intent(in)    :: j_match
          integer(ikind)                                  , intent(in)    :: i_max
          integer(ikind)                                  , intent(in)    :: j_max
          integer(ikind)                                  , intent(in)    :: interior_j_max1
          integer(ikind)                                  , intent(in)    :: interior_j_max2
          integer(ikind), dimension(2,2)                  , intent(in)    :: bf_alignment
          integer(ikind), dimension(2)                    , intent(in)    :: new_sizes

          real(rkind), dimension(:)    , allocatable :: new_x_map
          real(rkind), dimension(:)    , allocatable :: new_y_map
          real(rkind), dimension(:,:,:), allocatable :: new_nodes
          integer(ikind) :: i,j
          integer        :: k

          
          allocate(new_x_map(new_sizes(1)))
          allocate(new_y_map(new_sizes(2)))
          allocate(new_nodes(new_sizes(1),new_sizes(2),ne))


          !x_map
          call create_map_right(
     $         new_x_map,
     $         bf_x_map,
     $         interior_x_map,
     $         nx,
     $         i_max)


          !y_map
          call create_map_from_interior(
     $         new_y_map, bf_y_map, interior_y_map,
     $         j_min1, interior_j_max1,
     $         j_min3, j_max, j_match,
     $         j_min4, interior_j_max2,
     $         bf_alignment(2,1))


          !nodes
          do k=1, ne
             do j=1, interior_j_max1
                do i=1, 2*bc_size
                   new_nodes(i,j_min1+j,k) = interior_nodes(
     $                  nx-(2*bc_size)+i,
     $                  bf_alignment(2,1)-(bc_size+1)+j_min1+j,
     $                  k)
                end do
             end do

             do j=1, j_max
                do i=1, i_max
                   new_nodes(i,j_min3+j,k) = bf_nodes(i,j_match+j,k)
                end do
             end do
             
             do j=1, interior_j_max2
                do i=1, 2*bc_size
                   new_nodes(i,j_min4+j,k) = interior_nodes(
     $                  nx-(2*bc_size)+i,
     $                  bf_alignment(2,1)-(bc_size+1)+j_min4+j,
     $                  k)
                end do
             end do
          end do

          call MOVE_ALLOC(new_x_map,bf_x_map)
          call MOVE_ALLOC(new_y_map,bf_y_map)
          call MOVE_ALLOC(new_nodes,bf_nodes)

        end subroutine reallocate_nodes_E


        !< reallocate gridpts_id for eastern buffer layers
        subroutine reallocate_grdpts_id_E(
     $     bf_grdpts_id,
     $     j_min1, j_min3, j_min4, j_min6,
     $     j_match, i_max, j_max,
     $     outside_j_max1, outside_j_max2,
     $     interior_j_max1, interior_j_max2,
     $     interior_j_max11, interior_j_max13,
     $     j_min11, j_min13,
     $     interior_j_max21, interior_j_max23,
     $     j_min21, j_min23,
     $     bf_alignment, new_sizes)

          implicit none

          integer       , dimension(:,:), allocatable, intent(inout) :: bf_grdpts_id
          integer(ikind)                             , intent(in)    :: j_min1
          integer(ikind)                             , intent(in)    :: j_min3
          integer(ikind)                             , intent(in)    :: j_min4
          integer(ikind)                             , intent(in)    :: j_min6
          integer(ikind)                             , intent(in)    :: j_match
          integer(ikind)                             , intent(in)    :: i_max
          integer(ikind)                             , intent(in)    :: j_max
          integer(ikind)                             , intent(in)    :: outside_j_max1
          integer(ikind)                             , intent(in)    :: outside_j_max2
          integer(ikind)                             , intent(in)    :: interior_j_max1
          integer(ikind)                             , intent(in)    :: interior_j_max2
          integer(ikind)                             , intent(in)    :: interior_j_max11
          integer(ikind)                             , intent(in)    :: interior_j_max13
          integer(ikind)                             , intent(in)    :: j_min11
          integer(ikind)                             , intent(in)    :: j_min13
          integer(ikind)                             , intent(in)    :: interior_j_max21
          integer(ikind)                             , intent(in)    :: interior_j_max23
          integer(ikind)                             , intent(in)    :: j_min21
          integer(ikind)                             , intent(in)    :: j_min23
          integer(ikind), dimension(2,2)             , intent(in)    :: bf_alignment
          integer(ikind), dimension(2)               , intent(in)    :: new_sizes


          integer, dimension(:,:), allocatable :: new_grdpts_id
          
          integer(ikind) :: i,j

          integer, dimension(2*bc_size,bc_size) :: border_N1
          integer, dimension(2*bc_size,bc_size) :: border_S1
          integer, dimension(2*bc_size,bc_size) :: border_N2
          integer, dimension(2*bc_size,bc_size) :: border_S2
          integer, dimension(2*bc_size)         :: interior_profile


          allocate(new_grdpts_id(new_sizes(1),new_sizes(2)))

          
          !get the special border for the left and right
          !as well as the interior profile
          call get_additional_blocks_E(
     $         bf_alignment(2,1)-bc_size+j_min1,
     $         bf_alignment(2,1)-bc_size+j_min13,
     $         border_S1, border_N1, interior_profile)

          call get_additional_blocks_E(
     $         bf_alignment(2,1)-bc_size+j_min4,
     $         bf_alignment(2,1)-bc_size+j_min23,
     $         border_S2, border_N2, interior_profile)


          !fill the blocks 1 and partially 8 and 13
          do j=1, outside_j_max1
             do i=1, size(new_grdpts_id,1)
                new_grdpts_id(i,j) = no_pt
             end do
          end do

          
          !fill the blocks 2 and partially 8 and 13
          do j=1, interior_j_max11
             do i=1, 2*bc_size
                new_grdpts_id(i,j_min1+j) = border_S1(i,j)
             end do
             do i=2*bc_size+1, size(new_grdpts_id,1)
                new_grdpts_id(i,j_min1+j) = no_pt
             end do
          end do          


          !fill the blocks 3 and partially 8 and 13
          do j=1, interior_j_max1-(interior_j_max11+interior_j_max13)
             do i=1, 2*bc_size
                new_grdpts_id(i,j_min11+j) = interior_profile(i)
             end do
             do i=2*bc_size+1, size(new_grdpts_id,1)
                new_grdpts_id(i,j_min11+j) = no_pt
             end do
          end do

          
          !fill the blocks 4 and partially 8 and 13
          do j=1, interior_j_max13
             do i=1, 2*bc_size
                new_grdpts_id(i,j_min13+j) = border_N1(i,j)
             end do
             do i=2*bc_size+1, size(new_grdpts_id,1)
                new_grdpts_id(i,j_min13+j) = no_pt
             end do
          end do


          !fill the blocks 5 and partially 11 and 13
          do j=1, j_max
             do i=1, i_max
                new_grdpts_id(i,j_min3+j) = bf_grdpts_id(i,j_match+j)
             end do
             do i=i_max+1, size(new_grdpts_id,1)
                new_grdpts_id(i,j_min3+j) = no_pt
             end do
          end do

          
          !fill the blocks 6 and partially 12 and 13
          do j=1, interior_j_max21
             do i=1, 2*bc_size
                new_grdpts_id(i,j_min4+j) = border_S2(i,j)
             end do
             do i=2*bc_size+1, size(new_grdpts_id,1)
                new_grdpts_id(i,j_min4+j) = no_pt
             end do
          end do


          !fill the blocks 7 and partially 12 and 13
          do j=1, interior_j_max2-(interior_j_max21+interior_j_max23)
             do i=1, 2*bc_size
                new_grdpts_id(i,j_min21+j) = interior_profile(i)
             end do
             do i=2*bc_size+1, size(new_grdpts_id,1)
                new_grdpts_id(i,j_min21+j) = no_pt
             end do
          end do

          
          !fill the blocks 8 and partially 12 and 13
          do j=1, interior_j_max23
             do i=1, 2*bc_size
                new_grdpts_id(i,j_min23+j) = border_N2(i,j)
             end do
             do i=2*bc_size+1, size(new_grdpts_id,1)
                new_grdpts_id(i,j_min23+j) = no_pt
             end do
          end do


          !fill the blocks 9 and partially 12 and 13
          do j=1, outside_j_max2
             do i=1, size(new_grdpts_id,1)
                new_grdpts_id(i,j_min6+j) = no_pt
             end do
          end do


          !replace the content of bf_grdpts_id with new_grdpts_id
          call MOVE_ALLOC(new_grdpts_id,bf_grdpts_id)

        end subroutine reallocate_grdpts_id_E


        !< reallocate nodes for western buffer layers
        subroutine reallocate_nodes_W(
     $     bf_x_map, interior_x_map,
     $     bf_y_map, interior_y_map,
     $     bf_nodes, interior_nodes,
     $     j_min1, j_min3, j_min4,
     $     j_match, j_max,
     $     interior_j_max1, interior_j_max2,
     $     bf_alignment, new_sizes)

          implicit none

          real(rkind)   , dimension(:)       , allocatable, intent(inout) :: bf_x_map
          real(rkind)   , dimension(nx)                   , intent(in)    :: interior_x_map
          real(rkind)   , dimension(:)       , allocatable, intent(inout) :: bf_y_map
          real(rkind)   , dimension(ny)                   , intent(in)    :: interior_y_map
          real(rkind)   , dimension(:,:,:)   , allocatable, intent(inout) :: bf_nodes
          real(rkind)   , dimension(nx,ny,ne)             , intent(in)    :: interior_nodes
          integer(ikind)                                  , intent(in)    :: j_min1
          integer(ikind)                                  , intent(in)    :: j_min3
          integer(ikind)                                  , intent(in)    :: j_min4
          integer(ikind)                                  , intent(in)    :: j_match
          integer(ikind)                                  , intent(in)    :: j_max
          integer(ikind)                                  , intent(in)    :: interior_j_max1
          integer(ikind)                                  , intent(in)    :: interior_j_max2
          integer(ikind), dimension(2,2)                  , intent(in)    :: bf_alignment
          integer(ikind), dimension(2)                    , intent(in)    :: new_sizes

          real(rkind), dimension(:)    , allocatable :: new_x_map
          real(rkind), dimension(:)    , allocatable :: new_y_map
          real(rkind), dimension(:,:,:), allocatable :: new_nodes
          integer(ikind) :: i,j,i_min,i_start
          integer        :: k

          allocate(new_x_map(new_sizes(1)))
          allocate(new_y_map(new_sizes(2)))
          allocate(new_nodes(new_sizes(1),new_sizes(2),ne))

          !match indices
          i_min = size(new_nodes,1)-size(bf_nodes,1)
          if(i_min.lt.0) then
             i_start = 0
          else
             i_start = i_min
          end if

          !x_map
          call create_map_left(
     $         new_x_map, bf_x_map, interior_x_map,
     $         i_start, i_min)

          !y_map
          call create_map_from_interior(
     $         new_y_map, bf_y_map, interior_y_map,
     $         j_min1, interior_j_max1,
     $         j_min3, j_max, j_match,
     $         j_min4, interior_j_max2,
     $         bf_alignment(2,1))

          !nodes
          do k=1, ne
             do j=1, interior_j_max1
                do i=size(new_nodes,1)-(2*bc_size)+1, size(new_nodes,1)
                   new_nodes(i,j_min1+j,k) = interior_nodes(
     $                  i-(size(new_nodes,1)-2*bc_size),
     $                  bf_alignment(2,1)-(bc_size+1)+j_min1+j,
     $                  k)
                end do
             end do

             do j=1, j_max
                do i=i_start+1, size(new_nodes,1)
                   new_nodes(i,j_min3+j,k) = bf_nodes(i-i_min,j_match+j,k)
                end do
             end do
             
             do j=1, interior_j_max2
                do i=size(new_nodes,1)-(2*bc_size)+1, size(new_nodes,1)
                   new_nodes(i,j_min4+j,k) = interior_nodes(
     $                  i-(size(new_nodes,1)-2*bc_size),
     $                  bf_alignment(2,1)-(bc_size+1)+j_min4+j,
     $                  k)
                end do
             end do
          end do

          call MOVE_ALLOC(new_x_map,bf_x_map)
          call MOVE_ALLOC(new_y_map,bf_y_map)
          call MOVE_ALLOC(new_nodes,bf_nodes)

        end subroutine reallocate_nodes_W


        !< reallocate gridpts_id for eastern buffer layers
        subroutine reallocate_grdpts_id_W(
     $     bf_grdpts_id,
     $     j_min1, j_min3, j_min4, j_min6,
     $     j_match, j_max,
     $     outside_j_max1, outside_j_max2,
     $     interior_j_max1, interior_j_max2,
     $     interior_j_max11, interior_j_max13,
     $     j_min11, j_min13,
     $     interior_j_max21, interior_j_max23,
     $     j_min21, j_min23,
     $     bf_alignment, new_sizes)

          implicit none

          integer       , dimension(:,:), allocatable, intent(inout) :: bf_grdpts_id
          integer(ikind)                             , intent(in)    :: j_min1
          integer(ikind)                             , intent(in)    :: j_min3
          integer(ikind)                             , intent(in)    :: j_min4
          integer(ikind)                             , intent(in)    :: j_min6
          integer(ikind)                             , intent(in)    :: j_match
          integer(ikind)                             , intent(in)    :: j_max
          integer(ikind)                             , intent(in)    :: outside_j_max1
          integer(ikind)                             , intent(in)    :: outside_j_max2
          integer(ikind)                             , intent(in)    :: interior_j_max1
          integer(ikind)                             , intent(in)    :: interior_j_max2
          integer(ikind)                             , intent(in)    :: interior_j_max11
          integer(ikind)                             , intent(in)    :: interior_j_max13
          integer(ikind)                             , intent(in)    :: j_min11
          integer(ikind)                             , intent(in)    :: j_min13
          integer(ikind)                             , intent(in)    :: interior_j_max21
          integer(ikind)                             , intent(in)    :: interior_j_max23
          integer(ikind)                             , intent(in)    :: j_min21
          integer(ikind)                             , intent(in)    :: j_min23
          integer(ikind), dimension(2,2)             , intent(in)    :: bf_alignment
          integer(ikind), dimension(2)               , intent(in)    :: new_sizes


          integer, dimension(:,:), allocatable :: new_grdpts_id
          
          integer(ikind) :: i,j,i_min,i_match_profile,i_start

          integer, dimension(2*bc_size,bc_size) :: border_N1
          integer, dimension(2*bc_size,bc_size) :: border_S1
          integer, dimension(2*bc_size,bc_size) :: border_N2
          integer, dimension(2*bc_size,bc_size) :: border_S2
          integer, dimension(2*bc_size)         :: interior_profile


          allocate(new_grdpts_id(new_sizes(1),new_sizes(2)))

          i_min           = size(new_grdpts_id,1)-size(bf_grdpts_id,1)
          i_match_profile = size(new_grdpts_id,1)-(2*bc_size)
          if(i_min.lt.0) then
             i_start = 0
          else
             i_start = i_min
          end if

          !get the special border for the left and right
          !as well as the interior profile
          call get_additional_blocks_W(
     $         bf_alignment(2,1)-bc_size+j_min1,
     $         bf_alignment(2,1)-bc_size+j_min13,
     $         border_S1, border_N1, interior_profile)

          call get_additional_blocks_W(
     $         bf_alignment(2,1)-bc_size+j_min4,
     $         bf_alignment(2,1)-bc_size+j_min23,
     $         border_S2, border_N2, interior_profile)


          !fill the blocks 1 and partially 10 and 13
          do j=1, outside_j_max1
             do i=1, size(new_grdpts_id,1)
                new_grdpts_id(i,j) = no_pt
             end do
          end do

         
          !fill the blocks 2 and partially 10 and 13
          do j=1, interior_j_max11
             do i=1, i_match_profile
                new_grdpts_id(i,j_min1+j) = no_pt
             end do
             do i=i_match_profile+1, size(new_grdpts_id,1)
                new_grdpts_id(i,j_min1+j)= border_S1(i-i_match_profile,j)
             end do                          
          end do

          
          !fill the blocks 3 and partially 10 and 13
          do j=1, interior_j_max1-(interior_j_max11+interior_j_max13)
             do i=1, i_match_profile
                new_grdpts_id(i,j_min11+j) = no_pt
             end do
             do i=i_match_profile+1, size(new_grdpts_id,1)
                new_grdpts_id(i,j_min11+j)= interior_profile(i-i_match_profile)
             end do                          
          end do


          !fill the blocks 4 and partially 10 and 13
          do j=1, interior_j_max13
             do i=1, i_match_profile
                new_grdpts_id(i,j_min13+j) = no_pt
             end do
             do i=i_match_profile+1, size(new_grdpts_id,1)
                new_grdpts_id(i,j_min13+j)= border_N1(i-i_match_profile,j)
             end do                          
          end do


          !fill the blocks 5, 11 and partially 13
          do j=1, j_max
             do i=1, i_min
                new_grdpts_id(i,j_min3+j) = no_pt
             end do
             do i=i_start+1, size(new_grdpts_id,1)
                new_grdpts_id(i,j_min3+j) = bf_grdpts_id(i-i_min,j_match+j)
             end do
          end do


          !fill the blocks 6 and partially 12 and 13
          do j=1, interior_j_max21
             do i=1, i_match_profile
                new_grdpts_id(i,j_min4+j) = no_pt
             end do
             do i=i_match_profile+1, size(new_grdpts_id,1)
                new_grdpts_id(i,j_min4+j) = border_S2(i-i_match_profile,j)
             end do             
          end do

          
          !fill the blocks 7 and partially 12 and 13
          do j=1, interior_j_max2-(interior_j_max21+interior_j_max23)
             do i=1, i_match_profile
                new_grdpts_id(i,j_min21+j) = no_pt
             end do
             do i=i_match_profile+1, size(new_grdpts_id,1)
                new_grdpts_id(i,j_min21+j) = interior_profile(i-i_match_profile)
             end do             
          end do
          

          !fill the blocks 8 and partially 12 and 13
          do j=1, interior_j_max23
             do i=1, i_match_profile
                new_grdpts_id(i,j_min23+j) = no_pt
             end do
             do i=i_match_profile+1, size(new_grdpts_id,1)
                new_grdpts_id(i,j_min23+j) = border_N2(i-i_match_profile,j)
             end do             
          end do


          !fill the blocks 7 and partially 10 and 11
          do j=1, outside_j_max2
             do i=1, size(new_grdpts_id,1)
                new_grdpts_id(i,j_min6+j) = no_pt
             end do
          end do


          !replace the content of bf_grdpts_id with new_grdpts_id
          call MOVE_ALLOC(new_grdpts_id,bf_grdpts_id)

        end subroutine reallocate_grdpts_id_W


        subroutine get_match(
     $     dir,
     $     bf_alignment, border_changes,
     $     size_x, size_y,
     $     i_min1, i_min3, i_min4, i_min6,
     $     i_match, i_max, j_max,
     $     outside_i_max1, outside_i_max2,
     $     interior_i_max1, interior_i_max2,
     $     interior_i_max11, interior_i_max13,
     $     i_min11, i_min13,
     $     interior_i_max21, interior_i_max23,
     $     i_min21, i_min23)
        
          implicit none

          integer                       , intent(in)  :: dir
          integer(ikind), dimension(2,2), intent(in)  :: bf_alignment
          integer(ikind), dimension(2,2), intent(in)  :: border_changes
          integer(ikind)                , intent(in)  :: size_x
          integer(ikind)                , intent(in)  :: size_y
          integer(ikind)                , intent(out) :: i_min1
          integer(ikind)                , intent(out) :: i_min3
          integer(ikind)                , intent(out) :: i_min4
          integer(ikind)                , intent(out) :: i_min6
          integer(ikind)                , intent(out) :: i_match
          integer(ikind)                , intent(out) :: i_max
          integer(ikind)                , intent(out) :: j_max
          integer(ikind)                , intent(out) :: outside_i_max1
          integer(ikind)                , intent(out) :: outside_i_max2
          integer(ikind)                , intent(out) :: interior_i_max1
          integer(ikind)                , intent(out) :: interior_i_max2
          integer(ikind)                , intent(out) :: interior_i_max11
          integer(ikind)                , intent(out) :: interior_i_max13
          integer(ikind)                , intent(out) :: i_min11
          integer(ikind)                , intent(out) :: i_min13
          integer(ikind)                , intent(out) :: interior_i_max21
          integer(ikind)                , intent(out) :: interior_i_max23
          integer(ikind)                , intent(out) :: i_min21
          integer(ikind)                , intent(out) :: i_min23
          

          integer(ikind), dimension(2) :: old_bf_alignment
          integer(ikind) :: ndir

          select case(dir)
            case(x_direction)
               ndir = nx
            case(y_direction)
               ndir = ny
            case default
               print '(''bf_layer_reallocate_module'')'
               print '(''get_match'')'
               stop 'dir not recognized'
          end select


          !compute the previous alignment
          old_bf_alignment(1) = bf_alignment(dir,1)-border_changes(dir,1)
          old_bf_alignment(2) = bf_alignment(dir,2)-border_changes(dir,2)


          !define the length of the blocks 1 and 10
          !the length is restricted by the length of the
          !interior domain
          if(old_bf_alignment(1).le.(bc_size+1)) then
             outside_i_max1 = max(0, -border_changes(dir,1))
          else
             if(bf_alignment(dir,1).le.(bc_size+1)) then
                outside_i_max1 = bc_size + 1 - bf_alignment(dir,1)
             else
                outside_i_max1 = 0
             end if
          end if


          !define the length of the blocks 9 and 12
          !the length is restricted by the length of the
          !interior domain
          if(old_bf_alignment(2).ge.(ndir-bc_size)) then
             outside_i_max2 = max(0, border_changes(dir,2))
          else
             if(bf_alignment(dir,2).ge.(ndir-bc_size)) then
                outside_i_max2 = bf_alignment(dir,2)-(ndir-bc_size)
             else
                outside_i_max2 = 0
             end if
          end if


          !define the length of the blocks 2-4
          !the length is restricted by the length of the
          !interior domain
          if(old_bf_alignment(1).ge.(bc_size+1)) then
             if(bf_alignment(dir,1).ge.(bc_size+1)) then
                interior_i_max1 = max(0,-border_changes(dir,1))
             else
                interior_i_max1 = old_bf_alignment(1)-(bc_size+1)
             end if
          else
             interior_i_max1 = 0
          end if


          !define the length of the blocks 6-8
          !the length is restricted by the length of the
          !interior domain
          if(old_bf_alignment(2).le.(ndir-bc_size)) then
             if(bf_alignment(dir,2).le.(ndir-bc_size)) then
                interior_i_max2 = max(0, border_changes(dir,2))
             else
                interior_i_max2 = (ndir-bc_size) - old_bf_alignment(2)
             end if
          else
             interior_i_max2 = 0
          end if


          !define the length of the blocks 5 and 11
          !in the case the reallocated table in smaller than the
          !original one, we need to change the borders identifying
          !which part of the original table is copied
          i_match = 0 + max(0,border_changes(dir,1))
          i_max   = size_x -
     $         max(0,border_changes(1,1)) -
     $         max(0,-border_changes(1,2))
          j_max   = size_y -
     $         max(0,border_changes(2,1)) -
     $         max(0,-border_changes(2,2))

          i_min1 = outside_i_max1
          i_min3 = i_min1 + interior_i_max1
          if(dir.eq.x_direction) then
             i_min4 = i_min3 + i_max
          else
             i_min4 = i_min3 + j_max
          end if
          i_min6 = i_min4 + interior_i_max2


          !compute the sizes of blocks 2 and 4
          call get_match_interior(
     $         dir, ndir,
     $         bf_alignment, i_min1, interior_i_max1,
     $         interior_i_max11, interior_i_max13)

          !update the block indices
          i_min11 = i_min1 + interior_i_max11
          i_min13 = i_min3 - interior_i_max13

          !compute the sizes of blocks 6 and 8
          call get_match_interior(
     $         dir, ndir,
     $         bf_alignment, i_min4, interior_i_max2,
     $         interior_i_max21, interior_i_max23)

          !update the block indices
          i_min21 = i_min4 + interior_i_max21
          i_min23 = i_min6 - interior_i_max23

        end subroutine get_match        


        !< new size of tables for the buffer layer
        function get_new_sizes(border_changes, size_x, size_y)
     $     result(new_sizes)

          implicit none

          integer(ikind), dimension(2,2), intent(in) :: border_changes
          integer(ikind)                , intent(in) :: size_x
          integer(ikind)                , intent(in) :: size_y
          integer(ikind), dimension(2)               :: new_sizes

          new_sizes(1) = size_x - border_changes(1,1) + border_changes(1,2)
          new_sizes(2) = size_y - border_changes(2,1) + border_changes(2,2)

        end function get_new_sizes


        subroutine get_border_changes_and_new_alignment_N(
     $     border_changes, final_alignment, bf_alignment)

          implicit none

          integer(ikind), dimension(2,2), intent(out)  :: border_changes
          integer(ikind), dimension(2,2), intent(in)   :: final_alignment
          integer(ikind), dimension(2,2), intent(inout):: bf_alignment

          border_changes(1,1) = final_alignment(1,1) - bf_alignment(1,1)
          border_changes(2,1) = 0
          border_changes(1,2) = final_alignment(1,2) - bf_alignment(1,2)
          border_changes(2,2) = final_alignment(2,2) - bf_alignment(2,2)

          bf_alignment(1,1) = final_alignment(1,1)
          bf_alignment(2,1) = align_N
          bf_alignment(1,2) = final_alignment(1,2)
          bf_alignment(2,2) = final_alignment(2,2)

        end subroutine get_border_changes_and_new_alignment_N


        subroutine get_border_changes_and_new_alignment_S(
     $     border_changes, final_alignment, bf_alignment)

          implicit none

          integer(ikind), dimension(2,2), intent(out)  :: border_changes
          integer(ikind), dimension(2,2), intent(in)   :: final_alignment
          integer(ikind), dimension(2,2), intent(inout):: bf_alignment
          
          
          border_changes(1,1) = final_alignment(1,1) - bf_alignment(1,1)
          border_changes(2,1) = final_alignment(2,1) - bf_alignment(2,1)
          border_changes(1,2) = final_alignment(1,2) - bf_alignment(1,2)
          border_changes(2,2) = 0

          bf_alignment(1,1) = final_alignment(1,1)
          bf_alignment(2,1) = final_alignment(2,1)
          bf_alignment(1,2) = final_alignment(1,2)
          bf_alignment(2,2) = align_S

        end subroutine get_border_changes_and_new_alignment_S


        subroutine get_border_changes_and_new_alignment_E(
     $     border_changes, final_alignment, bf_alignment)

          implicit none

          integer(ikind), dimension(2,2), intent(out)  :: border_changes
          integer(ikind), dimension(2,2), intent(in)   :: final_alignment
          integer(ikind), dimension(2,2), intent(inout):: bf_alignment
          
          border_changes(1,1) = 0
          border_changes(2,1) = final_alignment(2,1) - bf_alignment(2,1)
          border_changes(1,2) = final_alignment(1,2) - bf_alignment(1,2)
          border_changes(2,2) = final_alignment(2,2) - bf_alignment(2,2)

          bf_alignment(1,1) = align_E
          bf_alignment(2,1) = final_alignment(2,1)
          bf_alignment(1,2) = final_alignment(1,2)
          bf_alignment(2,2) = final_alignment(2,2)

        end subroutine get_border_changes_and_new_alignment_E


        subroutine get_border_changes_and_new_alignment_W(
     $     border_changes, final_alignment, bf_alignment)

          implicit none

          integer(ikind), dimension(2,2), intent(out)  :: border_changes
          integer(ikind), dimension(2,2), intent(in)   :: final_alignment
          integer(ikind), dimension(2,2), intent(inout):: bf_alignment
          
          border_changes(1,1) = final_alignment(1,1) - bf_alignment(1,1)
          border_changes(2,1) = final_alignment(2,1) - bf_alignment(2,1)
          border_changes(1,2) = 0
          border_changes(2,2) = final_alignment(2,2) - bf_alignment(2,2)

          bf_alignment(1,1) = final_alignment(1,1)
          bf_alignment(2,1) = final_alignment(2,1)
          bf_alignment(1,2) = align_W
          bf_alignment(2,2) = final_alignment(2,2)

        end subroutine get_border_changes_and_new_alignment_W


        function is_reallocation_needed(border_changes)
     $     result(reallocation_needed)

          implicit none

          integer(ikind), dimension(2,2), intent(in) :: border_changes
          logical                                    :: reallocation_needed


          reallocation_needed = (border_changes(1,1).ne.0).or.
     $                          (border_changes(1,2).ne.0).or.
     $                          (border_changes(2,1).ne.0).or.
     $                          (border_changes(2,2).ne.0)


        end function is_reallocation_needed


        subroutine create_map_from_interior(
     $     new_x_map, bf_x_map, interior_x_map,
     $     i_min1, interior_i_max1,
     $     i_min3, i_max, i_match,
     $     i_min4, interior_i_max2,
     $     bf_alignment_i_min)
        
          implicit none

          real(rkind)   , dimension(:), intent(out) :: new_x_map
          real(rkind)   , dimension(:), intent(in)  :: bf_x_map
          real(rkind)   , dimension(:), intent(in)  :: interior_x_map
          integer(ikind)              , intent(in)  :: i_min1
          integer(ikind)              , intent(in)  :: interior_i_max1
          integer(ikind)              , intent(in)  :: i_min3
          integer(ikind)              , intent(in)  :: i_max
          integer(ikind)              , intent(in)  :: i_match
          integer(ikind)              , intent(in)  :: i_min4
          integer(ikind)              , intent(in)  :: interior_i_max2
          integer(ikind)              , intent(in)  :: bf_alignment_i_min

          
          integer(ikind) :: i
          integer(ikind) :: l_to_g_coord
          integer(ikind) :: g_coord
          real(rkind)    :: dx
          integer(ikind) :: size_interior_x


          !convert local to general coordinates
          l_to_g_coord = bf_alignment_i_min-(bc_size+1)

          !left outside domain
          dx = interior_x_map(2)-interior_x_map(1)

          do i=1, i_min1
             g_coord      =  l_to_g_coord + i
             new_x_map(i) = interior_x_map(1) + (g_coord-1)*dx
          end do

          !left inside domain
          do i=1, interior_i_max1
             new_x_map(i_min1+i) = interior_x_map(l_to_g_coord+i_min1+i)
          end do
          
          !copy of the previous x_map
          do i=1, i_max
             new_x_map(i_min3+i) = bf_x_map(i_match+i)
          end do
          
          !right inside domain
          do i=1, interior_i_max2
             new_x_map(i_min4+i) = interior_x_map(l_to_g_coord+i_min4+i)
          end do

          !right outside domain
          size_interior_x = size(interior_x_map,1)
          dx = interior_x_map(size_interior_x)-
     $         interior_x_map(size_interior_x-1)

          do i=i_min4+interior_i_max2+1, size(new_x_map,1)

             g_coord      = l_to_g_coord + i

             new_x_map(i) = interior_x_map(size_interior_x) +
     $                      (g_coord-size_interior_x)*dx

          end do

        end subroutine create_map_from_interior


        subroutine create_map_right(
     $     new_y_map,
     $     bf_y_map,
     $     interior_y_map,
     $     size_interior_y,
     $     j_max)

          implicit none

          real(rkind), dimension(:), intent(out) :: new_y_map
          real(rkind), dimension(:), intent(in)  :: bf_y_map
          real(rkind), dimension(:), intent(in)  :: interior_y_map
          integer(ikind)           , intent(in)  :: size_interior_y
          integer(ikind)           , intent(in)  :: j_max

          integer(ikind) :: j
          real(rkind)    :: dy

          !copy previous map
          do j=1, j_max
             new_y_map(j) = bf_y_map(j)
          end do

          !extend the map to the right
          dy = interior_y_map(size_interior_y) -
     $         interior_y_map(size_interior_y-1)

          do j=j_max+1, size(new_y_map,1)
             new_y_map(j) = new_y_map(j_max) + (j-j_max)*dy
          end do

        end subroutine create_map_right

      
        subroutine create_map_left(
     $     new_y_map, bf_y_map, interior_y_map,
     $     j_start, j_min)

          implicit none

          real(rkind), dimension(:), intent(out) :: new_y_map
          real(rkind), dimension(:), intent(in)  :: bf_y_map
          real(rkind), dimension(:), intent(in)  :: interior_y_map
          integer(ikind)           , intent(in)  :: j_start
          integer(ikind)           , intent(in)  :: j_min

          real(rkind)    :: dy
          integer(ikind) :: j

          !extend the map to the left
          dy = interior_y_map(2) - interior_y_map(1)
          do j=1, j_start
             new_y_map(j) = bf_y_map(j_start+1-j_min) - (j_start+1-j)*dy
          end do

          !copy the previous map
          do j=j_start+1, size(new_y_map,1)
             new_y_map(j) = bf_y_map(j-j_min)
          end do

        end subroutine create_map_left

      end module bf_layer_reallocate_module
