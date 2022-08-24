-include $(CONFIG)

BINARY    ?= Chocolate-Wolfenstein-3D
PREFIX    ?= /usr/local
MANPREFIX ?= $(PREFIX)
UNAME := $(shell uname -s)

INSTALL         ?= install
INSTALL_PROGRAM ?= $(INSTALL) -m 555 -s
INSTALL_MAN     ?= $(INSTALL) -m 444
INSTALL_DATA    ?= $(INSTALL) -m 444


SDL_CONFIG  ?= sdl-config
CFLAGS_SDL  ?= $(shell $(SDL_CONFIG) --cflags)
LDFLAGS_SDL ?= $(shell $(SDL_CONFIG) --libs)


CFLAGS += $(CFLAGS_SDL) -O2 -Wall -Wpointer-arith -Wreturn-type -Wwrite-strings -Wcast-align -O2 -std=gnu99 \
-Werror-implicit-function-declaration -Wimplicit-int -Wsequence-point

LDFLAGS += $(LDFLAGS_SDL)
ifeq ($(UNAME), Darwin)
	LDFLAGS += -lSDL_mixer -framework OpenGL
endif
ifeq ($(UNAME), Linux)
	LDFLAGS += -lSDL_mixer -lGL
endif

SRCS += fmopl.c id_ca.c id_in.c id_pm.c id_sd.c id_us.c id_vh.c id_vl.c signon.c wl_act1.c \
wl_act2.c wl_agent.c wl_debug.c wl_draw.c wl_game.c wl_inter.c wl_main.c wl_menu.c wl_play.c \
wl_state.c wl_text.c crt.c

DEPS = $(filter %.d, $(SRCS:.c=.d))
OBJS = $(filter %.o, $(SRCS:.c=.o))

.SUFFIXES: .c .d .o

Q ?= @

all: $(BINARY)

ifndef NO_DEPS
depend: $(DEPS)

ifeq ($(findstring $(MAKECMDGOALS), clean depend Data),)
-include $(DEPS)
endif
endif

$(BINARY): $(OBJS)
	@echo '===> LD $@'
	$(Q)$(C) $(CFLAGS) $(OBJS) $(LDFLAGS) -o $@

.c.o:
	@echo '===> CC $<'
	$(Q)$(CC) $(CFLAGS) -c $< -o $@
.c.d:
	@echo '===> DEP $<'
	$(Q)$(CC) $(CFLAGS) -MM $< | sed 's#^$(@F:%.d=%.o):#$@ $(@:%.d=%.o):#' > $@

clean distclean:
	@echo '===> CLEAN'
	$(Q)rm -fr $(DEPS) $(OBJS) $(BINARY)

install: $(BINARY)
	@echo '===> INSTALL'
	$(Q)$(INSTALL) -d $(PREFIX)/bin
	$(Q)$(INSTALL_PROGRAM) $(BINARY) $(PREFIX)/bin