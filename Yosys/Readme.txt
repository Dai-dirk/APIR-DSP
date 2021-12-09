/***********How to run*****************/
First, adding the files in the folder "yosys-modified file" to the original Yosys
file, such as adding the files in the "passes" folder to the Yosys "passes" folder.

Second, install the Yosys as usual. 

After that, you can run the Yosys to synthesis the DSP block by using the following script:
1）read_verilog *test.v
2）synth_xilinx -flatten -family pirdsp -noiopad -noclkbuf
3）write_blif -true - vcc -false - gnd -undef - unconn -blackbox *test.blif

Finally, using the BLIF file to implement placement and routing.