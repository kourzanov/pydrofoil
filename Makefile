RPYTHON_DIR ?= pypy2/rpython

ALL: pydrofoil-riscv

## RISC-V targets:

.PHONY: pydrofoil-riscv
pydrofoil-riscv: pypy_binary/bin/python pypy2/rpython/bin/rpython pydrofoil/softfloat/SoftFloat-3e/build/Linux-RISCV-GCC/softfloat.o ## Build the pydrofoil RISC-V emulator
	pkg-config libffi # if this fails, libffi development headers aren't installed
	PYTHONPATH=. pypy_binary/bin/python ${RPYTHON_DIR}/bin/rpython -Ojit --output=pydrofoil-riscv riscv/targetriscv.py

pydrofoil-test: pypy_binary/bin/python pypy2/rpython/bin/rpython pydrofoil/softfloat/SoftFloat-3e/build/Linux-RISCV-GCC/softfloat.o ## Run the pydrofoil implementation-level unit tests
	./pypy_binary/bin/python pypy2/pytest.py -v pydrofoil/ riscv/

.PHONY: pypy-c-pydrofoil-riscv

.PHONY: riscv-tests
riscv-tests: pypy_binary/bin/python pydrofoil-riscv  ## Run risc-v test suite, needs env variable RISCVMODELCHECKOUT set
ifndef RISCVMODELCHECKOUT
	$(error RISCVMODELCHECKOUT not set)
endif
	./pypy_binary/bin/python run_riscv_tests.py

.PHONY: regen-sail-ir-files
regen-sail-ir-files: isla/isla-sail/plugin.cmxs ## Regenerate the JIB IR files from a RISC-V Sail model, needs env variable RISCVMODELCHECKOUT set
ifndef RISCVMODELCHECKOUT
	$(error RISCVMODELCHECKOUT not set)
endif
	@# this is not great. ideally the sail model Makefile would have a
	@# target that generates the JIB files
	PATH=${realpath isla/isla-sail/}:${PATH} && export PATH && eval `opam config env --switch=5.1.0 --set-switch` && cd $(RISCVMODELCHECKOUT) && \
		isla-sail -dno_cast -O -Oconstant_fold -memo_z3 -c_include riscv_prelude.h -c_include riscv_platform.h -c_no_main \
		--config ~/src/sail-riscv/config/default.json\
		model/prelude.sail model/riscv_errors.sail model/riscv_xlen64.sail model/riscv_xlen.sail model/riscv_flen_D.sail model/riscv_flen.sail model/riscv_vlen.sail model/prelude_mem_addrtype.sail model/prelude_mem_metadata.sail model/prelude_mem.sail model/arithmetic.sail model/rvfi_dii.sail model/riscv_extensions.sail model/riscv_types_common.sail model/riscv_types_ext.sail model/riscv_types.sail model/riscv_vmem_types.sail model/riscv_csr_begin.sail model/riscv_callbacks.sail model/riscv_reg_type.sail model/riscv_freg_type.sail model/riscv_regs.sail model/riscv_pc_access.sail model/riscv_sys_regs.sail model/riscv_pmp_regs.sail model/riscv_pmp_control.sail model/riscv_ext_regs.sail model/riscv_addr_checks_common.sail model/riscv_addr_checks.sail model/riscv_misa_ext.sail model/riscv_vreg_type.sail model/riscv_vext_regs.sail model/riscv_vext_control.sail model/riscv_sys_exceptions.sail model/riscv_sync_exception.sail model/riscv_zihpm.sail model/riscv_sscofpmf.sail model/riscv_zkr_control.sail model/riscv_zicntr_control.sail model/riscv_softfloat_interface.sail model/riscv_fdext_regs.sail model/riscv_fdext_control.sail model/riscv_sys_control.sail model/riscv_smcntrpmf.sail model/riscv_inst_retire.sail model/riscv_platform.sail model/riscv_sstc.sail model/riscv_mem.sail model/riscv_vmem_pte.sail model/riscv_vmem_ptw.sail model/riscv_vmem_tlb.sail model/riscv_vmem.sail model/riscv_vmem_utils.sail model/riscv_types_kext.sail model/riscv_zvk_utils.sail model/riscv_insts_begin.sail model/riscv_insts_common.sail model/riscv_insts_base.sail model/riscv_insts_zifencei.sail model/riscv_insts_aext.sail model/riscv_insts_zca.sail model/riscv_insts_zicsr.sail model/riscv_insts_hints.sail model/riscv_insts_fext.sail model/riscv_insts_zcf.sail model/riscv_insts_dext.sail model/riscv_insts_zcd.sail model/riscv_insts_svinval.sail model/riscv_insts_zfh.sail model/riscv_insts_zfa.sail model/riscv_insts_zicond.sail model/riscv_insts_zawrs.sail model/riscv_insts_zicbom.sail model/riscv_insts_zicboz.sail model/riscv_insts_zimop.sail model/riscv_insts_zcmop.sail model/riscv_jalr_seq.sail model/riscv_insts_end.sail model/riscv_csr_end.sail model/riscv_step_common.sail model/riscv_step_ext.sail model/riscv_decode_ext.sail model/riscv_fetch_rvfi.sail model/riscv_fetch.sail model/riscv_step.sail model/main.sail\
		-o ${PWD}/riscv/riscv_model_RV64 \
		&& \
		${PWD}/isla/isla-sail/isla-sail -dno_cast -O -Oconstant_fold -memo_z3 -c_include riscv_prelude.h -c_include riscv_platform.h -c_no_main \
		--config ~/src/sail-riscv/config/default.json\
		model/prelude.sail model/riscv_errors.sail model/riscv_xlen32.sail model/riscv_xlen.sail model/riscv_flen_D.sail model/riscv_flen.sail model/riscv_vlen.sail model/prelude_mem_addrtype.sail model/prelude_mem_metadata.sail model/prelude_mem.sail model/arithmetic.sail model/rvfi_dii.sail model/riscv_extensions.sail model/riscv_types_common.sail model/riscv_types_ext.sail model/riscv_types.sail model/riscv_vmem_types.sail model/riscv_csr_begin.sail model/riscv_callbacks.sail model/riscv_reg_type.sail model/riscv_freg_type.sail model/riscv_regs.sail model/riscv_pc_access.sail model/riscv_sys_regs.sail model/riscv_pmp_regs.sail model/riscv_pmp_control.sail model/riscv_ext_regs.sail model/riscv_addr_checks_common.sail model/riscv_addr_checks.sail model/riscv_misa_ext.sail model/riscv_vreg_type.sail model/riscv_vext_regs.sail model/riscv_vext_control.sail model/riscv_sys_exceptions.sail model/riscv_sync_exception.sail model/riscv_zihpm.sail model/riscv_sscofpmf.sail model/riscv_zkr_control.sail model/riscv_zicntr_control.sail model/riscv_softfloat_interface.sail model/riscv_fdext_regs.sail model/riscv_fdext_control.sail model/riscv_sys_control.sail model/riscv_smcntrpmf.sail model/riscv_inst_retire.sail model/riscv_platform.sail model/riscv_sstc.sail model/riscv_mem.sail model/riscv_vmem_pte.sail model/riscv_vmem_ptw.sail model/riscv_vmem_tlb.sail model/riscv_vmem.sail model/riscv_vmem_utils.sail model/riscv_types_kext.sail model/riscv_zvk_utils.sail model/riscv_insts_begin.sail model/riscv_insts_common.sail model/riscv_insts_base.sail model/riscv_insts_zifencei.sail model/riscv_insts_aext.sail model/riscv_insts_zca.sail model/riscv_insts_zicsr.sail model/riscv_insts_hints.sail model/riscv_insts_fext.sail model/riscv_insts_zcf.sail model/riscv_insts_dext.sail model/riscv_insts_zcd.sail model/riscv_insts_svinval.sail model/riscv_insts_zfh.sail model/riscv_insts_zfa.sail model/riscv_insts_zicond.sail model/riscv_insts_zawrs.sail model/riscv_insts_zicbom.sail model/riscv_insts_zicboz.sail model/riscv_insts_zimop.sail model/riscv_insts_zcmop.sail model/riscv_jalr_seq.sail model/riscv_insts_end.sail model/riscv_csr_end.sail model/riscv_step_common.sail model/riscv_step_ext.sail model/riscv_decode_ext.sail model/riscv_fetch_rvfi.sail model/riscv_fetch.sail model/riscv_step.sail model/main.sail\
		-o ${PWD}/riscv/riscv_model_RV32 && \
		git describe --long --dirty --abbrev=10 --always --tags --first-parent > ${PWD}/riscv/riscv_model_version

pydrofoil/softfloat/SoftFloat-3e/build/Linux-RISCV-GCC/softfloat.o:
	make -C pydrofoil/softfloat/SoftFloat-3e/build/Linux-RISCV-GCC/ softfloat.o

## PyPy Pydrofoil RISC-V plugin targets:

.PHONY: pypy-c-pydrofoil-riscv
pypy-c-pydrofoil-riscv: pypy_binary/bin/python pypy2/rpython/bin/rpython pydrofoil/softfloat/SoftFloat-3e/build/Linux-RISCV-GCC/softfloat.o ## Build PyPy with Pydrofoil RISC-V plugin
	pkg-config libffi # if this fails, libffi development headers arent installed
	rm -f pypy-c-pydrofoil-riscv
	cd pypy2/pypy/goal && \
	PYTHONPATH=../../../ ../../../pypy_binary/bin/python ../../rpython/bin/rpython -Ojit targetpypystandalone.py --ext=riscv.pypymodule && \
	mv pypy3.11-c pypy-c-pydrofoil-riscv && \
	./pypy-c-pydrofoil-riscv ../../lib_pypy/pypy_tools/build_cffi_imports.py && \
	cd -
	ln -s pypy2/pypy/goal/pypy-c-pydrofoil-riscv pypy-c-pydrofoil-riscv


pypy-c-pydrofoil-riscv-package: ## Package PyPy with Pydrofoil RISC-V plugin
	cd pypy2/pypy/goal && \
	../../../pypy_binary/bin/python ../tool/release/package.py --override_pypy_c=pypy-c-pydrofoil-riscv --make-portable --archive-name=pypy-pydrofoil-scripting-experimental --targetdir=../../../

pypy2/lib/pypy3.11/site-packages/pytest/__init__.py:
	./pypy-c-pydrofoil-riscv -m ensurepip
	./pypy-c-pydrofoil-riscv -m pip install pytest pdbpp

.PHONY: plugin-riscv-tests
plugin-riscv-tests: pypy2/lib/pypy3.11/site-packages/pytest/__init__.py ## Run the tests for the PyPy Pydrofoil RISC-V plugin
	./pypy-c-pydrofoil-riscv -m pytest riscv/pypymodule/test/apptest_plugin.py
	#./pypy-c-pydrofoil-riscv -m pytest riscv/plugin/


## ARM model targets

.PHONY: pydrofoil-arm-test
pydrofoil-test-arm: pypy2/rpython/bin/rpython pypy_binary/bin/python pypy2/rpython/bin/rpython arm/armv9.ir ## Run the ARM emulator unit tests
	PYTHONPATH=. ./pypy_binary/bin/python pypy2/pytest.py -v arm/

.PHONY: pydrofoil-arm
pydrofoil-arm: pypy_binary/bin/python pypy2/rpython/bin/rpython arm/armv9.ir ## Build the Pydrofoil ARM emulator
	PYTHONPATH=. pypy_binary/bin/python ${RPYTHON_DIR}/bin/rpython -Ojit --translation-withsmallfuncsets=0 --output=pydrofoil-arm arm/targetarm.py

sail-arm/arm-v9.4-a/src/v8_base.sail: ## Clone the sail-arm submodule
	git submodule update --init --depth 1

.PHONY: regen-arm-ir-files
regen-arm-ir-files: sail-arm/arm-v9.4-a/src/v8_base.sail isla/isla-sail/plugin.cmxs ## Build ARM IR
	PATH=${realpath isla/isla-sail/}:${PATH} && export PATH && eval `opam config env --switch=5.1.0 --set-switch` &&  make -C sail-arm/arm-v9.4-a/ gen_ir
	mv sail-arm/arm-v9.4-a/ir/armv9.ir arm/

## CHERIoT targets

.PHONY: pydrofoil-cheriot-test
pydrofoil-cheriot-test: pypy2/rpython/bin/rpython pypy_binary/bin/python pypy2/rpython/bin/rpython cheriot/cheriot_model_rv32.ir ## Run the CHERIoT emulator unit tests
	PYTHONPATH=. ./pypy_binary/bin/python pypy2/pytest.py -v cheriot/

.PHONY: pydrofoil-cheriot
pydrofoil-cheriot: pypy_binary/bin/python pypy2/rpython/bin/rpython cheriot/cheriot_model_rv32.ir ## Build the Pydrofoil CHERIoT emulator
	PYTHONPATH=. ./pypy_binary/bin/python  ${RPYTHON_DIR}/bin/rpython -Ojit --output=pydrofoil-cheriot cheriot/targetcheriot.py

sail-cheriot/src/cheri_cap_common.sail: ## Clone the sail-cheriot submodule
	git submodule update --init --depth 1

.PHONY: regen-cheriot-ir-files
regen-cheriot-ir-files: sail-cheriot/src/cheri_cap_common.sail isla/isla-sail/plugin.cmxs ## Build CHERIoT IR
	PATH=${realpath isla/isla-sail/}:${PATH} && export PATH && eval `opam config env --switch=5.1.0 --set-switch` && \
	cd sail-cheriot && \
	isla-sail  -c_preserve _set_Misa_C -O -Oconstant_fold -memo_z3  -c_include riscv_prelude.h -c_include riscv_platform.h -c_no_main \
		--config ~/src/sail-riscv/config/default.json\
		model/prelude.sail model/riscv_errors.sail model/riscv_xlen32.sail model/riscv_xlen.sail model/riscv_flen_D.sail model/riscv_flen.sail model/riscv_vlen.sail model/prelude_mem_addrtype.sail model/prelude_mem_metadata.sail model/prelude_mem.sail model/arithmetic.sail model/rvfi_dii.sail model/riscv_extensions.sail model/riscv_types_common.sail model/riscv_types_ext.sail model/riscv_types.sail model/riscv_vmem_types.sail model/riscv_csr_begin.sail model/riscv_callbacks.sail model/riscv_reg_type.sail model/riscv_freg_type.sail model/riscv_regs.sail model/riscv_pc_access.sail model/riscv_sys_regs.sail model/riscv_pmp_regs.sail model/riscv_pmp_control.sail model/riscv_ext_regs.sail model/riscv_addr_checks_common.sail model/riscv_addr_checks.sail model/riscv_misa_ext.sail model/riscv_vreg_type.sail model/riscv_vext_regs.sail model/riscv_vext_control.sail model/riscv_sys_exceptions.sail model/riscv_sync_exception.sail model/riscv_zihpm.sail model/riscv_sscofpmf.sail model/riscv_zkr_control.sail model/riscv_zicntr_control.sail model/riscv_softfloat_interface.sail model/riscv_fdext_regs.sail model/riscv_fdext_control.sail model/riscv_sys_control.sail model/riscv_smcntrpmf.sail model/riscv_inst_retire.sail model/riscv_platform.sail model/riscv_sstc.sail model/riscv_mem.sail model/riscv_vmem_pte.sail model/riscv_vmem_ptw.sail model/riscv_vmem_tlb.sail model/riscv_vmem.sail model/riscv_vmem_utils.sail model/riscv_types_kext.sail model/riscv_zvk_utils.sail model/riscv_insts_begin.sail model/riscv_insts_common.sail model/riscv_insts_base.sail model/riscv_insts_zifencei.sail model/riscv_insts_aext.sail model/riscv_insts_zca.sail model/riscv_insts_zicsr.sail model/riscv_insts_hints.sail model/riscv_insts_fext.sail model/riscv_insts_zcf.sail model/riscv_insts_dext.sail model/riscv_insts_zcd.sail model/riscv_insts_svinval.sail model/riscv_insts_zfh.sail model/riscv_insts_zfa.sail model/riscv_insts_zicond.sail model/riscv_insts_zawrs.sail model/riscv_insts_zicbom.sail model/riscv_insts_zicboz.sail model/riscv_insts_zimop.sail model/riscv_insts_zcmop.sail model/riscv_jalr_seq.sail model/riscv_insts_end.sail model/riscv_csr_end.sail model/riscv_step_common.sail model/riscv_step_ext.sail model/riscv_decode_ext.sail model/riscv_fetch_rvfi.sail model/riscv_fetch.sail model/riscv_step.sail model/main.sail\
		-o ${PWD}/cheriot/cheriot_model_rv32


## Housekeeping targets:

pypy_binary/bin/python:  ## Download a PyPy binary
	mkdir -p pypy_binary
	python3 get_pypy_to_download.py
	tar -C pypy_binary --strip-components=1 -xf pypy.tar.bz2
	rm pypy.tar.bz2
	./pypy_binary/bin/python -m ensurepip
	./pypy_binary/bin/python -mpip install rply "hypothesis<4.40" junit_xml coverage==5.5 typing

.PHONY: pypy_binary_nightly
pypy_binary_nightly:  ## Download a nightly PyPy binary (instead of stable)
	rm -rf pypy_binary
	mkdir pypy_binary
	python3 get_pypy_to_download.py --nightly
	tar -C pypy_binary --strip-components=1 -xf pypy.tar.bz2
	rm pypy.tar.bz2
	./pypy_binary/bin/python -m ensurepip
	./pypy_binary/bin/python -mpip install rply "hypothesis<4.40" junit_xml coverage==5.5 typing

pypy2/rpython/bin/rpython: ## Clone the PyPy submodule
	git submodule update --init --depth 1

isla/isla-sail/Makefile: ## Clone the isla submodule
	git submodule update --init --depth 1

sail/libsail.opam: ## Clone the sail submodule
	git submodule update --init --depth 1

sail/_opam/bin/sail: sail/libsail.opam ## Build sail switch
	#opam switch create sail/ -y

isla/isla-sail/plugin.cmxs: sail/_opam/bin/sail isla/isla-sail/Makefile ## build isla-sail
	eval `opam config env --switch=5.1.0 --set-switch` && cd isla/isla-sail && $(MAKE)


## Other

.PHONY: clean
clean:  ## remove build artifacts.
	@# Sync with .gitignore. Could be done via git clean -xfdd ?
	rm -rf usession*
	rm -rf docs/_build
	rm -rf pypy_binary
	rm -rf pydrofoil-riscv-tests.xml
	make -C pydrofoil/softfloat/SoftFloat-3e/build/Linux-RISCV-GCC/ clean
	rm -rf pydrofoil-arm
	rm -rf sail/_opam
	rm -rf isla/isla-sail/plugin.cmxs

help:   ## Show this help.
	@echo "\nHelp for various make targets"
	@echo "Possible commands are:"
	@echo
	@grep -h "##" $(MAKEFILE_LIST) | grep -v grep | sed -e 's/\(.*\):.*##\(.*\)/    \1: \2/'

