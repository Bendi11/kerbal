
$(dir $(wildcard ./*/.)):
	make -C $@ install
