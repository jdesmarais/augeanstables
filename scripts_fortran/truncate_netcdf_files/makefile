#-----------------------------------------------------------------------
#makefile commands
#-----------------------------------------------------------------------
include $(AUGEANSTABLES_CONFIG)/makefile_header.mk

check_data_module.o:		$(param_dir)/parameters_kind.o

parameters_cst.o:

nf90_operators_truncate_module.o:\
				parameters_cst.o\
				$(param_dir)/parameters_kind.o\
				$(test_dir)/tools/check_data_module.o

cmd_operators_truncate_class.o:	$(param_dir)/parameters_kind.o



truncate_netcdf_file.o:	cmd_operators_truncate_class.o\
				nf90_operators_truncate_module.o

truncate_netcdf_file:		check_data_module.o\
				cmd_operators_truncate_class.o\
				nf90_operators_truncate_module.o\
				parameters_cst.o\
				parameters_kind.o


truncate_netcdf_files_par.o:	cmd_operators_truncate_class.o\
				nf90_operators_truncate_module.o

truncate_netcdf_files_par:	check_data_module.o\
				cmd_operators_truncate_class.o\
				nf90_operators_truncate_module.o\
				parameters_cst.o\
				parameters_kind.o


# test files
#-----------------------------------------------------------------------
test_nf90_operators_truncate.o:	$(test_dir)/tools/check_data_module.o\
				nf90_operators_truncate_module.o\
				parameters_cst.o\
				$(param_dir)/parameters_kind.o

test_nf90_operators_truncate:	parameters_cst.o\
				parameters_kind.o\
				nf90_operators_truncate_module.o\
				check_data_module.o


