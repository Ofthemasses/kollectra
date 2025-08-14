RISCV_BIN ?= riscv64-unknown-elf-
RISCV_CC      := $(RISCV_BIN)gcc
RISCV_OBJCOPY := $(RISCV_BIN)objcopy

CFLAGS  += -march=rv32imc -mabi=ilp32 -mcmodel=medany -ffreestanding -fdata-sections -ffunction-sections
LDFLAGS += -nostartfiles -nostdlib -Wl,-Bstatic -Wl,--gc-sections -Wl,-T,linker.ld -lgcc

OBJDIR  ?= build
PROJ_NAME ?= main
SRCS    := crt0.S main.c
OBJS    := $(addprefix $(OBJDIR)/,$(SRCS:.c=.o))
OBJS    := $(OBJS:.S=.o)

all: $(OBJDIR)/$(PROJ_NAME).hex

$(OBJDIR)/$(PROJ_NAME).elf: $(OBJS) | $(OBJDIR)
	$(RISCV_CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

$(OBJDIR)/$(PROJ_NAME).hex: $(OBJDIR)/$(PROJ_NAME).elf
	$(RISCV_OBJCOPY) -O ihex $< $@

$(OBJDIR)/%.o: %.c | $(OBJDIR)
	$(RISCV_CC) -c $(CFLAGS) -o $@ $<

$(OBJDIR)/%.o: %.S | $(OBJDIR)
	$(RISCV_CC) -c $(CFLAGS) -D__ASSEMBLY__=1 -o $@ $<

$(OBJDIR):
	mkdir -p $@

clean:
	rm -rf $(OBJDIR)
