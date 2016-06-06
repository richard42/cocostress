{ }CoCo 3 RAM Stress Test
{ }Version 1.2

Copyright (C) 2015-2016
By: Richard Goedeken
All Rights Reserved.

You are free to use and copy this program, provided that the disk image and all files therein remain unchanged.

June 5th, 2016
Richard@fascinationsoftware.com

This is a diagnostic program which detects the amount of RAM installed in a CoCo 3 (either 128kb or 512kb up to 8MB) and then writes and reads memory pages, checking for any errors.  All memory pages are tested in a continuous loop.  The CoCo must be reset or powered down to stop the stress test.

When an error is encountered, the error type (I1-I3 or D1-D3), the memory location of the error (page and offset), and the byte values (written vs. read) are logged and displayed in a list on the screen. The latest 8 errors are shown, with the newest at the top.

Each byte of each page (except those which get overwritten by the code page or graphics display) is tested twice: first immediately after writing the page, and then a second time after testing all other pages, just before writing new values to the page. If the first (immediate) verify fails, an I-type error is logged. If the second (delayed) verify fails, a D-type error is logged. When a byte verify fails, that same byte is read once or twice more to determine if the error was transient or persistent. The number of failed reads (1-3) is appended to the error type (I or D).

As the test runs, this program shows the 8kb memory page number currently being tested ($000-$3FF for 8MB), the total amount of memory detected in kilobytes, the total number of megabytes of RAM tested since the program started, and the total number of errors detected.

To start the test, LOADM the 'STRESS12' program.
{-}<end>
