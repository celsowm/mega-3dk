SHELL := /bin/sh
ROOT := $(CURDIR)
SRC := $(ROOT)/src
BUILD := $(ROOT)/build
ROM := $(BUILD)/rom/mega-3dk.bin
VASM := $(ROOT)/toolchain/vasm/vasmm68k_mot
VASMFLAGS := -Fbin -m68000 -spaces -o $(ROM)
ENTRY := $(SRC)/boot/boot.asm

.PHONY: all assets build clean info
all: build

assets:
	python3 tools/gen_lut.py
	python3 tools/pack_mesh.py

build: assets
	mkdir -p $(BUILD)/rom $(BUILD)/obj $(BUILD)/tmp
	@echo "v4.3 wireframe path prepared. Intended entry: $(ENTRY)"
	@echo "Assembler hook: $(VASM) $(VASMFLAGS) $(ENTRY)"
	@echo "ROM target: $(ROM)"
	@echo "Note: present_frame and final ROM validation still require local iteration."

info:
	@echo "Entry: $(ENTRY)"
	@echo "ROM:   $(ROM)"

clean:
	rm -rf $(BUILD)/* assets/generated/*
