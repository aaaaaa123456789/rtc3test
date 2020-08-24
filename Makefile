ASMFLAGS ?= -Wextra -Wshift-amount

all: rtc3test.gb

rtc3test.o: src/rom.asm src/*.asm
	cd src && rgbasm -E -Wno-truncation $(ASMFLAGS) -p 0xff -h -o ../$@ ../$<

rtc3test.gb: rtc3test.o
	rgblink -m rtc3test.map -n rtc3test.sym -o $@ -p 0xff $^
	rgbfix -c -i RTC3 -j -k XX -m 0x0f -n 1 -p 0xff -r 0 -t MBC3RTCTEST -v $@

clean:
	rm -rf *.o *.sym *.map *.gb
