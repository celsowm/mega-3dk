ROOT     := $(CURDIR)
SRC      := $(ROOT)/src
BUILD    := $(ROOT)/build
ROM      := $(BUILD)/rom/mega-3dk.bin
ENTRY    := $(SRC)/boot/boot.asm
SDK_ROOT := $(ROOT)/sdk
TOOLS    := $(ROOT)/tools

# Detect OS
ifeq ($(OS),Windows_NT)
  VASM     := $(ROOT)/toolchain/vasm/vasmm68k_mot.exe
  BLASTEM  := $(shell powershell -NoProfile -Command \
    "(Get-ChildItem '$(ROOT)/emulators' -Filter 'blastem*.exe' -Recurse | Select-Object -First 1).FullName")
  BIZHAWK  := $(shell powershell -NoProfile -Command \
    "(Get-ChildItem '$(ROOT)/emulators' -Filter 'EmuHawk.exe' -Recurse | Select-Object -First 1).FullName")
  MKDIR    = powershell -NoProfile -Command "New-Item -ItemType Directory -Force -Path '$(1)' | Out-Null"
else
  VASM     := $(ROOT)/toolchain/vasm/vasmm68k_mot
  BLASTEM  := $(shell find $(ROOT)/emulators -maxdepth 2 -type f \( -name 'blastem' -o -name 'blastem64' \) 2>/dev/null | head -n 1)
  BIZHAWK  :=
  MKDIR    = mkdir -p $(1)
endif

INCDIRS  := src src/boot src/core src/hw src/render src/scene src/data src/math src/debug sdk/include
VASMFLAGS := -Fbin -m68000 -spaces $(foreach d,$(INCDIRS),-I $(ROOT)/$(d))

# Collect all source files for dependency tracking
ASM_SRCS := $(wildcard $(SRC)/boot/*.asm) \
            $(wildcard $(SRC)/core/*.asm) $(wildcard $(SRC)/core/*.inc) \
            $(wildcard $(SRC)/hw/*.asm) $(wildcard $(SRC)/hw/*.inc) \
            $(wildcard $(SRC)/render/*.asm) \
            $(wildcard $(SRC)/scene/*.asm) \
            $(wildcard $(SRC)/data/*.asm) \
            $(wildcard $(SRC)/math/*.asm) \
            $(wildcard $(SRC)/debug/*.asm) \
            $(wildcard $(SRC)/sdk/*.asm) \
            $(wildcard $(ROOT)/sdk/examples/asm/minimal/*.asm) \
            $(wildcard $(ROOT)/sdk/examples/asm/multimesh/*.asm) \
            $(wildcard $(ROOT)/sdk/examples/asm/template/*.asm)

.PHONY: all build assets run run-bizhawk screenshot screenshot-bizhawk dev clean info bootstrap emulator bizhawk \
        sdk-example-minimal sdk-example-multimesh sdk-example-template sdk-package

all: build

assets:
	python3 $(TOOLS)/gen_lut.py
	python3 $(TOOLS)/pack_mesh.py

$(ROM): $(ASM_SRCS) | assets
	$(call MKDIR,$(BUILD)/rom)
	$(call MKDIR,$(BUILD)/obj)
	$(call MKDIR,$(BUILD)/tmp)
	$(VASM) $(VASMFLAGS) -o $@ $(ENTRY)

build: $(ROM)
	@echo "ROM built: $(ROM)"

sdk-example-minimal:
	$(MAKE) ENTRY=$(SDK_ROOT)/examples/asm/minimal/boot.asm ROM=$(BUILD)/rom/mega-3dk-sdk-minimal.bin build

sdk-example-multimesh:
	$(MAKE) ENTRY=$(SDK_ROOT)/examples/asm/multimesh/boot.asm ROM=$(BUILD)/rom/mega-3dk-sdk-multimesh.bin build

sdk-example-template:
	$(MAKE) ENTRY=$(SDK_ROOT)/examples/asm/template/boot.asm ROM=$(BUILD)/rom/mega-3dk-sdk-template.bin build

run: $(ROM)
ifeq ($(OS),Windows_NT)
ifneq ($(strip $(BLASTEM)),)
	powershell -NoProfile -Command "Start-Process '$(BLASTEM)' -ArgumentList '$(ROM)'"
else
	@echo "BlastEm not found under: $(ROOT)/emulators"
	@exit /b 1
endif
else
ifneq ($(strip $(BLASTEM)),)
	$(BLASTEM) $(ROM) &
else
	@echo "BlastEm not found under: $(ROOT)/emulators"
	@false
endif
endif

run-bizhawk: $(ROM)
ifeq ($(OS),Windows_NT)
ifneq ($(strip $(BIZHAWK)),)
	powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run-bizhawk-windows.ps1
else
	@echo "BizHawk not found under: $(ROOT)/emulators"
	@exit /b 1
endif
else
	@echo "run-bizhawk target is Windows-only for now"
	@false
endif

screenshot: $(ROM)
ifeq ($(OS),Windows_NT)
ifneq ($(strip $(BLASTEM)),)
	powershell -NoProfile -ExecutionPolicy Bypass -File scripts/screenshot-windows.ps1
else
	@echo "BlastEm not found under: $(ROOT)/emulators"
	@exit /b 1
endif
else
	@echo "screenshot target is Windows-only for now"
	@false
endif

screenshot-bizhawk: $(ROM)
ifeq ($(OS),Windows_NT)
ifneq ($(strip $(BIZHAWK)),)
	powershell -NoProfile -ExecutionPolicy Bypass -File scripts/screenshot-bizhawk-windows.ps1
else
	@echo "BizHawk not found under: $(ROOT)/emulators"
	@exit /b 1
endif
else
	@echo "screenshot-bizhawk target is Windows-only for now"
	@false
endif

dev: build run

bootstrap:
ifeq ($(OS),Windows_NT)
	powershell -NoProfile -ExecutionPolicy Bypass -File scripts/bootstrap-windows.ps1
else
	bash scripts/bootstrap-linux.sh
endif

emulator:
ifeq ($(OS),Windows_NT)
	powershell -NoProfile -ExecutionPolicy Bypass -File scripts/download-emulator-windows.ps1
else
	bash scripts/download-emulator-linux.sh
endif

bizhawk:
ifeq ($(OS),Windows_NT)
	powershell -NoProfile -ExecutionPolicy Bypass -File scripts/download-bizhawk-windows.ps1
else
	@echo "bizhawk target is Windows-only for now"
endif

clean:
	rm -rf $(BUILD)/*

sdk-package: build sdk-example-minimal sdk-example-multimesh sdk-example-template
	python3 scripts/package_sdk.py

info:
	@echo "Entry:    $(ENTRY)"
	@echo "ROM:      $(ROM)"
	@echo "VASM:     $(VASM)"
	@echo "BlastEm:  $(if $(strip $(BLASTEM)),$(BLASTEM),not found)"
	@echo "BizHawk:  $(if $(strip $(BIZHAWK)),$(BIZHAWK),not found)"
