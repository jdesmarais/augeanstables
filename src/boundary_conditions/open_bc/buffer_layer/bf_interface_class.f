      !> @file
      !> module implementing the object encapsulating the buffer layers
      !> around the interior domain and the relations to synchronize the
      !> data between them
      !
      !> @author
      !> Julien L. Desmarais
      !
      !> @brief
      !> module implementing the object encapsulating the buffer layers
      !> around the interior domain and the relations to synchronize the
      !> data between them
      !
      !> @date
      ! 27_06_2014 - documentation update - J.L. Desmarais
      !-----------------------------------------------------------------
      module bf_interface_class

        use bf_layer_errors_module    , only : error_mainlayer_id,
     $                                         error_incompatible_neighbor
        use bf_sublayer_class         , only : bf_sublayer
        use bf_mainlayer_class        , only : bf_mainlayer
        use bf_mainlayer_pointer_class, only : bf_mainlayer_pointer
        use nbf_interface_class       , only : nbf_interface

        use parameters_bf_layer       , only : align_N, align_S,
     $                                         align_E, align_W
        use parameters_constant       , only : N,S,E,W,
     $                                         x_direction, y_direction,
     $                                         interior
        use parameters_input          , only : nx,ny,ne,bc_size,debug
        use parameters_kind           , only : ikind, rkind
        use sbf_list_class            , only : sbf_list


        implicit none

        private
        public :: bf_interface
        

        !>@class bf_interface
        !> class encapsulating the buffer layers around the interior
        !> domain and subroutines to synchronize the data between them
        !
        !>@param mainlayer_pointers
        !> table with reference to the bf_mainlayers objects gathering
        !> the bf_sublayer corresponding to a specific cardinal point
        !
        !>@param border_interface
        !> object encapsulating references to the sublayers at the edge
        !> between the main layers and subroutines to synchronize the data
        !> between them
        !
        !>@param ini
        !> initialize the buffer/interior domain interface
        !
        !>@param get_mainlayer
        !> get the bf_mainlayer object corresponding to the cardinal point
        !
        !>@param allocate_sublayer
        !> allocate a bf_sublayer and insert it in the corresponding
        !> buffer mainlayer
        !
        !>@param reallocate_sublayer
        !> reallocate a buffer sublayer and check whether the neighboring
        !> buffer layer changed and so if the neighboring links should be
        !> updated
        !
        !>@param merge_sublayers
        !> merge the content of two sublayers and update
        !> the links to the border buffer layers
        !
        !>@param remove_sublayer
        !> remove a sublayer from the buffer main layers
        !
        !>@param update_grdpts_after_increase
        !> compute the new grid points of the bf_sublayer after its
        !> increase and synchronize the neighboring buffer layers
        !
        !>@param get_mainlayer_id
        !> get the cardinal coordinate corresponding to
        !> the general coordinates
        !
        !>@param get_sublayer
        !> get the sublayer corresponding to the general coordinates
        !> asked within the tolerance
        !
        !>@param get_nodes
        !> extract the governing variables at a general coordinates
        !> asked by the user
        !
        !>@param update_grdpts_from_neighbors
        !> if the buffer sublayer passed as argument has grid points
        !> in common with buffer layers from other main layers, the
        !> grid points in common are updated from the neighboring buffer
        !> layers
        !
        !>@param update_neighbor_grdpts
        !< if the buffer sublayer passed as argument has grid points
        !> in common with the buffer layers from other main layers, the
        !> grid points in common are updated in the neighboring buffer
        !> layers from the current buffer layer
        !
        !>@param shares_with_neighbor1
        !> check if the alignment of the future sublayer makes it a
        !> potential neighboring buffer layer of type 1 and if so
        !> update its alignment if it is shifted by one grid
        !> point from the border as it makes exchanges easier later the
        !> sublayer is here tested as a neighbor buffer layer of type 1
        !> this function echoes bf_layer_class%shares_grdpts_with_neighbor1
        !
        !>@param shares_with_neighbor2
        !> check if the alignment of the future sublayer makes it a
        !> potential neighboring buffer layer of type 2 and if so
        !> update its alignment if it is shifted by one grid
        !> point from the border as it makes exchanges easier later the
        !> sublayer is here tested as a neighbor buffer layer of type 1
        !> this function echoes bf_layer_class%shares_grdpts_with_neighbor1
        !
        !>@param get_nbf_layers_sharing_grdpts_with
        !> determine the neighboring buffer layers sharing grid points
        !> with the current buffer layer
        !
        !>@param bf_layer_depends_on_neighbors
        !> determine whether a buffer layer depends on its neighboring
        !> buffer layers
        !
        !>@param does_a_neighbor_remains
        !> check if the neighboring bf_layers from bf_sublayer_i can
        !> all be removed
        !
        !>@param print_binary
        !> print the content of the interface on external binary files
        !
        !>@param print_netcdf
        !> print the content of the interface on external netcdf files
        !---------------------------------------------------------------
        type :: bf_interface

          type(bf_mainlayer_pointer), dimension(4), private :: mainlayer_pointers
          type(nbf_interface)                     , private :: border_interface

          contains

          procedure, pass :: ini
          procedure, pass :: get_mainlayer

          procedure, pass :: allocate_sublayer
          procedure, pass :: reallocate_sublayer
          procedure, pass :: merge_sublayers
          procedure, pass :: remove_sublayer
          procedure, pass :: update_grdpts_after_increase

          procedure, nopass :: get_mainlayer_id
          procedure, pass   :: get_sublayer
          procedure, pass   :: get_nodes

          procedure, pass, private :: update_grdpts_from_neighbors
          procedure, pass, private :: update_neighbor_grdpts
          
          procedure, nopass, private :: shares_with_neighbor1
          procedure, nopass, private :: shares_with_neighbor2

          procedure, pass :: get_nbf_layers_sharing_grdpts_with
          procedure, pass :: bf_layer_depends_on_neighbors
          procedure, pass :: does_a_neighbor_remains

          procedure, pass :: print_binary
          procedure, pass :: print_netcdf

        end type bf_interface

        contains


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> initialize the buffer/interior domain interface
        !
        !> @date
        !> 26_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_interface object encapsulating the buffer layers
        !> around the interior domain and subroutines to synchronize
        ! the data between them
        !--------------------------------------------------------------
        subroutine ini(this)

          implicit none

          class(bf_interface), intent(inout) :: this

          integer :: i
          
          do i=1, size(this%mainlayer_pointers,1)
             call this%mainlayer_pointers(i)%ini()             
          end do

          call this%border_interface%ini()

        end subroutine ini


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the bf_mainlayer object corresponding to the cardinal point
        !
        !> @date
        !> 26_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_interface object encapsulating the buffer layers
        !> around the interior domain and subroutines to synchronize
        !> the data between them
        !
        !>@param mainlayer_id
        !> cardinal coordinate for the bf_mainlayer asked
        !
        !>@return get_mainlayer
        !> reference to the bf_mainlayer corresponding to the cardinal
        !> coordinate
        !--------------------------------------------------------------
        function get_mainlayer(this, mainlayer_id)
       
         implicit none
   
         class(bf_interface), intent(in) :: this
         integer            , intent(in) :: mainlayer_id
         type(bf_mainlayer) , pointer    :: get_mainlayer

         if(debug) then
            if((mainlayer_id.lt.1).or.(mainlayer_id.gt.4)) then
               call error_mainlayer_id(
     $              'bf_interface_class',
     $              'get_mainlayer',
     $              mainlayer_id)
            end if
         end if

         if(this%mainlayer_pointers(mainlayer_id)%associated_ptr()) then
            get_mainlayer => this%mainlayer_pointers(mainlayer_id)%get_ptr()
         else
            nullify(get_mainlayer)
         end if

       end function get_mainlayer


       !> @author
       !> Julien L. Desmarais
       !
       !> @brief
       !> check if the alignment of the future sublayer makes it a
       !> potential neighboring buffer layer of type 1 and if so
       !> update its alignment if it is shifted by one grid
       !> point from the border as it makes exchanges easier later the
       !> sublayer is here tested as a neighbor buffer layer of type 1
       !> this function echoes bf_layer_class%shares_grdpts_with_neighbor1
       !
       !> @date
       !> 27_06_2014 - initial version - J.L. Desmarais
       !
       !>@param mainlayer_id
       !> cardinal coordinate for the bf_mainlayer asked
       !
       !>@param bf_final_alignment
       !> position of the future buffer layer
       !
       !>@return share_grdpts
       !> logical stating whether the future sublayer is a potential
       !> buffer layer at the edge between main layers
       !--------------------------------------------------------------
       function shares_with_neighbor1(mainlayer_id, bf_final_alignment)
     $     result(share_grdpts)

         implicit none

         integer                       , intent(in)    :: mainlayer_id
         integer(ikind), dimension(2,2), intent(inout) :: bf_final_alignment
         logical                                       :: share_grdpts


         select case(mainlayer_id)
           case(N,S)
              share_grdpts = bf_final_alignment(1,1).le.(align_W+bc_size)
           case(E,W)
              share_grdpts = bf_final_alignment(2,1).le.(align_S+bc_size)
              if(bf_final_alignment(2,1).eq.(align_S+bc_size)) then
                 bf_final_alignment(2,1)=align_S+1
              end if
           case default
              call error_mainlayer_id(
     $             'bf_layer_class.f',
     $             'share_grdpts_with_neighbor1',
     $             mainlayer_id)
         end select

       end function shares_with_neighbor1


       !> @author
       !> Julien L. Desmarais
       !
       !> @brief
       !> check if the alignment of the future sublayer makes it a
       !> potential neighboring buffer layer of type 2 and if so
       !> update its alignment if it is shifted by one grid
       !> point from the border as it makes exchanges easier later the
       !> sublayer is here tested as a neighbor buffer layer of type 1
       !> this function echoes bf_layer_class%shares_grdpts_with_neighbor1
       !
       !> @date
       !> 27_06_2014 - initial version - J.L. Desmarais
       !
       !>@param mainlayer_id
       !> cardinal coordinate for the bf_mainlayer asked
       !
       !>@param bf_final_alignment
       !> position of the future buffer layer
       !
       !>@return share_grdpts
       !> logical stating whether the future sublayer is a potential
       !> buffer layer at the edge between main layers
       !--------------------------------------------------------------
       function shares_with_neighbor2(mainlayer_id, bf_final_alignment)
     $     result(share_grdpts)

         implicit none

         integer                       , intent(in)    :: mainlayer_id
         integer(ikind), dimension(2,2), intent(inout) :: bf_final_alignment
         logical                                       :: share_grdpts


         select case(mainlayer_id)
           case(N,S)
              share_grdpts = bf_final_alignment(1,2).ge.(align_E-bc_size)
           case(E,W)
              share_grdpts = bf_final_alignment(2,2).ge.(align_N-bc_size)
              if(bf_final_alignment(2,2).eq.(align_N-bc_size)) then
                 bf_final_alignment(2,2)=align_N-1
              end if
           case default
              call error_mainlayer_id(
     $             'bf_layer_class.f',
     $             'share_grdpts_with_neighbor1',
     $             mainlayer_id)
         end select

       end function shares_with_neighbor2


       !> @author
       !> Julien L. Desmarais
       !
       !> @brief
       !> allocate a bf_sublayer and insert it in the corresponding
       !> buffer mainlayer
       !
       !> @date
       !> 27_06_2014 - initial version - J.L. Desmarais
       !
       !>@param this
       !> bf_interface object encapsulating the buffer layers
       !> around the interior domain and subroutines to synchronize
       !> the data between them
       !
       !>@param mainlayer_id
       !> cardinal coordinate for the new bf_sublayer
       !
       !>@param nodes
       !> table encapsulating the data of the grid points of the
       !> interior domain
       !
       !>@param alignment
       !> table of integers characterizing the
       !> correspondance between the interior grid points
       !> and the buffer layer elements
       !
       !>@return added_sublayer
       !> reference to the newly allocated bf_sublayer
       !--------------------------------------------------------------
       function allocate_sublayer(
     $     this,
     $     mainlayer_id,
     $     nodes,
     $     alignment)
     $     result(added_sublayer)
        
          class(bf_interface)             , intent(inout) :: this
          integer                         , intent(in)    :: mainlayer_id
          real(rkind), dimension(nx,ny,ne), intent(in)    :: nodes
          integer, dimension(2,2)         , intent(inout) :: alignment

          type(bf_sublayer), pointer                      :: added_sublayer


          logical :: share_with_neighbor1
          logical :: share_with_neighbor2


          !0) debug : check the mainlayer id
          if(debug) then
             if((mainlayer_id.lt.1).or.(mainlayer_id.gt.4)) then
                call error_mainlayer_id(
     $              'bf_interface_class',
     $              'allocate_sublayer',
     $              mainlayer_id)
             end if
          end if

          !1) check if the new sublayer is at the interface between several
          !   main layers and update the alignment in case it is just one grid
          !   point away from a corner: exchanges are made easier
          share_with_neighbor1 = shares_with_neighbor1(mainlayer_id, alignment)
          share_with_neighbor2 = shares_with_neighbor2(mainlayer_id, alignment)


          !2) check if the mainlayer corresponding to the cardinal point is
          !   indeed allocated: if the memory space is not allocated, the space
          !   in memory is first allocated, the pointer identifying the mainlayer
          !   is initialized and the main layer itself is initialized
          if(.not.this%mainlayer_pointers(mainlayer_id)%associated_ptr()) then
             call this%mainlayer_pointers(mainlayer_id)%ini_mainlayer(mainlayer_id)
          end if


          !3) now that we are sure that space is allocated for the main layer,
          !   the sublayer can be integrated to the mainlayer and the buffer
          !   layer can be initialized using the nodes, alignment and neighbors
          !   arguments
          added_sublayer => this%mainlayer_pointers(mainlayer_id)%add_sublayer(
     $         nodes, alignment)
          call added_sublayer%set_neighbor1_share(share_with_neighbor1)
          call added_sublayer%set_neighbor2_share(share_with_neighbor2)

          !4) if the sublayer newly allocated is indeed a buffer layer at the
          !   interface between main layers and of type 1, the neighboring
          !   buffer layers should know that they will exchange data with this
          !   buffer layer.          
          !   The same is true for an interface buffer layer of type 2          
          if(share_with_neighbor1) then
             call this%border_interface%link_neighbor1_to_bf_sublayer(
     $            added_sublayer)
          end if
          if(share_with_neighbor2) then
             call this%border_interface%link_neighbor2_to_bf_sublayer(
     $            added_sublayer)
          end if
          
          !5) Morover, the new buffer layer has been allocated without considering
          !   the other buffer layers already allocated which could share grid
          !   points with this buffer layer. These grid points are now copy from
          !   the other buffer layers to this buffer layer
          call this%border_interface%update_grdpts_from_neighbors(added_sublayer)

       end function allocate_sublayer


       !> @author
       !> Julien L. Desmarais
       !
       !> @brief
       !> reallocate a buffer sublayer and check whether the neighboring
       !> buffer layer changed and so if the neighboring links should be
       !> updated
       !
       !> @date
       !> 27_06_2014 - initial version - J.L. Desmarais
       !
       !>@param this
       !> bf_interface object encapsulating the buffer layers
       !> around the interior domain and subroutines to synchronize
       !> the data between them
       !
       !>@param bf_sublayer_r
       !> reference to the bf_sublayer to be reallocated
       !
       !>@param nodes
       !> table encapsulating the data of the grid points of the
       !> interior domain
       !
       !>@param alignment
       !> table of integers characterizing the
       !> correspondance between the interior grid points
       !> and the buffer layer
       !--------------------------------------------------------------
       subroutine reallocate_sublayer(
     $     this, bf_sublayer_r, nodes, alignment)

         implicit none

         class(bf_interface)             , intent(inout) :: this
         type(bf_sublayer), pointer      , intent(inout) :: bf_sublayer_r
         real(rkind), dimension(nx,ny,ne), intent(in)    :: nodes
         integer    , dimension(2,2)     , intent(inout) :: alignment

         integer :: mainlayer_id
         logical :: share_with_neighbor1
         logical :: share_with_neighbor2

         mainlayer_id = bf_sublayer_r%get_localization()


         !1) check if the reallocated sublayer is at the interface between
         !   several main layers and update the alignment in case it is just
         !   one grid point away from a corner: exchanges are made easier
         share_with_neighbor1 = shares_with_neighbor1(mainlayer_id, alignment)
         share_with_neighbor2 = shares_with_neighbor2(mainlayer_id, alignment)

         
         !2) reallocate the buffer sublayer
         call bf_sublayer_r%reallocate_bf_layer(
     $        nodes, alignment)

         !3) check if the links to the neighbor1 should be updated
         ! if the bf_sublayer_r was exchanging with neighbor1 before
         if(bf_sublayer_r%can_exchange_with_neighbor1()) then
            
            !and the bf_sublayer_r can no longer exchange
            !the previous links should be removed
            if(.not.share_with_neighbor1) then
               call this%border_interface%remove_link_from_neighbor1_to_bf_sublayer(
     $              bf_sublayer_r)
            end if

         ! if the bf_sublayer_r was not exchanging with neighbor1 before
         else

            !and the bf_sublayer_r can now exchange, links should be added
            !to this bf_sublayer_r
            if(share_with_neighbor1) then
               call this%border_interface%link_neighbor1_to_bf_sublayer(
     $              bf_sublayer_r)
            end if

         end if

         !4) check if the links to the neighbor2 should be updated
         ! if the bf_sublayer_r was exchanging with neighbor2 before
         if(bf_sublayer_r%can_exchange_with_neighbor2()) then
            
            !and the bf_sublayer_r can no longer exchange
            !the previous links should be removed
            if(.not.share_with_neighbor2) then
               call this%border_interface%remove_link_from_neighbor2_to_bf_sublayer(
     $              bf_sublayer_r)
            end if

         ! if the bf_sublayer_r was not exchanging with neighbor2 before
         else

            !and the bf_sublayer_r can now exchange, links should be added
            !to this bf_sublayer_r
            if(share_with_neighbor2) then
               call this%border_interface%link_neighbor2_to_bf_sublayer(
     $              bf_sublayer_r)
            end if

         end if

         !5) update the status of the bf_sublayer_r for its neighbors
         call bf_sublayer_r%set_neighbor1_share(share_with_neighbor1)
         call bf_sublayer_r%set_neighbor2_share(share_with_neighbor2)

         !6) update the grid points new allocated using the neighboring sublayers
         call this%border_interface%update_grdpts_from_neighbors(bf_sublayer_r)
         
       end subroutine reallocate_sublayer
       

       !> @author
       !> Julien L. Desmarais
       !
       !> @brief
       !> merge the content of two sublayers and update
       !> the links to the border buffer layers
       !
       !> @date
       !> 27_06_2014 - initial version - J.L. Desmarais
       !
       !>@param this
       !> bf_interface object encapsulating the buffer layers
       !> around the interior domain and subroutines to synchronize
       !> the data between them
       !
       !>@param bf_sublayer1
       !> reference to the first bf_sublayer merged
       !
       !>@param bf_sublayer2
       !> reference to the second bf_sublayer merged
       !
       !>@param nodes
       !> table encapsulating the data of the grid points of the
       !> interior domain
       !
       !>@param alignment
       !> table of integers characterizing the
       !> correspondance between the interior grid points
       !> and the buffer layer
       !--------------------------------------------------------------
       function merge_sublayers(
     $     this,
     $     bf_sublayer1, bf_sublayer2,
     $     nodes, alignment)
     $     result(merged_sublayer)

          implicit none

          class(bf_interface)                        , intent(inout) :: this
          type(bf_sublayer), pointer                 , intent(inout) :: bf_sublayer1
          type(bf_sublayer), pointer                 , intent(inout) :: bf_sublayer2
          real(rkind)      , dimension(nx,ny,ne)     , intent(in)    :: nodes
          integer(ikind)   , dimension(2,2), optional, intent(inout) :: alignment
          type(bf_sublayer), pointer                                 :: merged_sublayer

          integer :: mainlayer_id
          logical :: share_with_neighbor1
          logical :: share_with_neighbor2


          mainlayer_id = bf_sublayer1%get_localization()
   

          if(present(alignment)) then


             !1) check if the sublayer resulting from the merge is at the interface
             !   between several main layers and update the alignment in case it is just
             !   one grid point away from a corner: exchanges are made easier
             share_with_neighbor1 = shares_with_neighbor1(mainlayer_id, alignment)
             share_with_neighbor2 = shares_with_neighbor2(mainlayer_id, alignment)


             !2) check if the links to neighbor1 should be updated
             !if the bf_sublayer1 was already linked to neighbor1 sublayers
             if(bf_sublayer1%can_exchange_with_neighbor1()) then
                
                !if the bf_sublayer2 was also linked to neighbor1 sublayers
                !as it will be merged, these links should be removed
                if(bf_sublayer2%can_exchange_with_neighbor1()) then
                   call this%border_interface%remove_link_from_neighbor1_to_bf_sublayer(
     $                  bf_sublayer2)

                end if

             !if the bf_sublayer1 was not linked to neighbor1 sublayers
             else

                !and the bf_sublayer2 was linked to this neighbor, the links should
                !be updated from bf_sublayer2 to bf_sublayer1 and the status of the
                !neighbor1 for bf_sublayer1 should be updated
                if(bf_sublayer2%can_exchange_with_neighbor1()) then

                   call this%border_interface%update_link_from_neighbor1_to_bf_sublayer(
     $                  bf_sublayer1, bf_sublayer2)

                   call bf_sublayer1%set_neighbor1_share(.true.)


                !and if the bf_sublayer2 was also not linked to neighbor1
                else
                   
                   !and if the final alignment is such that the merged sublayer
                   !will exchange with neighbor1, links should be created to
                   !bf_sublayer1 and the state of the neighbor1 for bf_sublayer1
                   !should be updated
                   if(share_with_neighbor1) then
                      
                      call this%border_interface%link_neighbor1_to_bf_sublayer(
     $                     bf_sublayer1)

                      call bf_sublayer1%set_neighbor1_share(.true.)

                   end if
                end if
             end if


             !3) check if the links to neighbor2 should be updated
             !if the bf_sublayer1 was already linked to neighbor1 sublayers
             if(bf_sublayer1%can_exchange_with_neighbor2()) then
                
                !if the bf_sublayer2 was also linked to neighbor2 sublayers
                !as it will be merged, these links should be removed
                if(bf_sublayer2%can_exchange_with_neighbor2()) then
                   call this%border_interface%remove_link_from_neighbor2_to_bf_sublayer(
     $                  bf_sublayer2)

                end if

             !if the bf_sublayer1 was not linked to neighbor2 sublayers
             else

                !and on the contrary the bf_sublayer2 was linked to this neighbor
                !the links should be updated from bf_sublayer2 to bf_sublayer1
                !and the status of the neighbor2 for bf_sublayer1 should be updated
                if(bf_sublayer2%can_exchange_with_neighbor2()) then

                   call this%border_interface%update_link_from_neighbor2_to_bf_sublayer(
     $                  bf_sublayer1, bf_sublayer2)

                   call bf_sublayer1%set_neighbor2_share(.true.)


                !and if the bf_sublayer2 was also not linked to neighbor2
                else
                   
                   !and if the final alignment is such that the merged sublayer
                   !will exchange with neighbor2, links should be created to
                   !bf_sublayer1 and the state of the neighbor2 for bf_sublayer1
                   !should be updated
                   if(share_with_neighbor2) then
                      
                      call this%border_interface%link_neighbor2_to_bf_sublayer(
     $                     bf_sublayer1)

                      call bf_sublayer1%set_neighbor2_share(.true.)

                   end if
                end if
             end if


             !4) merge the content of the sublayers
             merged_sublayer => this%mainlayer_pointers(mainlayer_id)%merge_sublayers(
     $            bf_sublayer1, bf_sublayer2,
     $            nodes,alignment)

          else

             !2) check if the links to neighbor1 should be updated
             !if the bf_sublayer1 was already linked to neighbor1 sublayers
             if(bf_sublayer1%can_exchange_with_neighbor1()) then
                
                !if the bf_sublayer2 was also linked to neighbor1 sublayers
                !as it will be merged, these links should be removed
                if(bf_sublayer2%can_exchange_with_neighbor1()) then
                   call this%border_interface%remove_link_from_neighbor1_to_bf_sublayer(
     $                  bf_sublayer2)

                end if

             !if the bf_sublayer1 was not linked to neighbor1 sublayers
             else

                !and the bf_sublayer2 was linked to this neighbor, the links should
                !be updated from bf_sublayer2 to bf_sublayer1 and the status of the
                !neighbor1 for bf_sublayer1 should be updated
                if(bf_sublayer2%can_exchange_with_neighbor1()) then

                   call this%border_interface%update_link_from_neighbor1_to_bf_sublayer(
     $                  bf_sublayer1, bf_sublayer2)

                   call bf_sublayer1%set_neighbor1_share(.true.)

                end if
             end if


             !3) check if the links to neighbor2 should be updated
             !if the bf_sublayer1 was already linked to neighbor1 sublayers
             if(bf_sublayer1%can_exchange_with_neighbor2()) then
                
                !if the bf_sublayer2 was also linked to neighbor2 sublayers
                !as it will be merged, these links should be removed
                if(bf_sublayer2%can_exchange_with_neighbor2()) then
                   call this%border_interface%remove_link_from_neighbor2_to_bf_sublayer(
     $                  bf_sublayer2)

                end if

             !if the bf_sublayer1 was not linked to neighbor2 sublayers
             else

                !and on the contrary the bf_sublayer2 was linked to this neighbor
                !the links should be updated from bf_sublayer2 to bf_sublayer1
                !and the status of the neighbor2 for bf_sublayer1 should be updated
                if(bf_sublayer2%can_exchange_with_neighbor2()) then

                   call this%border_interface%update_link_from_neighbor2_to_bf_sublayer(
     $                  bf_sublayer1, bf_sublayer2)

                   call bf_sublayer1%set_neighbor2_share(.true.)

                end if
             end if


             !4) merge the content of the sublayers
             merged_sublayer => this%mainlayer_pointers(mainlayer_id)%merge_sublayers(
     $            bf_sublayer1, bf_sublayer2,
     $            nodes)

          end if


          !5) update the grid points that have been newly allocated
          !   with grid points from the neighboring sublayers
          call this%border_interface%update_grdpts_from_neighbors(bf_sublayer1)


c$$$          !6) if the merge is such that grid points between the two
c$$$          !   sublayers should be updated to prevent a line of inconsistent
c$$$          !   boundary points
c$$$          !    ________  ________        __________________
c$$$          !   |        ||        |      |                  |
c$$$          !   |        ||        |  ->  |                  |
c$$$          !   |        ||        |      |                  |
c$$$          print '(''bf_interface_class'')'
c$$$          print '(''merge_sublayers'')'
c$$$          stop 'not implemented yet'

       end function merge_sublayers


       !> @author
       !> Julien L. Desmarais
       !
       !> @brief
       !> remove a sublayer from the buffer main layers
       !
       !> @date
       !> 27_06_2014 - initial version - J.L. Desmarais
       !
       !>@param this
       !> bf_interface object encapsulating the buffer layers
       !> around the interior domain and subroutines to synchronize
       !> the data between them
       !
       !>@param sublayer_ptr
       !> reference to the bf_sublayer removed
       !
       !>@param bf_mainlayer_id
       !> cardinal coordinate of the buffer layer removed
       !--------------------------------------------------------------
       subroutine remove_sublayer(this, sublayer_ptr, bf_mainlayer_id)

         implicit none

         class(bf_interface)       , intent(inout) :: this
         type(bf_sublayer), pointer, intent(inout) :: sublayer_ptr
         integer         , optional, intent(in)    :: bf_mainlayer_id

         
         integer :: mainlayer_id


         !> identify the mainlayer to which the sublayer belongs
         if(present(bf_mainlayer_id)) then
            mainlayer_id = bf_mainlayer_id
         else
            mainlayer_id = sublayer_ptr%get_localization()
         end if

         !> remove the sublayer from the table identifying the
         !> neighboring buffer layers
         if(sublayer_ptr%can_exchange_with_neighbor1()) then
            call this%border_interface%remove_link_from_neighbor1_to_bf_sublayer(
     $           sublayer_ptr)
         end if
         if(sublayer_ptr%can_exchange_with_neighbor2()) then
            call this%border_interface%remove_link_from_neighbor2_to_bf_sublayer(
     $           sublayer_ptr)
         end if

         !> remove the sublayer from the main layer
         call this%mainlayer_pointers(mainlayer_id)%remove_sublayer(sublayer_ptr)

       end subroutine remove_sublayer


       !> @author
       !> Julien L. Desmarais
       !
       !> @brief
       !> get the cardinal coordinate corresponding to
       !> the general coordinates
       !
       !> @date
       !> 11_04_2013 - initial version - J.L. Desmarais
       !
       !>@param general_coord
       !> integer table giving the general coordinates
       !
       !>@return mainlayer_id
       !> main layer cardinal coordinates
       !--------------------------------------------------------------
       function get_mainlayer_id(general_coord) result(mainlayer_id)

         implicit none

         integer(ikind), dimension(2), intent(in) :: general_coord
         integer                                  :: mainlayer_id

         if(general_coord(2).le.align_S) then
            mainlayer_id = S

         else
            if(general_coord(2).lt.(align_N)) then

               if(general_coord(1).le.align_W) then
                  mainlayer_id = W

               else
                  if(general_coord(1).lt.align_E) then
                     mainlayer_id = interior

                  else
                     mainlayer_id = E

                  end if
               end if
                     
            else
               mainlayer_id = N

            end if
         end if

       end function get_mainlayer_id


       !> @author
       !> Julien L. Desmarais
       !
       !> @brief
       !> get the sublayer corresponding to the general coordinates
       !> asked within the tolerance
       !
       !> @date
       !> 11_04_2013 - initial version - J.L. Desmarais
       !
       !>@param this
       !> bf_interface object encapsulating the buffer layers
       !> around the interior domain and subroutines to synchronize
       !> the data between them
       !
       !>@param general_coord
       !> table giving the general coordinates of the point analyzed
       !
       !>@param local_coord
       !> table giving the local coordinates of the point analyzed
       !> in the corresponding bf_sublayer
       !
       !>@param tolerance_i
       !> integer indicating how far the gridpoint can be from the
       !> closest sublayer to be considered inside
       !
       !>@param mainlayer_id_i
       !> cardinal coordinate cooresponding to the general coordinates
       !
       !>@return sublayer
       !> reference to the bf_sublayer matching the general coordinates
       !> of the grid point
       !--------------------------------------------------------------
       function get_sublayer(
     $    this,
     $    general_coord,
     $    local_coord,
     $    tolerance_i,
     $    mainlayer_id_i)
     $    result(sublayer)

         implicit none

         class(bf_interface)         , intent(in)  :: this
         integer(ikind), dimension(2), intent(in)  :: general_coord
         integer(ikind), dimension(2), intent(out) :: local_coord
         integer       , optional    , intent(in)  :: tolerance_i
         integer       , optional    , intent(in)  :: mainlayer_id_i
         type(bf_sublayer), pointer                :: sublayer


         integer                     :: direction_tested
         integer                     :: mainlayer_id
         type(bf_mainlayer), pointer :: mainlayer
         integer                     :: tolerance
         logical                     :: grdpt_in_sublayer


         !< identification of the main layer
         if(present(mainlayer_id_i)) then
            mainlayer_id = mainlayer_id_i
         else
            mainlayer_id = get_mainlayer_id(general_coord)
         end if

         !< if the general coordinates match the interior,
         !> no sublayer matches the general coordinates
         !> and the sublayer pointer is nullified
         if(mainlayer_id.eq.interior) then
            nullify(sublayer)

         !< otherwise, the mainlayers are analyzed
         else

            !< check that the main layer exists
            !< if it does not exist, no sublayer can be saved inside
            !< and the pointer to the sublayer is nullified
            if(.not.this%mainlayer_pointers(mainlayer_id)%associated_ptr()) then
               nullify(sublayer)
                 
            !< if the main layer exists, the sublayers saved inside are
            !< checked to decide whether the grid point asked belongs to
            !< one of them or not
            else
               mainlayer => this%mainlayer_pointers(mainlayer_id)%get_ptr()
            
               !< check if sublayers are saved inside the mainlayer
               !> if no sublayers are saved inside the mainlayer,
               !> no existing sublayer can match the general coord
               !> and so the pointer to sublayer is nullified
               if(.not.associated(mainlayer%get_head_sublayer())) then
                  nullify(sublayer)
            
               !< otherwise, the sublayer corresponding to the general
               !> coordinates is searched by going through the different
               !> element of the doubled chained list
               else
                  sublayer => mainlayer%get_head_sublayer()
            
              	  !< processing the tolerance for matching a sublayer
            	  !> if no tolerence is provided, the default option is 0
                  if(.not.present(tolerance_i)) then
                     tolerance=0
                  else
                     tolerance=tolerance_i
                  end if
                  
                  !< if the mainlayer investigated is N,S,E or W, there can
                  !> be sublayers to be investigated
                  select case(mainlayer_id)
                    case(N,S)
                       direction_tested = x_direction
                    case(E,W)
                       direction_tested = y_direction
                  end select 

                  !check if the grid point belongs to the current sublayer
                  grdpt_in_sublayer =
     $                 (  general_coord(direction_tested).ge.
     $                 (sublayer%get_alignment(direction_tested,1)-bc_size-tolerance))
     $                 .and.(
     $                 general_coord(direction_tested).le.
     $                 (sublayer%get_alignment(direction_tested,2)+bc_size+tolerance))
            	
                  !go through the different sublayers
                  do while(.not.grdpt_in_sublayer)
            	        
            	     !if no matching sublayer can be found
            	     !nullify the corresponding pointer
                     if(.not.associated(sublayer%get_next())) then
                        nullify(sublayer)
                        exit
                     end if
                   
                     sublayer => sublayer%get_next()
                     grdpt_in_sublayer =
     $                    (general_coord(direction_tested).ge.
     $                    (sublayer%get_alignment(direction_tested,1)-bc_size-tolerance))
     $                    .and.(
     $                    general_coord(1).le.
     $                    (sublayer%get_alignment(direction_tested,2)+bc_size+tolerance))
            	
                  end do
            
               end if
            end if
         end if

         !< if a sublayer matching the general coordinates was found
         !> compute the local coordinates in this sublayer
         if(associated(sublayer)) then
            local_coord = sublayer%get_local_coord(general_coord)
         end if           
         
       end function get_sublayer


       !> @author
       !> Julien L. Desmarais
       !
       !> @brief
       !> extract the governing variables at a general coordinates
       !> asked by the user
       !
       !> @date
       !> 11_04_2013 - initial version - J.L. Desmarais
       !
       !>@param this
       !> bf_interface object encapsulating the buffer layers
       !> around the interior domain and subroutines to synchronize
       !> the data between them
       !
       !>@param g_coord
       !> table giving the general coordinates of the point analyzed
       !
       !>@param interior_nodes
       !> table encapsulating the data of the grid points of the
       !> interior domain
       !
       !>@return var
       !> governing variables at the grid point asked
       !--------------------------------------------------------------
       function get_nodes(this, g_coords, interior_nodes) result(var)

         implicit none
         
         class(bf_interface)             , intent(in) :: this
         integer(ikind), dimension(2)    , intent(in) :: g_coords
         real(rkind), dimension(nx,ny,ne), intent(in) :: interior_nodes
         real(rkind), dimension(ne)                   :: var

         integer                      :: mainlayer_id
         type(bf_sublayer), pointer   :: sublayer
         integer(ikind), dimension(2) :: l_coords
         
         mainlayer_id = this%get_mainlayer_id(g_coords)
         if((g_coords(1).ge.1).and.
     $        (g_coords(1).le.nx).and.
     $        (g_coords(2).ge.1).and.
     $        (g_coords(2).le.ny)) then
            var = interior_nodes(g_coords(1),g_coords(2),:)
         else
            sublayer => this%get_sublayer(
     $               g_coords, l_coords, mainlayer_id_i=mainlayer_id)
            if(associated(sublayer)) then
               var = sublayer%get_nodes(l_coords)
            else
               print '(''bf_interface_class'')'
               print '(''get_nodes'')'
               print '(''cannot get sublayer'')'
               stop 'check way to get nodes'
            end if               
         end if

       end function get_nodes    


       !> @author
       !> Julien L. Desmarais
       !
       !> @brief
       !> if the buffer sublayer passed as argument has grid points
       !> in common with buffer layers from other main layers, the
       !> grid points in common are updated from the neighboring buffer
       !> layers
       !
       !> @date
       !> 11_04_2013 - initial version - J.L. Desmarais
       !
       !>@param this
       !> bf_interface object encapsulating the buffer layers
       !> around the interior domain and subroutines to synchronize
       !> the data between them
       !
       !>@param nbf_sublayer
       !> bf_sublayer exchanging data with the neighboring buffer layers
       !--------------------------------------------------------------
       subroutine update_grdpts_from_neighbors(this, nbf_sublayer)

         implicit none

         class(bf_interface), intent(in)    :: this
         type(bf_sublayer)  , intent(inout) :: nbf_sublayer

         call this%border_interface%update_grdpts_from_neighbors(
     $        nbf_sublayer)

       end subroutine update_grdpts_from_neighbors


       !> @author
       !> Julien L. Desmarais
       !
       !> @brief
       !< if the buffer sublayer passed as argument has grid points
       !> in common with the buffer layers from other main layers, the
       !> grid points in common are updated in the neighboring buffer
       !> layers from the current buffer layer
       !
       !> @date
       !> 11_04_2013 - initial version - J.L. Desmarais
       !
       !>@param this
       !> bf_interface object encapsulating the buffer layers
       !> around the interior domain and subroutines to synchronize
       !> the data between them
       !
       !>@param nbf_sublayer
       !> bf_sublayer exchanging data with the neighboring buffer layers
       !--------------------------------------------------------------
       subroutine update_neighbor_grdpts(this, nbf_sublayer)

         implicit none

         class(bf_interface), intent(inout) :: this
         type(bf_sublayer)  , intent(inout) :: nbf_sublayer

         call this%border_interface%update_neighbor_grdpts(nbf_sublayer)

       end subroutine update_neighbor_grdpts


       !> @author
       !> Julien L. Desmarais
       !
       !> @brief
       !> compute the new grid points of the bf_sublayer after its
       !> increase and synchronize the neighboring buffer layers
       !
       !> @date
       !> 11_04_2013 - initial version - J.L. Desmarais
       !
       !>@param this
       !> bf_interface object encapsulating the buffer layers
       !> around the interior domain and subroutines to synchronize
       !> the data between them
       !
       !>@param bf_sublayer_i
       !> bf_sublayer exchanging data with the neighboring buffer layers
       !
       !>@param selected_grdpts
       !> list of the general coordinates of the grid points to be
       !> computed
       !--------------------------------------------------------------
       subroutine update_grdpts_after_increase(
     $     this, bf_sublayer_i, selected_grdpts)

         implicit none

         class(bf_interface)           , intent(inout) :: this
         type(bf_sublayer)             , intent(inout) :: bf_sublayer_i
         integer(ikind), dimension(:,:), intent(in)    :: selected_grdpts

         !compute the new grid points after the increase
         call bf_sublayer_i%update_grdpts_after_increase(
     $        selected_grdpts)

         !update the neighboring buffer layers
         call this%update_neighbor_grdpts(bf_sublayer_i)

       end subroutine update_grdpts_after_increase


       !> @author
       !> Julien L. Desmarais
       !
       !> @brief
       !> determine the neighboring buffer layers sharing grid points
       !> with the current buffer layer
       !
       !> @date
       !> 11_04_2013 - initial version - J.L. Desmarais
       !
       !>@param this
       !> bf_interface object encapsulating the buffer layers
       !> around the interior domain and subroutines to synchronize
       !> the data between them
       !
       !>@param bf_sublayer_i
       !> bf_sublayer exchanging data with the neighboring buffer layers
       !
       !>@param nbf1_list
       !> list of the neighboring buffer layers of type 1 sharing grid
       !> points with bf_sublayer_i
       !
       !>@param nbf2_list
       !> list of the neighboring buffer layers of type 2 sharing grid
       !> points with bf_sublayer_i
       !
       !>@param bf_mainlayer_id
       !> cardinal coordinate of bf_sublayer_i
       !--------------------------------------------------------------
       subroutine get_nbf_layers_sharing_grdpts_with(
     $     this, bf_sublayer_i, nbf1_list, nbf2_list, bf_mainlayer_id)

         implicit none
         
         class(bf_interface)       , intent(in)    :: this
         type(bf_sublayer), pointer, intent(in)    :: bf_sublayer_i
         type(sbf_list)            , intent(inout) :: nbf1_list
         type(sbf_list)            , intent(inout) :: nbf2_list
         integer         , optional, intent(in)    :: bf_mainlayer_id


         !determine inside the list of neighboring buffer layer of
         !type 1 which ones share grid points with the current
         !buffer layer
         if(bf_sublayer_i%can_exchange_with_neighbor1()) then
            if(present(bf_mainlayer_id)) then
               call this%border_interface%get_nbf_layers_sharing_grdpts_with(
     $              1, bf_sublayer_i, nbf1_list, bf_mainlayer_id)
            else
               call this%border_interface%get_nbf_layers_sharing_grdpts_with(
     $              1, bf_sublayer_i, nbf1_list)
            end if
         end if


         !determine inside the list of neighboring buffer layer of
         !type 2 which ones share grid points with the current
         !buffer layer
         if(bf_sublayer_i%can_exchange_with_neighbor2()) then
            if(present(bf_mainlayer_id)) then
               call this%border_interface%get_nbf_layers_sharing_grdpts_with(
     $              2, bf_sublayer_i, nbf2_list, bf_mainlayer_id)
            else
               call this%border_interface%get_nbf_layers_sharing_grdpts_with(
     $              2, bf_sublayer_i, nbf2_list)
            end if
         end if         

       end subroutine get_nbf_layers_sharing_grdpts_with


       !> @author
       !> Julien L. Desmarais
       !
       !> @brief
       !> determine whether a buffer layer depends on its neighboring
       !> buffer layers
       !
       !> @date
       !> 11_04_2013 - initial version - J.L. Desmarais
       !
       !>@param this
       !> bf_interface object encapsulating the buffer layers
       !> around the interior domain and subroutines to synchronize
       !> the data between them
       !
       !>@param bf_sublayer_i
       !> bf_sublayer exchanging data with the neighboring buffer layers
       !
       !>@param bf_mainlayer_id
       !> cardinal coordinate of bf_sublayer_i
       !
       !>@return dependent
       !> logical stating whether the bf_sublayer_i depends on neighboring
       !> buffer layers
       !--------------------------------------------------------------
       function bf_layer_depends_on_neighbors(
     $     this, bf_sublayer_i, bf_mainlayer_id)
     $     result(dependent)

         implicit none

         class(bf_interface)       , intent(in) :: this
         type(bf_sublayer), pointer, intent(in) :: bf_sublayer_i
         integer         , optional, intent(in) :: bf_mainlayer_id
         logical                                :: dependent
       
         
         !determine if the buffer layer is sharing grid points
         !with its neighborign buffer layers of type 1
         if(bf_sublayer_i%can_exchange_with_neighbor1()) then
            
            if(present(bf_mainlayer_id)) then
               dependent = this%border_interface%bf_layer_depends_on_neighbors(
     $              1, bf_sublayer_i, bf_mainlayer_id)
            else
               dependent = this%border_interface%bf_layer_depends_on_neighbors(
     $              1, bf_sublayer_i)
            end if
         else
            dependent = .false.
         end if
         

         !determine if the buffer layer is sharing grid points
         !with its neighborign buffer layers of type 2
         if(.not.dependent) then
            
            if(bf_sublayer_i%can_exchange_with_neighbor2()) then
               
               if(present(bf_mainlayer_id)) then
                  dependent = this%border_interface%bf_layer_depends_on_neighbors(
     $                 2, bf_sublayer_i, bf_mainlayer_id)
               else
                  dependent = this%border_interface%bf_layer_depends_on_neighbors(
     $                 2, bf_sublayer_i)
               end if

            else
               dependent = .false.
            end if
            
         end if

       end function bf_layer_depends_on_neighbors


       !> @author
       !> Julien L. Desmarais
       !
       !> @brief
       !> check if the neighboring bf_layers from bf_sublayer_i can
       !> all be removed
       !
       !> @date
       !> 11_04_2013 - initial version - J.L. Desmarais
       !
       !>@param this
       !> bf_interface object encapsulating the buffer layers
       !> around the interior domain and subroutines to synchronize
       !> the data between them
       !
       !>@param bf_sublayer_i
       !> bf_sublayer exchanging data with the neighboring buffer layers
       !
       !>@param bf_mainlayer_id
       !> cardinal coordinate of bf_sublayer_i
       !
       !>@return a_neighbor_remains
       !> logical stating whether the bf_sublayer_i should not be removed
       !> because one of its neighbors remains
       !--------------------------------------------------------------
       function does_a_neighbor_remains(
     $     this, bf_sublayer_i, bf_mainlayer_id)
     $     result(a_neighbor_remains)

         implicit none

         class(bf_interface)       , intent(in) :: this
         type(bf_sublayer), pointer, intent(in) :: bf_sublayer_i
         integer         , optional, intent(in) :: bf_mainlayer_id
         logical                                :: a_neighbor_remains


         !determine if the buffer layer is sharing grid points
         !with its neighborign buffer layers of type 1
         if(bf_sublayer_i%can_exchange_with_neighbor1()) then
            
            if(present(bf_mainlayer_id)) then
               a_neighbor_remains = this%border_interface%does_a_neighbor_remains(
     $              1, bf_sublayer_i, bf_mainlayer_id)
            else
               a_neighbor_remains = this%border_interface%does_a_neighbor_remains(
     $              1, bf_sublayer_i)
            end if

         else
            a_neighbor_remains = .false.

         end if
         

         !determine if the buffer layer is sharing grid points
         !with its neighborign buffer layers of type 2
         if(.not.a_neighbor_remains) then
            
            if(bf_sublayer_i%can_exchange_with_neighbor2()) then
               
               if(present(bf_mainlayer_id)) then
                  a_neighbor_remains = this%border_interface%does_a_neighbor_remains(
     $                 2, bf_sublayer_i, bf_mainlayer_id)
               else
                  a_neighbor_remains = this%border_interface%does_a_neighbor_remains(
     $                 2, bf_sublayer_i)
               end if

            else
               a_neighbor_remains = .false.
            end if
            
         end if

       end function does_a_neighbor_remains


       !> @author
       !> Julien L. Desmarais
       !
       !> @brief
       !> print the content of the interface on external binary files
       !
       !> @date
       !> 11_04_2013 - initial version - J.L. Desmarais
       !
       !>@param this
       !> bf_interface object encapsulating the buffer layers
       !> around the interior domain and subroutines to synchronize
       !> the data between them
       !
       !>@param suffix_nodes
       !> suffix for the name of the files storing the nodes content
       !
       !>@param suffix_grdid
       !> suffix for the name of the files storing the grdpts_id content
       !
       !>@param suffix_sizes
       !> suffix for the name of the files storing the profile of the 
       !> nodes and grdpts_id arrays
       !
       !>@param suffix_nb_sublayers_max
       !> suffix for the name of the files storing the maximum number of
       !> sublayers per main buffer layer
       !--------------------------------------------------------------
       subroutine print_binary(
     $     this,
     $     suffix_nodes, suffix_grdid, suffix_sizes,
     $     suffix_nb_sublayers_max)

         implicit none

         class(bf_interface), intent(in) :: this
         character(*)       , intent(in) :: suffix_nodes
         character(*)       , intent(in) :: suffix_grdid
         character(*)       , intent(in) :: suffix_sizes
         character(*)       , intent(in) :: suffix_nb_sublayers_max
         

         integer           :: i
         integer           :: nb_sublayers_max
         character(len=18) :: filename_format
         character(len=28) :: nb_sublayers_filename
                  

         !go through the buffer main layers and
         !print the content of each buffer layer
         !in seperate binary output files and 
         !determine the maximum number of sublayers
         nb_sublayers_max = 0
         do i=1, size(this%mainlayer_pointers,1)

            if(this%mainlayer_pointers(i)%associated_ptr()) then
               
               call this%mainlayer_pointers(i)%print_binary(suffix_nodes,
     $                                            suffix_grdid,
     $                                            suffix_sizes)

               nb_sublayers_max = max(
     $              nb_sublayers_max,
     $              this%mainlayer_pointers(i)%get_nb_sublayers())
            end if            
         end do


         !print the maximum number of sublayers in an output
         !binary file
         write(filename_format,
     $        '(''(A12,A'',I2,'')'')')
     $        len(suffix_nb_sublayers_max)

         write(nb_sublayers_filename, filename_format)
     $        'sublayers_nb',
     $        suffix_nb_sublayers_max

         call print_nb_sublayers_max(
     $        nb_sublayers_filename, nb_sublayers_max)

        end subroutine print_binary


       !> @author
       !> Julien L. Desmarais
       !
       !> @brief
       !> print the maxmimum number of sublayers per main layer
       !
       !> @date
       !> 11_04_2013 - initial version - J.L. Desmarais
       !
       !>@param filename
       !> name of the file for storing the maximum number of sublayer
       !> per mainlayer
       !
       !>@param nb_sublayers
       !> maximum number of sublayers per main layer
       !--------------------------------------------------------------
       subroutine print_nb_sublayers_max(filename, nb_sublayers)

          implicit none

          character(*), intent(in) :: filename
          integer     , intent(in) :: nb_sublayers

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
              write(unit=1, iostat=ios) nb_sublayers
              close(unit=1)
           else
              stop 'file opening pb'
           end if

        end subroutine print_nb_sublayers_max


       !> @author
       !> Julien L. Desmarais
       !
       !> @brief
       !> print the content of the interface on external netcdf files
       !
       !> @date
       !> 11_07_2013 - initial version - J.L. Desmarais
       !
       !>@param this
       !> bf_interface object encapsulating the buffer layers
       !> around the interior domain and subroutines to synchronize
       !> the data between them
       !
       !>@param timestep_written
       !> integer identifying the timestep written
       !
       !>@param name_var
       !> table with the short name for the governing variables saved
       !> in the netcdf file
       !
       !>@param longname_var
       !> table with the long name for the governing variables saved
       !> in the netcdf file
       !
       !>@param unit_var
       !> table with the units of the governing variables saved
       !> in the netcdf file
       !
       !>@param x_min_interior
       !> x-coordinate of interior grid point next to the left
       !> boundary layer
       !
       !>@param y_min_interior
       !> y-coordinate of interior grid point next to the lower
       !> boundary layer
       !
       !>@param dx
       !> grid size along the x-coordinate
       !
       !>@param dy
       !> grid size along the y-coordinate
       !
       !>@param time
       !> time corresponding to the data for the grdpts and the nodes
       !--------------------------------------------------------------
       subroutine print_netcdf(
     $     this,
     $     timestep_written,
     $     name_var,
     $     longname_var,
     $     unit_var,
     $     x_min_interior,
     $     y_min_interior,
     $     dx,
     $     dy,
     $     time)

         implicit none

         class(bf_interface)        , intent(in) :: this
         integer                    , intent(in) :: timestep_written
         character(*), dimension(ne), intent(in) :: name_var
         character(*), dimension(ne), intent(in) :: longname_var
         character(*), dimension(ne), intent(in) :: unit_var
         real(rkind)                , intent(in) :: x_min_interior
         real(rkind)                , intent(in) :: y_min_interior
         real(rkind)                , intent(in) :: dx
         real(rkind)                , intent(in) :: dy
         real(rkind)                , intent(in) :: time

         integer           :: i
                  

         !go through the buffer main layers and
         !print the content of each buffer layer
         !in seperate binary output files
         do i=1, size(this%mainlayer_pointers,1)

            if(this%mainlayer_pointers(i)%associated_ptr()) then
               
               call this%mainlayer_pointers(i)%print_netcdf(
     $              timestep_written,
     $              name_var,
     $              longname_var,
     $              unit_var,
     $              x_min_interior,
     $              y_min_interior,
     $              dx,dy,
     $              time)

            end if
         end do

        end subroutine print_netcdf

      end module bf_interface_class