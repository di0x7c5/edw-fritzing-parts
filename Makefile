VERSION_MAJOR := 0
VERSION_MINOR := 1
VERSION_RELEASE := 1

PWD := $(shell pwd)
BUILD := $(PWD)/build
OUT := $(PWD)/out
SCRIPTS := $(PWD)/scripts

PARTS := $(shell ls parts/)

VERSION := $(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_RELEASE)
TARGET := edw-fritzing-parts_v$(VERSION).tar.gz

FRITZING_PATH := /opt/fritzing
FRITZING_PARTS := $(FRITZING_PATH)/fritzing-parts
FRITZING := $(FRITZING_PATH)/Fritzing

default: all

all: build-all-parts

# Prepare the build root tree
build-prepare:
	@mkdir -p $(BUILD)/core
	@mkdir -p $(BUILD)/bins/more
	@mkdir -p $(BUILD)/svg/core/breadboard
	@mkdir -p $(BUILD)/svg/core/icon
	@mkdir -p $(BUILD)/svg/core/pcb
	@mkdir -p $(BUILD)/svg/core/schematic

# For all parts/* do a copy of files to build root tree
# And generate SVG and FZP from *.ic files
build-all-parts: $(addprefix parts-,$(PARTS)) icupdate

parts-%: build-prepare
	@cp parts/$(subst parts-,,$@)/*.fzb parts/$(subst parts-,,$@)/*.png $(BUILD)/bins/more
	@cp parts/$(subst parts-,,$@)/fzp/* $(BUILD)/core
	@cp parts/$(subst parts-,,$@)/svg/* $(BUILD)/svg/core/schematic

icupdate: build-prepare $(SCRIPTS)/icupdate.sh
	@$(SCRIPTS)/icupdate.sh

release: $(OUT)/$(TARGET)

.ONESHELL:
$(OUT)/$(TARGET):
	cd $(BUILD)
	mkdir -p $(OUT)
	tar -zcvf $(OUT)/$(TARGET) *

install: build-all-parts $(FRITZING)
	find $(FRITZING_PARTS) -name EdW_* -exec rm {} \;
	cp -r $(BUILD)/* $(FRITZING_PARTS)
	rm -f $(FRITZING_PARTS)/parts.db
	$(FRITZING) -db $(FRITZING_PARTS)/parts.db

run:
	pkill Fritzing
	$(FRITZING)

clean:
	rm -fr $(BUILD) $(OUT) tmp/

.PHONY: default all clean parts-% build-prepare build-all-parts release install icupdate run
