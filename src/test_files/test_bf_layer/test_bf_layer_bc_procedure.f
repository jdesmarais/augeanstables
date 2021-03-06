      program test_bf_layer_bc_procedure

        use parameters_bf_layer, only :
     $       bc_pt,
     $       bc_interior_pt,
     $       interior_pt,
     $       BF_SUCCESS,
     $       SW_corner_type,
     $       SE_corner_type,
     $       NW_corner_type,
     $       NE_corner_type,
     $       S_edge_type,
     $       E_edge_type,
     $       W_edge_type,
     $       N_edge_type,
     $       SE_edge_type,
     $       SW_edge_type,
     $       NE_edge_type,
     $       NW_edge_type

        use bf_layer_bc_procedure_module, only :
     $       get_bc_interior_pt_procedure

        implicit none

        logical :: detailled
        logical :: test_loc
        logical :: test_validated
        
        detailled = .true.
        test_validated = .true.


        test_loc = test_get_bc_interior_pt_procedure(detailled)
        test_validated = test_validated.and.test_loc

        print '(''test_get_bc_interior_pt_procedure: '',L1)', test_loc
        print '()'

        print '(''test_validated: '',L1)', test_validated

        contains


        function test_get_bc_interior_pt_procedure(detailled)
     $       result(test_validated)

          implicit none

          logical, intent(in) :: detailled
          logical             :: test_validated

          integer                              :: k
          integer, dimension(:,:), allocatable :: grdpts_id
          integer                              :: test_i
          integer                              :: test_j
          integer                              :: test_procedure_type
          integer                              :: test_i_proc
          integer                              :: test_j_proc
          integer                              :: procedure_type
          integer                              :: i_proc
          integer                              :: j_proc
          logical                              :: ierror


          test_validated = .true.

          
          do k=1,60

             !input
             call make_test_bf_layer_bc_procedure(
     $            k,
     $            grdpts_id,
     $            test_i,
     $            test_j,
     $            test_procedure_type,
     $            test_i_proc,
     $            test_j_proc)

             !output
             call get_bc_interior_pt_procedure(
     $            test_i,
     $            test_j,
     $            grdpts_id,
     $            procedure_type,
     $            i_proc,
     $            j_proc,
     $            ierror)

             !validation
             if(ierror.eq.BF_SUCCESS) then

                test_loc = test_procedure_type.eq.procedure_type
                test_loc = test_loc.and.(test_i_proc.eq.i_proc)
                test_loc = test_loc.and.(test_j_proc.eq.j_proc)

             else

                test_loc = .false.

             end if

             test_validated = test_validated.and.test_loc


             if(allocated(grdpts_id)) then
                deallocate(grdpts_id)
             end if

             !detailled
             if(detailled) then

                if(ierror.eq.BF_SUCCESS) then

                   if(.not.test_loc) then

                      print '(''test '',I2,'': failed'')', k

                      print '(''  -  procedure_type: '', I2, '' -> '', I2)',
     $                     procedure_type, test_procedure_type
                      print '(''  -  i_proc        : '', I2, '' -> '', I2)',
     $                     i_proc, test_i_proc
                      print '(''  -  j_proc        : '', I2, '' -> '', I2)',
     $                     j_proc, test_j_proc
                   
                   end if

                else
                   print '(''test '',I2,'': failed'')',k
                end if

             end if

          end do          
 
          print '()'

        end function test_get_bc_interior_pt_procedure        


        subroutine make_test_bf_layer_bc_procedure(
     $       test_id,
     $       grdpts_id,
     $       test_i,
     $       test_j,
     $       test_procedure,
     $       test_i_proc,
     $       test_j_proc)
        
          implicit none

          integer                             , intent(in)  :: test_id
          integer, dimension(:,:), allocatable, intent(out) :: grdpts_id
          integer                             , intent(out) :: test_i
          integer                             , intent(out) :: test_j
          integer                             , intent(out) :: test_procedure
          integer                             , intent(out) :: test_i_proc
          integer                             , intent(out) :: test_j_proc

          
          allocate(grdpts_id(3,3))
          test_i = 2
          test_j = 2

          select case(test_id)

            ! -------
            !| 3 3 3 |
            !| 2 2 3 |
            !| 1 2 3 | 
            ! -------
            case(1)
               grdpts_id = reshape(
     $              (/
     $              interior_pt,bc_interior_pt,bc_pt,
     $              bc_interior_pt,bc_interior_pt,bc_pt,
     $              bc_pt,bc_pt,bc_pt
     $              /),
     $              (/3,3/))
               test_procedure = NE_corner_type
               test_i_proc    = 2
               test_j_proc    = 2

            ! -------
            !| 1 1 1 |
            !| 2 2 1 |
            !| 3 2 1 |
            ! -------
            case(2)
               grdpts_id = reshape( (/
     $              bc_pt,bc_interior_pt,interior_pt,
     $              bc_interior_pt,bc_interior_pt,interior_pt,
     $              interior_pt,interior_pt,interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = SW_edge_type
               test_i_proc    = 1
               test_j_proc    = 1

            ! -------
            !| 3 3 3 |
            !| 3 2 2 |
            !| 3 2 1 | 
            ! -------
            case(3)
               grdpts_id = reshape(
     $              (/
     $              bc_pt,bc_interior_pt,interior_pt,
     $              bc_pt,bc_interior_pt,bc_interior_pt,
     $              bc_pt,bc_pt,bc_pt
     $              /),
     $              (/3,3/))
               test_procedure = NW_corner_type
               test_i_proc    = 1
               test_j_proc    = 2

            ! -------
            !| 1 1 1 |
            !| 1 2 2 |
            !| 1 2 3 |
            ! -------
            case(4)
               grdpts_id = reshape( (/
     $              interior_pt,bc_interior_pt,bc_pt,
     $              interior_pt,bc_interior_pt,bc_interior_pt,
     $              interior_pt,interior_pt,interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = SE_edge_type
               test_i_proc    = 2
               test_j_proc    = 1

            ! -------
            !| 3 2 1 |
            !| 3 2 2 |
            !| 3 3 3 | 
            ! -------
            case(5)
               grdpts_id =  reshape(
     $              (/
     $              bc_pt,bc_pt,bc_pt,
     $              bc_pt,bc_interior_pt,bc_interior_pt,
     $              bc_pt,bc_interior_pt,interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = SW_corner_type
               test_i_proc    = 1
               test_j_proc    = 1

            ! -------
            !| 1 2 3 |
            !| 1 2 2 |
            !| 1 1 1 | 
            ! -------
            case(6)
               grdpts_id = reshape( (/
     $              interior_pt,interior_pt,interior_pt,
     $              interior_pt,bc_interior_pt,bc_interior_pt,
     $              interior_pt,bc_interior_pt,bc_pt
     $              /),
     $              (/3,3/))
               test_procedure = NE_edge_type
               test_i_proc    = 2
               test_j_proc    = 2
             
            ! -------
            !| 1 2 3 |
            !| 2 2 3 |
            !| 3 3 3 | 
            ! -------
            case(7)
               grdpts_id = reshape(
     $              (/
     $              bc_pt,bc_pt,bc_pt,
     $              bc_interior_pt,bc_interior_pt,bc_pt,
     $              interior_pt,bc_interior_pt,bc_pt
     $              /),
     $              (/3,3/))
               test_procedure = SE_corner_type
               test_i_proc    = 2
               test_j_proc    = 1

            ! -------
            !| 3 2 1 |
            !| 2 2 1 |
            !| 1 1 1 | 
            ! -------
            case(8)
               grdpts_id = reshape(
     $              (/
     $              interior_pt,interior_pt,interior_pt,
     $              bc_interior_pt,bc_interior_pt,interior_pt,
     $              bc_pt,bc_interior_pt,interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = NW_edge_type
               test_i_proc    = 1
               test_j_proc    = 2

            ! -------
            !| 3 3 3 |
            !| 2 2 2 |
            !| 1 1 1 |
            ! -------
            case(9)
               grdpts_id = reshape( (/
     $              interior_pt,interior_pt,interior_pt,
     $              bc_interior_pt,bc_interior_pt,bc_interior_pt,
     $              bc_pt,bc_pt,bc_pt
     $              /),
     $              (/3,3/))
               test_procedure = N_edge_type
               test_i_proc    = 2
               test_j_proc    = 2

            ! -------
            !| 1 1 1 |
            !| 2 2 2 |
            !| 3 3 3 |
            ! -------
            case(10)
               grdpts_id = reshape( (/
     $              bc_pt,bc_pt,bc_pt,
     $              bc_interior_pt,interior_pt,bc_interior_pt,
     $              interior_pt,interior_pt,interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = S_edge_type
               test_i_proc    = 2
               test_j_proc    = 2

            ! -------
            !| 3 2 1 |
            !| 3 2 1 |
            !| 3 2 1 |
            ! -------
            case(11)
               grdpts_id = reshape( (/
     $              bc_pt,bc_interior_pt,interior_pt,
     $              bc_pt,bc_interior_pt,interior_pt,
     $              bc_pt,bc_interior_pt,interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = W_edge_type
               test_i_proc    = 2
               test_j_proc    = 2

            ! -------
            !| 1 2 3 |
            !| 1 2 3 |
            !| 1 2 3 |
            ! -------
            case(12)
               grdpts_id = reshape( (/
     $              interior_pt,bc_interior_pt,bc_pt,
     $              interior_pt,bc_interior_pt,bc_pt,
     $              interior_pt,bc_interior_pt,bc_pt
     $              /),
     $              (/3,3/))
               test_procedure = E_edge_type
               test_i_proc    = 2
               test_j_proc    = 2

            ! -------
            !| 3 3 3 |
            !| 3 2 2 |
            !| 2 2 1 |
            ! -------
            case(13)
               grdpts_id = reshape( (/
     $              bc_interior_pt,bc_interior_pt,interior_pt,
     $              bc_pt,bc_interior_pt,bc_interior_pt,
     $              bc_pt,bc_pt,bc_pt
     $              /),
     $              (/3,3/))
               test_procedure = NW_corner_type
               test_i_proc    = 1
               test_j_proc    = 2

            ! -------
            !| 1 1 1 |
            !| 1 2 2 |
            !| 2 2 3 |
            ! -------
            case(14)
               grdpts_id = reshape( (/
     $              bc_interior_pt,bc_interior_pt,bc_pt,
     $              interior_pt,bc_interior_pt,bc_interior_pt,
     $              interior_pt,interior_pt,interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = SE_edge_type
               test_i_proc    = 2
               test_j_proc    = 1

            ! -------
            !| 3 3 3 |
            !| 2 2 3 |
            !| 1 2 2 |
            ! -------
            case(15)
               grdpts_id = reshape( (/
     $              interior_pt,bc_interior_pt,bc_interior_pt,
     $              bc_interior_pt,bc_interior_pt,bc_pt,
     $              bc_pt,bc_pt,bc_pt
     $              /),
     $              (/3,3/))
               test_procedure = NE_corner_type
               test_i_proc    = 2
               test_j_proc    = 2

            ! -------
            !| 1 1 1 |
            !| 2 2 1 |
            !| 3 2 2 |
            ! -------
            case(16)
               grdpts_id = reshape( (/
     $              bc_pt,bc_interior_pt,bc_interior_pt,
     $              bc_interior_pt,bc_interior_pt,interior_pt,
     $              interior_pt,interior_pt,interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = SW_edge_type
               test_i_proc    = 1
               test_j_proc    = 1

            ! -------
            !| 1 2 2 |
            !| 2 2 3 |
            !| 3 3 3 |
            ! -------
            case(17)
               grdpts_id = reshape( (/
     $              bc_pt,bc_pt,bc_pt,
     $              bc_interior_pt,bc_interior_pt,bc_pt,
     $              interior_pt,bc_interior_pt,bc_interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = SE_corner_type
               test_i_proc    = 2
               test_j_proc    = 1

            ! -------
            !| 3 2 2 |
            !| 2 2 1 |
            !| 1 1 1 |
            ! -------
            case(18)
               grdpts_id = reshape( (/
     $              interior_pt,interior_pt,interior_pt,
     $              bc_interior_pt,bc_interior_pt,interior_pt,
     $              bc_pt,bc_interior_pt,bc_interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = NW_edge_type
               test_i_proc    = 1
               test_j_proc    = 2

            ! -------
            !| 2 2 1 |
            !| 3 2 2 |
            !| 3 3 3 |
            ! -------
            case(19)
               grdpts_id = reshape( (/
     $              bc_pt,bc_pt,bc_pt,
     $              bc_pt,bc_interior_pt,bc_interior_pt,
     $              bc_interior_pt,bc_interior_pt,interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = SW_corner_type
               test_i_proc    = 1
               test_j_proc    = 1

            ! -------
            !| 2 2 3 |
            !| 1 2 2 |
            !| 1 1 1 |
            ! -------
            case(20)
               grdpts_id = reshape( (/
     $              interior_pt,interior_pt,interior_pt,
     $              interior_pt,bc_interior_pt,bc_interior_pt,
     $              bc_interior_pt,bc_interior_pt,bc_pt
     $              /),
     $              (/3,3/))
               test_procedure = NE_edge_type
               test_i_proc    = 2
               test_j_proc    = 2

            ! -------
            !| 1 2 3 |
            !| 2 2 3 |
            !| 2 3 3 |
            ! -------
            case(21)
               grdpts_id = reshape( (/
     $              bc_interior_pt,bc_pt,bc_pt,
     $              bc_interior_pt,bc_interior_pt,bc_pt,
     $              interior_pt,bc_interior_pt,bc_pt
     $              /),
     $              (/3,3/))
               test_procedure = SE_corner_type
               test_i_proc    = 2
               test_j_proc    = 1

            ! -------
            !| 3 2 1 |
            !| 2 2 1 |
            !| 2 1 1 |
            ! -------
            case(22)
               grdpts_id = reshape( (/
     $              bc_interior_pt,interior_pt,interior_pt,
     $              bc_interior_pt,bc_interior_pt,interior_pt,
     $              bc_pt,bc_interior_pt,interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = NW_edge_type
               test_i_proc    = 1
               test_j_proc    = 2

            ! -------
            !| 3 2 1 |
            !| 3 2 2 |
            !| 3 3 2 |
            ! -------
            case(23)
               grdpts_id = reshape( (/
     $              bc_pt,bc_pt,bc_interior_pt,
     $              bc_pt,bc_interior_pt,bc_interior_pt,
     $              bc_pt,bc_interior_pt,interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = SW_corner_type
               test_i_proc    = 1
               test_j_proc    = 1

            ! -------
            !| 1 2 3 |
            !| 1 2 2 |
            !| 1 1 2 |
            ! -------
            case(24)
               grdpts_id = reshape( (/
     $              interior_pt,interior_pt,bc_interior_pt,
     $              interior_pt,bc_interior_pt,bc_interior_pt,
     $              interior_pt,bc_interior_pt,bc_pt
     $              /),
     $              (/3,3/))
               test_procedure = NE_edge_type
               test_i_proc    = 2
               test_j_proc    = 2

            ! -------
            !| 3 3 2 |
            !| 3 2 2 |
            !| 3 2 1 |
            ! -------
            case(25)
               grdpts_id = reshape( (/
     $              bc_pt, bc_interior_pt, interior_pt,
     $              bc_pt, bc_interior_pt, bc_interior_pt,
     $              bc_pt, bc_pt, bc_interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = NW_corner_type
               test_i_proc    = 1
               test_j_proc    = 2

            ! -------
            !| 1 1 2 |
            !| 1 2 2 |
            !| 1 2 3 |
            ! -------
            case(26)
               grdpts_id = reshape( (/
     $              interior_pt, bc_interior_pt, bc_pt,
     $              interior_pt, bc_interior_pt, bc_interior_pt,
     $              interior_pt, interior_pt, bc_interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = SE_edge_type
               test_i_proc    = 2
               test_j_proc    = 1

            ! -------
            !| 2 3 3 |
            !| 2 2 3 |
            !| 1 2 3 |
            ! -------
            case(27)
               grdpts_id = reshape( (/
     $              interior_pt,bc_interior_pt,bc_pt,
     $              bc_interior_pt,bc_interior_pt,bc_pt,
     $              bc_interior_pt,bc_pt,bc_pt
     $              /),
     $              (/3,3/))
               test_procedure = NE_corner_type
               test_i_proc    = 2
               test_j_proc    = 2

            ! -------
            !| 2 1 1 |
            !| 2 2 1 |
            !| 3 2 1 |
            ! -------
            case(28)
               grdpts_id = reshape( (/
     $              bc_pt,bc_interior_pt,interior_pt,
     $              bc_interior_pt,bc_interior_pt,interior_pt,
     $              bc_interior_pt,interior_pt,interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = SW_edge_type
               test_i_proc    = 1
               test_j_proc    = 1

            ! -------
            !| 3 3 3 |
            !| 2 2 2 |
            !| 2 1 1 |
            ! -------
            case(29)
               grdpts_id = reshape( (/
     $              bc_interior_pt,interior_pt,interior_pt,
     $              bc_interior_pt,bc_interior_pt,bc_interior_pt,
     $              bc_pt,bc_pt,bc_pt
     $              /),
     $              (/3,3/))
               test_procedure = N_edge_type
               test_i_proc    = 2
               test_j_proc    = 2
               
            ! -------
            !| 1 1 1 |
            !| 2 2 2 |
            !| 2 3 3 |
            ! -------
            case(30)
               grdpts_id = reshape( (/
     $              bc_interior_pt,bc_pt,bc_pt,
     $              bc_interior_pt,bc_interior_pt,bc_interior_pt,
     $              interior_pt,interior_pt,interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = SE_edge_type
               test_i_proc    = 1
               test_j_proc    = 1

            ! -------
            !| 3 3 3 |
            !| 2 2 2 |
            !| 1 1 2 |
            ! -------
            case(31)
               grdpts_id = reshape( (/
     $              interior_pt,interior_pt,bc_interior_pt,
     $              bc_interior_pt,bc_interior_pt,bc_interior_pt,
     $              bc_pt,bc_pt,bc_pt
     $              /),
     $              (/3,3/))
               test_procedure = N_edge_type
               test_i_proc    = 2
               test_j_proc    = 2

            ! -------
            !| 1 1 1 |
            !| 2 2 2 |
            !| 3 3 2 |
            ! -------
            case(32)
               grdpts_id = reshape( (/
     $              bc_pt,bc_pt,bc_interior_pt,
     $              bc_interior_pt,bc_interior_pt,bc_interior_pt,
     $              interior_pt,interior_pt,interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = SW_edge_type
               test_i_proc    = 2
               test_j_proc    = 1

            ! -------
            !| 2 1 1 |
            !| 2 2 2 |
            !| 3 3 3 |
            ! -------
            case(33)
               grdpts_id = reshape( (/
     $              bc_pt,bc_pt,bc_pt,
     $              bc_interior_pt,bc_interior_pt,bc_interior_pt,
     $              bc_interior_pt,interior_pt,interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = S_edge_type
               test_i_proc    = 2
               test_j_proc    = 2

            ! -------
            !| 2 3 3 |
            !| 2 2 2 |
            !| 1 1 1 |
            ! -------
            case(34)
               grdpts_id = reshape( (/
     $              interior_pt,interior_pt,interior_pt,
     $              bc_interior_pt,bc_interior_pt,bc_interior_pt,
     $              bc_interior_pt,bc_pt,bc_pt
     $              /),
     $              (/3,3/))
               test_procedure = NE_edge_type
               test_i_proc    = 1
               test_j_proc    = 2

            ! -------
            !| 1 1 2 |
            !| 2 2 2 |
            !| 3 3 3 |
            ! -------
            case(35)
               grdpts_id = reshape( (/
     $              bc_pt,bc_pt,bc_pt,
     $              bc_interior_pt,bc_interior_pt,bc_interior_pt,
     $              interior_pt,interior_pt,bc_interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = S_edge_type
               test_i_proc    = 2
               test_j_proc    = 2

            ! -------
            !| 3 3 2 |
            !| 2 2 2 |
            !| 1 1 1 |
            ! -------
            case(36)
               grdpts_id = reshape( (/
     $              interior_pt,interior_pt,interior_pt,
     $              bc_interior_pt,bc_interior_pt,bc_interior_pt,
     $              bc_pt,bc_pt,bc_interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = NW_edge_type
               test_i_proc    = 2
               test_j_proc    = 2

            ! -------
            !| 1 2 3 |
            !| 1 2 3 |
            !| 2 2 3 |
            ! -------
            case(37)
               grdpts_id = reshape( (/
     $              bc_interior_pt,bc_interior_pt,bc_pt,
     $              interior_pt,bc_interior_pt,bc_pt,
     $              interior_pt,bc_interior_pt,bc_pt
     $              /),
     $              (/3,3/))
               test_procedure = E_edge_type
               test_i_proc    = 2
               test_j_proc    = 2

            ! -------
            !| 3 2 1 |
            !| 3 2 1 |
            !| 2 2 1 |
            ! -------
            case(38)
               grdpts_id = reshape( (/
     $              bc_interior_pt,bc_interior_pt,interior_pt,
     $              bc_pt,bc_interior_pt,interior_pt,
     $              bc_pt,bc_interior_pt,interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = NW_edge_type
               test_i_proc    = 1
               test_j_proc    = 1

            ! -------
            !| 3 2 1 |
            !| 3 2 1 |
            !| 3 2 2 |
            ! -------
            case(39)
               grdpts_id = reshape( (/
     $              bc_pt,bc_interior_pt,bc_interior_pt,
     $              bc_pt,bc_interior_pt,interior_pt,
     $              bc_pt,bc_interior_pt,interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = W_edge_type
               test_i_proc    = 2
               test_j_proc    = 2

            ! -------
            !| 1 2 3 |
            !| 1 2 3 |
            !| 1 2 2 |
            ! -------
            case(40)
               grdpts_id = reshape( (/
     $              interior_pt,bc_interior_pt,bc_interior_pt,
     $              interior_pt,bc_interior_pt,bc_pt,
     $              interior_pt,bc_interior_pt,bc_pt
     $              /),
     $              (/3,3/))
               test_procedure = NE_edge_type
               test_i_proc    = 2
               test_j_proc    = 1

            ! -------
            !| 2 2 3 |
            !| 1 2 3 |
            !| 1 2 3 |
            ! -------
            case(41)
               grdpts_id = reshape( (/
     $              interior_pt,bc_interior_pt,bc_pt,
     $              interior_pt,bc_interior_pt,bc_pt,
     $              bc_interior_pt,bc_interior_pt,bc_pt
     $              /),
     $              (/3,3/))
               test_procedure = E_edge_type
               test_i_proc    = 2
               test_j_proc    = 2

            ! -------
            !| 2 2 1 |
            !| 3 2 1 |
            !| 3 2 1 |
            ! -------
            case(42)
               grdpts_id = reshape( (/
     $              bc_pt,bc_interior_pt,interior_pt,
     $              bc_pt,bc_interior_pt,interior_pt,
     $              bc_interior_pt,bc_interior_pt,interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = SW_edge_type
               test_i_proc    = 1
               test_j_proc    = 2

            ! -------
            !| 3 2 2 |
            !| 3 2 1 |
            !| 3 2 1 |
            ! -------
            case(43)
               grdpts_id = reshape( (/
     $              bc_pt,bc_interior_pt,interior_pt,
     $              bc_pt,bc_interior_pt,interior_pt,
     $              bc_pt,bc_interior_pt,bc_interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = W_edge_type
               test_i_proc    = 2
               test_j_proc    = 2

            ! -------
            !| 1 2 2 |
            !| 1 2 3 |
            !| 1 2 3 |
            ! -------
            case(44)
               grdpts_id = reshape( (/
     $              interior_pt,bc_interior_pt,bc_pt,
     $              interior_pt,bc_interior_pt,bc_pt,
     $              interior_pt,bc_interior_pt,bc_interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = SE_edge_type
               test_i_proc    = 2
               test_j_proc    = 2

            ! -------
            !| 3 2 2 |
            !| 3 2 1 |
            !| 2 2 1 |
            ! -------
            case(45)
               grdpts_id = reshape( (/
     $              bc_interior_pt,bc_interior_pt,interior_pt,
     $              bc_pt,bc_interior_pt,interior_pt,
     $              bc_pt,bc_interior_pt,bc_interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = NW_edge_type
               test_i_proc    = 1
               test_j_proc    = 1

            ! -------
            !| 1 2 2 |
            !| 1 2 3 |
            !| 2 2 3 |
            ! -------
            case(46)
               grdpts_id = reshape( (/
     $              bc_interior_pt,bc_interior_pt,bc_pt,
     $              interior_pt,bc_interior_pt,bc_pt,
     $              interior_pt,bc_interior_pt,bc_interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = SE_edge_type
               test_i_proc    = 2
               test_j_proc    = 2

            ! -------
            !| 2 2 1 |
            !| 3 2 1 |
            !| 3 2 2 |
            ! -------
            case(47)
               grdpts_id = reshape( (/
     $              bc_pt,bc_interior_pt,bc_interior_pt,
     $              bc_pt,bc_interior_pt,interior_pt,
     $              bc_interior_pt,bc_interior_pt,interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = SW_edge_type
               test_i_proc    = 1
               test_j_proc    = 2

            ! -------
            !| 2 2 3 |
            !| 1 2 3 |
            !| 1 2 2 |
            ! -------
            case(48)
               grdpts_id = reshape( (/
     $              interior_pt,bc_interior_pt,bc_interior_pt,
     $              interior_pt,bc_interior_pt,bc_pt,
     $              bc_interior_pt,bc_interior_pt,bc_pt
     $              /),
     $              (/3,3/))
               test_procedure = NE_edge_type
               test_i_proc    = 2
               test_j_proc    = 1

            ! -------
            !| 1 1 2 |
            !| 2 2 2 |
            !| 2 3 3 |
            ! -------
            case(49)
               grdpts_id = reshape( (/
     $              bc_interior_pt,bc_pt,bc_pt,
     $              bc_interior_pt,bc_interior_pt,bc_interior_pt,
     $              interior_pt,interior_pt,bc_interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = SE_edge_type
               test_i_proc    = 1
               test_j_proc    = 1

            ! -------
            !| 3 3 2 |
            !| 2 2 2 |
            !| 2 1 1 |
            ! -------
            case(50)
               grdpts_id = reshape( (/
     $              bc_interior_pt,interior_pt,interior_pt,
     $              bc_interior_pt,bc_interior_pt,bc_interior_pt,
     $              bc_pt,bc_pt,bc_interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = NW_edge_type
               test_i_proc    = 2
               test_j_proc    = 2

            ! -------
            !| 2 1 1 |
            !| 2 2 2 |
            !| 3 3 2 |
            ! -------
            case(51)
               grdpts_id = reshape( (/
     $              bc_pt,bc_pt,bc_interior_pt,
     $              bc_interior_pt,bc_interior_pt,bc_interior_pt,
     $              bc_interior_pt,interior_pt,interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = SW_edge_type
               test_i_proc    = 2
               test_j_proc    = 1

            ! -------
            !| 2 3 3 |
            !| 2 2 2 |
            !| 1 1 2 |
            ! -------
            case(52)
               grdpts_id = reshape( (/
     $              interior_pt,interior_pt,bc_interior_pt,
     $              bc_interior_pt,bc_interior_pt,bc_interior_pt,
     $              bc_interior_pt,bc_pt,bc_pt
     $              /),
     $              (/3,3/))
               test_procedure = NE_edge_type
               test_i_proc    = 1
               test_j_proc    = 2

            ! -------
            !| 3 3 2 |
            !| 3 2 2 |
            !| 2 2 1 |
            ! -------
            case(53)
               grdpts_id = reshape( (/
     $              bc_interior_pt,bc_interior_pt,interior_pt,
     $              bc_pt,bc_interior_pt,bc_interior_pt,
     $              bc_pt,bc_pt,bc_interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = NW_corner_type
               test_i_proc    = 1
               test_j_proc    = 2

            ! -------
            !| 1 1 2 |
            !| 1 2 2 |
            !| 2 2 3 |
            ! -------
            case(54)
               grdpts_id = reshape( (/
     $              bc_interior_pt, bc_interior_pt, bc_pt,
     $              interior_pt, bc_interior_pt, bc_interior_pt,
     $              interior_pt,interior_pt,bc_interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = SE_edge_type
               test_i_proc    = 2
               test_j_proc    = 1

            ! -------
            !| 2 3 3 |
            !| 2 2 3 |
            !| 1 2 2 |
            ! -------
            case(55)
               grdpts_id = reshape( (/
     $              interior_pt,bc_interior_pt,bc_interior_pt,
     $              bc_interior_pt,bc_interior_pt,bc_pt,
     $              bc_interior_pt,bc_pt,bc_pt
     $              /),
     $              (/3,3/))
               test_procedure = NE_corner_type
               test_i_proc    = 2
               test_j_proc    = 2

            ! -------
            !| 2 1 1 |
            !| 2 2 1 |
            !| 3 2 2 |
            ! -------
            case(56)
               grdpts_id = reshape( (/
     $              bc_pt,bc_interior_pt,bc_interior_pt,
     $              bc_interior_pt,bc_interior_pt,interior_pt,
     $              bc_interior_pt,interior_pt,interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = SW_edge_type
               test_i_proc    = 1
               test_j_proc    = 1

            ! -------
            !| 1 2 2 |
            !| 2 2 3 |
            !| 2 3 3 |
            ! -------
            case(57)
               grdpts_id = reshape( (/
     $              bc_interior_pt,bc_pt,bc_pt,
     $              bc_interior_pt,bc_interior_pt,bc_pt,
     $              interior_pt,bc_interior_pt,bc_interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = SE_corner_type
               test_i_proc    = 2
               test_j_proc    = 1

            ! -------
            !| 3 2 2 |
            !| 2 2 1 |
            !| 2 1 1 |
            ! -------
            case(58)
               grdpts_id = reshape( (/
     $              bc_interior_pt,interior_pt,interior_pt,
     $              bc_interior_pt,bc_interior_pt,interior_pt,
     $              bc_pt,bc_interior_pt,bc_interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = NW_edge_type
               test_i_proc    = 1
               test_j_proc    = 2

            ! -------
            !| 2 2 1 |
            !| 3 2 2 |
            !| 3 3 2 |
            ! -------
            case(59)
               grdpts_id = reshape( (/
     $              bc_pt,bc_pt,bc_interior_pt,
     $              bc_pt,bc_interior_pt,bc_interior_pt,
     $              bc_interior_pt,bc_interior_pt,interior_pt
     $              /),
     $              (/3,3/))
               test_procedure = SW_corner_type
               test_i_proc    = 1
               test_j_proc    = 1

            ! -------
            !| 2 2 3 |
            !| 1 2 2 |
            !| 1 1 2 |
            ! -------
            case(60)
               grdpts_id = reshape( (/
     $              interior_pt,interior_pt,bc_interior_pt,
     $              interior_pt,bc_interior_pt,bc_interior_pt,
     $              bc_interior_pt,bc_interior_pt,bc_pt
     $              /),
     $              (/3,3/))
               test_procedure = NE_edge_type
               test_i_proc    = 2
               test_j_proc    = 2

            case default
               print '(''test_bf_layer_bc_procedure'')'
               print '(''make_test_bf_layer_bc_procedure'')'
               print '(''test case not implemented: '', I2)', test_id
               stop ''

          end select

        end subroutine make_test_bf_layer_bc_procedure

      end program test_bf_layer_bc_procedure
