-include config.mk

ifeq ($(CXX), gcc)
	cxx_pref=c
else
	cxx_pref=cpp
endif

ifeq ($(BUILD_MODE), debug)
	CXXFLAGS := $(CXXFLAGS) -Wall -Werror -Werror=shadow -Wextra -pedantic-errors
endif

ifeq ($(OS),Windows_NT)
    FIND=winfind
else
    FIND=find
endif

#Directory Vars
TARGETDIR = target/$(BUILD_MODE)
OBJDIR = $(TARGETDIR)/obj
BINDIR = $(TARGETDIR)/bin
SRCDIR = src

SRCS = $(shell $(FIND) $(SRCDIR) -type f -name *.$(cxx_pref))
DEPS = $(subst $(SRCDIR),$(OBJDIR),$(addsuffix .d,$(basename $(SRCS))))
OBJS = $(DEPS:.d=.o)

.PHONY: all clean reconfigure

all: $(BINDIR)/$(TARGET)

$(BINDIR)/$(TARGET): $(OBJS)

$(OBJDIR) $(BINDIR):
	mkdir -p $@

$(OBJDIR)/%.o: $(SRCDIR)/%.$(cxx_pref) | $(OBJDIR)
	mkdir -p $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -MMD -c $< -o $@

$(BINDIR)/%: | $(BINDIR)
	mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $^ -o $@

clean:
	rm -rf $(TARGETDIR)

run: all
	$(BINDIR)/$(TARGET)

-include $(DEPS)
