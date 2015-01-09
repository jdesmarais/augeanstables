#!/usr/bin/python

import sys         #for system fcts
#import getopt
#import subprocess
#import shlex
#import string
import math        #for mathematical fcts


# for the global variables of the module
from automatization_csts import nb_pts_inside_interface_required, precision


# compute the reduced saturated mass density of vapor
def get_mass_density_vapor(T):
    '''
    @description:
    compute the reduced mass density of saturated vapor
    as function of temperature
    '''

    return 1.0-1.86*math.sqrt(1.0-T)


# compute the reduced saturated mass density of liquid
def get_mass_density_liquid(T):
    '''
    @description:
    compute the reduced mass density of saturated liquid
    as function of temperature
    '''

    return 1.0+2.08*math.sqrt(1.0-T)


# compute the maximum reduced speed of sound in a multi-phase fluid
# of saturated liquid and vapor at equilibrium
def get_max_speed_of_sound(gamma,T):
    '''
    @description:
    compute the maximum reduced speed of sound in a
    multi-phase fluid of saturated liquid and vapor
    at equilibrium using in ratio of heat capacities
    and the reduced temperature
    '''

    mass      = get_mass_density_vapor(T)
    pressure  = 8.0*mass*T/(3.0-mass) - 3.0*mass**2
    speed_vap = math.sqrt(gamma*pressure/mass)

    mass      = get_mass_density_liquid(T)
    pressure  = 8.0*mass*T/(3.0-mass) - 3.0*mass**2
    speed_liq = math.sqrt(gamma*pressure/mass)

    return max(speed_vap,speed_liq)


# compute the weber number corresponding to the characteristic
# length, the Van der Waals state equation parameters, the molar
# mass and the capillarity constant
def get_we(length_c, dim1d_a, dim1d_b, dim1d_M, dim1d_K):
    '''
    @description:
    compute the weber number corresponding to the
    characteristic length, the Van der Waals state
    equation parameters, the molar mass and the
    capillarity constant
    '''

    #critical mass density
    rho_c = dim1d_M/(3.*dim1d_b)

    #critical pressure
    p_c   = dim1d_a/(27.*dim1d_b**2.)

    #critical speed of sound
    u_c   = math.sqrt(p_c/rho_c)

    #weber number
    we    = (length_c**2*u_c**2)/(rho_c*dim1d_K)

    return we


# compute the reduced length of an interface b/w saturated
# liquid and vapor phases at equilibrium as function of
# reduced temperature and weber number
def get_interface_length(we,T):
    '''
    @description:
    compute the reduced length of an interface at
    equilibrium between liquid and vapor phases
    as function of temperature and the weber number
    '''

    return (2.0/math.sqrt(we))*(-0.19+1.65/(math.sqrt(1.0-T)))


# compute the space step ensuring that the interface is
# captured by a defined number of grid points
def get_interface_space_step(interface_lgh,nb_pts):
    '''
    @description
    compute the space step ensuring that the interface is
    captured by a defined number of grid points
    '''

    return float(math.floor(
            interface_lgh/nb_pts
            *10**4))/(10**4)


# compute the diameter of the bubble from the interface size
def get_bubble_diameter(interface_lgh,ratio_bubble_interface):
    '''
    @description
    compute the diameter of the bubble from the interface length
    and the ratio between the two
    '''
    
    return ratio_bubble_interface*interface_lgh


# compute the computational domain extent from the bubble
# diameter and the ratio between the computational domain
# and the bubble
def get_domain_length(bubble_diameter,ratio_domain_bubble):
    '''
    @description
    compute the length of the computational domain from
    the bubble diameter and the ratio between the
    computational domain and the bubble
    '''
    
    return ratio_domain_bubble*bubble_diameter


#determine the extent of the small domain simulation
def get_small_domain_extent(domain_length,dx):
    '''
    @description
    determine the extent of the small domain simulation
    '''

    nb_grdpts_half_domain = math.ceil(domain_lgh/(2.0*dx))
    
    small_domain_extent = [[0 for x in range(2)] for x in range(2)]
    small_domain_extent[0][0] = 0.0 - nb_grdpts_half_domain*dx
    small_domain_extent[1][0] = 0.0 + nb_grdpts_half_domain*dx
    small_domain_extent[0][1] = 0.0 - nb_grdpts_half_domain*dx
    small_domain_extent[1][1] = 0.0 + nb_grdpts_half_domain*dx
    
    return small_domain_extent


# compute the maximum time step ensuring numerical stability
# according to the CFL condition
def get_dt_max(dx,speed_max,CFL_constant):
    '''
    @description
    compute the maximum time step ensuring numerical
    stability according to the CFL condition
    '''

    return float(math.floor(
            CFL_constant*dx/speed_max
            *10**precision))/(10**precision)


# compute the total simulation time ensuring that the
# interface left the computational domain
#   ____________
#  |            |    _______
#  |            |   /       \
#  |     .      |  |  bubble |
#  |     |      |   \___|___/
#  |_____|______|       |
#        |              |
#        |              |
#        <-----><-><--->
#         /       \   \___ bubble_diameter/2
#        /         \   
# domain_lgh/2   ratio_interface_influence*interface_lgh
def get_simulation_time(domain_lgh,
                        bubble_diameter,
                        interface_lgh,
                        ratio_interface_influence,
                        flow_velocity):
    '''
    @description
    compute the total simulation time ensuring that the
    interface left the computational domain
    '''

    #the total distance travelled by the bubble during the
    #simulation is
    total_distance = domain_lgh/2.0+ratio_interface_influence*interface_lgh+bubble_diameter/2.0

    return total_distance/flow_velocity


# get the detail_print such that the total number of files
# written fits what is asked by the user
def get_detail_print(total_nb_files, simulation_time, dt):
    '''
    @description
    get the detail_print such that the total number of files
    written fits what is asked by the user
    '''

    return dt*total_nb_files/simulation_time


#get the extent of the large computational domain
def get_large_domain_extent(small_domain_extent,
                            dx,dy,
                            flow_velocity,
                            speed_of_sound):
    '''
    @description
    get the extent of the large domain such that the perturbations
    from the interior domain of interest do not have time to travel
    to the edges and re-enter the interior domain
    '''
    
    #distance travelled by the perturbations during the simulation
    distance_travelled = (abs(flow_velocity)+speed_of_sound)*simulation_time
    nb_add_x_grdpts    = math.ceil(distance_travelled/(2.0*dx))
    nb_add_y_grdpts    = math.ceil(distance_travelled/(2.0*dy))
    

    #extent of the large domain
    x_min = small_domain_extent[0][0]
    x_max = small_domain_extent[1][0]
    y_min = small_domain_extent[0][1]
    y_max = small_domain_extent[1][1]
    
    large_domain_extent = [[0 for x in range(2)] for x in range(2)]
    large_domain_extent[0][0] = x_min - nb_add_x_grdpts*dx
    large_domain_extent[1][0] = x_max + nb_add_x_grdpts*dx
    large_domain_extent[0][1] = y_min - nb_add_y_grdpts*dy
    large_domain_extent[1][1] = y_max + nb_add_y_grdpts*dy
    
    return large_domain_extent


def print_comparison(name_var,var,var_test):

    print '%20s'%name_var, '%6.3f'%var,'%6.3f'%var_test


def print_comparison_matrix(name_var,var,var_test):

    print '%20s'%name_var, '%6.3f'%var[0][0],'%6.3f'%var_test[0][0]
    print '%20s'%' '     , '%6.3f'%var[1][0],'%6.3f'%var_test[1][0]
    print '%20s'%' '     , '%6.3f'%var[0][1],'%6.3f'%var_test[0][1]
    print '%20s'%' '     , '%6.3f'%var[1][1],'%6.3f'%var_test[1][1]
    

if __name__ == "__main__":
    
    #test parameters
    T_test                         = 0.99
    md_vap_test                    = 0.814
    md_liq_test                    = 1.208
    gamma_test                     = 0.5
    speed_of_sound_test            = 0.768
    length_c_test                  = 0.5
    dim1d_a_test                   = 0.1
    dim1d_b_test                   = 0.2
    dim1d_M_test                   = 0.3
    dim1d_K_test                   = 0.4
    we_test                        = 0.231
    interface_lgh_test             = 67.799
    nb_pts_test                    = 10
    dx_max_test                    = 6.780
    ratio_bubble_interface_test    = 2
    diameter_test                  = 135.599
    ratio_domain_bubble_test       = 1.5
    domain_lgh_test                = 203.398
    CFL_constant_test              = 0.1
    dt_max_test                    = 0.882
    ratio_interface_influence_test = 1.5
    flow_velocity_test             = 0.1
    simulation_time_test           = 2711.976
    total_nb_files_test            = 10
    detail_print_test              = 0.003

    small_domain_extent_test = [[0 for x in range(2)] for x in range(2)]
    small_domain_extent_test[0][0] = -108.4784
    small_domain_extent_test[1][0] =  108.4784
    small_domain_extent_test[0][1] = -108.4784
    small_domain_extent_test[1][1] =  108.4784

    large_domain_extent_test = [[0 for x in range(2)] for x in range(2)] 
    large_domain_extent_test[0][0] = - 1288.181
    large_domain_extent_test[1][0] =   1288.181
    large_domain_extent_test[0][1] = - 1288.181
    large_domain_extent_test[1][1] =   1288.181
    

    #test: get_mass_density_vapor
    md_vap = get_mass_density_vapor(T_test)
    
    #test: get_mass_density_liquid
    md_liq = get_mass_density_liquid(T_test)
    
    #test: get_max_speed_of_sound
    speed_of_sound  = get_max_speed_of_sound(gamma_test,T_test)

    #test: get_we
    we = get_we(length_c_test, dim1d_a_test, dim1d_b_test, dim1d_M_test, dim1d_K_test)

    #test: get_interface_length
    interface_lgh = get_interface_length(we,T_test)

    #test: get_interface_space_step
    dx_max = get_interface_space_step(interface_lgh,nb_pts_test)

    #test: get_bubble_diameter
    diameter = get_bubble_diameter(interface_lgh,ratio_bubble_interface_test)

    #test: get_domain_length
    domain_lgh = get_domain_length(diameter,ratio_domain_bubble_test)

    #test: get_dt_max
    dt_max = get_dt_max(dx_max,speed_of_sound,CFL_constant_test)

    #test: get_simulation_time
    simulation_time = get_simulation_time(domain_lgh,
                                          diameter,
                                          interface_lgh,
                                          ratio_interface_influence_test,
                                          flow_velocity_test)
    #test: get_detail_print
    detail_print = get_detail_print(total_nb_files_test,
                                    simulation_time,
                                    dt_max)
    
    #test: get_small_domain_extent
    small_domain_extent = get_small_domain_extent(domain_lgh,dx_max)

    #test: get_large_domain_extent
    large_domain_extent = get_large_domain_extent(small_domain_extent_test,
                                                  dx_max,dx_max,
                                                  flow_velocity_test,
                                                  speed_of_sound)

    #compare data
    print_comparison('md_vap:',md_vap, md_vap_test)
    print_comparison('md_liq:',md_liq, md_liq_test)
    print_comparison('speed_of_sound:',speed_of_sound, speed_of_sound_test)
    print_comparison('we:',we, we_test)
    print_comparison('interface_lgh:',interface_lgh, interface_lgh_test)
    print_comparison('dx_max:',dx_max, dx_max_test)
    print_comparison('diameter:',diameter, diameter_test)
    print_comparison('domain_lgh:', domain_lgh, domain_lgh_test)
    print_comparison('dt_max:',dt_max, dt_max_test)
    print_comparison('simulation_time:',simulation_time, simulation_time_test)
    print_comparison('detail_print:',detail_print, detail_print_test)
    print_comparison_matrix('small_domain_extent:',small_domain_extent,small_domain_extent_test)
    print_comparison_matrix('large_domain_extent:',large_domain_extent,large_domain_extent_test)