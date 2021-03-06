      program test_nbf_list_prog

        use nbf_list_class      , only : nbf_list
        use bf_mainlayer_class  , only : bf_mainlayer
        use bf_sublayer_class   , only : bf_sublayer
        use parameters_constant , only : N,S,E,W
        use parameters_input    , only : nx,ny,ne
        use parameters_kind     , only : ikind, rkind
        use test_bf_layer_module, only : print_interior_data,
     $                                   ini_nodes,
     $                                   ini_grdpts_id,
     $                                   ini_cst_nodes
        use test_nbf_list_module, only : ini_alignment,
     $                                   print_nbf_list

        implicit none

        
        real(rkind)       , dimension(nx,ny,ne) :: nodes
        integer           , dimension(nx,ny)    :: grdpts_id
        integer           , dimension(4)        :: bf_layer_loc
        character(2)      , dimension(4)        :: bf_layer_char

        type(bf_mainlayer), dimension(4)        :: bf_mainlayers
        type(nbf_list)    , dimension(4,2)      :: nbf_lists
        type(bf_sublayer) , pointer             :: added_sublayer
        type(bf_sublayer) , pointer             :: added_sublayer2

        integer(ikind)    , dimension(4,5,2,2)  :: test_alignment
        integer(ikind)    , dimension(2,2)      :: alignment
        integer           , dimension(4,2)      :: neighbors
        real(rkind)                             :: scale

        integer :: g,h,i,j

        real(rkind) :: dx,dy

        !initialize the nodes and the grdpts_id
        call ini_nodes(nodes)
        call ini_grdpts_id(grdpts_id)

        !print the nodes
        call print_interior_data(
     $       nodes, grdpts_id,
     $       'interior_nodes.dat',
     $       'interior_grdpts_id.dat',
     $       'interior_sizes.dat')

        !buffer layers tested
        bf_layer_loc  = [N,S,E,W]
        bf_layer_char = ['N_','S_','E_','W_']
        
        neighbors(N,1) = W
        neighbors(N,2) = E
        neighbors(S,1) = W
        neighbors(S,2) = E
        neighbors(W,1) = S
        neighbors(W,2) = N
        neighbors(E,1) = S
        neighbors(E,2) = N


        !initialize the alignment for all the buffer layers
        call ini_alignment(test_alignment)


        !initialize the main layers
        do j=1,4
           call bf_mainlayers(j)%ini(j)           
        end do

        
        !initialize the 
        do j=1,2
           do i=1,4
              call nbf_lists(i,j)%ini()
           end do
        end do


        !add the buffer layers to the mainlayers
        !+ add the links to the nbf_lists
        !loop over the cardinal coordinates
        print '()'
        print '(''buffer layer alignments'')'
        print '(''-----------------------'')'
        do j=1,2

           !loop over the number of buffer layers
           !per cardinal coordinate
           do i=1,5

              !alignment for the buffer layer
              do g=1,2
                 do h=1,2
                    alignment(h,g) = test_alignment(j,i,h,g)
                 end do
              end do

              !print the alignment
              print '(A2,I1,'' ('',2I3,'')  ('',2I3,'')'')',
     $             bf_layer_char(j), i,
     $             alignment(1,1), alignment(1,2),
     $             alignment(2,1), alignment(2,2)

              !allocate the buffer layer
              added_sublayer => bf_mainlayers(j)%add_sublayer(
     $             nodes,alignment,dx,dy)

              select case(i)
                case(1,4)
                   call nbf_lists(j,1)%add_link_in_list(added_sublayer)
                case(3,5)
                   call nbf_lists(j,2)%add_link_in_list(added_sublayer)
              end select

           end do
        end do

        do j=3,4

           !loop over the number of buffer layers
           !per cardinal coordinate
           do i=1,3

              !alignment for the buffer layer
              do g=1,2
                 do h=1,2
                    alignment(h,g) = test_alignment(j,i,h,g)
                 end do
              end do

              !print the alignment
              print '(A2,I1,'' ('',2I3,'')  ('',2I3,'')'')',
     $             bf_layer_char(j), i,
     $             alignment(1,1), alignment(1,2),
     $             alignment(2,1), alignment(2,2)

              !allocate the buffer layer
              added_sublayer => bf_mainlayers(j)%add_sublayer(
     $             nodes,alignment,dx,dy)

              select case(i)
                case(1)
                   call nbf_lists(j,1)%add_link_in_list(added_sublayer)
                case(3)
                   call nbf_lists(j,2)%add_link_in_list(added_sublayer)
              end select

           end do
        end do
        print '(''-----------------------'')'
        print '()'
              

        !print the main layers before the tests
        do j=1,4
           call bf_mainlayers(j)%print_binary(
     $          'nodes1.dat',
     $          'grdpt_id1.dat',
     $          'sizes1.dat')

        end do


        !print the content of the list after add
        print '()'
        print '(''nbf_list content'')'
        print '(''-----------------------'')'
        do j=1,2
           do i=1,4
              print '(A1,''_'',A1,'' nbf_list:'')',
     $             bf_layer_char(i),
     $             bf_layer_char(neighbors(i,j))
              call print_nbf_list(nbf_lists(i,j))
           end do
        end do
        print '(''-----------------------'')'
        print '()'


        !test update_link_in_list()
        added_sublayer => bf_mainlayers(N)%get_head_sublayer()
        added_sublayer2 => bf_mainlayers(N)%get_tail_sublayer()
        call nbf_lists(N,1)%update_link_in_list(added_sublayer,added_sublayer2)

        print '()'
        print '(''nbf_list_N_W content after update'')'
        print '(''---------------------------------'')'
        call print_nbf_list(nbf_lists(N,1))
        print '()'

        print '()'
        print '(''nbf_list_N_W content after re-update'')'
        print '(''------------------------------------'')'
        added_sublayer => bf_mainlayers(N)%get_head_sublayer()
        added_sublayer2 => bf_mainlayers(N)%get_tail_sublayer()
        call nbf_lists(N,1)%update_link_in_list(added_sublayer,added_sublayer2)
        call print_nbf_list(nbf_lists(N,1))
        print '()'

        !test remove link from list()
        print '()'
        print '(''nbf_list_N_W content after remove'')'
        print '(''---------------------------------'')'
        call nbf_lists(N,1)%remove_link_from_list(added_sublayer)
        call nbf_lists(N,1)%remove_link_from_list(added_sublayer2)
        added_sublayer => bf_mainlayers(N)%get_head_sublayer()
        added_sublayer => added_sublayer%get_next()
        call nbf_lists(N,1)%remove_link_from_list(added_sublayer)
        call print_nbf_list(nbf_lists(N,1))
        print '()'


        !initialization of the nodes of the different layers
        scale = 0.07
        do j=1,4
           added_sublayer => bf_mainlayers(j)%get_head_sublayer()

           do i=1, bf_mainlayers(j)%get_nb_sublayers()
              
              !initialize the nodes of the buffer layer with a constant value
              call ini_cst_nodes(added_sublayer, (3*(j-1)+i)*scale)
              added_sublayer => added_sublayer%get_next()

           end do
        end do


        !test copy_from_neighbors_to_bf_layer
        print '()'
        print '(''copy_from_neighbors_to_bf_layer() '')'
        print '(''copy_from_neighbor2_to_bf_layer() '')'
        print '(''WARNING: all N neighbors for the W were removed'')'
        print '(''------------------------'')'
        do j=1,4
           added_sublayer => bf_mainlayers(j)%get_head_sublayer()
           do i=1, bf_mainlayers(j)%get_nb_sublayers()
              
              !potential neighbor1 buffer layers
              do g=1,2

                 select case(j)
                   case(S,W)
                      call nbf_lists(neighbors(j,g),1)%copy_from_neighbors_to_bf_layer(
     $                     g, added_sublayer)
                   case(N,E)
                      call nbf_lists(neighbors(j,g),2)%copy_from_neighbors_to_bf_layer(
     $                     g, added_sublayer)
                 end select
                 
              end do

              added_sublayer => added_sublayer%get_next()

           end do
        end do
        print '(''------------------------'')'
        print '()'
        

        !print the main layers before the tests
        do j=1,4
           call bf_mainlayers(j)%print_binary(
     $          'nodes2.dat',
     $          'grdpt_id2.dat',
     $          'sizes2.dat')

        end do


        !test copy_from_neighbors_to_bf_layer
        print '()'
        print '(''copy_from_neighbors_to_bf_layer() '')'
        print '(''copy_from_neighbor2_to_bf_layer() '')'
        print '(''------------------------'')'
        do j=1,4
           added_sublayer => bf_mainlayers(j)%get_head_sublayer()
           do i=1, bf_mainlayers(j)%get_nb_sublayers()
              
              !potential neighbor1 buffer layers
              do g=1,2

                 select case(j)
                   case(S,W)
                      call nbf_lists(neighbors(j,g),1)%copy_to_neighbors_from_bf_layer(
     $                     g, added_sublayer)
                   case(N,E)
                      call nbf_lists(neighbors(j,g),2)%copy_to_neighbors_from_bf_layer(
     $                     g, added_sublayer)
                 end select
                 
              end do

              added_sublayer => added_sublayer%get_next()

           end do
        end do
        print '(''------------------------'')'
        print '()'


        !print the main layers before the tests
        do j=1,4
           call bf_mainlayers(j)%print_binary(
     $          'nodes3.dat',
     $          'grdpt_id3.dat',
     $          'sizes3.dat')

        end do

      end program test_nbf_list_prog
