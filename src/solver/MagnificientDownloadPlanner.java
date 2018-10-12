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


	public static void writeDatFile(SolutionPlan plan, String datFilename, Satellite sat)
			throws IOException{
		// generate OPL data (only for the satellite selected)
		PrintWriter writer = new PrintWriter(new BufferedWriter(
				new FileWriter(datFilename, false)));

		PlanningProblem pb = plan.pb;

		// Make a list of all acquisitions, filtered for our current sat
		List<Acquisition> acqlist = new ArrayList<Acquisition>();
		acqlist.addAll(plan.plannedAcquisitions);
		acqlist.addAll(pb.recordedAcquisitions);

		// Remove all acquisition for other satellites
		List<Acquisition> acqlist2 = new ArrayList<Acquisition>();
		for(int i = 0; i < acqlist.size(); i++) {
			Acquisition a = acqlist.get(i);
			if(a.getSatellite().equals(sat)) {
				acqlist2.add(a);
			}
		}
		acqlist = acqlist2;

        // Write download speed
        writer.write("DownloadSpeed = " + Params.downlinkRate + "\n");

		// Write the number of acquisitions
		writer.write("Nacquisitions = " + acqlist.size() + ";\n");

		// Write AcquisitionVolumes
		writeModelParameter(writer, acqlist, "AcquisitionVolumes",
				(Object a) -> Long.toString(((Acquisition) a).getVolume()));

		// Write priorities
		writeModelParameter(writer, acqlist, "AcquisitionPriority",
				(Object a) -> Integer.toString(((Acquisition) a).priority));

		// Write AcquisitionUser
		writeModelParameter(writer, acqlist, "AcquisitionUserShare",
				(Object a) -> Double.toString(((Acquisition) a).user.quota));

		// Write time finished
		writeModelParameter(writer, acqlist, "AcquisitionEndTime",
				(Object a) -> Double.toString(((Acquisition) a).getAcquisitionTime()));

		// Write ids
		writeModelParameter(writer, acqlist, "AcquisitionIds",
				(Object a) -> {
					if (a instanceof CandidateAcquisition) {
						return "CAND " + Integer.toString(((CandidateAcquisition) a).idx);
					}
					else {
						return "REC " + Integer.toString(((RecordedAcquisition) a).idx);
					}
				});
		writer.write("\n");

		// Write download windows
		List<DownloadWindow> ldw = pb.downloadWindows;
		List<DownloadWindow> ldw2 = new ArrayList<DownloadWindow>();

		for(int i = 0; i < ldw.size(); i++) {
			DownloadWindow w = ldw.get(i);
			if(ldw.get(i).satellite.name.equals(sat.name)) {
				ldw2.add(w);
			}
		}
		ldw = ldw2;

		// Write windows
		writer.write("NdownloadWindows = " + ldw.size() + ";\n");
		writeModelParameter(writer, ldw, "DownloadWindowId",
				(Object a) -> Integer.toString(((DownloadWindow) a).idx));

		writeModelParameter(writer, ldw, "DownloadWindowStart",
				(Object a) -> Double.toString(((DownloadWindow) a).start));

		writeModelParameter(writer, ldw, "DownloadWindowEnd",
				(Object a) -> Double.toString(((DownloadWindow) a).end));

		writer.write("\nOutputFile = \"solutionDlPlan_" + sat.name + ".txt\";");

		// close the writer
		writer.flush();
		writer.close();
	}

	// Write a single model parameter
	public static void writeModelParameter(PrintWriter writer, List l,
			String name, getterFunction getParameter) throws IOException {

		writer.write(name + "=[");
		if(!l.isEmpty()){
			// "" + is for type conversion :-D
			writer.write("" + getParameter.f(l.get(0)));
			for(int i=1; i < l.size(); i++) {
				writer.write("," + getParameter.f(l.get(i)));
			}
		}
		writer.write("];\n");
	}

	public interface getterFunction{
		public String f(Object o);
	}

	public static void main(String[] args) throws XMLStreamException, FactoryConfigurationError, IOException, ParseException{
        System.out.print("Starting Magnificient Download Planner... ");


		ProblemParserXML parser = new ProblemParserXML();
		PlanningProblem pb = parser.read(Params.systemDataFile,Params.planningDataFile);
		SolutionPlan plan = new SolutionPlan(pb);
		plan.readAcquisitionPlan("output/solutionAcqPlan_SAT1.txt");
		plan.readAcquisitionPlan("output/solutionAcqPlan_SAT2.txt");

		for (Satellite sat : pb.satellites) {
			writeDatFile(plan, "output/download_data_" + sat.name + ".dat", sat);
		}
        System.out.println("done!");
	}

}
