# Ballan Luca Protected Mode Interface (BLPMI)

Assembly code I built long time ago (1996) to run my experiments in protected mode on an Intel 80386 (https://en.wikipedia.org/wiki/Protected_mode).

At that time there was the DOS Protected Mode Interface (DPMI) but I wanted to build my own. 

Once the processor was set in protected mode, any call to the operating system or interrupts/IRQs would fail. 
The code to handle these situations have to be completely rewritten in 32bit mode, including the handling of the timer IRQ (see IRQ section, currently in line 1916), the standard "cout" function (see label Cout, currently on line 2294), getch, kbhit, etc...

It also supported SVGA, and callbacks to the original operating system.

Very nostalgic...
