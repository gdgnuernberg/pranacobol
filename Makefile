# Makefile for GnuCOBOL Breathwork Web Server

COBC = cobc
COBCFLAGS = -x -free -Wall
SOURCES = server.cob socket_helper.c
TARGET = server

.PHONY: all run clean clean-db

all: $(TARGET)

$(TARGET): $(SOURCES)
	$(COBC) $(COBCFLAGS) $(SOURCES) -o $(TARGET)

run: all
	./$(TARGET)

clean:
	rm -f $(TARGET)
	rm -rf *.dSYM

clean-db:
	rm -f sessions.dat lock.dat
