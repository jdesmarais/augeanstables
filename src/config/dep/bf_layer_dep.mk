#buffer layer parameters and errors
$(bf_layer_dir)/parameters_bf_layer.o:\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o

$(bf_layer_dir)/bf_layer_errors_module.o:


#bf_layer_parents
$(pbf_layer_dir)/bf_layer_basic_class.o:\
	$(sbf_layer_dir)/bf_layer_extract_module.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o

$(pbf_layer_dir)/bf_layer_print_class.o:\
	$(pbf_layer_dir)/bf_layer_basic_class.o\
	$(iobf_layer_dir)/bf_layer_nf90_operators_module.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o

$(pbf_layer_dir)/bf_layer_sync_class.o:\
	$(pbf_layer_dir)/bf_layer_print_class.o\
	$(bf_layer_dir)/bf_layer_errors_module.o\
	$(sbf_layer_dir)/bf_layer_exchange_module.o\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o

$(pbf_layer_dir)/bf_layer_dyn_class.o:\
	$(bf_layer_dir)/bf_layer_errors_module.o\
	$(pbf_layer_dir)/bf_layer_sync_class.o\
	$(gbf_layer_dir)/bf_layer_allocate_module.o\
	$(gbf_layer_dir)/bf_layer_reallocate_module.o\
	$(gbf_layer_dir)/bf_layer_merge_module.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o

$(pbf_layer_dir)/bf_layer_time_class.o:\
	$(bbf_layer_dir)/bf_layer_bc_sections_class.o\
	$(pbf_layer_dir)/bf_layer_dyn_class.o\
	$(bf_layer_dir)/bf_layer_errors_module.o\
	$(sbf_layer_dir)/bf_layer_extract_module.o\
	$(cbf_layer_dir)/bf_compute_newgrdpt_class.o\
	$(bc_dir)/bc_operators_gen_class.o\
	$(ti_dir)/interface_integration_step.o\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o\
	$(pm_cdir)/pmodel_eq_class.o\
	$(sd_cdir)/sd_operators_class.o\
	$(td_cdir)/td_operators_class.o

$(pbf_layer_dir)/bf_layer_newgrdpt_class.o:\
	$(pbf_layer_dir)/bf_layer_time_class.o\
	$(sbf_layer_dir)/bf_layer_extract_module.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o\
	$(pm_cdir)/pmodel_eq_class.o

$(pbf_layer_dir)/bf_layer_grdpts_id_update_class.o:\
	$(gbf_layer_dir)/bf_bc_interior_pt_crenel_module.o\
	$(gbf_layer_dir)/bf_bc_pt_crenel_module.o\
	$(sbf_layer_dir)/bf_layer_extract_module.o\
	$(pbf_layer_dir)/bf_layer_newgrdpt_class.o\
	$(ngbf_layer_dir)/bf_newgrdpt_verification_module.o\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o

$(pbf_layer_dir)/bf_layer_icr_class.o:\
	$(pbf_layer_dir)/bf_layer_grdpts_id_update_class.o\
	$(ngbf_layer_dir)/bf_newgrdpt_verification_module.o\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_kind.o\
	$(pm_cdir)/pmodel_eq_class.o

$(bf_layer_dir)/bf_layer_class.o:\
	$(pbf_layer_dir)/bf_layer_icr_class.o\
	$(dbf_layer_dir)/bf_decrease_module.o\
	$(pm_cdir)/pmodel_eq_class.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o

$(bf_layer_dir)/bf_sublayer_class.o:\
	$(bf_layer_dir)/bf_layer_class.o\
	$(param_dir)/parameters_kind.o

$(lbf_layer_dir)/bf_sublayer_pointer_class.o:\
	$(bf_layer_dir)/bf_sublayer_class.o


#bf_mainlayer_parents
$(mpbf_layer_dir)/bf_mainlayer_basic_class.o:\
	$(bf_layer_dir)/bf_sublayer_class.o\
	$(param_dir)/parameters_kind.o

$(mpbf_layer_dir)/bf_mainlayer_print_class.o:\
	$(mpbf_layer_dir)/bf_mainlayer_basic_class.o\
	$(bf_layer_dir)/bf_sublayer_class.o\
	$(param_dir)/parameters_input.o

$(mpbf_layer_dir)/bf_mainlayer_sync_class.o:\
	$(bbf_layer_dir)/bf_interior_bc_sections_module.o\
	$(bf_layer_dir)/bf_layer_errors_module.o\
	$(mpbf_layer_dir)/bf_mainlayer_print_class.o\
	$(bf_layer_dir)/bf_sublayer_class.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o

$(mpbf_layer_dir)/bf_mainlayer_time_class.o:\
	$(bc_dir)/bc_operators_gen_class.o\
	$(bf_layer_dir)/bf_layer_errors_module.o\
	$(mpbf_layer_dir)/bf_mainlayer_sync_class.o\
	$(bf_layer_dir)/bf_sublayer_class.o\
	$(ti_dir)/interface_integration_step.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o

$(bf_layer_dir)/bf_mainlayer_class.o:\
	$(mpbf_layer_dir)/bf_mainlayer_time_class.o\
	$(ibf_layer_dir)/bf_increase_coords_module.o\
	$(bf_layer_dir)/bf_layer_errors_module.o\
	$(bf_layer_dir)/bf_sublayer_class.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o

$(bf_layer_dir)/bf_mainlayer_pointer_class.o:\
	$(bf_layer_dir)/bf_layer_errors_module.o\
	$(bf_layer_dir)/bf_sublayer_class.o\
	$(bf_layer_dir)/bf_mainlayer_class.o\
	$(ti_dir)/interface_integration_step.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o


#mainlayer_interface parents
$(mbf_layer_dir)/mainlayer_interface_basic_class.o:\
	$(bf_layer_dir)/bf_sublayer_class.o\
	$(bf_layer_dir)/bf_layer_errors_module.o\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_constant.o

$(mbf_layer_dir)/mainlayer_interface_sync_class.o:\
	$(mbf_layer_dir)/mainlayer_interface_basic_class.o\
	$(bf_layer_dir)/bf_layer_errors_module.o\
	$(bf_layer_dir)/bf_sublayer_class.o\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_constant.o

$(mbf_layer_dir)/mainlayer_interface_dyn_class.o:\
	$(bf_layer_dir)/bf_layer_errors_module.o\
	$(sbf_layer_dir)/bf_layer_exchange_module.o\
	$(bf_layer_dir)/bf_sublayer_class.o\
	$(mbf_layer_dir)/mainlayer_interface_sync_class.o\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o

$(mbf_layer_dir)/mainlayer_interface_time_class.o:\
	$(bbf_layer_dir)/bf_layer_bc_sections_class.o\
	$(bbf_layer_dir)/bf_layer_bc_sections_merge_module.o\
	$(bf_layer_dir)/bf_layer_class.o\
	$(sbf_layer_dir)/bf_layer_extract_module.o\
	$(bf_layer_dir)/bf_sublayer_class.o\
	$(mbf_layer_dir)/mainlayer_interface_dyn_class.o\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_kind.o

$(mbf_layer_dir)/mainlayer_interface_newgrdpt_class.o:\
	$(sbf_layer_dir)/bf_layer_extract_module.o\
	$(ngbf_layer_dir)/bf_newgrdpt_class.o\
	$(ngbf_layer_dir)/bf_newgrdpt_procedure_module.o\
	$(ngbf_layer_dir)/bf_newgrdpt_verification_module.o\
	$(bf_layer_dir)/bf_sublayer_class.o\
	$(mbf_layer_dir)/mainlayer_interface_time_class.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o\
	$(pm_cdir)/pmodel_eq_class.o

$(mbf_layer_dir)/mainlayer_interface_grdpts_id_update_class.o:\
	$(gbf_layer_dir)/bf_bc_interior_pt_crenel_module.o\
	$(gbf_layer_dir)/bf_bc_pt_crenel_module.o\
	$(sbf_layer_dir)/bf_layer_extract_module.o\
	$(ngbf_layer_dir)/bf_newgrdpt_verification_module.o\
	$(bf_layer_dir)/bf_sublayer_class.o\
	$(mbf_layer_dir)/mainlayer_interface_newgrdpt_class.o\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o\
	$(pm_cdir)/pmodel_eq_class.o

$(mbf_layer_dir)/mainlayer_interface_icr_class.o:\
	$(bbf_layer_dir)/bf_layer_bc_sections_merge_module.o\
	$(bbf_layer_dir)/bf_layer_bc_sections_icr_module.o\
	$(bf_layer_dir)/bf_layer_class.o\
	$(mbf_layer_dir)/mainlayer_interface_grdpts_id_update_class.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_kind.o


#bf_interface parents
$(ipbf_layer_dir)/bf_interface_basic_class.o:\
	$(bf_layer_dir)/bf_mainlayer_class.o\
	$(bf_layer_dir)/bf_mainlayer_pointer_class.o\
	$(mbf_layer_dir)/mainlayer_interface_icr_class.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o

$(ipbf_layer_dir)/bf_interface_print_class.o:\
	$(iobf_layer_dir)/bf_layer_nf90_operators_module.o\
	$(ipbf_layer_dir)/bf_interface_basic_class.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o

$(ipbf_layer_dir)/bf_interface_sync_class.o:\
	$(ipbf_layer_dir)/bf_interface_print_class.o\
	$(bf_layer_dir)/bf_sublayer_class.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o

$(ipbf_layer_dir)/bf_interface_dyn_class.o:\
	$(ipbf_layer_dir)/bf_interface_sync_class.o\
	$(bf_layer_dir)/bf_layer_errors_module.o\
	$(bf_layer_dir)/bf_sublayer_class.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o

$(ipbf_layer_dir)/bf_interface_time_class.o:\
	$(bc_dir)/bc_operators_gen_class.o\
	$(ipbf_layer_dir)/bf_interface_dyn_class.o\
	$(bbf_layer_dir)/bf_mainlayer_bc_sections_module.o\
	$(bf_layer_dir)/bf_sublayer_class.o\
	$(ti_dir)/interface_integration_step.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o\
	$(pm_cdir)/pmodel_eq_class.o\
	$(sd_cdir)/sd_operators_class.o\
	$(td_cdir)/td_operators_class.o

$(ipbf_layer_dir)/bf_interface_grdpts_id_update_class.o:\
	$(ipbf_layer_dir)/bf_interface_time_class.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o\
	$(pm_cdir)/pmodel_eq_class.o

$(ipbf_layer_dir)/bf_interface_coords_class.o:\
	$(ibf_layer_dir)/bf_increase_coords_module.o\
	$(ipbf_layer_dir)/bf_interface_grdpts_id_update_class.o\
	$(bf_layer_dir)/bf_sublayer_class.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_kind.o

$(ipbf_layer_dir)/bf_interface_icr_class.o:\
	$(ibf_layer_dir)/bf_increase_coords_module.o\
	$(ipbf_layer_dir)/bf_interface_coords_class.o\
	$(bbf_layer_dir)/bf_layer_bc_sections_overlap_module.o\
	$(bf_layer_dir)/bf_layer_errors_module.o\
	$(bf_layer_dir)/bf_sublayer_class.o\
	$(ibf_layer_dir)/icr_interface_class.o\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_kind.o\
	$(pm_cdir)/pmodel_eq_class.o

$(ipbf_layer_dir)/bf_interface_dcr_class.o:\
	$(ipbf_layer_dir)/bf_interface_icr_class.o\
	$(bf_layer_dir)/bf_sublayer_class.o\
	$(dbf_layer_dir)/dcr_interface_class.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o\
	$(pm_cdir)/pmodel_eq_class.o

$(bf_layer_dir)/bf_interface_class.o:\
	$(ipbf_layer_dir)/bf_interface_dcr_class.o\
	$(rbf_layer_dir)/bf_restart_module.o\
	$(bf_layer_dir)/bf_sublayer_class.o\
	$(nf90_dir)/nf90_operators_module.o\
	$(nf90_dir)/nf90_operators_read_module.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o\
	$(pm_cdir)/pmodel_eq_class.o


#buffer layer bc_sections
$(bbf_layer_dir)/bf_layer_bc_procedure_module.o:\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_constant.o

$(bbf_layer_dir)/bf_layer_bc_sections_overlap_module.o:\
	$(bf_layer_dir)/bf_layer_errors_module.o\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_constant.o

$(bbf_layer_dir)/bf_layer_bc_sections_class.o:\
	$(bbf_layer_dir)/bf_layer_bc_procedure_module.o\
	$(bbf_layer_dir)/bf_layer_bc_sections_overlap_module.o\
	$(bf_layer_dir)/bf_layer_errors_module.o\
	$(sbf_layer_dir)/bf_layer_extract_module.o\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o

$(bbf_layer_dir)/bf_interior_bc_sections_module.o:\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o

$(bbf_layer_dir)/bf_layer_bc_checks_module.o:\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o

$(bbf_layer_dir)/bf_layer_bc_fluxes_module.o:\
	$(sbf_layer_dir)/bf_layer_extract_module.o\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o\
	$(pm_cdir)/pmodel_eq_class.o

$(bbf_layer_dir)/bf_mainlayer_bc_sections_module.o:\
	$(bbf_layer_dir)/bf_interior_bc_sections_module.o\
	$(bf_layer_dir)/bf_mainlayer_pointer_class.o\
	$(bf_layer_dir)/bf_mainlayer_class.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o

$(bbf_layer_dir)/bf_layer_bc_sections_merge_module.o:\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_kind.o

$(bbf_layer_dir)/bf_layer_bc_sections_icr_module.o:\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_kind.o


#bf_layer_newgrdpt folder
$(ngbf_layer_dir)/bf_newgrdpt_verification_module.o:\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_kind.o

$(ngbf_layer_dir)/bf_newgrdpt_procedure_module.o:\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_kind.o

$(ngbf_layer_dir)/bf_newgrdpt_extract_module.o:\
	$(sbf_layer_dir)/bf_layer_extract_module.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o

$(ngbf_layer_dir)/bf_newgrdpt_class.o:\
	$(bf_layer_dir)/bf_layer_errors_module.o\
	$(sd_dir)/interface_primary.o\
	$(sd_dir)/n_coords_module.o\
	$(obc_dir)/openbc_operators_module.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o\
	$(pm_cdir)/pmodel_eq_class.o\
	$(sd_cdir)/sd_operators_fd_module.o

$(ngbf_layer_dir)/bf_newgrdpt_dispatch_module.o:\
	$(bf_layer_dir)/bf_layer_errors_module.o\
	$(sbf_layer_dir)/bf_layer_extract_module.o\
	$(ngbf_layer_dir)/bf_newgrdpt_class.o\
	$(ngbf_layer_dir)/bf_newgrdpt_procedure_module.o\
	$(ngbf_layer_dir)/bf_newgrdpt_verification_module.o\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_kind.o


#functions for the time integration of the buffer layer
$(cbf_layer_dir)/bf_compute_basic_class.o:\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o

$(cbf_layer_dir)/bf_compute_time_class.o:\
	$(bc_dir)/bc_operators_gen_class.o\
	$(cbf_layer_dir)/bf_compute_basic_class.o\
	$(ti_dir)/interface_integration_step.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o\
	$(pm_cdir)/pmodel_eq_class.o\
	$(sd_cdir)/sd_operators_class.o\
	$(td_cdir)/td_operators_class.o

$(cbf_layer_dir)/bf_compute_newgrdpt_class.o:\
	$(cbf_layer_dir)/bf_compute_time_class.o\
	$(sbf_layer_dir)/bf_layer_extract_module.o\
	$(ngbf_layer_dir)/bf_newgrdpt_dispatch_module.o\
	$(param_dir)/parameters_kind.o\
	$(pm_cdir)/pmodel_eq_class.o


#buffer layer grdpts_id
$(gbf_layer_dir)/bf_layer_allocate_module.o:\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o

$(gbf_layer_dir)/bf_layer_reallocate_module.o:\
	$(gbf_layer_dir)/bf_layer_allocate_module.o\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o

$(gbf_layer_dir)/bf_layer_merge_module.o:\
	$(gbf_layer_dir)/bf_layer_allocate_module.o\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o

$(gbf_layer_dir)/bf_bc_interior_pt_crenel_module.o:\
	$(ngbf_layer_dir)/bf_newgrdpt_dispatch_module.o\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_kind.o

$(gbf_layer_dir)/bf_bc_pt_crenel_module.o:\
	$(ngbf_layer_dir)/bf_newgrdpt_dispatch_module.o\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_kind.o

#buffer layer i/o
$(iobf_layer_dir)/bf_layer_nf90_operators_module.o:\
	$(bf_layer_dir)/bf_layer_errors_module.o\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o


#buffer layer restart
$(rbf_layer_dir)/bf_restart_module.o:\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o


#buffer layer synchronization
$(sbf_layer_dir)/bf_layer_exchange_module.o:\
	$(bf_layer_dir)/bf_layer_errors_module.o\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o

$(sbf_layer_dir)/bf_layer_extract_module.o:\
	$(bf_layer_dir)/bf_layer_errors_module.o\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o



#bf_layer_increase
$(ibf_layer_dir)/bf_increase_coords_module.o:\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o

$(ibf_layer_dir)/bf_sorting_module.o:\
	$(param_dir)/parameters_kind.o

$(ibf_layer_dir)/icr_path_class.o:\
	$(bf_layer_dir)/bf_layer_errors_module.o\
	$(sbf_layer_dir)/bf_layer_exchange_module.o\
	$(ibf_layer_dir)/bf_increase_coords_module.o\
	$(ipbf_layer_dir)/bf_interface_coords_class.o\
	$(ibf_layer_dir)/bf_sorting_module.o\
	$(bf_layer_dir)/bf_sublayer_class.o\
	$(pm_cdir)/pmodel_eq_class.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o

$(ibf_layer_dir)/icr_path_chain_class.o:\
	$(ibf_layer_dir)/icr_path_class.o

$(ibf_layer_dir)/icr_path_list_class.o:\
	$(ibf_layer_dir)/icr_path_chain_class.o

$(ibf_layer_dir)/icr_interface_class.o:\
	$(ipbf_layer_dir)/bf_interface_coords_class.o\
	$(bf_layer_dir)/bf_sublayer_class.o\
	$(ibf_layer_dir)/icr_path_chain_class.o\
	$(ibf_layer_dir)/icr_path_list_class.o\
	$(pm_cdir)/pmodel_eq_class.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o


#bf_layer decrease
$(dbf_layer_dir)/bf_decrease_module.o:\
	$(bf_layer_dir)/bf_layer_errors_module.o\
	$(bf_layer_dir)/parameters_bf_layer.o\
	$(param_dir)/parameters_constant.o\
	$(param_dir)/parameters_input.o\
	$(param_dir)/parameters_kind.o\
	$(pm_cdir)/pmodel_eq_class.o

$(dbf_layer_dir)/dcr_chain_class.o:\
	$(bf_layer_dir)/bf_sublayer_class.o

$(dbf_layer_dir)/dcr_list_class.o:\
	$(dbf_layer_dir)/dcr_chain_class.o\
	$(bf_layer_dir)/bf_sublayer_class.o

$(dbf_layer_dir)/dcr_interface_class.o:\
	$(ipbf_layer_dir)/bf_interface_icr_class.o\
	$(bf_layer_dir)/bf_mainlayer_class.o\
	$(bf_layer_dir)/bf_sublayer_class.o\
	$(dbf_layer_dir)/dcr_list_class.o


