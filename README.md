



# ECE464/564 Final Project
This document contains the instructions and commands to setup ECE464/564 final project directory. In the folder tree of this project, several ```Makefile```s are used to 

## Overview
- [Unzip](#unzip)
- [Testbench Setup](#testbench-setup)
- [Start Designing](#start-designing)
- [Synthesis](#synthesis)
- [Submission](#submission)
- [Appendix](#appendix)

## Unzip
Once you have placed ```project2022.zip``` at desired directory. Launch a terminal at that directory and use the following command to unzip.
```bash
unzip project2022.zip
```
You should find the unzipped project folder ```projectFall2022/```

## Testbench Setup
### Generate input, kernel, and weights in the test fixture

Change directory to ```projectFall2022/```
```bash
cd projectFall2022
```
and use the following command to generate the test environment.
```bash
make all
```

## Start Designing
### Setup script

```projectFall2022/setup.sh``` is provided to load Modelsim and Synopsys

To source the script:
```bash
source setup.sh
```
This script also enables you to <kbd>Tab</kbd> complete ```make``` commands

### Project description

The document is located in ```projectFall2022/project_specification/```

### Where to put your design

A Verilog file ```projectFall2022/rtl/dut.v``` is provided with all the ports already connected to the test fixture

### How to compile your design

To compile your design

Change directory to ```projectFall2022/run/``` 

```bash
make vlog-v
```

All the .v files in ```projectFall2022/rtl/``` will be compiled with this command.

### How to run your design

#### For ECE464
Run with Modelsim UI Extra:
```bash
make debug-464-extra
```
Run with Modelsim UI Base:
```bash
make debug-464-base
```
Run without UI(Faster) Extra:
```bash
make verify-464-extra
```
Run without UI(Faster) Base:
```bash
make verify-464-base
```
#### For ECE564
Run with Modelsim UI Extra:
```bash
make debug-564-extra
```
Run with Modelsim UI Base:
```bash
make debug-564-base
```
Run without UI(Faster) Extra:
```bash
make verify-564-extra
```
Run without UI(Faster) Base:
```bash
make verify-564-base
```

### How to compile and run the golden model
In case you still have doubt in how to interface with the test fixture, a golden model is provided for your reference.

To compile the golden model, change directory to ```projectFall2022/run/```

```bash
make vlog-golden
```
The run commands are the same ```make debug-564``` for 564 project and ```make debug-464``` for 464 project

Make sure to recompile your own design with the following command when you wish to switch back
```bash
make vlog-v
```
The golden model is only intended to give you an example of how to interface with the SRAMs
and is not synthesizable by design. 

## Synthesis

Once you have a functional design, you can synthesize it in ```projectFall2022/synthesis/```

### Synthesis Command
The following command will synthesize your design with a default clock period of 10 ns
```bash
make all
```
### Clock Period

To run synthesis with a different clock period
```bash
make all CLOCK_PER=<YOUR_CLOCK_PERIOD>
```
For example, the following command will set the target clock period to 4 ns.

```bash
make all CLOCK_PER=4
```

### Synthesis Reports
You can find your timing report and area report in ```projectFall2022/synthesis/reports/```

## Submission
### Project Report

Place your report file in ```projectFall2022/project_report/```

### Zip for submission

To generate the zip file for submission

change directory to ```projectFall2022/``` and use the following command

```bash
make zip MY_UID=<your_unity_id>
```

For example, if your unity ID is "jdoe12", you should enter the following command when generating the .zip file for submission.
```bash
make zip MY_UID=jdoe12
```
You will find the generated zip file in ```projectFall2022/``` 

### Check before you submit

Please check your zip file and make sure all the files are present for submission

It's recommended to download a fresh copy of the project directory and place the zip file in the root of the copy

The following command will restore the submission file to the directory
```bash
make unzip MY_UID=<your_unity_id>
```
You could then proceed to compile, run and synthesis your design and check if you misplaced any file that did not get included in the zip file.

### Submit your files
Upload the generated zip file to Moodle page


## Appendix

### Directory Rundown

You will find the following directories in ```projectFall2022/```

* ```464/``` 
  * Contains the .dat files for the input SRAMs used in 464 project
* ```564/``` 
  * Contains the .dat files for the input SRAMs used in 564 project
* ```golden_model/``` 
  * Contains the reference behavior model for the project
  * The content in this directory is compiled instead when executing ```make vlog-golden``` in ```projectFall2022/run/```
* ```inputs/```
  * Contains the .yaml files used to generate the .dat files for all projects
* ```outputs/```
  * Contains the reference output files that can be used for debug
* ```project_report/```
  * Place your project report here before running ```make zip MY_UID=<your_unity_id>``` command
* ```project_specification/```
  * Contains the project specification document
* ```rtl/```
  * All .v files will be compiled when executing ```make vlog-v``` in ```projectFall2022/run/```
  * A template ```dut.v``` that interfaces with the test fixture is provided
* ```run/```
  * Contains the ```Makefile``` to compile and simulate the design
* ```scripts/```
  * Contains the python script that generates the reference output
* ```synthesis/```
  * The directory you will use to synthesize your design
  * Synthesis reports will be exported to ```synthesis/reports/```
  * Synthesized netlist will be generated to ```synthesis/gl/```
* ```testbench/```
  * Contains the test fixture of the project


