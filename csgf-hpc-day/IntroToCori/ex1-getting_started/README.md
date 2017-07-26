# CSGF HPC Day - Introduction to Cori

If you are reading this in a terminal on Cori .. congratulations! You're more
than halfway there. Here are the steps you should have taken to get here, and
what to do next

**Note:** In the command samples here, `$` at the beginning of a line 
represents the bash prompt. Lines not beginning with `$` are sample outputs 
from commands. Blocks like:

```console
$ some_command
output of that command
```

indicate commands to type at the console, and `...` generally means that the
output has been cut for brevity.


## Setting up your workstation (with an X server)

Later today we'll use [Intel] [VTune] to identify performance hotspots in a
sample application. Vtune results are most easily explored using the GUI, which
will require your laptop to be running an X server. For Windows users, either 
[XMing] or [Cygwin/X] are good options, for the Mac [XQuartz]. (If you use 
Linux, you have an X server already)

Better than any of these is [NX] .. X is notoriously "talkative" between the 
client and server, which translates into very slow performance over 
long-latency connections. NX bypasses this by running an X server local to 
NERSC and using a far lighter protocol to project this virtual desktop to your
laptop.

For once-off use (like today), the easiest way to use NX is to point your web
browser to https://nxcloud01.nersc.gov 

For longer-term usage, you can download an NX player and configuration files 
from [the NERSC website][NX].

For this morning's session you can continue on to "Logging in" then return
to installing NX or an X server in the lunch break, if you don't have one 
already.

[Intel]: https://software.intel.com/en-us/intel-vtune-amplifier-xe
[Vtune]: http://www.nersc.gov/users/software/performance-and-debugging-tools/vtune/

[XMing]: http://www.straightrunning.com/XmingNotes/
[Cygwin/X]: https://x.cygwin.com/

[XQuartz]: https://www.xquartz.org/

[NX]: http://www.nersc.gov/users/connecting-to-nersc/using-nx/

## Logging in

More detail about connecting to NERSC systems can be found at 
http://www.nersc.gov/users/connecting-to-nersc/ but for a quick start today:


### From a command line (Mac, Linux, or within an NX session)

If you are using XQuartz on a Mac, first launch it via Spotlight ("XQuartz") 

Using your training account details for `my_login_name` and the password, log
in with:

```console
$ ssh -Y -l my_login_name cori.nersc.gov
```


### From Windows

You'll need an SSH client such as [PuTTY]. To use PuTTY, insert 
`cori.nersc.gov` as the Hostname, then navigate to Category:

Connection -> SSH -> X11

And check the "Enable X Forwarding" box. Then navigate back to the "Session" 
Category, enter `NERSC Cori` under "Saved Sessions" and click "Save". In future
you can load this saved session instead of filling in those details each time

Click "Open" and enter your training account details at the prompt.

[PuTTY]: http://www.putty.org/


### Now that you are in

Cori has 12 login nodes (plus some others for special purposes) and when you 
log in to `cori.nersc.gov` you will land on one of these. A second login might
not be on the same node. Check which node you are on by typing:

```console
$ hostname
cori03
```


## Moving around

When you first login you are in `$HOME`, which is a small filesystem intended
for holding source code and scripts and for building application. Most 
importantly, **this is not the place to run jobs**

The best place to run most jobs is `$SCRATCH`. For today, we'll do everything 
there, so first of all enter:

```console
$ cd $SCRATCH
```


## Getting this training material

If you are reading this on Cori, you've probably already completed this step.

Cori uses a package called "Environment Modules" to manage which software is 
available in your environment. You can see which modules you currently have
loaded with:

```console
$ module list
```

For today we have a module to help you obtain these training materials - load
it into your environment with:

```console
$ module load training/csgf-2017
```

The module sets an environment variable `$TRAINING`, which points at the 
location of these materials. `$TRAINING` is a git repository so you can clone 
it to your `$SCRATCH` directory with:

```console
$ git clone $TRAINING $SCRATCH/csgf-hpc-day
Cloning into '/global/cscratch1/sd/elvis/csgf-hpc-day'...
done.
$ cd $SCRATCH/csgf-hpc-day
```


## Viewing and editing files

If you are not familiar with `vi` or `emacs`, a Windows-notepad-like editor
named `nano` is available via the `nano` module. In `nano` you move around the
file using the arrow keys, and simple command like cut, paste, open, save and
quit are shown at the bottom of the screen, with `^` indicating `ctrl`:

```console
$ module load nano
$ nano my_file.txt
# hit ctrl-o to "WriteOut" (save), and ctrl-x to exit
```


## Make sure you can use GUI programs with X

Finally, if you have NX or an X server running, you should be able to run:

```console
$ xterm &
```

and see a small terminal window appear on your screen

