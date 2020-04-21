###############################################################################
## Makefile for CoCo3 RAM Stress Tester

# paths
SRCDIR = ./src
TOOLDIR = ./tools
BUILDDIR = ./build
SCRIPTDIR = ./scripts
GENLISTDIR = $(BUILDDIR)/list
GENDISKDIR = $(BUILDDIR)/disk

# paths to dependencies
COCODISKGEN = $(TOOLDIR)/file2dsk
ASSEMBLER = $(TOOLDIR)/lwasm
EMULATOR = $(TOOLDIR)/mess64

# make sure build products directories exist
$(shell mkdir -p $(GENLISTDIR))
$(shell mkdir -p $(GENDISKDIR))

# assembly source files
LOADERSRC = $(addprefix $(SRCDIR)/, init.asm \
                                    graphics-bkgrnd.asm \
                                    graphics-text.asm \
                                    main.asm \
                                    math.asm \
                                    memory.asm \
                                    utility.asm)

# files to be added to Coco3 disk image
READMEBAS = $(GENDISKDIR)/README.BAS
TESTBIN = $(GENDISKDIR)/STRESS12.BIN
DISKFILES = $(READMEBAS) $(TESTBIN)

# core assembler pass outputs
PASS1LIST = $(GENLISTDIR)/ramtest-pass1.lst

# options
ifeq ($(MAMEDBG), 1)
  MAMEFLAGS += -debug
endif

# output disk image filename
TARGET = STRESS12.DSK

# build targets
targets:
	@echo "CoCo3 RAM Stress Tester makefile. "
	@echo "  Targets:"
	@echo "    all           == Build disk image"
	@echo "    clean         == remove binary and output files"
	@echo "    test          == run test in MAME"
	@echo "  Debugging Options:"
	@echo "    MAMEDBG=1     == run MAME with debugger window (for 'test' target)"


all: $(TARGET)

clean:
	rm -rf $(GENASMDIR) $(GENOBJDIR) $(GENDISKDIR) $(GENLISTDIR)

test:
	$(EMULATOR) coco3h -flop1 $(TARGET) $(MAMEFLAGS) -window -waitvsync -resolution 640x480 -video opengl -rompath /mnt/terabyte/pyro/Emulators/firmware/

# build rules

# 0. Build dependencies
$(COCODISKGEN): $(TOOLDIR)/src/file2dsk/main.c
	gcc -o $@ $<

# 1. Assemble CoCo3 RAM Stress Tester
$(TESTBIN) $(PASS1LIST): $(LOADERSRC)
	$(ASSEMBLER) $(ASMFLAGS) --define=PASS=1 -b -o $(TESTBIN) --list=$(PASS1LIST) $(SRCDIR)/main.asm

# 2. Generate the README.BAS document
$(READMEBAS): $(SCRIPTDIR)/build-readme.py $(SRCDIR)/readme-bas.txt
	$(SCRIPTDIR)/build-readme.py $(SRCDIR)/readme-bas.txt $(READMEBAS)

# 3. Create Coco disk image (file2dsk))
$(TARGET): $(COCODISKGEN) $(DISKFILES)
	rm -f $(TARGET)
	$(COCODISKGEN) $(TARGET) $(DISKFILES)

.PHONY: all clean test

