package solver;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

import javax.xml.stream.FactoryConfigurationError;
import javax.xml.stream.XMLStreamException;

import params.Params;
import problem.AcquisitionWindow;
import problem.Acquisition;
import problem.CandidateAcquisition;
import problem.User;
import problem.PlanningProblem;
import problem.ProblemParserXML;
import problem.Satellite;
import java.util.Collections;
import java.util.Vector;
import java.lang.Math;

/**
 * Acquisition planner which solves the acquisition problem for each satellite separately,
 * and which only tries to maximize the number of acquisitions realized. To do this, this
 * planner generates OPL data files.
 * @author cpralet
 *
 */
public class DualAcquisitionPlanner {

  /**
   * Write a .dat file which represents the acquisition planning problem for a particular satellite
   * @param pb planning problem
   * @param satellite satellite for which the acquisition plan must be built
   * @param datFilename name of the .dat file generated
   * @param solutionFilename name of the file in which CPLEX solution will be written
   * @throws IOException
   */
  public static void writeDatFile(PlanningProblem pb, String datFilename, String solutionFilename) throws IOException{
    // generate OPL data (only for the satellite selected)
    PrintWriter writer = new PrintWriter(new BufferedWriter(new FileWriter(datFilename, false)));

    //write number of satellites
    int nSatellites = pb.satellites.size();
    writer.write("Nsatellites = " + nSatellites + ";");
    //get number of candidates
    int nCandidates = pb.candidateAcquisitions.size();
    writer.write("\nNcandidates = " + nCandidates + ";");
    // get all users
    List<User> Users = new ArrayList<User>();
    for(User a : pb.users){
    	Users.add(a);
	}
    
    // write the number of users
    int nUsers = Users.size();
    writer.write("\nNUsers = "+ nUsers + ";");

    // write the contribution for each user
    writer.write("\nUserContribution = [");
    if(!Users.isEmpty()){
    	writer.write(""+pb.users.get(0).quota);
    	for(int i=1;i<nUsers;i++){
    		writer.write(","+pb.users.get(i).quota);
    	}
    }
    writer.write("];");
    
    for(Satellite satellite : pb.satellites){
    	 // get all acquisition windows for this satellite
        List<AcquisitionWindow> acquisitionWindows = new ArrayList<AcquisitionWindow>();
    
	    for(CandidateAcquisition a : pb.candidateAcquisitions){
	      for(AcquisitionWindow w : a.acquisitionWindows){
	        if(w.satellite == satellite){
	          acquisitionWindows.add(w);
	        }
	      }
	    }

	    // write the number of acquisition windows
	    int nAcquisitionWindows = acquisitionWindows.size();
	    writer.write("\n\nNacquisitionWindows_"+ satellite.name + " = " + nAcquisitionWindows + ";");
		
		// write the user of each acquisition window
		writer.write("\nAcquisitionWindowUser_" + satellite.name + " = [");
		if(!acquisitionWindows.isEmpty()){
			writer.write(""+(acquisitionWindows.get(0).candidateAcquisition.user.idx + 1));
			for(int i=1;i<nAcquisitionWindows;i++){
				writer.write(","+(acquisitionWindows.get(i).candidateAcquisition.user.idx + 1));
			}
		}
		writer.write("];");
	    
	    /* write the number of candidate acquisitions
	    int nCandidateAcquisitions = pb.candidateAcquisitions.size();
	    writer.write("\nNcandidateAcquisitions = " + nCandidateAcquisitions + ";");*/
	
	    // write the index of each acquisition
	    writer.write("\nCandidateAcquisitionIdx_"+ satellite.name + " = [");
	    if(!acquisitionWindows.isEmpty()){
	      writer.write(""+acquisitionWindows.get(0).candidateAcquisition.idx);
	      for(int i=1;i<nAcquisitionWindows;i++){
	        writer.write(","+acquisitionWindows.get(i).candidateAcquisition.idx);
	      }
	    }
	    writer.write("];");
	    
	    
	    // write the contribution of user associated with acquisition window
	    writer.write("\nContribution_"+ satellite.name + " = [");
	    Vector<Double> Contribute = new Vector<Double>();
	    if(!acquisitionWindows.isEmpty()){
	      writer.write(""+acquisitionWindows.get(0).candidateAcquisition.user.quota);
	      Contribute.add(acquisitionWindows.get(0).candidateAcquisition.user.quota);
	      for(int i=1;i<nAcquisitionWindows;i++){
	        writer.write(","+acquisitionWindows.get(i).candidateAcquisition.user.quota);
	        Contribute.add(acquisitionWindows.get(i).candidateAcquisition.user.quota);
	      }
	    }
	    writer.write("];");
	    
	    // write the volume of the data of each candidate acquisition
	    writer.write("\nVolume_"+ satellite.name + " = [");
	    if(!acquisitionWindows.isEmpty()){
	      writer.write(""+acquisitionWindows.get(0).volume);
	      for(int i=1;i<nAcquisitionWindows;i++){
	        writer.write(","+acquisitionWindows.get(i).volume);
	      }
	    }
	    writer.write("];");
	    
	    // write the index of each acquisition window
	    writer.write("\nAcquisitionWindowIdx_"+ satellite.name + " = [");
	    if(!acquisitionWindows.isEmpty()){
	      writer.write(""+acquisitionWindows.get(0).idx);
	      for(int i=1;i<nAcquisitionWindows;i++){
	        writer.write(","+acquisitionWindows.get(i).idx);
	      }
	    }
	    writer.write("];");
	
	    // write the earliest acquisition start time associated with each acquisition window
	    writer.write("\nEarliestStartTime_"+ satellite.name + " = [");
	    if(!acquisitionWindows.isEmpty()){
	      writer.write(""+acquisitionWindows.get(0).earliestStart);
	      for(int i=1;i<nAcquisitionWindows;i++){
	        writer.write(","+acquisitionWindows.get(i).earliestStart);
	      }
	    }
	    writer.write("];");
	
	    // write the latest acquisition start time associated with each acquisition window
	    writer.write("\nLatestStartTime_"+ satellite.name + " = [");
	    if(!acquisitionWindows.isEmpty()){
	      writer.write(""+acquisitionWindows.get(0).latestStart);
	      for(int i=1;i<nAcquisitionWindows;i++){
	        writer.write(","+acquisitionWindows.get(i).latestStart);
	      }
	    }
	    writer.write("];");
	
	    // write the duration of acquisitions in each acquisition window
	    writer.write("\nDuration_"+ satellite.name + " = [");
	    if(!acquisitionWindows.isEmpty()){
	      writer.write(""+acquisitionWindows.get(0).duration);
	      for(int i=1;i<nAcquisitionWindows;i++){
	        writer.write(","+acquisitionWindows.get(i).duration);
	      }
	    }
	    writer.write("];");
	    
	    ///////////////////////////////////////////////////////////////////////////
	    
	    // write the priority of ... in each candidateAcquisitions
	    writer.write("\nPriority_"+ satellite.name + " = [");
	    if(!acquisitionWindows.isEmpty()){
	      writer.write(""+acquisitionWindows.get(0).candidateAcquisition.priority);
	      for(int i=1;i<nAcquisitionWindows;i++){
	        writer.write(","+acquisitionWindows.get(i).candidateAcquisition.priority);
	      }
	    }
	    writer.write("];");
	    
	    // write the cloud probability in each acquisition window
	    writer.write("\nCloudProba_"+ satellite.name + " = [");
	    if(!acquisitionWindows.isEmpty()){
	      writer.write(""+acquisitionWindows.get(0).cloudProba);
	      for(int i=1;i<nAcquisitionWindows;i++){
	        writer.write(","+acquisitionWindows.get(i).cloudProba);
	      }
	    }
	    writer.write("];");
	    
	    // write the ZenithAngle in each acquisition window
	    writer.write("\nZenithAngle_"+ satellite.name + " = [");
	    Vector<Double> Zenith = new Vector<Double>();
	    if(!acquisitionWindows.isEmpty()){
	      writer.write(""+acquisitionWindows.get(0).zenithAngle);
	      Zenith.add(acquisitionWindows.get(0).zenithAngle);
	      for(int i=1;i<nAcquisitionWindows;i++){
	        writer.write(","+acquisitionWindows.get(i).zenithAngle);
	        Zenith.add(acquisitionWindows.get(i).zenithAngle);
	      }
	    }
	    writer.write("];");
	    
	    // Zenith Angle methods: norm or cos
	    writer.write("\nNormZenithAngle_"+ satellite.name + " = [");
	    if(!acquisitionWindows.isEmpty()){
	      Double minZenith = Collections.min(Zenith);
	      Double maxZenith = Collections.max(Zenith);
	      Double divRangeZen = 1/(maxZenith - minZenith);
	      
	      writer.write(""+(acquisitionWindows.get(0).zenithAngle - minZenith)*divRangeZen);
	      for(int i=1;i<nAcquisitionWindows;i++){
	        writer.write(","+(acquisitionWindows.get(i).zenithAngle - minZenith)*divRangeZen);
	      }
	    }
	    writer.write("];");
	    
	    // write the RollAngle in each acquisition window
	    writer.write("\nRollAngle_"+ satellite.name + " = [");
	    Vector<Double> RollAngles = new Vector<Double>();
	    if(!acquisitionWindows.isEmpty()){
	      writer.write(""+acquisitionWindows.get(0).rollAngle);
	      RollAngles.add(acquisitionWindows.get(0).rollAngle);
	      for(int i=1;i<nAcquisitionWindows;i++){
	        writer.write(","+acquisitionWindows.get(i).rollAngle);
	        RollAngles.add(acquisitionWindows.get(i).rollAngle);
	      }
	    }
	    writer.write("];");
	    
	    ////////////////////////////////////////////////////////////////////////////
	    
	
	    // write the transition times between acquisitions in acquisition windows
	    writer.write("\nTransitionTimes_"+ satellite.name + " = [");
	    //Vector<Double> NormTrans = new Vector<Double>();
	    for(int i=0;i<nAcquisitionWindows;i++){
	      AcquisitionWindow a1 = acquisitionWindows.get(i);
	      if(i != 0) writer.write(",");
	      writer.write("\n\t[");
	      for(int j=0;j<nAcquisitionWindows;j++){
	        if(j != 0) writer.write(",");
	        writer.write(""+pb.getTransitionTime(a1, acquisitionWindows.get(j)));
	      }  
	      writer.write("]");
	    }
	    writer.write("\n];");
	    
	    Double minRoll = Collections.min(RollAngles);
		Double maxRoll = Collections.max(RollAngles);
		Double divRange = 1/(maxRoll - minRoll);
		
	    Double maxTrans = (maxRoll - minRoll)/Params.meanRotationSpeed;
	    Double divRangeTrans = 1/maxTrans;
	    
	    // write the normalised transition times between acquisitions in acquisition windows
	    writer.write("\nNormTransitionTimes_"+ satellite.name + " = [");
	    
	    for(int i=0;i<nAcquisitionWindows;i++){
	      
	      AcquisitionWindow a1 = acquisitionWindows.get(i);
	      if(i != 0) writer.write(",");
	      writer.write("\n\t[");
	      for(int j=0;j<nAcquisitionWindows;j++){
	        if(j != 0) writer.write(",");
	        writer.write(""+pb.getTransitionTime(a1, acquisitionWindows.get(j))*divRangeTrans);
	      }  
	      writer.write("]");
	    }
	    writer.write("\n];");

    
    // write the name of the file in which the result will be written
    writer.write("\nOutputFile_" + satellite.name + " = \"" + solutionFilename +satellite.name+".txt\";");
    String solutionCaracFilename = "solutionAcqPlan_Carac_"+satellite.name+".txt";
    writer.write("\nCarac_" + satellite.name + " = \"" + solutionCaracFilename + "\";");
    String solutionCritereFilename = "solutionAcqPlan_Critere_"+satellite.name+".txt";
    writer.write("\nCritere_" + satellite.name + " = \"" + solutionCritereFilename + "\";");
    }
    
    // close the writer
    writer.flush();
    writer.close();  
  }
  

  public static void main(String[] args) throws XMLStreamException, FactoryConfigurationError, IOException{
    ProblemParserXML parser = new ProblemParserXML();
    PlanningProblem pb = parser.read(Params.systemDataFile,Params.planningDataFile);
    pb.printStatistics();
    //for(Satellite satellite : pb.satellites){
    String datFilename = "output/acqPlanning_UNI.dat";
    String solutionFilename = "solutionAcqPlan";
    writeDatFile(pb, datFilename, solutionFilename);
    }
}
