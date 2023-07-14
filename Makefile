DIRS := $(dir $(wildcard ./*/.))

$(DIRS):
	make -C $@ install

.PHONY: $(DIRS)
