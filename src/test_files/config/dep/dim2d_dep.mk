#diffuse interface model equations
$(dim2d_dir)/dim2d_parameters.o:\
			$(param_dir)/parameters_kind.o

$(dim2d_dir)/dim2d_prim_module.o:\
			$(dim2d_dir)/dim2d_parameters.o\
			$(sd_dir)/interface_primary.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o

$(dim2d_dir)/dim2d_ncoords_module.o:\
			$(dim2d_dir)/dim2d_parameters.o\
			$(dim2d_dir)/dim2d_prim_module.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o

$(dim2d_dir)/dim2d_fluxes_module.o:\
			$(dim2d_dir)/dim2d_parameters.o\
			$(dim2d_dir)/dim2d_prim_module.o\
			$(param_dir)/parameters_kind.o\
			$(sd_cdir)/sd_operators_class.o

$(dim2d_dir)/dim2d_state_eq_module.o:\
			$(dim2d_dir)/dim2d_parameters.o\
			$(param_dir)/parameters_kind.o

$(dim2d_dir)/pmodel_eq_class.o:\
			$(sd_dir)/interface_primary.o\
			$(sd_cdir)/sd_operators_class.o\
			$(dim2d_dir)/dim2d_parameters.o\
			$(dim2d_dir)/dim2d_prim_module.o\
			$(dim2d_dir)/dim2d_ncoords_module.o\
			$(dim2d_dir)/dim2d_fluxes_module.o\
			$(bf_layer_dir)/parameters_bf_layer.o\
			$(param_dir)/parameters_constant.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o\
			$(phy_eq_dir)/pmodel_eq_default_class.o\
			\
			$(dim2d_ic)/dim2d_bubble_ascending_module.o\
			$(dim2d_ic)/dim2d_drop_collision_module.o\
			$(dim2d_ic)/dim2d_drop_retraction_module.o\
			$(dim2d_ic)/dim2d_homogeneous_module.o\
			$(dim2d_ic)/dim2d_phase_separation_module.o\
			$(dim2d_ic)/dim2d_steadystate_module.o


#diffuse interface model initial conditions
$(dim2d_ic)/drop_collision/ic_class.o:\
			$(dim2d_ic)/dim2d_dropbubble_module.o\
			$(dim2d_dir)/dim2d_parameters.o\
			$(dim2d_ic)/dim2d_vortex_module.o\
			$(dim2d_dir)/dim2d_state_eq_module.o\
			$(phy_eq_dir)/ic_abstract_class.o\
			$(param_dir)/parameters_constant.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o

$(dim2d_ic)/drop_retraction/ic_class.o:\
			$(dim2d_ic)/dim2d_dropbubble_module.o\
			$(dim2d_dir)/dim2d_parameters.o\
			$(dim2d_dir)/dim2d_state_eq_module.o\
			$(phy_eq_dir)/ic_abstract_class.o\
			$(param_dir)/parameters_constant.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o

$(dim2d_ic)/homogeneous_liquid/ic_class.o:\
			$(dim2d_dir)/dim2d_parameters.o\
			$(dim2d_dir)/dim2d_state_eq_module.o\
			$(phy_eq_dir)/ic_abstract_class.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o

$(dim2d_ic)/phase_separation/ic_class.o:\
			$(dim2d_dir)/dim2d_parameters.o\
			$(dim2d_dir)/dim2d_state_eq_module.o\
			$(phy_eq_dir)/ic_abstract_class.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o

$(dim2d_ic)/steady_state/ic_class.o:\
			$(dim2d_dir)/dim2d_parameters.o\
			$(dim2d_dir)/dim2d_prim_module.o\
			$(dim2d_dir)/dim2d_state_eq_module.o\
			$(phy_eq_dir)/ic_abstract_class.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o




#common subroutines for the initial conditions
$(dim2d_ic)/dim2d_dropbubble_module.o:\
			$(dim2d_dir)/dim2d_parameters.o\
			$(param_dir)/parameters_constant.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o

$(dim2d_ic)/dim2d_steadystate_module.o:\
			$(dim2d_dir)/dim2d_parameters.o\
			$(dim2d_dir)/dim2d_state_eq_module.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o

$(dim2d_ic)/dim2d_vortex_module.o:\
			$(param_dir)/parameters_kind.o

$(dim2d_ic)/dim2d_bubble_ascending_module.o:\
			$(dim2d_ic)/dim2d_dropbubble_module.o\
			$(dim2d_ic)/dim2d_vortex_module.o\
			$(dim2d_dir)/dim2d_state_eq_module.o\
			$(param_dir)/parameters_constant.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o

$(dim2d_ic)/dim2d_drop_collision_module.o:\
			$(dim2d_ic)/dim2d_dropbubble_module.o\
			$(dim2d_ic)/dim2d_vortex_module.o\
			$(dim2d_dir)/dim2d_state_eq_module.o\
			$(param_dir)/parameters_constant.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o

$(dim2d_ic)/dim2d_drop_retraction_module.o:\
			$(dim2d_ic)/dim2d_dropbubble_module.o\
			$(dim2d_dir)/dim2d_state_eq_module.o\
			$(param_dir)/parameters_constant.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o

$(dim2d_ic)/dim2d_phase_separation.o:\
			$(dim2d_ic)/dim2d_parameters.o\
			$(dim2d_dir)/dim2d_state_eq_module.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o

$(dim2d_ic)/dim2d_homogeneous_module.o:\
			$(dim2d_dir)/dim2d_parameters.o\
			$(dim2d_dir)/dim2d_state_eq_module.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o
