OBJ := ./obj
BIN := ./bin
SRC := ./src

dirs:
	mkdir -p $(OBJ) $(BIN)

$(OBJ)/%.ko: $(SRC)/%.s dirs
	kasm -o $@ $<

src := $(wildcard $(SRC)/*.s)
obj := $(foreach pat,$(src:.s=.ko),$(pat:$(SRC)%=$(OBJ)%))

bin: $(obj)
	kld $(obj) -o $(BIN)/$(NAME).ksm

install: $(BIN)/$(NAME).ksm
	cp $< '$(KOS_ARCHIVE)'
