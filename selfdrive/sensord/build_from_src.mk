CC = clang
CXX = clang++

PHONELIBS = ../../phonelibs
BASEDIR = ../..

WARN_FLAGS = -Werror=implicit-function-declaration \
             -Werror=incompatible-pointer-types \
             -Werror=int-conversion \
             -Werror=return-type \
             -Werror=format-extra-args

CFLAGS = -std=gnu11 -g -fPIC -O2 $(WARN_FLAGS) \
          -I$(PHONELIBS)/android_frameworks_native/include \
          -I$(PHONELIBS)/android_system_core/include \
          -I$(PHONELIBS)/android_hardware_libhardware/include \
          -I$(PHONELIBS)/zmq/x64/include \
          -I/usr/include/android

CXXFLAGS = -std=c++11 -g -fPIC -O2 $(WARN_FLAGS) \
            -I$(PHONELIBS)/android_frameworks_native/include \
            -I$(PHONELIBS)/android_system_core/include \
            -I$(PHONELIBS)/android_hardware_libhardware/include \
            -I$(PHONELIBS)/zmq/x64/include \
            -I/usr/include/android

ZMQ_LIBS = -l:libczmq.a -l:libzmq.a -llog -luuid \
       -L$(BASEDIR)/phonelibs/zmq/x64/lib \
       -L$(BASEDIR)/external/zmq/lib \
       -L/usr/lib/x86_64-linux-gnu/android/ \
       -L/lib/x86_64-linux-gnu/

ifeq ($(ARCH),aarch64)
CFLAGS += -mcpu=cortex-a57
CXXFLAGS += -mcpu=cortex-a57
ZMQ_LIBS += -lgnustl_shared
DIAG_LIBS = -L/system/vendor/lib64 -ltime_genoff -ldiag
DEFINES = -DTARGET_AARCH64
else
DIAG_LIBS =
DEFINES = -DTARGET_X64
endif


JSON_FLAGS = -I$(PHONELIBS)/json/src



.PHONY: all
all: sensord gpsd

include ../common/cereal.mk

SENSORD_OBJS = sensors.o \
       ../common/swaglog.o \
       $(PHONELIBS)/json/src/json.o

GPSD_OBJS = gpsd.o \
       rawgps.o \
       ../common/swaglog.o \
       $(PHONELIBS)/json/src/json.o

DEPS := $(SENSORD_OBJS:.o=.d) $(GPSD_OBJS:.o=.d)

sensord: $(SENSORD_OBJS)
	@echo "[ LINK ] $@"
	$(CXX) -fPIC -o '$@' $^ \
            $(CEREAL_LIBS) \
            $(ZMQ_LIBS) \
            -lpthread
           # -lhardware

gpsd: $(GPSD_OBJS)
	@echo "[ LINK ] $@"
	$(CXX) -fPIC -o '$@' $^ \
            $(CEREAL_LIBS) \
            $(ZMQ_LIBS) \
            $(DIAG_LIBS) \
            -lpthread
            #-lhardware

%.o: %.cc
	@echo "[ CXX ] $@"
	$(CXX) $(CXXFLAGS) \
           $(CEREAL_CXXFLAGS) \
           $(ZMQ_FLAGS) \
           $(JSON_FLAGS) \
           -I../ \
           -I../../ \
           -c -o '$@' '$<'


%.o: %.c
	@echo "[ CC ] $@"
	$(CC) $(CFLAGS) \
           $(JSON_FLAGS) \
           -I../ \
           -I../../ \
           -c -o '$@' '$<'

.PHONY: clean
clean:
	rm -f sensord gpsd $(OBJS) $(DEPS)

-include $(DEPS)
