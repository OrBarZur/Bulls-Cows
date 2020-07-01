# Bulls-Cows

A game developed in assembly to play bulls and cows against a computer.

This is the link for the project book - https://drive.google.com/file/d/1K_LcpZCV9hYvujIR98hF3AEh47jLJPfc/view?usp=sharing

To play you need to download DOSBox Portable and Assembly.
Then you will have to follow these steps:
1. go to the TASM folder in the AssemblyInstall and create a folder called BIN inside if it doesn't exist already.
2. Put the Bu_Co.asm file inside the BIN folder.
3. Open DOSBox.
4. Write there the following with enters between each command:
   a. tasm /zi Bu_Co.asm
   b. tlink /v Bu_Co.obj
   c. td Bu_Co
   d. press f9
   
5. Play and have fun!
