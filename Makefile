VERSION=0.1
CFLAGS=-O2 -g3
INCLUDES=-I./c_include/ `pkg-config --cflags lua5.1` `pkg-config --cflags ruby-2.6`
LIBFLAGS=`pkg-config --libs lua5.1` `pkg-config --libs ruby-2.6`
NAME=libshithouse.so

# OSX might need some shit like this:
# gcc -bundle -undefined dynamic_lookup -o module.so module.o

all: lib

clean:
	rm -f *.o
	rm -f $(NAME)

%.o: ./c_src/%.c
	$(CC) $(CFLAGS) $(INCLUDES) -c -fPIC $<

lib: $(NAME)
$(NAME): shithouse.o
	$(CC) $(CLAGS) $(INCLUDES) -o $(NAME) -shared $^ -lm $(LIBFLAGS)
