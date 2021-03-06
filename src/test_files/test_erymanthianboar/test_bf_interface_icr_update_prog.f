      program test_bf_interface_icr_update_prog

        use bf_mainlayer_class, only :
     $     bf_mainlayer

        use bf_sublayer_class, only :
     $       bf_sublayer

        use bf_detector_icr_list_class, only :
     $       bf_detector_icr_list

        use bf_interface_icr_class, only :
     $       bf_interface_icr

        use parameters_bf_layer, only :
     $       search_dcr

        use parameters_constant, only :
     $       N,S,E,W

        use parameters_input, only :
     $       npx,npy,ntx,nty,
     $       nx,ny,ne,bc_size,
     $       x_min,x_max,
     $       y_min,y_max,
     $       dt,
     $       search_dcr

        use parameters_kind, only :
     $       rkind

        use pmodel_eq_class, only :
     $       pmodel_eq

        use test_bf_layer_module, only :
     $       ini_grdpts_id

        use test_cases_interface_update_module, only :
     $       update_nodes,
     $       print_state

        implicit none


        type(bf_interface_icr)              :: interface_used
        real(rkind)   , dimension(nx,ny,ne) :: interior_nodes
        integer       , dimension(nx,ny)    :: grdpts_id
        type(pmodel_eq)                     :: p_model
        integer       , parameter           :: test_case=8

        integer :: i

        real(rkind) :: dx
        real(rkind) :: dy

        integer :: timestep
        integer :: file_index

        !check the inputs
        if(
     $       (npx.ne.1).or.(npy.ne.1).or.
     $       (ntx.ne.40).or.(nty.ne.40).or.
     $       (x_min.ne.-3.0d0).or.(x_max.ne.0.0d0).or.
     $       (y_min.ne.0.0d0).or.(y_max.ne.3.0d0).or.
     $       (dt.ne.0.02d0).or.(ne.ne.4).or.
     $       (search_dcr.ne.4)) then

           print '(''the test requires: '')'
           print '(''npx = 1'')'
           print '(''npy = 1'')'
           print '(''ntx = 40'')'
           print '(''nty = 40'')'
           print '(''x_min = -3.0d0'')'
           print '(''x_max = 0.0d0'')'
           print '(''y_min = 0.0d0'')'
           print '(''y_max = 3.0d0'')'
           print '(''dt = 0.02d0'')'
           print '(''ne = 4'')'
           print '(''search_dcr = 4'')'
           stop ''

        end if


        dx = 1.0d0/(nx-2*bc_size)
        dy = 1.0d0/(ny-2*bc_size)


        timestep = 0
        file_index = 0

        !initialization of the grdpts_id
        call ini_grdpts_id(grdpts_id)

        !initialization of the interface
        call interface_used%ini()

        !initialization of the nodes
        call update_nodes(
     $       test_case,
     $       timestep,dx,dy,
     $       interior_nodes, interface_used)

        !printing the initial state
        call print_state(
     $       interior_nodes, grdpts_id,
     $       interface_used,
     $       file_index)
        file_index = file_index+1

        timestep = timestep+1


        !update the buffer layers
        do i=1,30

           call interface_used%update_bf_layers_with_idetectors(
     $          interior_nodes, dx, dy, p_model)

           call update_nodes(
     $          test_case,
     $          timestep,dx,dy,
     $          interior_nodes, interface_used)

           if(mod(timestep,4).eq.0) then
              call print_state(
     $             interior_nodes, grdpts_id,
     $             interface_used,
     $             file_index)
              file_index = file_index+1
           end if

           timestep = timestep+1

        end do


        !remove a buffer layer
        call test_remove_sublayers(
     $       test_case,
     $       interior_nodes,
     $       grdpts_id,
     $       interface_used,
     $       file_index)

                

        contains

        subroutine test_remove_sublayers(
     $       test_case,
     $       nodes,
     $       grdpts_id,
     $       interface_used,
     $       file_index)

          implicit none
          
          integer                         , intent(in)    :: test_case
          real(rkind), dimension(nx,ny,ne), intent(in)    :: nodes
          integer    , dimension(nx,ny)   , intent(in)    :: grdpts_id
          class(bf_interface_icr)         , intent(inout) :: interface_used
          integer                         , intent(inout) :: file_index

          integer, dimension(2) :: mainlayer_id
          integer :: i

          select case(test_case)
            case(1)
               mainlayer_id = [E,W]
            case(2)
               mainlayer_id = [E,W]
            case(3)
               mainlayer_id = [N,W]
            case(4)
               mainlayer_id = [S,W]
            case(5)
               mainlayer_id = [N,E]
            case(6)
               mainlayer_id = [S,E]
            case(7)
               mainlayer_id = [N,W]
            case(8)
               mainlayer_id = [S,W]
            case default
               print '(''test_bf_interface_icr_update_prog'')'
               print '(''test_remove_sublayers'')'
               stop 'test case not recognized'
          end select

          do i=1,2

             call test_remove_sublayer(
     $            nodes,
     $            grdpts_id,
     $            interface_used,
     $            mainlayer_id(i),
     $            file_index)

          end do

        end subroutine test_remove_sublayers


        subroutine test_remove_sublayer(
     $       nodes,
     $       grdpts_id,
     $       interface_used,
     $       mainlayer_id,
     $       file_index)
        
          implicit none
          
          real(rkind), dimension(nx,ny,ne), intent(in)    :: nodes
          integer    , dimension(nx,ny)   , intent(in)    :: grdpts_id
          class(bf_interface_icr)         , intent(inout) :: interface_used
          integer                         , intent(in)    :: mainlayer_id
          integer                         , intent(inout) :: file_index

          type(bf_mainlayer), pointer :: mainlayer_ptr
          type(bf_sublayer) , pointer :: sublayer_ptr

          !remove the head sublayer
          mainlayer_ptr => interface_used%get_mainlayer(mainlayer_id)
          if(associated(mainlayer_ptr)) then
             sublayer_ptr => mainlayer_ptr%get_head_sublayer()
             call interface_used%remove_sublayer(sublayer_ptr)
          end if

          !print the interface
          call print_state(nodes, grdpts_id, interface_used, file_index)
          file_index = file_index+1

        end subroutine test_remove_sublayer

      end program test_bf_interface_icr_update_prog
