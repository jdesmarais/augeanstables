      module check_data_module

        use parameters_kind, only :
     $     rkind

        implicit none


        private
        public ::
     $       is_test_validated,
     $       is_vector_validated,
     $       is_matrix_validated,
     $       is_int_vector_validated,
     $       is_int_matrix_validated

        
        contains


        function is_test_validated(var,cst,detailled) result(test_validated)

          implicit none

          real(rkind), intent(in) :: var
          real(rkind), intent(in) :: cst
          logical                 :: detailled
          logical                 :: test_validated

          if(detailled) then
             print *, nint(var*1e13)
             print *, nint(cst*1e13)
          end if
          
          test_validated=abs(
     $         nint(var*1e13)-
     $         nint(cst*1e13)).le.1
          
        end function is_test_validated


        function is_vector_validated(var,cst,detailled) result(test_validated)

          implicit none

          real(rkind), dimension(:), intent(in) :: var
          real(rkind), dimension(:), intent(in) :: cst
          logical                  , intent(in) :: detailled
          logical                               :: test_validated

          logical :: test_loc
          integer :: i

          test_validated = .true.

          do i=1,size(var,1)
             test_loc = is_test_validated(var(i),cst(i),.false.)
             test_validated = test_validated.and.test_loc
             if(detailled.and.(.not.test_loc)) then
                print '(''['',I2'']:'',F8.3,'' -> '',F8.3)', 
     $               i, var(i), cst(i)
             end if
          end do

        end function is_vector_validated


        function is_matrix_validated(var,cst,detailled) result(test_validated)

          implicit none

          real(rkind), dimension(:,:), intent(in) :: var
          real(rkind), dimension(:,:), intent(in) :: cst
          logical                    , intent(in) :: detailled
          logical                                 :: test_validated

          logical :: test_loc
          integer :: i,j

          test_validated = .true.

          do j=1,size(var,2)
             do i=1,size(var,1)
                test_loc = is_test_validated(var(i,j),cst(i,j),.false.)
                test_validated = test_validated.and.test_loc
                if(detailled.and.(.not.test_loc)) then
                   print '(''['',2I2'']:'',F8.3,'' -> '',F8.3)', 
     $                  i,j,
     $                  var(i,j), cst(i,j)
                end if
             end do
          end do

        end function is_matrix_validated


        function is_int_vector_validated(
     $     int_vector,
     $     int_vector_cst,
     $     detailled)
     $     result(test_validated)

          implicit none

          integer, dimension(:), intent(in) :: int_vector
          integer, dimension(:), intent(in) :: int_vector_cst
          logical, optional    , intent(in) :: detailled
          logical                           :: test_validated


          integer :: i
          logical :: test_loc
          logical :: detailled_op


          if(present(detailled)) then
             detailled_op = detailled
          else
             detailled_op = .false.
          end if


          test_validated = .true.


          do i=1, size(int_vector)

             test_loc = int_vector(i).eq.int_vector_cst(i)
             test_validated = test_validated.and.test_loc

             if(detailled_op.and.(.not.test_loc)) then

                print '(''['',I2,'']: '',I5, '' -> '',I5)',
     $               i, int_vector(i), int_vector_cst(i)

             end if

          end do

        end function is_int_vector_validated


        function is_int_matrix_validated(
     $     int_matrix,
     $     int_matrix_cst,
     $     detailled)
     $     result(test_validated)

          implicit none

          integer, dimension(:,:), intent(in) :: int_matrix
          integer, dimension(:,:), intent(in) :: int_matrix_cst
          logical, optional      , intent(in) :: detailled
          logical                             :: test_validated


          integer :: j
          logical :: test_loc
          logical :: detailled_op


          if(present(detailled)) then
             detailled_op = detailled
          else
             detailled_op = .false.
          end if

          test_validated = .true.

          do j=1, size(int_matrix,2)

             test_loc = is_int_vector_validated(
     $            int_matrix(:,j),
     $            int_matrix_cst(:,j),
     $            detailled=detailled_op)

             test_validated = test_validated.and.test_loc

          end do

        end function is_int_matrix_validated

      end module check_data_module
