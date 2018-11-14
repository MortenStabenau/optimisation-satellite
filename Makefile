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
output/acqPlanning_SAT%.dat: bin/solver/$(JP)AcquisitionPlanner.class
	java -cp bin solver.$(JP)AcquisitionPlanner

# Acquisition optimisation
output/solutionAcqPlan_SAT%.txt: output/acqPlanning_SAT%.dat output/$(MP)Planning.mod
	cd output; $(OPL) $(MP)Planning.mod ../$<

# MagnificientDownloadPlanner
output/download_data_SAT%.dat: output/solutionAcqPlan_SAT%.txt bin/solver/MagnificientDownloadPlanner.class
	java -cp bin solver.MagnificientDownloadPlanner

# Download optimisation
output/solutionDlPlan_SAT%.txt: output/download_data_SAT%.dat output/dlPlanning.mod
	cd output; $(OPL) dlPlanning.mod ../$<

output/downloadPlan.txt: output/solutionDlPlan_SAT1.txt output/solutionDlPlan_SAT2.txt
	cat output/solutionDlPlan_SAT*.txt > output/downloadPlan.txt

view:
	java -cp lib/jcommon-1.0.23.jar:lib/jfreechart-1.0.19.jar:bin solver.PlanViewer

# Cleanup
clean:
	rm -rf output/*.txt output/download_data_SAT* output/acqPlanning_SAT* bin/*
