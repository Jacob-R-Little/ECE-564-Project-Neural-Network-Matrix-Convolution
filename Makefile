export MY_UID :=your_unity_id

all : build-564-mem build-464-mem 


build-564-mem : 564/input_0/input_sram_564.dat 564/input_1/input_sram_564.dat 
build-464-mem : 464/input_0/input_sram_464.dat 464/input_1/input_sram_464.dat 

python3_latest.sif: 
	singularity pull --arch amd64 library://jasteve4/ece564/python3:latest

outputs/564_output0.yaml: python3_latest.sif
	singularity exec python3_latest.sif python3 scripts/generate_output.py inputs/input0.yaml outputs/564_output0.yaml

outputs/464_output0.yaml: python3_latest.sif
	singularity exec python3_latest.sif python3 scripts/generate_output.py inputs/input0.yaml outputs/464_output0.yaml

outputs/564_output1.yaml: python3_latest.sif
	singularity exec python3_latest.sif python3 scripts/generate_output.py inputs/input1.yaml outputs/564_output1.yaml

outputs/464_output1.yaml: python3_latest.sif
	singularity exec python3_latest.sif python3 scripts/generate_output.py inputs/input1.yaml outputs/464_output1.yaml

564/input_0/input_sram_564.dat: outputs/564_output0.yaml
	singularity exec python3_latest.sif python3 scripts/generate_mem_files.py inputs/input0.yaml outputs/564_output0.yaml ./564/input_0/

464/input_0/input_sram_464.dat: outputs/464_output0.yaml
	singularity exec python3_latest.sif python3 scripts/generate_mem_files.py inputs/input0.yaml outputs/464_output0.yaml ./464/input_0/

564/input_1/input_sram_564.dat: outputs/564_output1.yaml
	singularity exec python3_latest.sif python3 scripts/generate_mem_files.py inputs/input1.yaml outputs/564_output1.yaml ./564/input_1/

464/input_1/input_sram_464.dat: outputs/464_output1.yaml
	singularity exec python3_latest.sif python3 scripts/generate_mem_files.py inputs/input1.yaml outputs/464_output1.yaml ./464/input_1/

zip:
	zip -FSr ${MY_UID}.zip ./project_report ./rtl/*.v ./synthesis/*.tcl ./synthesis/gl/*.v ./synthesis/*.log ./synthesis/logs/*.log ./synthesis/reports/* ./run/transcript

unzip:
	unzip -o ${MY_UID}.zip

clean:
	rm -rf 464/input_0/* 464/input_1/* 564/input_0/* 564/input_1/* outputs/*


