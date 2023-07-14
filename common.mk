OBJFILES := $(foreach path,$(OBJ),./obj/$(path))

dirs:
	mkdir -p ./obj ./bin

./obj/%.ko: ./src/%.s dirs
	kasm -o $@ $<

./bin/$(NAME).ksm: bin
bin: $(OBJFILES)
	kld $^ -o ./bin/$(NAME).ksm

install: ./bin/$(NAME).ksm
	cp $< '$(KOS_ARCHIVE)/boot'
