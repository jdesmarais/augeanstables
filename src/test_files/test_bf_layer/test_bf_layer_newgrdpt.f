      program test_bf_layer_newgrdpt

        use bf_layer_newgrdpt_class, only :
     $       bf_layer_newgrdpt

        use check_data_module, only :
     $       is_real_validated,
     $       is_real_vector_validated,
     $       is_real_matrix3D_validated,
     $       is_int_vector_validated,
     $       is_int_matrix_validated,
     $       is_boolean_vector_validated

        use dim2d_parameters, only :
     $       cv_r

        use parameters_bf_layer, only :
     $       align_N, align_E, align_W,
     $       
     $       NE_corner_type,
     $       W_edge_type,
     $       no_pt,
     $       
     $       gradient_I_type,
     $       
     $       BF_SUCCESS,
     $       
     $       NEWGRDPT_NO_ERROR,
     $       NEWGRDPT_NO_PREVIOUS_DATA_ERROR

        use parameters_constant, only :
     $       N,S,E,W

        use parameters_input, only :
     $       ne

        use parameters_kind, only :
     $       ikind,
     $       rkind

        use pmodel_eq_class, only : 
     $       pmodel_eq

        implicit none

        logical :: detailled
        logical :: test_loc
        logical :: test_validated


        detailled      = .true.
        test_validated = .true.


        call check_inputs()


        test_loc = test_compute_newgrdpt(detailled)
        test_validated = test_validated.and.test_loc
        print '(''test_compute_newgrdpt: '',L1)', test_loc
        print '()'


        test_loc = test_extract_grdpts_id(detailled)
        test_validated = test_validated.and.test_loc
        print '(''test_extract_grdpts_id: '',L1)', test_loc
        print '()'


        test_loc = test_extract_nodes(detailled)
        test_validated = test_validated.and.test_loc
        print '(''test_extract_nodes: '',L1)', test_loc
        print '()'


        test_loc = test_insert_grdpts_id(detailled)
        test_validated = test_validated.and.test_loc
        print '(''test_insert_grdpts_id: '',L1)', test_loc
        print '()'


        print '(''test_validated: '',L1)', test_validated

        contains


        function test_compute_newgrdpt(detailled)
     $       result(test_validated)

          implicit none

          logical, intent(in) :: detailled
          logical             :: test_validated

          
          type(bf_layer_newgrdpt)          :: bf_layer_used
          type(pmodel_eq)                  :: p_model
          real(rkind)                      :: t
          real(rkind)                      :: dt
          integer(ikind), dimension(2)     :: bf_newgrdpt_coords1

          integer                          :: nb_procedures
          integer       , dimension(4)     :: procedure_type
          integer       , dimension(4)     :: gradient_type
          logical       , dimension(4)     :: grdpts_available
          integer(ikind), dimension(2,2)   :: data_needed_bounds0

          integer                          :: test_nb_procedures
          integer       , dimension(4)     :: test_procedure_type
          integer       , dimension(4)     :: test_gradient_type
          logical       , dimension(4)     :: test_grdpts_available
          integer(ikind), dimension(2,2)   :: test_data_needed_bounds0

          integer                          :: ierror

          integer                          :: test_ierror
          real(rkind)   , dimension(ne)    :: test_newgrdpt

          logical :: test_loc


          test_validated = .true.


          !test w/o an initialization to have an error
          !------------------------------------------------------------
          ierror = bf_layer_used%compute_newgrdpt(
     $         p_model,
     $         t,
     $         dt,
     $         bf_newgrdpt_coords1,
     $         nb_procedures,
     $         procedure_type,
     $         gradient_type,
     $         grdpts_available,
     $         data_needed_bounds0)

          test_loc = ierror.eq.NEWGRDPT_NO_PREVIOUS_DATA_ERROR
          test_validated = test_validated.and.test_loc
          if(detailled.and.(.not.test_loc)) then
             print '(''error no data failed'')'
          end if


          !test w/ an intialization to compute the newgrdpt
          !------------------------------------------------------------

          !input
          call p_model%initial_conditions%ini_far_field()

          call get_param_test_compute_newgrdpt(
     $         bf_layer_used,
     $         t,
     $         dt,
     $         bf_newgrdpt_coords1,
     $         test_nb_procedures,
     $         test_procedure_type,
     $         test_gradient_type,
     $         test_grdpts_available,
     $         test_data_needed_bounds0,
     $         test_ierror,
     $         test_newgrdpt)

          !output
          ierror = bf_layer_used%compute_newgrdpt(
     $         p_model,
     $         t,
     $         dt,
     $         bf_newgrdpt_coords1,
     $         nb_procedures,
     $         procedure_type,
     $         gradient_type,
     $         grdpts_available,
     $         data_needed_bounds0)

          !validation
          test_loc = ierror.eq.test_ierror
          test_validated = test_validated.and.test_loc
          if(detailled.and.(.not.test_loc)) then
             print '(''ierror failed'')'
          end if
          
          test_loc = is_real_vector_validated(
     $         bf_layer_used%nodes(bf_newgrdpt_coords1(1),
     $         bf_newgrdpt_coords1(2),
     $         :),
     $         test_newgrdpt,
     $         detailled)
          test_validated = test_validated.and.test_loc
          if(detailled.and.(.not.test_loc)) then
             print '(''newgrdpt failed'')'
          end if

          test_loc = nb_procedures.eq.test_nb_procedures
          test_validated = test_validated.and.test_loc
          if(detailled.and.(.not.test_loc)) then
             print '(''nb_procedures failed'')'
          end if

          test_loc = is_int_vector_validated(
     $         procedure_type(1:nb_procedures),
     $         test_procedure_type(1:nb_procedures),
     $         detailled)
          test_validated = test_validated.and.test_loc
          if(detailled.and.(.not.test_loc)) then
             print '(''procedure_type failed'')'
          end if

          test_loc = is_int_vector_validated(
     $         gradient_type(1:nb_procedures),
     $         test_gradient_type(1:nb_procedures),
     $         detailled)
          test_validated = test_validated.and.test_loc
          if(detailled.and.(.not.test_loc)) then
             print '(''gradient_type failed'')'
          end if

          test_loc = is_boolean_vector_validated(
     $         grdpts_available(1:nb_procedures),
     $         test_grdpts_available(1:nb_procedures),
     $         detailled)
          test_validated = test_validated.and.test_loc
          if(detailled.and.(.not.test_loc)) then
             print '(''grdpts_available failed'')'
          end if

          test_loc = is_int_matrix_validated(
     $         data_needed_bounds0,
     $         test_data_needed_bounds0,
     $         detailled)
          test_validated = test_validated.and.test_loc
          if(detailled.and.(.not.test_loc)) then
             print '(''data_needed_bounds0 failed'')'
          end if          

        end function test_compute_newgrdpt


        subroutine get_param_test_compute_newgrdpt(
     $     bf_layer_used,
     $     t,
     $     dt,
     $     bf_newgrdpt_coords1,
     $     nb_procedures,
     $     procedure_type,
     $     gradient_type,
     $     test_grdpts_available,
     $     test_data_needed_bounds0,
     $     test_ierror,
     $     test_newgrdpt)

          implicit none

          
          type(bf_layer_newgrdpt)       , intent(inout)  :: bf_layer_used
          real(rkind)                   , intent(out)    :: t
          real(rkind)                   , intent(out)    :: dt
          integer(ikind), dimension(2)  , intent(out)    :: bf_newgrdpt_coords1
          integer                       , intent(out)    :: nb_procedures
          integer       , dimension(4)  , intent(out)    :: procedure_type
          integer       , dimension(4)  , intent(out)    :: gradient_type
          logical       , dimension(4)  , intent(out)    :: test_grdpts_available
          integer(ikind), dimension(2,2), intent(out)    :: test_data_needed_bounds0
          integer                       , intent(out)    :: test_ierror
          real(rkind)   , dimension(ne) , intent(out)    :: test_newgrdpt

          integer                           :: bf_localization
          logical                           :: bf_can_exchange_with_neighbor1
          logical                           :: bf_can_exchange_with_neighbor2
          integer(ikind), dimension(2,2)    :: bf_alignment1
          real(rkind)   , dimension(8)      :: bf_x_map1
          real(rkind)   , dimension(6)      :: bf_y_map1
          real(rkind)   , dimension(8,6,ne) :: bf_nodes1

          integer(ikind), dimension(2,2) :: bf_alignment0
          real(rkind), dimension(6)      :: bf_x_map0
          real(rkind), dimension(5)      :: bf_y_map0
          real(rkind), dimension(6,5,ne) :: bf_nodes0
          integer    , dimension(6,5)    :: bf_grdpts_id0

          real(rkind), dimension(ne) :: test_newgrdpt_W
          real(rkind), dimension(ne) :: test_newgrdpt_NE

          integer(ikind) :: i,j
          integer        :: k

          t  = 0.0d0
          dt = 0.25d0

          bf_localization = E

          bf_can_exchange_with_neighbor1 = .false.
          bf_can_exchange_with_neighbor2 = .false.

          bf_alignment0 = reshape((/align_E  , align_N-2, align_E+1, align_N-2/), (/2,2/))
          bf_x_map0 = [0.5d0, 1.50d0, 2.50d0, 3.50d0, 4.50d0, 5.50d0]
          bf_y_map0 = [0.0d0, 0.25d0, 0.50d0, 0.75d0, 1.00d0]

          bf_alignment1 = reshape((/align_E-1, align_N-2, align_E+2, align_N-1/), (/2,2/))
          bf_x_map1 = [-0.5d0, 0.50d0, 1.50d0, 2.50d0, 3.50d0, 4.50d0, 5.50d0, 6.50d0]
          bf_y_map1 = [ 0.0d0, 0.25d0, 0.50d0, 0.75d0, 1.00d0, 1.25d0]

          nb_procedures     = 2
          procedure_type(1) = NE_corner_type
          procedure_type(2) = W_edge_type
          gradient_type(2)  = gradient_I_type

          test_data_needed_bounds0 = reshape((/-3,-3,2,1/),(/2,2/))

          bf_newgrdpt_coords1 = [5,4]

          bf_grdpts_id0 = reshape((/
     $         ((no_pt,i=1,6),j=1,5)/),(/6,5/))

          bf_nodes0 = reshape((/
     $         (((-99.0d0,i=1,6),j=1,5),k=1,ne)/),
     $         (/6,5,ne/))
          
          bf_nodes1 = reshape((/
     $         (((-99.0d0,i=1,8),j=1,6),k=1,ne)/),
     $         (/8,6,ne/))
          
          !data for the NE corner
          bf_nodes0(1:3,1:3,:) = reshape((/
     $         1.48d0, 1.30d0, 1.35d0,
     $         1.26d0, 1.45d0, 1.40d0,
     $         1.46d0, 1.27d0, 1.47d0,
     $         
     $         0.128d0, 0.127d0, 0.142d0,
     $         1.138d0, 0.148d0, 0.132d0,
     $         0.146d0, 0.143d0, 0.145d0,
     $         
     $         0.0050d0, 0.020d0, 0.060d0,
     $         0.0025d0, 0.001d0, 0.015d0, 
     $         0.0100d0, 0.002d0, 0.050d0,
     $         
     $         4.88d0, 4.870d0, 4.855d0,
     $         4.85d0, 4.865d0, 4.845d0,
     $         4.89d0, 4.870d0, 4.860d0/),
     $         (/3,3,ne/))

          bf_nodes1(2:4,1:3,:) = reshape((/
     $         1.50d0, 1.455d0, 1.48d0,
     $         1.20d0, 1.350d0, 1.25d0,
     $         1.49d0, 1.250d0, 1.40d0,
     $         
     $         0.128d0, 0.450d0, 0.135d0,
     $         0.148d0, 0.150d0, 0.122d0,
     $         0.142d0, 1.152d0, 0.236d0,
     $         
     $         0.006d0, 0.0600d0, 0.020d0,
     $         0.000d0, 0.0028d0, 0.035d0,
     $         0.020d0, 0.0030d0, 0.040d0,
     $         
     $         4.876d0, 4.825d0, 4.862d0,
     $         4.890d0, 4.871d0, 4.892d0,
     $         4.865d0, 4.757d0, 4.895d0/),
     $         (/3,3,ne/))

          bf_grdpts_id0(1:3,1:3) = reshape((/
     $         2,2,3,
     $         2,2,3,
     $         3,3,3/),
     $         (/3,3/))

          !data for the W_edge
          bf_nodes0(5:6,3:5,:) = reshape((/
     $         1.45d0,  1.26d0,
     $         1.27d0,  1.46d0,
     $         1.26d0,  1.48d0,
     $         
     $       -0.148d0, -1.138d0, 
     $       -0.143d0, -0.146d0, 
     $       -0.129d0, -0.123d0, 
     $         
     $        0.001d0,  0.0025d0,
     $        0.002d0,  0.0100d0,
     $        0.015d0,  0.0800d0,
     $         
     $        4.865d0,  4.85d0, 
     $        4.870d0,  4.89d0, 
     $        4.950d0,  4.83d0/),
     $         (/2,3,ne/))

          bf_nodes1(6:7,3:5,:) = reshape((/
     $         1.35d0, 1.20d0, 
     $         1.25d0, 1.49d0, 
     $         1.28d0, 1.52d0, 
     $         
     $        -0.150d0, -0.148d0, 
     $        -1.152d0, -0.142d0, 
     $        -0.185d0, -0.136d0,
     $         
     $         0.0028d0, 0.00d0,
     $         0.0030d0, 0.02d0,
     $         0.0850d0, 0.06d0,
     $         
     $         4.871d0, 4.890d0,
     $         4.757d0, 4.865d0,
     $         4.785d0, 4.625d0/),
     $         (/2,3,ne/))

          bf_grdpts_id0(5:6,3:5) = reshape((/
     $         3,2,
     $         3,2,
     $         3,2/),
     $         (/2,3/))

          test_newgrdpt_W = [
     $         1.10558898620299d0,
     $        -0.21493341075159d0,
     $         0.49142653305574d0,
     $         4.65867937589912d0]

          test_newgrdpt_NE = [
     $         1.55742091189301d0,
     $         0.56224898725725d0,
     $        -0.14504765609975d0,
     $         4.63647450016455d0]

          do k=1,ne
             test_newgrdpt(k) = (test_newgrdpt_W(k)+test_newgrdpt_NE(k))/2.0d0
          end do

          test_grdpts_available = [.true.,.true.,.false.,.false.]
          test_ierror = NEWGRDPT_NO_ERROR

          !initialization of the bf_layer_used
          bf_layer_used%localization = bf_localization
          bf_layer_used%alignment    = bf_alignment1

          allocate(bf_layer_used%grdpts_id(8,6))
          allocate(bf_layer_used%x_map(8))
          allocate(bf_layer_used%y_map(6))
          allocate(bf_layer_used%nodes(8,6,ne))

          bf_layer_used%x_map = bf_x_map1
          bf_layer_used%y_map = bf_y_map1
          bf_layer_used%nodes = bf_nodes1          

          call bf_layer_used%set_neighbor1_share(bf_can_exchange_with_neighbor1)
          call bf_layer_used%set_neighbor2_share(bf_can_exchange_with_neighbor2)

          !initialization of the bf_compute_used
          call bf_layer_used%bf_compute_used%allocate_tables(
     $         size(bf_x_map0,1),
     $         size(bf_y_map0,1),
     $         bf_alignment0,
     $         bf_x_map0,
     $         bf_y_map0,
     $         bf_grdpts_id0)

          bf_layer_used%bf_compute_used%alignment_tmp = bf_alignment0
          bf_layer_used%bf_compute_used%nodes_tmp     = bf_nodes0

        end subroutine get_param_test_compute_newgrdpt


        function test_extract_grdpts_id(detailled) result(test_validated)

          implicit none

          logical, intent(in) :: detailled
          logical             :: test_validated

          type(bf_layer_newgrdpt)           :: bf_layer_used
          integer(ikind), dimension(2,2)    :: gen_coords
          integer       , dimension(6,7)    :: tmp_grdpts_id_test
          real(rkind)   , dimension(6,7,ne) :: tmp_nodes_test
          logical                           :: previous_step_test

          integer :: k
          logical :: test_loc

          test_validated = .true.


          do k=1,3

             !input
             !============================================================
             call get_param_test_extract(
     $            k,
     $            bf_layer_used,
     $            gen_coords,
     $            tmp_grdpts_id_test,
     $            tmp_nodes_test,
     $            previous_step_test)

             !output+validation
             !============================================================
             test_loc = validate_test_extract_grdpts_id(
     $            bf_layer_used,
     $            gen_coords,
     $            previous_step_test,
     $            tmp_grdpts_id_test)
             test_validated = test_validated.and.test_loc


             !detailled
             !============================================================
             if(detailled.and.(.not.test_loc)) then
                print '(''test('',I1,'') failed'')',k
             end if

          end do

        end function test_extract_grdpts_id


        function test_extract_nodes(detailled) result(test_validated)

          implicit none

          logical, intent(in) :: detailled
          logical             :: test_validated

          type(bf_layer_newgrdpt)           :: bf_layer_used
          integer(ikind), dimension(2,2)    :: gen_coords
          integer       , dimension(6,7)    :: tmp_grdpts_id_test
          real(rkind)   , dimension(6,7,ne) :: tmp_nodes_test
          logical                           :: previous_step_test

          integer :: k
          logical :: test_loc

          test_validated = .true.


          do k=1,3

             !input
             !============================================================
             call get_param_test_extract(
     $            k,
     $            bf_layer_used,
     $            gen_coords,
     $            tmp_grdpts_id_test,
     $            tmp_nodes_test,
     $            previous_step_test)

             !output+validation
             !============================================================
             test_loc = validate_test_extract_nodes(
     $            bf_layer_used,
     $            gen_coords,
     $            previous_step_test,
     $            tmp_nodes_test)
             test_validated = test_validated.and.test_loc


             !detailled
             !============================================================
             if(detailled.and.(.not.test_loc)) then
                print '(''test('',I1,'') failed'')',k
             end if

          end do

        end function test_extract_nodes


        subroutine get_param_test_extract(
     $     test_id,
     $     bf_layer_used,
     $     gen_coords,
     $     tmp_grdpts_id_test,
     $     tmp_nodes_test,
     $     previous_step_test)

          implicit none

          integer                          , intent(in)    :: test_id
          type(bf_layer_newgrdpt)          , intent(inout) :: bf_layer_used
          integer(ikind), dimension(2,2)   , intent(out)   :: gen_coords
          integer       , dimension(6,7)   , intent(out)   :: tmp_grdpts_id_test
          real(rkind)   , dimension(6,7,ne), intent(out)   :: tmp_nodes_test
          logical                          , intent(out)   :: previous_step_test

          integer(ikind) :: i,j
          integer        :: k
          

          gen_coords = reshape((/align_W+10,align_N+2,align_W+15,align_N+8/),(/2,2/))

          select case(test_id)

          !no provious time step 
            case(1)
               tmp_grdpts_id_test = reshape((/
     $            ((-999,i=1,6),j=1,7)/),(/6,7/))
               tmp_nodes_test = reshape((/
     $            (((-999,i=1,6),j=1,7),k=1,ne)/),(/6,7,ne/))
               previous_step_test = .true.
               
          !previous time exist
            case(2)

               allocate(bf_layer_used%bf_compute_used%alignment_tmp(2,2))
               bf_layer_used%bf_compute_used%alignment_tmp = reshape((/
     $              align_W,align_N,align_W+10,align_N+2/),
     $              (/2,2/))          
               
               allocate(bf_layer_used%bf_compute_used%grdpts_id_tmp(15,7))
               bf_layer_used%bf_compute_used%grdpts_id_tmp = reshape((/
     $              ((-20*(align_N-3+j-1)-(align_W-3+(i-1)),i=1,15),j=1,7)/),
     $              (/15,7/))

               allocate(bf_layer_used%bf_compute_used%nodes_tmp(15,7,ne))
               bf_layer_used%bf_compute_used%nodes_tmp = reshape((/
     $              (((-200*(k-1)-20*(align_N-3+j-1)-(align_W-3+(i-1)),i=1,15),j=1,7),k=1,ne)/),
     $              (/15,7,ne/))

               tmp_grdpts_id_test = reshape((/
     $              ((-20*(align_N+1+j-1)-(align_W+9+(i-1)),i=1,6),j=1,7)/),
     $              (/6,7/))

               tmp_nodes_test = reshape((/
     $              (((-200*(k-1)-20*(align_N+1+j-1)-(align_W+9+(i-1)),i=1,6),j=1,7),k=1,ne)/),
     $              (/6,7,ne/))

               previous_step_test = .true.

          !this time step
            case(3)

               bf_layer_used%alignment = reshape((/
     $              align_W,align_N,align_W+10,align_N+2/),
     $              (/2,2/))          
               
               allocate(bf_layer_used%grdpts_id(15,7))
               bf_layer_used%grdpts_id = reshape((/
     $              ((20*(align_N-3+j-1)+(align_W-3+(i-1)),i=1,15),j=1,7)/),
     $              (/15,7/))

               allocate(bf_layer_used%nodes(15,7,ne))
               bf_layer_used%nodes = reshape((/
     $              (((200*(k-1)+20*(align_N-3+j-1)+(align_W-3+(i-1)),i=1,15),j=1,7),k=1,ne)/),
     $              (/15,7,ne/))

               tmp_grdpts_id_test = reshape((/
     $              ((20*(align_N+1+j-1)+(align_W+9+(i-1)),i=1,6),j=1,7)/),
     $              (/6,7/))

               tmp_nodes_test = reshape((/
     $              (((200*(k-1)+20*(align_N+1+j-1)+(align_W+9+(i-1)),i=1,6),j=1,7),k=1,ne)/),
     $              (/6,7,ne/))

               previous_step_test = .false.

          end select

        end subroutine get_param_test_extract


        function validate_test_extract_grdpts_id(
     $     bf_layer_used,
     $     gen_coords,
     $     previous_step_test,
     $     tmp_grdpts_id_test)
     $     result(test_validated)

          implicit none

          type(bf_layer_newgrdpt)       , intent(in) :: bf_layer_used
          integer(ikind), dimension(2,2), intent(in) :: gen_coords
          logical                       , intent(in) :: previous_step_test
          integer       , dimension(6,7), intent(in) :: tmp_grdpts_id_test
          logical                                    :: test_validated


          integer(ikind)                 :: i,j
          integer       , dimension(6,7) :: tmp_grdpts_id
          integer(ikind), dimension(6)   :: extract_param
          logical                        :: test_loc


          test_validated = .true.


          !test w/o optional arg
          !------------------------------------------------------------
          tmp_grdpts_id = reshape((/
     $         ((-999,i=1,6),j=1,7)/),(/6,7/))
          call bf_layer_used%extract_grdpts_id(
     $         tmp_grdpts_id,
     $         gen_coords,
     $         previous_step=previous_step_test)
          
          test_loc = is_int_matrix_validated(
     $         tmp_grdpts_id(1:3,1:3),
     $         tmp_grdpts_id_test(1:3,1:3),
     $         detailled)
          test_validated = test_validated.and.test_loc
          if(detailled.and.(.not.test_loc)) then
             print '(''w/o optional arg failed'')'
          end if
          
          
          !test w/ optional arg extract_param_out
          !------------------------------------------------------------
          tmp_grdpts_id = reshape((/
     $         ((-999,i=1,6),j=1,7)/),(/6,7/))
          call bf_layer_used%extract_grdpts_id(
     $         tmp_grdpts_id,
     $         gen_coords,
     $         extract_param_out=extract_param,
     $         previous_step=previous_step_test)
          
          test_loc = is_int_matrix_validated(
     $         tmp_grdpts_id(1:3,1:3),
     $         tmp_grdpts_id_test(1:3,1:3),
     $         detailled)
          test_validated = test_validated.and.test_loc
          if(detailled.and.(.not.test_loc)) then
             print '(''w/ optional arg extract_param_out failed'')'
          end if
          
          
          !test w/ optional arg extract_param_in
          !------------------------------------------------------------
          tmp_grdpts_id = reshape((/
     $         ((-999,i=1,6),j=1,7)/),(/6,7/))
          call bf_layer_used%extract_grdpts_id(
     $         tmp_grdpts_id,
     $         gen_coords,
     $         extract_param_in=extract_param,
     $         previous_step=previous_step_test)
          
          test_loc = is_int_matrix_validated(
     $         tmp_grdpts_id(1:3,1:3),
     $         tmp_grdpts_id_test(1:3,1:3),
     $         detailled)
          test_validated = test_validated.and.test_loc
          if(detailled.and.(.not.test_loc)) then
             print '(''w/ optional arg extract_param_in failed'')'
          end if

        end function validate_test_extract_grdpts_id


        function validate_test_extract_nodes(
     $     bf_layer_used,
     $     gen_coords,
     $     previous_step_test,
     $     tmp_nodes_test)
     $     result(test_validated)

          implicit none

          type(bf_layer_newgrdpt)          , intent(in) :: bf_layer_used
          integer(ikind), dimension(2,2)   , intent(in) :: gen_coords
          logical                          , intent(in) :: previous_step_test
          real(rkind)   , dimension(6,7,ne), intent(in) :: tmp_nodes_test
          logical                                       :: test_validated


          integer(ikind)                    :: i,j
          integer                           :: k
          real(rkind)   , dimension(6,7,ne) :: tmp_nodes
          integer(ikind), dimension(6)      :: extract_param
          logical                           :: test_loc


          test_validated = .true.


          !test w/o optional arg
          !------------------------------------------------------------
          tmp_nodes = reshape((/
     $         (((-999,i=1,6),j=1,7),k=1,ne)/),(/6,7,ne/))
          call bf_layer_used%extract_nodes(
     $         tmp_nodes,
     $         gen_coords,
     $         previous_step=previous_step_test)
          
          test_loc = is_real_matrix3D_validated(
     $         tmp_nodes(1:3,1:3,:),
     $         tmp_nodes_test(1:3,1:3,:),
     $         detailled)
          test_validated = test_validated.and.test_loc
          if(detailled.and.(.not.test_loc)) then
             print '(''w/o optional arg failed'')'
          end if
          
          
          !test w/ optional arg extract_param_out
          !------------------------------------------------------------
          tmp_nodes = reshape((/
     $         (((-999,i=1,6),j=1,7),k=1,ne)/),(/6,7,ne/))
          call bf_layer_used%extract_nodes(
     $         tmp_nodes,
     $         gen_coords,
     $         extract_param_out=extract_param,
     $         previous_step=previous_step_test)
          
          test_loc = is_real_matrix3D_validated(
     $         tmp_nodes(1:3,1:3,:),
     $         tmp_nodes_test(1:3,1:3,:),
     $         detailled)
          test_validated = test_validated.and.test_loc
          if(detailled.and.(.not.test_loc)) then
             print '(''w/ optional arg extract_param_out failed'')'
          end if
          
          
          !test w/ optional arg extract_param_in
          !------------------------------------------------------------
          tmp_nodes = reshape((/
     $         (((-999,i=1,6),j=1,7),k=1,ne)/),(/6,7,ne/))
          call bf_layer_used%extract_nodes(
     $         tmp_nodes,
     $         gen_coords,
     $         extract_param_in=extract_param,
     $         previous_step=previous_step_test)
          
          test_loc = is_real_matrix3D_validated(
     $         tmp_nodes(1:3,1:3,:),
     $         tmp_nodes_test(1:3,1:3,:),
     $         detailled)
          test_validated = test_validated.and.test_loc
          if(detailled.and.(.not.test_loc)) then
             print '(''w/ optional arg extract_param_in failed'')'
          end if

        end function validate_test_extract_nodes

      
        function test_insert_grdpts_id(detailled) result(test_validated)

          implicit none

          logical, intent(in) :: detailled
          logical             :: test_validated

          type(bf_layer_newgrdpt)         :: bf_layer_used
          integer(ikind), dimension(2,2)  :: gen_coords
          integer       , dimension(6,7)  :: tmp_grdpts_id
          integer       , dimension(15,7) :: bf_grdpts_id_test
          logical                         :: previous_step_test

          integer :: k
          logical :: test_loc

          test_validated = .true.


          do k=1,2

             !input
             !============================================================
             call get_param_test_insert(
     $            k,
     $            bf_layer_used,
     $            gen_coords,
     $            tmp_grdpts_id,
     $            bf_grdpts_id_test,
     $            previous_step_test)

             !output+validation
             !============================================================
             test_loc = validate_test_insert_grdpts_id(
     $            bf_layer_used,
     $            gen_coords,
     $            previous_step_test,
     $            tmp_grdpts_id,
     $            bf_grdpts_id_test)
             test_validated = test_validated.and.test_loc


             !detailled
             !============================================================
             if(detailled.and.(.not.test_loc)) then
                print '(''test('',I1,'') failed'')',k
             end if

          end do

        end function test_insert_grdpts_id


        subroutine get_param_test_insert(
     $     test_id,
     $     bf_layer_used,
     $     gen_coords,
     $     tmp_grdpts_id,
     $     bf_grdpts_id_test,
     $     previous_step_test)

          implicit none

          integer                        , intent(in)    :: test_id
          type(bf_layer_newgrdpt)        , intent(inout) :: bf_layer_used
          integer(ikind), dimension(2,2) , intent(out)   :: gen_coords
          integer       , dimension(6,7) , intent(out)   :: tmp_grdpts_id
          integer       , dimension(15,7), intent(out)   :: bf_grdpts_id_test
          logical                        , intent(out)   :: previous_step_test

          integer(ikind) :: i,j
          

          gen_coords = reshape((/align_W+10,align_N+2,align_W+15,align_N+8/),(/2,2/))

          tmp_grdpts_id = reshape((/
     $         ((i+(j-1)*6,i=1,6),j=1,7)/),
     $         (/6,7/))


          select case(test_id)

          !previous time
            case(1)

               allocate(bf_layer_used%bf_compute_used%alignment_tmp(2,2))
               bf_layer_used%bf_compute_used%alignment_tmp = reshape((/
     $              align_W,align_N,align_W+10,align_N+2/),
     $              (/2,2/))          
               
               allocate(bf_layer_used%bf_compute_used%grdpts_id_tmp(15,7))
               bf_layer_used%bf_compute_used%grdpts_id_tmp = reshape((/
     $              ((-20*(align_N-3+j-1)-(align_W-3+(i-1)),i=1,15),j=1,7)/),
     $              (/15,7/))

               allocate(bf_layer_used%bf_compute_used%nodes_tmp(15,7,ne))

               bf_grdpts_id_test = bf_layer_used%bf_compute_used%grdpts_id_tmp
               bf_grdpts_id_test(13:15,5:7) = reshape((/
     $              ((i+(j-1)*6,i=1,3),j=1,3)/),
     $              (/3,3/))
               
               previous_step_test = .true.

          !this time step
            case(2)

               bf_layer_used%alignment = reshape((/
     $              align_W,align_N,align_W+10,align_N+2/),
     $              (/2,2/))          
               
               allocate(bf_layer_used%grdpts_id(15,7))
               bf_layer_used%grdpts_id = reshape((/
     $              ((20*(align_N-3+j-1)+(align_W-3+(i-1)),i=1,15),j=1,7)/),
     $              (/15,7/))

               bf_grdpts_id_test = bf_layer_used%grdpts_id
               bf_grdpts_id_test(13:15,5:7) = reshape((/
     $              ((i+(j-1)*6,i=1,3),j=1,3)/),
     $              (/3,3/))

               previous_step_test = .false.

          end select

        end subroutine get_param_test_insert


        function validate_test_insert_grdpts_id(
     $     bf_layer_used,
     $     gen_coords,
     $     previous_step_test,
     $     tmp_grdpts_id,
     $     bf_grdpts_id_test)
     $     result(test_validated)

          implicit none

          type(bf_layer_newgrdpt)        , intent(inout) :: bf_layer_used
          integer(ikind), dimension(2,2) , intent(in)    :: gen_coords
          logical                        , intent(in)    :: previous_step_test
          integer       , dimension(6,7) , intent(in)    :: tmp_grdpts_id
          integer       , dimension(15,7), intent(in)    :: bf_grdpts_id_test
          logical                                        :: test_validated


          integer(ikind)                 :: i,j
          integer(ikind), dimension(6)   :: insert_param
          logical                        :: test_loc


          test_validated = .true.


          !test w/o optional arg
          !------------------------------------------------------------
          call bf_layer_used%insert_grdpts_id(
     $         tmp_grdpts_id,
     $         gen_coords,
     $         previous_step=previous_step_test)
          
          if(previous_step_test) then
             test_loc = is_int_matrix_validated(
     $            bf_layer_used%bf_compute_used%grdpts_id_tmp,
     $            bf_grdpts_id_test,
     $            detailled)
          else
             test_loc = is_int_matrix_validated(
     $            bf_layer_used%grdpts_id,
     $            bf_grdpts_id_test,
     $            detailled)
          end if
          test_validated = test_validated.and.test_loc
          if(detailled.and.(.not.test_loc)) then
             print '(''w/o optional arg failed'')'
          end if
          
          
          !test w/ optional arg insert_param_out
          !------------------------------------------------------------
          bf_layer_used%bf_compute_used%grdpts_id_tmp = reshape((/
     $         ((-20*(align_N-3+j-1)-(align_W-3+i-1),i=1,15),j=1,7)/),
     $         (/15,7/))
          if(allocated(bf_layer_used%grdpts_id)) then
             bf_layer_used%grdpts_id = reshape((/
     $            ((20*(align_N-3+j-1)+(align_W-3+i-1),i=1,15),j=1,7)/),
     $            (/15,7/))
          end if

          call bf_layer_used%insert_grdpts_id(
     $         tmp_grdpts_id,
     $         gen_coords,
     $         insert_param_out=insert_param,
     $         previous_step=previous_step_test)
          
          if(previous_step_test) then
             test_loc = is_int_matrix_validated(
     $            bf_layer_used%bf_compute_used%grdpts_id_tmp,
     $            bf_grdpts_id_test,
     $            detailled)
          else
             test_loc = is_int_matrix_validated(
     $            bf_layer_used%grdpts_id,
     $            bf_grdpts_id_test,
     $            detailled)
          end if
          test_validated = test_validated.and.test_loc
          if(detailled.and.(.not.test_loc)) then
             print '(''w/ optional arg insert_param_out failed'')'
          end if
          
          
          !test w/ optional arg insert_param_in
          !------------------------------------------------------------
          bf_layer_used%bf_compute_used%grdpts_id_tmp = reshape((/
     $         ((-20*(align_N-3+j-1)-(align_W-3+i-1),i=1,15),j=1,7)/),
     $         (/15,7/))
          if(allocated(bf_layer_used%grdpts_id)) then
             bf_layer_used%grdpts_id = reshape((/
     $            ((20*(align_N-3+j-1)+(align_W-3+i-1),i=1,15),j=1,7)/),
     $            (/15,7/))
          end if

          call bf_layer_used%insert_grdpts_id(
     $         tmp_grdpts_id,
     $         gen_coords,
     $         insert_param_in=insert_param,
     $         previous_step=previous_step_test)
          
          if(previous_step_test) then
             test_loc = is_int_matrix_validated(
     $            bf_layer_used%bf_compute_used%grdpts_id_tmp,
     $            bf_grdpts_id_test,
     $            detailled)
          else
             test_loc = is_int_matrix_validated(
     $            bf_layer_used%grdpts_id,
     $            bf_grdpts_id_test,
     $            detailled)
          end if
          test_validated = test_validated.and.test_loc
          if(detailled.and.(.not.test_loc)) then
             print '(''w/ optional arg insert_param_in failed'')'
          end if

        end function validate_test_insert_grdpts_id


        subroutine check_inputs()

          implicit none

          real(rkind), dimension(4) :: far_field
          type(pmodel_eq)           :: p_model

          if(ne.ne.4) then
             stop 'the test requires ne=4: DIM2D model'
          end if

          if(.not.is_real_validated(cv_r,2.5d0,.false.)) then
             stop 'the test requires c_v_r=2.5'
          end if

          call p_model%initial_conditions%ini_far_field()

          far_field = p_model%get_far_field(0.0d0,1.0d0,1.0d0)

          if(.not.is_real_vector_validated(
     $         far_field,
     $         [1.46510213931996d0,0.146510214d0,0.0d0,2.84673289046992d0],
     $         .true.)) then
             print '(''the test requires p_model%get_far_field(t,x,y)='')'
             print '(''[1.465102139d0,0.14651021d0,0.0d0,2.84673289d0]'')'
             print '()'
             print '(''T0 should be 0.95'')'
             print '(''flow_direction should be x-direction'')'
             print '(''ic_choice should be newgrdpt_test'')'
             print '()'
             stop ''
             
          end if

        end subroutine check_inputs

      end program test_bf_layer_newgrdpt
