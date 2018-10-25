OPL=oplrun

# Java prefix, options: Bad, Single, Dual
JP=Single
# Model prefix for acquisition: acq, singleAcq, dualAcq
MP=singleAcq

all: output/downloadPlan.txt

# Java compiling
bin/%.class: src/%.java
	find src -name '*.java' -not -name 'PlanViewer.java' > sources.txt
	javac @sources.txt -d bin
	rm sources.txt

# Java acquisition planner
output/acqPlanning_SAT1.dat: bin/solver/$(JP)DownloadPlanner.class
	java -cp bin solver.$(JP)AcquisitionPlanner

# Acquisition optimisation
output/solutionAcqPlan_SAT1.txt: output/acqPlanning_SAT1.dat output/$(MP)Planning.mod
	cd output; $(OPL) $(MP)Planning.mod ../$<

output/solutionAcqPlan_SAT2.txt: output/acqPlanning_SAT1.dat output/$(MP)Planning.mod
	cd output; $(OPL) $(MP)Planning.mod ../$<

# MagnificientDownloadPlanner
output/download_data_SAT1.dat: output/solutionAcqPlan_SAT1.txt output/solutionAcqPlan_SAT2.txt bin/solver/MagnificientDownloadPlanner.class
	java -cp bin solver.MagnificientDownloadPlanner

# Download optimisation
output/solutionDlPlan_SAT1.txt: output/download_data_SAT1.dat output/dlPlanning.mod
	cd output; $(OPL) dlPlanning.mod download_data_SAT1.dat

output/solutionDlPlan_SAT2.txt: output/download_data_SAT2.dat output/dlPlanning.mod
	cd output; $(OPL) dlPlanning.mod download_data_SAT2.dat

output/downloadPlan.txt: output/solutionDlPlan_SAT1.txt output/solutionDlPlan_SAT2.txt
	cat output/solutionDlPlan_SAT*.txt > output/downloadPlan.txt

# Cleanup
clean:
	rm -rf output/*.txt output/download_data_SAT* output/acqPlanning* bin/*
