ROOT     := $(CURDIR)
SRC      := $(ROOT)/src
BUILD    := $(ROOT)/build
ROM      := $(BUILD)/rom/mega-3dk.bin
ENTRY    := $(SRC)/boot/boot.asm
TOOLS    := $(ROOT)/tools

# Detect OS
ifeq ($(OS),Windows_NT)
  VASM     := $(ROOT)/toolchain/vasm/vasmm68k_mot.exe
  BLASTEM  := $(shell powershell -NoProfile -Command \
    "(Get-ChildItem '$(ROOT)/emulator' -Filter 'blastem*.exe' -Recurse | Select-Object -First 1).FullName")
  MKDIR    = powershell -NoProfile -Command "New-Item -ItemType Directory -Force -Path '$(1)' | Out-Null"
else
  VASM     := $(ROOT)/toolchain/vasm/vasmm68k_mot
  BLASTEM  := $(shell find $(ROOT)/emulator -maxdepth 2 -type f \( -name 'blastem' -o -name 'blastem64' \) 2>/dev/null | head -n 1)
  MKDIR    = mkdir -p $(1)
endif

INCDIRS  := src src/boot src/core src/hw src/render src/scene src/data src/math src/debug
VASMFLAGS := -Fbin -m68000 -spaces $(foreach d,$(INCDIRS),-I $(ROOT)/$(d))

# Collect all source files for dependency tracking
ASM_SRCS := $(wildcard $(SRC)/boot/*.asm) \
            $(wildcard $(SRC)/core/*.asm) $(wildcard $(SRC)/core/*.inc) \
            $(wildcard $(SRC)/hw/*.asm) $(wildcard $(SRC)/hw/*.inc) \
            $(wildcard $(SRC)/render/*.asm) \
            $(wildcard $(SRC)/scene/*.asm) \
            $(wildcard $(SRC)/data/*.asm) \
            $(wildcard $(SRC)/math/*.asm) \
            $(wildcard $(SRC)/debug/*.asm)

.PHONY: all build assets run dev clean info bootstrap emulator

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

run: $(ROM)
ifeq ($(OS),Windows_NT)
	powershell -NoProfile -Command "Start-Process '$(BLASTEM)' -ArgumentList '$(ROM)'"
else
	$(BLASTEM) $(ROM) &
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

clean:
	rm -rf $(BUILD)/*

info:
	@echo "Entry:    $(ENTRY)"
	@echo "ROM:      $(ROM)"
	@echo "VASM:     $(VASM)"
	@echo "BlastEm:  $(BLASTEM)"
