      !> @file
      !> test file for the Cockburn and Gau operators
      !
      !> @author 
      !> Julien L. Desmarais
      !
      !> @brief
      !> test the space discretization operators by comparing the
      !> results with previous computations
      !
      !> @date
      ! 30_07_2014 - initial version - J.L. Desmarais
      !-----------------------------------------------------------------
      program test_cg_operators

        use sd_operators_fd_module, only :
     $       gradient_x_interior,
     $       gradient_y_interior,
     $       gradient_x_x_oneside_L0,
     $       gradient_x_x_oneside_L1,
     $       gradient_x_x_oneside_R1,
     $       gradient_x_x_oneside_R0,
     $       gradient_y_y_oneside_L0,
     $       gradient_y_y_oneside_L1,
     $       gradient_y_y_oneside_R1,
     $       gradient_y_y_oneside_R0

        use dim2d_prim_module, only :
     $       mass_density

        use interface_primary, only :
     $       gradient_x_proc,
     $       gradient_y_proc

        use parameters_input, only :
     $       nx,ny,ne

        use parameters_kind, only :
     $       ikind, rkind

        use sd_operators_abstract_class, only :
     $       sd_operators_abstract

        use sd_operators_class, only :
     $       sd_operators

        use sd_operators_x_oneside_L0_class, only :
     $       sd_operators_x_oneside_L0

        use sd_operators_x_oneside_L1_class, only :
     $       sd_operators_x_oneside_L1

        use sd_operators_x_oneside_R1_class, only :
     $       sd_operators_x_oneside_R1

        use sd_operators_x_oneside_R0_class, only :
     $       sd_operators_x_oneside_R0

        use sd_operators_y_oneside_L0_class, only :
     $       sd_operators_y_oneside_L0

        use sd_operators_y_oneside_L1_class, only :
     $       sd_operators_y_oneside_L1

        use sd_operators_y_oneside_R1_class, only :
     $       sd_operators_y_oneside_R1

        use sd_operators_y_oneside_R0_class, only :
     $       sd_operators_y_oneside_R0
        

        implicit none


        !<operators tested
        real(rkind), dimension(nx,ny,ne) :: nodes
        real(rkind) :: dx
        real(rkind) :: dy

        type(sd_operators)              :: sd_interior

        type(sd_operators_x_oneside_L0) :: sd_x_oneside_L0
        type(sd_operators_x_oneside_L1) :: sd_x_oneside_L1
        type(sd_operators_x_oneside_R1) :: sd_x_oneside_R1
        type(sd_operators_x_oneside_R0) :: sd_x_oneside_R0

        type(sd_operators_y_oneside_L0) :: sd_y_oneside_L0
        type(sd_operators_y_oneside_L1) :: sd_y_oneside_L1
        type(sd_operators_y_oneside_R1) :: sd_y_oneside_R1
        type(sd_operators_y_oneside_R0) :: sd_y_oneside_R0


        !<CPU recorded times
        real :: time1, time2

        !<test parameters
        logical                    :: detailled
        real(rkind), dimension(16) :: test_data
        logical                    :: test_validated


        !<if nx<4, ny<4 then the test cannot be done
        if((nx.lt.4).or.(ny.lt.4)) then
           stop 'nx and ny must be greater than 4 for the test'
        end if


        !<get the initial CPU time
        call CPU_TIME(time1)


        !<initialize the tables for the field
        dx=0.5
        dy=0.6

        nodes(1,1,1)=0.5
        nodes(2,1,1)=0.2
        nodes(3,1,1)=1.2
        nodes(4,1,1)=5.0
        nodes(5,1,1)=0.6
        nodes(6,1,1)=-3.6
        nodes(7,1,1)=-6.52

        nodes(1,2,1)=3.0
        nodes(2,2,1)=4.2
        nodes(3,2,1)=11.0
        nodes(4,2,1)=10.6
        nodes(5,2,1)=5.2
        nodes(6,2,1)=1.2
        nodes(7,2,1)=7.89

        nodes(1,3,1)=-14.2
        nodes(2,3,1)=23
        nodes(3,3,1)=9.8
        nodes(4,3,1)=3.4
        nodes(5,3,1)=9.1
        nodes(6,3,1)=6.7
        nodes(7,3,1)=4.12

        nodes(1,4,1)=2.45
        nodes(2,4,1)=0.2
        nodes(3,4,1)=9.0
        nodes(4,4,1)=5.4
        nodes(5,4,1)=-2.3
        nodes(6,4,1)=1.0
        nodes(7,4,1)=-5.62

        nodes(1,5,1)=3.6
        nodes(2,5,1)=0.1
        nodes(3,5,1)=6.3
        nodes(4,5,1)=8.9
        nodes(5,5,1)=-4.23
        nodes(6,5,1)=8.9
        nodes(7,5,1)=8.95


        print '()'
        print '(''test interior'')'
        print '(''----------------------------------------'')'

        !<test the operators
        test_data(1) = 20.0333333d0 !<test f
        test_data(2) =-26.4d0       !<test dfdx
        test_data(3) = -2.51736d0   !<test dfdy
        test_data(4) =-87.2d0       !<test d2fdx2
        test_data(5) =-76.7245d0    !<test d2fdy2
        test_data(6) =  3.3333333d0 !<test d2fdxdy
        test_data(7) =-19.6d0 !-30.0167d0    !<test gradient_x

        test_data(8) =  11.283333d0 !<test g
        test_data(9) = -8.5333333d0 !<test dgdx
        test_data(10)= -2d0         !<test dgdy
        test_data(11)=  2.2666667d0 !<test d2gdx2
        test_data(12)= -14.722222d0 !<test d2gdy2
        test_data(13)= -43.333333d0 !<test d2gdxdy
        test_data(14)= -1.66666667d0!-2.93056d0   !<test gradient_y

        test_data(15)=-83.8667d0    !<test dfdx_nl
        test_data(16)=-58.0556d0    !<test dgdy_nl

        detailled = .false.
        
        call test_operator(
     $       sd_interior,
     $       gradient_x_interior,
     $       gradient_y_interior,
     $       3,3, 3,3, test_data, detailled)
        print '()'

        
        print '()'
        print '(''test x_oneside_L0'')'
        print '(''----------------------------------------'')'

        !<test the operators
        test_data(1) = -29.166667d0 !<test f
        test_data(2) = 175.2d0      !<test dfdx
        test_data(3) = 0.96180556d0 !<test dfdy
        test_data(4) = -337.2d0     !<test d2fdx2
        test_data(5) = 179.31713d0  !<test d2fdy2
        test_data(6) = -14.833333d0 !<test d2fdxdy
        test_data(7) = 74.4d0       !<test gradient_x

        test_data(8) = -6.7791667d0 !<test g
        test_data(9) =  45.225d0    !<test dgdx
        test_data(10)= -28.666667d0 !<test dgdy
        test_data(11)= -108.65d0    !<test d2gdx2
        test_data(12)=  19.652778d0 !<test d2gdy2
        test_data(13)=  120d0       !<test d2gdxdy
        test_data(14) =-0.4583333d0!-1.0416667d0 !<test gradient_y

        test_data(15)=-129.233333d0 !<test dfdx_nl
        test_data(16)= 139.65278d0  !<test dgdy_nl

        detailled = .false.
        
        call test_operator(
     $       sd_x_oneside_L0,
     $       gradient_x_x_oneside_L0,
     $       gradient_y_interior,
     $       1,3, 1,3, test_data, detailled)
        print '()'


        print '()'
        print '(''test x_oneside_L1'')'
        print '(''----------------------------------------'')'

        !<test the operators
        test_data(1) =  8.0333333d0 !<test f
        test_data(2) = 74.4d0       !<test dfdx
        test_data(3) = -1.91319d0   !<test dfdy
        test_data(4) = -108.4d0     !<test d2fdx2
        test_data(5) = -30.2662d0   !<test d2fdy2
        test_data(6) = -5.75d0      !<test d2fdxdy
        test_data(7) = 24d0         !<test gradient_x

        test_data(8) =  15.833333d0 !<test g
        test_data(9) =  18.0625d0   !<test dgdx
        test_data(10)=  31.333333d0 !<test dgdy
        test_data(11)= -108.65d0    !<test d2gdx2
        test_data(12)= -37.222222d0 !<test d2gdy2
        test_data(13)=  26.666667d0 !<test d2gdxdy
        test_data(14)= -3.3333333d0!-4.43056d0   !<test gradient_y

        test_data(15)=-106.55d0     !<test dfdx_nl
        test_data(16)=-10.5556d0    !<test dgdy_nl

        detailled = .false.
        
        call test_operator(
     $       sd_x_oneside_L1,
     $       gradient_x_x_oneside_L1,
     $       gradient_y_interior,
     $       2,3, 2,3, test_data, detailled)
        print '()'


        print '()'
        print '(''test x_oneside_R1'')'
        print '(''----------------------------------------'')'

        !<test the operators
        test_data(1) =  7.5666667d0 !<test f
        test_data(2) = -4.8d0       !<test dfdx
        test_data(3) = -3.9375d0    !<test dfdy
        test_data(4) =  29.2d0      !<test d2fdx2
        test_data(5) = -35.7176d0   !<test d2fdy2
        test_data(6) =  12.166667d0 !<test d2fdxdy
        test_data(7) = -4.98d0      !<test gradient_x

        test_data(8) =  8.4833333d0 !<test g
        test_data(9) = -2.475d0     !<test dgdx
        test_data(10)=  6.5d0       !<test dgdy
        test_data(11)= -19.366667d0 !<test d2gdx2
        test_data(12)= -22.222222d0 !<test d2gdy2
        test_data(13)=  21.166667d0 !<test d2gdxdy
        test_data(14)= -6.25d0 !-7.6625d0    !<test gradient_y

        test_data(15)=-4.03333d0    !<test dfdx_nl
        test_data(16)=-1.05556d0    !<test dgdy_nl

        detailled = .false.
        
        call test_operator(
     $       sd_x_oneside_R1,
     $       gradient_x_x_oneside_R1,
     $       gradient_y_interior,
     $       6,3, 5,3, test_data, detailled)
        print '()'


        print '()'
        print '(''test x_oneside_R0'')'
        print '(''----------------------------------------'')'

        !<test the operators
        test_data(1) =  5.166667d0  !<test f
        test_data(2) = -21d0        !<test dfdx
        test_data(3) =  2.145833d0  !<test dfdy
        test_data(4) = -51.6d0      !<test d2fdx2
        test_data(5) = -24.3287d0   !<test d2fdy2
        test_data(6) =  28.166667d0 !<test d2fdxdy
        test_data(7) = -5.16d0      !<test gradient_x

        test_data(8) =  4.825d0     !<test g
        test_data(9) = -7.3166667d0 !<test dgdx
        test_data(10)=  9.1666667d0 !<test dgdy
        test_data(11)= -19.366667d0 !<test d2gdx2
        test_data(12)= -14.5833d0   !<test d2gdy2
        test_data(13)=   5.333333d0 !<test d2gdxdy
        test_data(14)= -0.1666667d0 !-1.95833d0   !<test gradient_y

        test_data(15)=-12.2333d0    !<test dfdx_nl
        test_data(16)=-9.25d0       !<test dgdy_nl

        detailled = .false.
        
        call test_operator(
     $       sd_x_oneside_R0,
     $       gradient_x_x_oneside_R0,
     $       gradient_y_interior,
     $       7,3, 6,3, test_data, detailled)
        print '()'



        print '()'
        print '(''test FV vs FD formulations : dfdx       '')'
        print '(''----------------------------------------'')'

        !< test data
        test_data(1) =  2.4d0       !<test dfdx(1)
        test_data(2) =  8d0         !<test dfdx(2)
        test_data(3) =  8.1666667d0 !<test dfdx(3)
        test_data(4) = -7.2333333d0 !<test dfdx(4)
        test_data(5) = -9.4d0       !<test dfdx(5)
        test_data(6) = -8d0         !<test dfdx(6)

        detailled = .false.
        call test_dfdx(nodes, dx, 2, test_data, detailled)
        print '()'


        print '()'
        print '(''test FV vs FD formulations : d2fdx2     '')'
        print '(''----------------------------------------'')'

        !< test data
        test_data(1) =  22.4d0      !<test d2fdx2(1)
        test_data(2) =  22.4d0      !<test d2fdx2(2)
        test_data(3) = -28.8d0      !<test d2fdx2(3)
        test_data(4) = -20d0        !<test d2fdx2(4)
        test_data(5) =  5.6d0       !<test d2fdx2(5)
        test_data(6) =  5.6d0       !<test d2fdx2(6)

        detailled = .false.
        call test_d2fdx2(nodes, dx, 2, test_data, detailled)
        print '()'


        print '()'
        print '(''test FV vs FD formulations : d3fdx3     '')'
        print '(''----------------------------------------'')'

        !< test data
        test_data(1) = -102.4d0     !<test d3fdx3(1)
        test_data(2) =  17.6d0      !<test d3fdx3(2)
        test_data(3) = -42.4d0      !<test d3fdx3(3)
        test_data(4) =  34.4d0      !<test d3fdx3(4)
        test_data(5) =  17.6d0      !<test d3fdx3(5)
        test_data(6) =  51.2d0      !<test d3fdx3(6)

        detailled = .false.
        call test_d3fdx3(nodes, dx, 2, test_data, detailled)
        print '()'        


        !> initialize the nodes for the y-fluxes tests
        !<initialize the tables for the field
        dx=0.6
        dy=0.5

        nodes(1,1,1)=0.5
        nodes(1,2,1)=0.2
        nodes(1,3,1)=1.2
        nodes(1,4,1)=5.0
        nodes(1,5,1)=0.6
        nodes(1,6,1)=-3.6
        nodes(1,7,1)=-6.52

        nodes(2,1,1)=3.0
        nodes(2,2,1)=4.2
        nodes(2,3,1)=11.0
        nodes(2,4,1)=10.6
        nodes(2,5,1)=5.2
        nodes(2,6,1)=1.2
        nodes(2,7,1)=7.89

        nodes(3,1,1)=-14.2
        nodes(3,2,1)=23
        nodes(3,3,1)=9.8
        nodes(3,4,1)=3.4
        nodes(3,5,1)=9.1
        nodes(3,6,1)=6.7
        nodes(3,7,1)=4.12

        nodes(4,1,1)=2.45
        nodes(4,2,1)=0.2
        nodes(4,3,1)=9.0
        nodes(4,4,1)=5.4
        nodes(4,5,1)=-2.3
        nodes(4,6,1)=1.0
        nodes(4,7,1)=-5.62

        nodes(5,1,1)=3.6
        nodes(5,2,1)=0.1
        nodes(5,3,1)=6.3
        nodes(5,4,1)=8.9
        nodes(5,5,1)=-4.23
        nodes(5,6,1)=8.9
        nodes(5,7,1)=8.95


        print '()'
        print '(''test y_oneside_L0'')'
        print '(''----------------------------------------'')'

        !<test the operators
        test_data(1)  = -6.7791667d0 !<test f        
        test_data(2)  = -28.666667d0 !<test dfdx     
        test_data(3)  =  45.225d0    !<test dfdy     
        test_data(4)  =  19.652778d0 !<test d2fdx2   
        test_data(5)  = -108.65d0    !<test d2fdy2   
        test_data(6)  =  120d0       !<test d2fdxdy
        test_data(7)  = -0.4583333d0 !-1.0416667d0 !<test gradient_x

        test_data(8)  = -29.166667d0 !<test g      
        test_data(9)  = 0.96180556d0 !<test dgdx   
        test_data(10) = 175.2d0      !<test dgdy   
        test_data(11) = 179.31713d0  !<test d2gdx2 
        test_data(12) = -337.2d0     !<test d2gdy2 
        test_data(13) = -14.833333d0 !<test d2gdxdy
        test_data(14) = 74.4d0       !<test gradient_y

        test_data(15)= 139.65278d0  !<test dfdx_nl
        test_data(16)=-129.233333d0 !<test dgdy_nl

        detailled = .false.
        
        call test_operator(
     $       sd_y_oneside_L0,
     $       gradient_x_interior,
     $       gradient_y_y_oneside_L0,
     $       3,1, 3,1, test_data, detailled)
        print '()'


        print '()'
        print '(''test y_oneside_L1'')'
        print '(''----------------------------------------'')'

        !<test the operators
        test_data(1)  =  15.833333d0 !<test f      
        test_data(2)  =  31.333333d0 !<test dfdx   
        test_data(3)  =  18.0625d0   !<test dfdy   
        test_data(4)  = -37.222222d0 !<test d2fdx2 
        test_data(5)  = -108.65d0    !<test d2fdy2 
        test_data(6)  =  26.666667d0 !<test d2fdxdy
        test_data(7)  = -3.3333333d0 !-4.43056d0   !<test gradient_x

        test_data(8)  =  8.0333333d0 !<test g      
        test_data(9)  = -1.91319d0   !<test dgdx   
        test_data(10) = 74.4d0       !<test dgdy   
        test_data(11) = -30.2662d0   !<test d2gdx2 
        test_data(12) = -108.4d0     !<test d2gdy2 
        test_data(13) = -5.75d0      !<test d2gdxdy
        test_data(14) =  24d0        !<test gradient_y

        test_data(15)=-10.5556d0     !<test dfdx_nl
        test_data(16)=-106.55d0      !<test dgdy_nl

        detailled = .false.
        
        call test_operator(
     $       sd_y_oneside_L1,
     $       gradient_x_interior,
     $       gradient_y_y_oneside_L1,
     $       3,2, 3,2, test_data, detailled)
        print '()'


        print '()'
        print '(''test y_oneside_R1'')'
        print '(''----------------------------------------'')'

        !<test the operators
        test_data(1)  =  8.4833333d0 !<test f      
        test_data(2)  =  6.5d0       !<test dfdx   
        test_data(3)  = -2.475d0     !<test dfdy   
        test_data(4)  = -22.222222d0 !<test d2fdx2 
        test_data(5)  = -19.366667d0 !<test d2fdy2 
        test_data(6)  =  21.166667d0 !<test d2fdxdy
        test_data(7)  = -6.25d0 !-7.6625d0    !<test gradient_x

        test_data(8)  =  7.5666667d0 !<test g      
        test_data(9)  = -3.9375d0    !<test dgdx   
        test_data(10) = -4.8d0       !<test dgdy   
        test_data(11) = -35.7176d0   !<test d2gdx2 
        test_data(12) =  29.2d0      !<test d2gdy2 
        test_data(13) =  12.166667d0 !<test d2gdxdy
        test_data(14) = -4.98d0      !<test gradient_y

        test_data(15)=-1.05556d0     !<test dfdx_nl
        test_data(16)=-4.03333d0     !<test dgdy_nl


        detailled = .false.
        
        call test_operator(
     $       sd_y_oneside_R1,
     $       gradient_x_interior,
     $       gradient_y_y_oneside_R1,
     $       3,5, 3,6, test_data, detailled)
        print '()'


        print '()'
        print '(''test y_oneside_R0'')'
        print '(''----------------------------------------'')'

        !<test the operators
        test_data(1)  =  4.825d0     !<test f      
        test_data(2)  =  9.1666667d0 !<test dfdx   
        test_data(3)  = -7.3166667d0 !<test dfdy   
        test_data(4)  = -14.5833d0   !<test d2fdx2 
        test_data(5)  = -19.366667d0 !<test d2fdy2 
        test_data(6)  =   5.333333d0 !<test d2fdxdy
        test_data(7)  = -0.1666667d0 !-1.95833d0   !<test gradient_x

        test_data(8)  =  5.166667d0  !<test g      
        test_data(9)  =  2.145833d0  !<test dgdx   
        test_data(10) = -21d0        !<test dgdy   
        test_data(11) = -24.3287d0   !<test d2gdx2 
        test_data(12) = -51.6d0      !<test d2gdy2 
        test_data(13) =  28.166667d0 !<test d2gdxdy
        test_data(14) =  -5.16d0     !<test gradient_y

        test_data(15)=-9.25d0        !<test dfdx_nl
        test_data(16)=-12.2333d0     !<test dgdy_nl

        detailled = .false.
        
        call test_operator(
     $       sd_y_oneside_R0,
     $       gradient_x_interior,
     $       gradient_y_y_oneside_R0,
     $       3,6, 3,7, test_data, detailled)
        print '()'


        print '()'
        print '(''test FV vs FD formulations : dgdy       '')'
        print '(''----------------------------------------'')'

        !< test data
        test_data(1) =  2.4d0       !<test dgdy(1)
        test_data(2) =  8d0         !<test dgdy(2)
        test_data(3) =  8.1666667d0 !<test dgdy(3)
        test_data(4) = -7.2333333d0 !<test dgdy(4)
        test_data(5) = -9.4d0       !<test dgdy(5)
        test_data(6) = -8d0         !<test dgdy(6)

        detailled = .false.
        call test_dgdy(nodes, dy, 2, test_data, detailled)
        print '()'


        print '()'
        print '(''test FV vs FD formulations : d2gdy2     '')'
        print '(''----------------------------------------'')'
        
        !< test data
        test_data(1) =  22.4d0      !<test d2gdy2(1)
        test_data(2) =  22.4d0      !<test d2gdy2(2)
        test_data(3) = -28.8d0      !<test d2gdy2(3)
        test_data(4) = -20d0        !<test d2gdy2(4)
        test_data(5) =  5.6d0       !<test d2gdy2(5)
        test_data(6) =  5.6d0       !<test d2gdy2(6)
        
        detailled = .false.
        call test_d2gdy2(nodes, dy, 2, test_data, detailled)
        print '()'
        
        
        print '()'
        print '(''test FV vs FD formulations : d3gdy3     '')'
        print '(''----------------------------------------'')'
        
        !< test data
        test_data(1) = -102.4d0     !<test d3gdy3(1)
        test_data(2) =  17.6d0      !<test d3gdy3(2)
        test_data(3) = -42.4d0      !<test d3gdy3(3)
        test_data(4) =  34.4d0      !<test d3gdy3(4)
        test_data(5) =  17.6d0      !<test d3gdy3(5)
        test_data(6) =  51.2d0      !<test d3gdy3(6)
        
        detailled = .false.
        call test_d3gdy3(nodes, dy, 2, test_data, detailled)
        print '()'


        !<get the last CPU time
        call CPU_TIME(time2)
        print *, 'time elapsed: ', time2-time1

        contains


        function is_test_validated(var,cst,detailled) result(test_validated)

          implicit none

          real(rkind), intent(in) :: var
          real(rkind), intent(in) :: cst
          logical    , intent(in) :: detailled
          logical                 :: test_validated

          if(detailled) then
             print *, int(var*1e5)
             print *, int(cst*1e5)
          end if
          
          test_validated=abs(
     $         int(var*10000.)-
     $         sign(int(abs(cst*10000.)),int(cst*10000.))).le.1
          
        end function is_test_validated


        subroutine test_dfdx(nodes, dx, j, test_data, detailled)

          real(rkind), dimension(nx,ny,ne), intent(in) :: nodes
          real(rkind)                     , intent(in) :: dx
          integer                         , intent(in) :: j
          real(rkind), dimension(:)       , intent(in) :: test_data
          logical                         , intent(in) :: detailled

          
          real(rkind), dimension(7) :: fluxes
          integer :: i
          

          !> flux computation
          i=1
          fluxes(1) = sd_x_oneside_L0%f(nodes,i,j,mass_density)
          
          i=2
          fluxes(2) = sd_x_oneside_L1%f(nodes,i,j,mass_density)
          
          do i=3,5
             fluxes(i) = sd_interior%f(nodes,i,j,mass_density)
          end do
          
          i=6
          fluxes(6) = sd_x_oneside_R1%f(nodes,i,j,mass_density)
          
          i=7
          fluxes(7) = sd_x_oneside_R0%f(nodes,i,j,mass_density)
          

          !> derivative computation + comparison with test_data
          call test_space_derivative(fluxes, dx, test_data, detailled)

        end subroutine test_dfdx


        subroutine test_d2fdx2(nodes, dx, j, test_data, detailled)

          real(rkind), dimension(nx,ny,ne), intent(in) :: nodes
          real(rkind)                     , intent(in) :: dx
          integer                         , intent(in) :: j
          real(rkind), dimension(:)       , intent(in) :: test_data
          logical                         , intent(in) :: detailled

          
          real(rkind), dimension(7) :: fluxes
          integer :: i
          

          !> flux computation
          i=1
          fluxes(1) = sd_x_oneside_L0%dfdx(nodes,i,j,mass_density,dx)
          
          i=2
          fluxes(2) = sd_x_oneside_L1%dfdx(nodes,i,j,mass_density,dx)
          
          do i=3,5
             fluxes(i) = sd_interior%dfdx(nodes,i,j,mass_density,dx)
          end do
          
          i=6
          fluxes(6) = sd_x_oneside_R1%dfdx(nodes,i,j,mass_density,dx)
          
          i=7
          fluxes(7) = sd_x_oneside_R0%dfdx(nodes,i,j,mass_density,dx)
          

          !> derivative computation + comparison with test_data
          call test_space_derivative(fluxes, dx, test_data, detailled)

        end subroutine test_d2fdx2


        subroutine test_d3fdx3(nodes, dx, j, test_data, detailled)

          real(rkind), dimension(nx,ny,ne), intent(in) :: nodes
          real(rkind)                     , intent(in) :: dx
          integer                         , intent(in) :: j
          real(rkind), dimension(:)       , intent(in) :: test_data
          logical                         , intent(in) :: detailled

          
          real(rkind), dimension(7) :: fluxes
          integer :: i
          

          !> flux computation
          i=1
          fluxes(1) = sd_x_oneside_L0%d2fdx2(nodes,i,j,mass_density,dx)
          
          i=2
          fluxes(2) = sd_x_oneside_L1%d2fdx2(nodes,i,j,mass_density,dx)
          
          do i=3,5
             fluxes(i) = sd_interior%d2fdx2(nodes,i,j,mass_density,dx)
          end do
          
          i=6
          fluxes(6) = sd_x_oneside_R1%d2fdx2(nodes,i,j,mass_density,dx)
          
          i=7
          fluxes(7) = sd_x_oneside_R0%d2fdx2(nodes,i,j,mass_density,dx)
          

          !> derivative computation + comparison with test_data
          call test_space_derivative(fluxes, dx, test_data, detailled)

        end subroutine test_d3fdx3


        subroutine test_dgdy(nodes, dy, i, test_data, detailled)

          real(rkind), dimension(nx,ny,ne), intent(in) :: nodes
          real(rkind)                     , intent(in) :: dy
          integer                         , intent(in) :: i
          real(rkind), dimension(:)       , intent(in) :: test_data
          logical                         , intent(in) :: detailled

          
          real(rkind), dimension(7) :: fluxes
          integer :: j
          

          !> flux computation
          j=1
          fluxes(1) = sd_y_oneside_L0%g(nodes,i,j,mass_density)
          
          j=2
          fluxes(2) = sd_y_oneside_L1%g(nodes,i,j,mass_density)
          
          do j=3,5
             fluxes(j) = sd_interior%g(nodes,i,j,mass_density)
          end do
          
          j=6
          fluxes(6) = sd_y_oneside_R1%g(nodes,i,j,mass_density)
          
          j=7
          fluxes(7) = sd_y_oneside_R0%g(nodes,i,j,mass_density)
          

          !> derivative computation + comparison with test_data
          call test_space_derivative(fluxes, dy, test_data, detailled)

        end subroutine test_dgdy


        subroutine test_d2gdy2(nodes, dy, i, test_data, detailled)

          real(rkind), dimension(nx,ny,ne), intent(in) :: nodes
          real(rkind)                     , intent(in) :: dy
          integer                         , intent(in) :: i
          real(rkind), dimension(:)       , intent(in) :: test_data
          logical                         , intent(in) :: detailled

          
          real(rkind), dimension(7) :: fluxes
          integer :: j
          

          !> flux computation
          j=1
          fluxes(1) = sd_y_oneside_L0%dgdy(nodes,i,j,mass_density,dy)
          
          j=2
          fluxes(2) = sd_y_oneside_L1%dgdy(nodes,i,j,mass_density,dy)
          
          do j=3,5
             fluxes(j) = sd_interior%dgdy(nodes,i,j,mass_density,dy)
          end do
          
          j=6
          fluxes(6) = sd_y_oneside_R1%dgdy(nodes,i,j,mass_density,dy)
          
          j=7
          fluxes(7) = sd_y_oneside_R0%dgdy(nodes,i,j,mass_density,dy)
          

          !> derivative computation + comparison with test_data
          call test_space_derivative(fluxes, dy, test_data, detailled)

        end subroutine test_d2gdy2


        subroutine test_d3gdy3(nodes, dy, i, test_data, detailled)

          real(rkind), dimension(nx,ny,ne), intent(in) :: nodes
          real(rkind)                     , intent(in) :: dy
          integer                         , intent(in) :: i
          real(rkind), dimension(:)       , intent(in) :: test_data
          logical                         , intent(in) :: detailled

          
          real(rkind), dimension(7) :: fluxes
          integer :: j
          

          !> flux computation
          j=1
          fluxes(1) = sd_y_oneside_L0%d2gdy2(nodes,i,j,mass_density,dy)
          
          j=2
          fluxes(2) = sd_y_oneside_L1%d2gdy2(nodes,i,j,mass_density,dy)
          
          do j=3,5
             fluxes(j) = sd_interior%d2gdy2(nodes,i,j,mass_density,dy)
          end do
          
          j=6
          fluxes(6) = sd_y_oneside_R1%d2gdy2(nodes,i,j,mass_density,dy)
          
          j=7
          fluxes(7) = sd_y_oneside_R0%d2gdy2(nodes,i,j,mass_density,dy)
          

          !> derivative computation + comparison with test_data
          call test_space_derivative(fluxes, dy, test_data, detailled)

        end subroutine test_d3gdy3


        subroutine test_space_derivative(fluxes, dx, test_data, detailled)
        
          implicit none

          real(rkind), dimension(:), intent(in) :: fluxes
          real(rkind)              , intent(in) :: dx
          real(rkind), dimension(:), intent(in) :: test_data
          logical                  , intent(in) :: detailled


          real(rkind), dimension(:), allocatable :: dev
          integer :: i
          logical :: loc

          allocate(dev(size(fluxes,1)-1))

          do i=1, size(dev,1)
             dev(i) = 1.0/dx*(-fluxes(i)+fluxes(i+1))
          end do

          if(detailled) then
             do i=1, size(dev,1)
                loc = is_test_validated(dev(i), test_data(i), detailled)
                print '(''test dev('',I2,''): '', L3)', i, loc
             end do
          else
             i=1
             test_validated=is_test_validated(dev(i), test_data(i), detailled)
             do i=2, size(dev,1)
                loc = is_test_validated(dev(i), test_data(i), detailled)
                test_validated = test_validated.and.loc
             end do
             print '(''test validated: '',L3)', loc
          end if

          deallocate(dev)

        end subroutine test_space_derivative


        function gradient_av(
     $     nodes,i,j,dx,dy,gradient_x,gradient_y)
     $     result(var)

          implicit none

          real(rkind), dimension(:,:,:), intent(in) :: nodes
          integer(ikind)               , intent(in) :: i
          integer(ikind)               , intent(in) :: j
          real(rkind)                  , intent(in) :: dx
          real(rkind)                  , intent(in) :: dy
          procedure(gradient_x_proc)                :: gradient_x
          procedure(gradient_y_proc)                :: gradient_y
          real(rkind)                               :: var


          var = gradient_x(nodes,i,j,mass_density,dx) +
     $          gradient_y(nodes,i,j,mass_density,dy)

        end function gradient_av


        subroutine test_operator(
     $     sd_operators_tested,
     $     gradient_x,
     $     gradient_y,
     $     i1,j1, i2,j2,
     $     test_data,
     $     detailled)

          implicit none

          class(sd_operators_abstract), intent(in) :: sd_operators_tested
          procedure(gradient_x_proc)               :: gradient_x
          procedure(gradient_y_proc)               :: gradient_y
          integer                     , intent(in) :: i1,j1, i2,j2
          real(rkind), dimension(:)   , intent(in) :: test_data
          logical                     , intent(in) :: detailled

          logical :: loc

          if(detailled) then
          
             !TAG INLINE
             loc = is_test_validated(
     $            sd_operators_tested%f(
     $            nodes,
     $            i1,j1,
     $            mass_density),
     $            test_data(1),
     $            detailled)
          
             print '(''test %f: '',L3)', loc
          
          
             !TAG INLINE
             loc = is_test_validated(
     $            sd_operators_tested%dfdx(
     $            nodes,
     $            i1,j1,
     $            mass_density,
     $            dx),
     $            test_data(2),
     $            detailled)
          
             print '(''test %dfdx: '',L3)', loc
          
          
             !TAG INLINE
             loc = is_test_validated(
     $            sd_operators_tested%dfdy(
     $            nodes,
     $            i1,j1,
     $            mass_density,
     $            dy),
     $            test_data(3),
     $            detailled)
             
             print '(''test %dfdy: '',L3)', loc
          
     $            
             !TAG INLINE
             loc = is_test_validated(
     $            sd_operators_tested%d2fdx2(
     $            nodes,
     $            i1,j1,
     $            mass_density,
     $            dx),
     $            test_data(4),
     $            detailled)
          
             print '(''test %d2fdx2: '',L3)', loc
     $            
          
             !TAG INLINE
             loc = is_test_validated(
     $            sd_operators_tested%d2fdy2(
     $            nodes,
     $            i1,j1,
     $            mass_density,
     $            dy),
     $            test_data(5),
     $            detailled)
          
             print '(''test %d2fdy2: '',L3)', loc
     $            
          
             !TAG INLINE
             loc = is_test_validated(
     $            sd_operators_tested%d2fdxdy(
     $            nodes,
     $            i1,j1,
     $            mass_density,
     $            dx,
     $            dy),
     $            test_data(6),
     $            detailled)

             print '(''test %d2fdxdy: '',L3)', loc


             !TAG INLINE
             loc = is_test_validated(
     $            gradient_x(
     $            nodes,
     $            i1,j1,
     $            mass_density,
     $            dx),
     $            test_data(7),
     $            detailled)

             print '(''test %gradient_x: '',L3)', loc             
     $            
          
             !TAG INLINE
             loc = is_test_validated(
     $            sd_operators_tested%g(
     $            nodes,
     $            i2,j2,
     $            mass_density),
     $            test_data(8),
     $            detailled)
          
             print '(''test %g: '',L3)', loc
          
          
             !TAG INLINE
             loc = is_test_validated(
     $            sd_operators_tested%dgdx(
     $            nodes,
     $            i2,j2,
     $            mass_density,
     $            dx),
     $            test_data(9),
     $            detailled)
          
             print '(''test %dgdx: '',L3)', loc
     $            
          
             !TAG INLINE
             loc = is_test_validated(
     $            sd_operators_tested%dgdy(
     $            nodes,
     $            i2,j2,
     $            mass_density,
     $            dy),
     $            test_data(10),
     $            detailled)
          
             print '(''test %dgdy: '',L3)', loc
          
          
             !TAG INLINE
             loc = is_test_validated(
     $            sd_operators_tested%d2gdx2(
     $            nodes,
     $            i2,j2,
     $            mass_density,
     $            dx),
     $            test_data(11),
     $            detailled)
          
             print '(''test %d2gdx2: '',L3)', loc
          
          
             !TAG INLINE
             loc = is_test_validated(
     $            sd_operators_tested%d2gdy2(
     $            nodes,
     $            i2,j2,
     $            mass_density,
     $            dy),
     $            test_data(12),
     $            detailled)
          
             print '(''test %d2gdy2: '',L3)', loc
          
          
             !TAG INLINE
             loc = is_test_validated(
     $            sd_operators_tested%d2gdxdy(
     $            nodes,
     $            i2,j2,
     $            mass_density,
     $            dx,
     $            dy),
     $            test_data(13),
     $            detailled)
          
             print '(''test %d2gdxdy: '',L3)', loc

          
             !TAG INLINE
             loc = is_test_validated(
     $            gradient_y(
     $            nodes,
     $            i2,j2,
     $            mass_density,
     $            dy),
     $            test_data(14),
     $            detailled)
          
             print '(''test %gradient_y: '',L3)', loc


             !TAG INLINE
             loc = is_test_validated(
     $            sd_operators_tested%dfdx_nl(
     $            nodes,
     $            i1,j1,
     $            gradient_av,
     $            dx,
     $            dy),
     $            test_data(15),
     $            detailled)
          
             print '(''test %dfdx_nl: '',L3)', loc


             !TAG INLINE
             loc = is_test_validated(
     $            sd_operators_tested%dgdy_nl(
     $            nodes,
     $            i2,j2,
     $            gradient_av,
     $            dx,
     $            dy),
     $            test_data(16),
     $            detailled)
          
             print '(''test %dgdy_nl: '',L3)', loc

          else
             test_validated=.true.
          
             test_validated=is_test_validated(
     $            sd_operators_tested%f(
     $            nodes,
     $            i1,j1,
     $            mass_density),
     $            test_data(1),
     $            detailled)
          
             test_validated=test_validated.and.
     $            is_test_validated(
     $            sd_operators_tested%dfdx(
     $            nodes,
     $            i1,j1,
     $            mass_density,
     $            dx),
     $            test_data(2),
     $            detailled)
          
             test_validated=test_validated.and.
     $            is_test_validated(
     $            sd_operators_tested%dfdy(
     $            nodes,
     $            i1,j1,
     $            mass_density,
     $            dy),
     $            test_data(3),
     $            detailled)
          
             test_validated=test_validated.and.
     $            is_test_validated(
     $            sd_operators_tested%d2fdx2(
     $            nodes,
     $            i1,j1,
     $            mass_density,
     $            dx),
     $            test_data(4),
     $            detailled)
          
             test_validated=test_validated.and.
     $            is_test_validated(
     $            sd_operators_tested%d2fdy2(
     $            nodes,
     $            i1,j1,
     $            mass_density,
     $            dy),
     $            test_data(5),
     $            detailled)
          
             test_validated=test_validated.and.
     $            is_test_validated(
     $            sd_operators_tested%d2fdxdy(
     $            nodes,
     $            i1,j1,
     $            mass_density,
     $            dx,
     $            dy),
     $            test_data(6),
     $            detailled)

             test_validated=test_validated.and.
     $            is_test_validated(
     $            gradient_x(
     $            nodes,
     $            i1,j1,
     $            mass_density,
     $            dx),
     $            test_data(7),
     $            detailled)
          
             test_validated=test_validated.and.
     $            is_test_validated(
     $            sd_operators_tested%g(
     $            nodes,
     $            i2,j2,
     $            mass_density),
     $            test_data(8),
     $            detailled)
          
             test_validated=test_validated.and.
     $            is_test_validated(
     $            sd_operators_tested%dgdx(
     $            nodes,
     $            i2,j2,
     $            mass_density,
     $            dx),
     $            test_data(9),
     $            detailled)
          
             test_validated=test_validated.and.
     $            is_test_validated(
     $            sd_operators_tested%dgdy(
     $            nodes,
     $            i2,j2,
     $            mass_density,
     $            dy),
     $            test_data(10),
     $            detailled)
          
             test_validated=test_validated.and.
     $            is_test_validated(
     $            sd_operators_tested%d2gdx2(
     $            nodes,
     $            i2,j2,
     $            mass_density,
     $            dx),
     $            test_data(11),
     $            detailled)
          
             test_validated=test_validated.and.
     $            is_test_validated(
     $            sd_operators_tested%d2gdy2(
     $            nodes,
     $            i2,j2,
     $            mass_density,
     $            dy),
     $            test_data(12),
     $            detailled)
          
             test_validated=test_validated.and.
     $            is_test_validated(
     $            sd_operators_tested%d2gdxdy(
     $            nodes,
     $            i2,j2,
     $            mass_density,
     $            dx,
     $            dy),
     $            test_data(13),
     $            detailled)

             test_validated=test_validated.and.
     $            is_test_validated(
     $            gradient_y(
     $            nodes,
     $            i2,j2,
     $            mass_density,

     $            dy),
     $            test_data(14),
     $            detailled)

             test_validated=test_validated.and.
     $            is_test_validated(
     $            sd_operators_tested%dfdx_nl(
     $            nodes,
     $            i1,j1,
     $            gradient_av,
     $            dx,
     $            dy),
     $            test_data(15),
     $            detailled)

             test_validated=test_validated.and.
     $            is_test_validated(
     $            sd_operators_tested%dgdy_nl(
     $            nodes,
     $            i2,j2,
     $            gradient_av,
     $            dx,
     $            dy),
     $            test_data(16),
     $            detailled)
          
             print '(''test_validated: '', 1L1)', test_validated
          
          end if

        end subroutine test_operator

      end program test_cg_operators
