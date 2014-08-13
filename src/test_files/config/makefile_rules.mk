help:
	@(echo 'make all      : create executable for all test files')
	@(echo 'make clean    : remove .o files')
	@(echo 'make cleanall : remove .o and executable files')
	@(echo 'make clear    : remove .err .out and .nc')
	@(echo 'make test     : display makefile options')

	@(echo 'to change the cluster configuration, change the env. var. AUGEANSTABLES_CLUSTER')
	@(echo 'to change the compiler, change the env. var. AUGEANSTABLES_COMPILER')
	@(echo 'to activate profiling, change the env. var. AUGEANSTABLES_PROFILE')
	@(echo 'to activate analyzing, change the env. var. AUGEANSTABLES_ANALYSE')
	@(echo 'to activate tracing, change the env. var. AUGEANSTABLES_TRACE')
	@(echo 'to activate report, change the env. var. AUGEANSTABLES_OPTREPORT')
	@(echo 'all these variables can also be set in the corresponding module file')
	@(echo '')

doc:
	./config/generate_doc.sh
	@(echo 'documentation generated')
	@(echo 'opening documentation...')
	@(firefox ./doc/html/files.html &)

dir:
	@(./config/display_dir.sh 'bc_dir:         ' $(bc_dir)          )
	@(./config/display_dir.sh 'field_dir:      ' $(field_dir)	)
	@(./config/display_dir.sh 'io_dir:         ' $(io_dir)	        )
	@(./config/display_dir.sh 'mpi_dir:        ' $(mpi_dir)	        )
	@(./config/display_dir.sh 'param_dir:      ' $(param_dir)       )
	@(./config/display_dir.sh 'phy_eq_dir:     ' $(phy_eq_dir)      )
	@(./config/display_dir.sh 'sd_dir:         ' $(sd_dir)	        )
	@(./config/display_dir.sh 'ti_dir:         ' $(ti_dir)	        )
	@(./config/display_dir.sh 'td_dir:         ' $(td_dir)          )
	@(./config/display_dir.sh 'test_dir:       ' $(test_dir)        )
	@(echo '' )
	@(./config/display_dir.sh 'rbc_dir:        ' $(rbc_dir)	        )
	@(./config/display_dir.sh 'pbc_dir:        ' $(pbc_dir)	        )
	@(./config/display_dir.sh 'wbc_dir:        ' $(wbc_dir)	        )
	@(./config/display_dir.sh 'wrbc_dir:       ' $(wrbc_dir)        )
	@(./config/display_dir.sh 'obc_dir:        ' $(obc_dir)         )
	@(echo '' )
	@(./config/display_dir.sh 'nf90_dir:       ' $(nf90_dir)        )
	@(echo '' )
	@(./config/display_dir.sh 'mpi_bc_dir:     ' $(mpi_bc_dir)      )
	@(echo '' )
	@(./config/display_dir.sh 'dim2d_dir:      ' $(dim2d_dir)       )
	@(./config/display_dir.sh 'simpletest_dir: ' $(simpletest_dir)  )
	@(echo '' )
	@(./config/display_dir.sh 'rk3tvd_dir:     ' $(rk3tvd_dir)      )
	@(echo '' )
	@(./config/display_dir.sh 'fv_dir:         ' $(fv_dir)	        )
	@(echo '' )
	@(echo '' )
	@(./config/display_dir.sh 'dim2d_ic:       ' $(dim2d_ic)        )
	@(echo '' )
	@(./config/display_dir.sh 'hobc_dir:       ' $(hobc_dir)        )
	@(./config/display_dir.sh 'hcobc_dir:      ' $(hcobc_dir)       )
	@(./config/display_dir.sh 'hrobc_dir:      ' $(hrobc_dir)       )
	@(echo '' )
	@(./config/display_dir.sh 'lobc_dir:       ' $(lobc_dir)        )
	@(./config/display_dir.sh 'lpobc_dir:      ' $(lpobc_dir)       )
	@(./config/display_dir.sh 'lpobc_ns2d_dir: ' $(lpobc_ns2d_dir)  )
	@(echo '' )
	@(./config/display_dir.sh 'bf_layer_dir:   ' $(bf_layer_dir)    )
	@(./config/display_dir.sh 'nbf_layer_dir:  ' $(nbf_layer_dir)   )
	@(./config/display_dir.sh 'dbf_layer_dir:  ' $(dbf_layer_dir)   )
	@(./config/display_dir.sh 'sbf_layer_dir:  ' $(sbf_layer_dir)   )

cdir:
	@(echo 'sd_cdir:   '   	 $(sd_cdir)          )
	@(echo 'pm_cdir:   '	 $(pm_cdir)          )
	@(echo 'bc_cdir:   '	 $(bc_cdir)          )
	@(echo 'lobc_cdir: '	 $(lobc_cdir)        )

test:
	@(echo '')

	@(echo 'source code folder: ' $(src_dir))
	@(echo 'cluster:            ' $(cluster))
	@(echo '')

	@(echo 'profile:   ' $(profile))
	@(echo 'analyse:   ' $(analyse))
	@(echo 'trace:     ' $(trace))
	@(echo 'report:    ' $(report))
	@(echo 'scalasca:  ' $(scalasca))
	@(echo '')

	@(echo 'PREP:    ' $(PREP))
	@(echo 'FC:      ' $(FC))
	@(echo 'FFLAGS:  ' $(FFLAGS))
	@(echo 'LDFLAGS: ' $(LDFLAGS))
	@(echo 'INCLUDE: ' $(INCLUDE))
	@(echo 'LIBS:    ' $(LIBS))
	@(echo '')

	@(echo $(test_dir))

tests:	test_field\
	test_cg_operators\
	test_dim2d_prim\
	test_dim2d_fluxes\
	test_dim2d_eq\
	test_fv_operators\
	test_bc_periodic\
	test_bc_reflection\
	test_wall_xy_module\
	test_bc_wall\
	test_rk3tvd\
	test_nf90_operators\
	test_dim2d_ic\
	test_rk3tvd_dim2d

tests_par: test_field_par\
	test_mpi_mg_bc

sims:	sim_dim2d

#objects
%.o:	%.f
	@(basename $@)
	@($(PREP) $(FC) $(FFLAGS) -c $< $(INCLUDE))

#executable
%:	%.o
	@(basename $@)
	@($(PREP) $(FC) $(LDFLAGS) -o $@ $^ $(LIBS))

#main commmand
all:	$(CMD)

#cleaning previous simulations
clear:
	rm *.err *.out *.nc

#cleaning
clean:	
	rm -f *.o *.mod core *~

#complete cleaning
cleanall:
	rm -f $(subst .exe,_mono.exe,$(CMD)) $(CMD) *.o *.mod core *~


