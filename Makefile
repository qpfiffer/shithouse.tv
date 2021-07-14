VERSION=1.4.0
CFLAGS=-Werror -Wno-ignored-qualifiers -Wno-missing-field-initializers -Wextra -Wall -O3 -ffunction-sections -fdata-sections -g
INCLUDES=-I./c_include/ `pkg-config --cflags luajit`
LIBFLAGS=`pkg-config --libs luajit`
SONAME=libshithouse.so
REALNAME=$(SONAME).$(VERSION)

DESTDIR?=
PREFIX?=/usr/local
LIBDIR?=lib
INSTALL_LIB=$(DESTDIR)$(PREFIX)/$(LIBDIR)/
INSTALL_INCLUDE=$(DESTDIR)$(PREFIX)/include/shithouse/

# OSX might need some shit like this:
# gcc -bundle -undefined dynamic_lookup -o module.so module.o

all: lib

clean:
	rm -f *.o
	rm -f $(REALNAME)

%.o: ./c_src/%.c
	$(CC) $(CFLAGS) $(INCLUDES) -c -fPIC $<

lib: $(REALNAME)
$(REALNAME): shithouse.o
	$(CC) $(CFLAGS) $(LIB_INCLUDES) $(INCLUDES) -o $(REALNAME) -shared -Wl,-soname,${SONAME} $^ $(LIBFLAGS)

install: all
	@mkdir -p $(INSTALL_LIB)
	@mkdir -p $(INSTALL_INCLUDE)
	@install $(REALNAME) $(INSTALL_LIB)$(REALNAME)
	@cd $(INSTALL_LIB) && ln -fs $(REALNAME) $(SONAME)
	@cd $(INSTALL_LIB) && ln -fs $(REALNAME) $(SONAME).1
	@install ./c_include/*.h $(INSTALL_INCLUDE)
	@echo "shithouse installed to $(DESTDIR)$(PREFIX) :^)."

uninstall:
	rm -rf $(INSTALL_LIB)$(REALNAME)
	rm -rf $(INSTALL_LIB)$(SONAME).1
	rm -rf $(INSTALL_INCLUDE)
