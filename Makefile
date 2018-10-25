OPL=oplrun

all: output/downloadPlan.txt

bin/%.class: src/%.java
	find src -name '*.java' -not -name 'PlanViewer.java' > sources.txt
	javac @sources.txt -d bin
	rm sources.txt

output/acqPlanning_SAT%.dat: bin/solver/BadDownloadPlanner.class
	java -cp bin solver.BadAcquisitionPlanner

output/solutionAcqPlan_SAT%.txt: output/acqPlanning_SAT%.dat output/acqPlanning.mod
	cd output; $(OPL) acqPlanning.mod ../$<

output/download_data_SAT%.dat: output/solutionAcqPlan_SAT%.txt bin/solver/MagnificientDownloadPlanner.class
	java -cp bin solver.MagnificientDownloadPlanner

output/solutionDlPlan_SAT%.txt: output/download_data_SAT%.dat output/dlPlanning.mod
	cd output; $(OPL) dlPlanning.mod ../$<

output/downloadPlan.txt: output/solutionDlPlan_SAT1.txt output/solutionDlPlan_SAT2.txt
	cat output/solutionDlPlan_SAT*.txt > output/downloadPlan.txt
