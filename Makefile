SUBDIRS := 2022

all clean: $(SUBDIRS) FORCE
$(SUBDIRS): FORCE
	$(MAKE) -C $@ $(MAKECMDGOALS)

FORCE:
