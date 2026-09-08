# Half Life for goodluckOS
The greatest first-person shooter ever made, available on goodluckOS.

# Where Do I Get It?
This port relies on two projects: `FWGS/Xash3D-FWGS` and `FWGS/hlsdk-portable`. Unfortunately, the code in these projects is stuck in a legal black hole of mutual incompatiblity and distributing them in binary form is _technically_ a violation of both the GPLv3 and Valve's SDK License. Instead of risking a DMCA takedown, cease & desist, or lawsuit from the FSF or Gabe Newell, I'm going to let you do the work of building it yourself!

# Build Instructions
1. Install Docker or Podman.
2. Clone this repo and open a terminal inside of it.
3. If you use Podman, run `podman build -o ./out .`

   If you use Docker, run `docker buildx build --output type=local,dest=./out .`
5. Unzip `out/half-life-port.zip` into the root of the HOME partition on your goodluckOS microSD card. 

   Allow it to merge-into other folders if it asks.
6. Now copy the game files from your legally acquired copy of Half-Life into `ports/half-life/valve` on your microSD card.
7. You're done!

# Where Do I Find My Game Files
If you own Half-Life on steam you can find the game files by right-clicking on Half-Life in your Steam Library and clicking `Manage->Browse Local Files`. 
This should open a file explorer at a directory which contains a folder called `valve`. The contents of the `valve` folder are your game files that you'll have to copy onto your micro SD card.
