# Bulls-Cows

A game developed in assembly to play bulls and cows against a computer.

This is the link for the project book - https://docs.google.com/document/d/1JpDDn6RA-HyxkhnY2WCj2-o1UTY-qSn_/edit?usp=sharing&ouid=116528611868542702089&rtpof=true&sd=true

To play you need to download DOSBox Portable and Assembly.
Then you will have to follow these steps:
1. go to the TASM folder in the AssemblyInstall and create a folder called BIN inside if it doesn't exist already.
2. Put the Bu_Co.asm file inside the BIN folder.
3. Open DOSBox.
4. Write there the following with enter between each command:
tasm /zi Bu_Co.asm  ---> tlink /v Bu_Co.obj  ---> td Bu_Co  ---> press f9
   
5. Play and have fun!
