package solver;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import javax.xml.stream.FactoryConfigurationError;
import javax.xml.stream.XMLStreamException;

import params.Params;
import problem.Acquisition;
import problem.CandidateAcquisition;
import problem.DownloadWindow;
import problem.PlanningProblem;
import problem.RecordedAcquisition;
import problem.ProblemParserXML;
import problem.Satellite;
import problem.User;


/**
 * Class implementing a download planner which tries to insert downloads into the plan
 * by ordering acquisitions following an increasing order of their realization time, and by
 * considering download windows chronologically 
 * @author Liz Ramos, Morten Stabenau
 *
 */
public class MagnificientDownloadPlanner {

	
	public static void writeDatFile(SolutionPlan plan, String datFilename)
			throws IOException{
		// generate OPL data (only for the satellite selected)
		PrintWriter writer = new PrintWriter(new BufferedWriter(
				new FileWriter(datFilename, false)));
		
		PlanningProblem pb = plan.pb;
		
		// Write user shares
		writer.write("UserShare=[");
		if(!pb.users.isEmpty()){
			// "" + is for type conversion :-D
			writer.write("" + pb.users.get(0).quota);
			for(int i=1; i < pb.users.size(); i++) {
				writer.write("," + pb.users.get(i).quota);
			}
		}
		writer.write("];");
		
		// Make a list of all acquisitions
		List<Acquisition> acqlist = new ArrayList<Acquisition>();
		acqlist.addAll(plan.plannedAcquisitions);
		acqlist.addAll(pb.recordedAcquisitions);
		
		// Write AcquisitionVolumes
		writer.write("AcquisitionVolumes=[");
		if(!plan.plannedAcquisitions.isEmpty()){
			// "" + is for type conversion :-D
			writer.write("" + pb.users.get(0).quota);
			for(int i=1; i < pb.users.size(); i++) {
				writer.write("," + pb.users.get(i).quota);
			}
		}
		writer.write("];");
		
		// close the writer
		writer.flush();
		writer.close();	
	}
		
	public static void main(String[] args) throws XMLStreamException, FactoryConfigurationError, IOException, ParseException{
		ProblemParserXML parser = new ProblemParserXML(); 
		PlanningProblem pb = parser.read(Params.systemDataFile,Params.planningDataFile);
		SolutionPlan plan = new SolutionPlan(pb);
		plan.readAcquisitionPlan("output/solutionAcqPlan_SAT1.txt");
		plan.readAcquisitionPlan("output/solutionAcqPlan_SAT2.txt");
		writeDatFile(plan, "output/download_data_sat1.dat");		
	}
	
}
