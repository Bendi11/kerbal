dirs:
	mkdir -p ./obj ./bin

./obj/%.ko: ./obj/%.s dirs
	kasm -o $@ $<

bin: $(OBJ)
	kld $^ -o ./bin/$(NAME).ksm

install: ./bin/$(NAME).ksm
	cp $< '$(KOS_ARCHIVE)/boot'
