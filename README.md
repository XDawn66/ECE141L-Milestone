# ECE141L-Milestone

## To run our programs
```
git clone https://github.com/XDawn66/ECE141L-Milestone.git
```
Then
```
cd ECE141L-Milestone
```
- Go to the folder for the program you want to run and copy 1. the look up table .txt 2.machine code .txt 3.testbench
- Put them in to the hardware folder
- Change the file names in the InstROM.sv and JLUT.sv to the matching .txt files
- Next, Create a new project using Modelsim.
- After you create the project, put all our hardware .sv into the project then complie.

## To synthesize the hardware

- Create a new project at Quartus, load all our hardware from the hardware folder
- Set the top level as "Top"
- Then complie
- After complied, you can check our hardware at STL viewer

## To run the assember
- open the assembler.py
- at the bottom, change the conver function with the assembly program you want to convert to the machine code
- put a name for you machine code and for the lookup table
- run:
  ```
  python assembler.py
  ```
