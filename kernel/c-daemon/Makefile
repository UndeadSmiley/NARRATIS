CC = gcc
CFLAGS = -Wall -pthread
TARGET = eduos_comm_daemon
SOURCES = eduos_comm_daemon.c

$(TARGET): $(SOURCES)
	$(CC) $(CFLAGS) -o $(TARGET) $(SOURCES)

clean:
	rm -f $(TARGET)
