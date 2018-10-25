/** Number of satellites*/
int Nsatellites = ...;
/** Number of candidates*/
int Ncandidates = ...;
/** Candidate range */
range Candidates = 0..(Ncandidates-1);
/** Number of users */
int NUsers = ...;
/** Users range */
range Users = 1..NUsers;
/** Contribution of the user */
float UserContribution[Users] = ...;

//---------------------------------------------------------------------------------------------//
//																							   //
//																							   //
// Parameters for SAT1																		   //
//																							   //
//---------------------------------------------------------------------------------------------//

/** Number of acquisition opportunities */
int NacquisitionWindows_SAT1= ...;
/** Acquisition range */
range AcquisitionWindows_SAT1= 1..NacquisitionWindows_SAT1;
range AcquisitionWindowsPlusZero_SAT1= 0..NacquisitionWindows_SAT1;

/** User of each window */
int AcquisitionWindowUser_SAT1[AcquisitionWindows_SAT1] = ...;
/** Index of the acquisition in the list of candidate acquisitions of the problem */
int CandidateAcquisitionIdx_SAT1[AcquisitionWindows_SAT1] = ...;
/** Index of the acquisition window in the list of windows associated with the same candidate acquisition */
int AcquisitionWindowIdx_SAT1[AcquisitionWindows_SAT1] = ...;

/** Earliest start time associated with each acquisition window */
float EarliestStartTime_SAT1[AcquisitionWindows_SAT1] = ...;
/** Latest start time associated with each acquisition window */
float LatestStartTime_SAT1[AcquisitionWindows_SAT1] = ...;
/** Acquisition duration associated with each acquisition window */
float Duration_SAT1[AcquisitionWindows_SAT1] = ...;

// Import the new variables
int Priority_SAT1[AcquisitionWindows_SAT1] = ...; 	// 0 = most important ; 1 = less important
float CloudProba_SAT1[AcquisitionWindows_SAT1] = ...; 	// Probability of clouds belongs to R [0, 1]
float ZenithAngle_SAT1[AcquisitionWindows_SAT1] = ...;
float NormZenithAngle_SAT1[AcquisitionWindows_SAT1] = ...; //float cosZenithAngle[AcquisitionWindows] = ...;
float RollAngle_SAT1[AcquisitionWindows_SAT1] = ...;
float Contribution_SAT1[AcquisitionWindows_SAT1]= ...;
int Volume_SAT1[AcquisitionWindows_SAT1] = ...;

/** Required transition time between each pair of successive acquisitions windows */
float TransitionTimes_SAT1[AcquisitionWindows_SAT1][AcquisitionWindows_SAT1] = ...;
float NormTransitionTimes_SAT1[AcquisitionWindows_SAT1][AcquisitionWindows_SAT1] = ...;

/** File in which the result will be written */
string OutputFile_SAT1= ...;
string Carac_SAT1 = ...;
string Critere_SAT1 = ...;

/** Boolean variable indicating whether an acquisition window is selected */
dvar int selectAcq_SAT1[AcquisitionWindowsPlusZero_SAT1] in 0..1;
/** next[a1][a2] = 1 when a1 is the selected acquisition window that follows a2 */
dvar int next_SAT1[AcquisitionWindowsPlusZero_SAT1][AcquisitionWindowsPlusZero_SAT1] in 0..1;
/** Acquisition start time in each acquisition window */
dvar float+ startTime_SAT1[a in AcquisitionWindows_SAT1] in EarliestStartTime_SAT1[a]..LatestStartTime_SAT1[a];

//---------------------------------------------------------------------------------------------//
//																							   //
//																							   //
// Parameters for SAT2																		   //
//																							   //
//---------------------------------------------------------------------------------------------//

/** Number of acquisition opportunities */
int NacquisitionWindows_SAT2 = ...;
/** Acquisition range */
range AcquisitionWindows_SAT2 = 1..NacquisitionWindows_SAT2;
range AcquisitionWindowsPlusZero_SAT2 = 0..NacquisitionWindows_SAT2;

/** User of each window */
int AcquisitionWindowUser_SAT2[AcquisitionWindows_SAT2] = ...;
/** Index of the acquisition in the list of candidate acquisitions of the problem */
int CandidateAcquisitionIdx_SAT2[AcquisitionWindows_SAT2] = ...;
/** Index of the acquisition window in the list of windows associated with the same candidate acquisition */
int AcquisitionWindowIdx_SAT2[AcquisitionWindows_SAT2] = ...;

/** Earliest start time associated with each acquisition window */
float EarliestStartTime_SAT2[AcquisitionWindows_SAT2] = ...;
/** Latest start time associated with each acquisition window */
float LatestStartTime_SAT2[AcquisitionWindows_SAT2] = ...;
/** Acquisition duration associated with each acquisition window */
float Duration_SAT2[AcquisitionWindows_SAT2] = ...;

// Import the new variables
int Priority_SAT2[AcquisitionWindows_SAT2] = ...; 	// 0 = most important ; 1 = less important
float CloudProba_SAT2[AcquisitionWindows_SAT2] = ...; 	// Probability of clouds belongs to R [0, 1]
float ZenithAngle_SAT2[AcquisitionWindows_SAT2] = ...;
float NormZenithAngle_SAT2[AcquisitionWindows_SAT2] = ...; //float cosZenithAngle[AcquisitionWindows] = ...;
float RollAngle_SAT2[AcquisitionWindows_SAT2] = ...;
float Contribution_SAT2[AcquisitionWindows_SAT2]= ...;
int Volume_SAT2[AcquisitionWindows_SAT2] = ...;

/** Required transition time between each pair of successive acquisitions windows */
float TransitionTimes_SAT2[AcquisitionWindows_SAT2][AcquisitionWindows_SAT2] = ...;
float NormTransitionTimes_SAT2[AcquisitionWindows_SAT2][AcquisitionWindows_SAT2] = ...;

/** File in which the result will be written */
string OutputFile_SAT2 = ...;
string Carac_SAT2 = ...;
string Critere_SAT2 = ...;

/** Boolean variable indicating whether an acquisition window is selected */
dvar int selectAcq_SAT2[AcquisitionWindowsPlusZero_SAT2] in 0..1;
/** next[a1][a2] = 1 when a1 is the selected acquisition window that follows a2 */
dvar int next_SAT2[AcquisitionWindowsPlusZero_SAT2][AcquisitionWindowsPlusZero_SAT2] in 0..1;
/** Acquisition start time in each acquisition window */
dvar float+ startTime_SAT2[a in AcquisitionWindows_SAT2] in EarliestStartTime_SAT2[a]..LatestStartTime_SAT2[a];

execute{
	cplex.tilim = 10;//60*2; // 60 seconds
}

// weights (somme = 1)
float W1 = 12./24; //0.5;
float W2 = 3./24; //0.125;
float W3 = 6./24; //0.25;
float W4 = 2./24; //0.0625;
float W5 = 1./24; //0.015625;


//Criteria definition
maximize ( ((sum(a in AcquisitionWindows_SAT1) (( W1 
					+ W2*(1-CloudProba_SAT1[a]) 
					+ W3*(1-Priority_SAT1[a])
					+ W4*(1-NormZenithAngle_SAT1[a]))*selectAcq_SAT1[a])
					+ W5*( sum(a, b in AcquisitionWindows_SAT1) ( ((1-NormTransitionTimes_SAT1[a][b])*next_SAT1[a][b] )*selectAcq_SAT1[a])) ) 
				+
			(sum(a in AcquisitionWindows_SAT2) (( W1 
					+ W2*(1-CloudProba_SAT2[a]) 
					+ W3*(1-Priority_SAT2[a])
					+ W4*(1-NormZenithAngle_SAT2[a]))*selectAcq_SAT2[a])
					+ W5*( sum(a, b in AcquisitionWindows_SAT2) ( ((1-NormTransitionTimes_SAT2[a][b])*next_SAT2[a][b] )*selectAcq_SAT2[a])) )) 
					/ ((W1+W2+W3+W4+W5)*(NacquisitionWindows_SAT1 + NacquisitionWindows_SAT2))
					);
					
constraints {
	
	//---------------------------------------------------------------------------------------------//
	//																							   //
	//																							   //
	// Constraints for SAT1																		   //
	//																							   //
	//---------------------------------------------------------------------------------------------//
	
	// default selection of the dummy acquisition window numbered by 0
	selectAcq_SAT1[0] == 1;
	// an acquisition window is selected if and only if it has a (unique) precedessor and a (unique) successor in the plan
	forall(a1 in AcquisitionWindowsPlusZero_SAT1){
		sum(a2 in AcquisitionWindowsPlusZero_SAT1 : a2 != a1) next_SAT1[a1][a2] == selectAcq_SAT1[a1];
		sum(a2 in AcquisitionWindowsPlusZero_SAT1 : a2 != a1) next_SAT1[a2][a1] == selectAcq_SAT1[a1];
		next_SAT1[a1][a1] == 0;
	}

	// restriction of possible successive selected acquisition windows by using earliest and latest acquisition times
	forall(a1,a2 in AcquisitionWindows_SAT1 : a1 != a2 && EarliestStartTime_SAT1[a1] + Duration_SAT1[a1] + TransitionTimes_SAT1[a1][a2] >= LatestStartTime_SAT1[a2]){
		next_SAT1[a1][a2] == 0;
	}

	// temporal separation constraints between successive acquisition windows (big-M formulation)
	forall(a1,a2 in AcquisitionWindows_SAT1 : a1 != a2 && EarliestStartTime_SAT1[a1] + Duration_SAT1[a1] + TransitionTimes_SAT1[a1][a2] < LatestStartTime_SAT1[a2]){
		startTime_SAT1[a1] + Duration_SAT1[a1] + TransitionTimes_SAT1[a1][a2]  <= startTime_SAT1[a2] 
                + (1-next_SAT1[a1][a2])*(LatestStartTime_SAT1[a1]+Duration_SAT1[a1]+TransitionTimes_SAT1[a1][a2]-EarliestStartTime_SAT1[a2]);
	}
	
	//---------------------------------------------------------------------------------------------//
	//																							   //
	//																							   //
	// Constraints for SAT2																		   //
	//																							   //
	//---------------------------------------------------------------------------------------------//
	
	// default selection of the dummy acquisition window numbered by 0
	selectAcq_SAT2[0] == 1;
	// an acquisition window is selected if and only if it has a (unique) precedessor and a (unique) successor in the plan
	forall(a1 in AcquisitionWindowsPlusZero_SAT2){
		sum(a2 in AcquisitionWindowsPlusZero_SAT2 : a2 != a1) next_SAT2[a1][a2] == selectAcq_SAT2[a1];
		sum(a2 in AcquisitionWindowsPlusZero_SAT2 : a2 != a1) next_SAT2[a2][a1] == selectAcq_SAT2[a1];
		next_SAT2[a1][a1] == 0;
	}

	// restriction of possible successive selected acquisition windows by using earliest and latest acquisition times
	forall(a1,a2 in AcquisitionWindows_SAT2 : a1 != a2 && EarliestStartTime_SAT2[a1] + Duration_SAT2[a1] + TransitionTimes_SAT2[a1][a2] >= LatestStartTime_SAT2[a2]){
		next_SAT2[a1][a2] == 0;
	}

	// temporal separation constraints between successive acquisition windows (big-M formulation)
	forall(a1,a2 in AcquisitionWindows_SAT2 : a1 != a2 && EarliestStartTime_SAT2[a1] + Duration_SAT2[a1] + TransitionTimes_SAT2[a1][a2] < LatestStartTime_SAT2[a2]){
		startTime_SAT2[a1] + Duration_SAT2[a1] + TransitionTimes_SAT2[a1][a2]  <= startTime_SAT2[a2] 
                + (1-next_SAT2[a1][a2])*(LatestStartTime_SAT2[a1]+Duration_SAT2[a1]+TransitionTimes_SAT2[a1][a2]-EarliestStartTime_SAT2[a2]);
	}
		
	//---------------------------------------------------------------------------------------------//
	//																							   //
	//																							   //
	// Shared constraints																		   //
	//																							   //
	//---------------------------------------------------------------------------------------------//
	
	// New constraints
	// Guarantee share of acquisitions according to contribution
	forall(u in Users){
		sum(a in AcquisitionWindows_SAT1 : AcquisitionWindowUser_SAT1[a] == u) selectAcq_SAT1[a] + 
		sum(a in AcquisitionWindows_SAT2 : AcquisitionWindowUser_SAT2[a] == u) selectAcq_SAT2[a]
		>=
		(UserContribution[u] - 0.05) *
		(sum(b in AcquisitionWindows_SAT1) selectAcq_SAT1[b] + sum(b in AcquisitionWindows_SAT2) selectAcq_SAT2[b]);									
	}
	// Guarantee no candidate is captured more than once
	forall(c in Candidates) {
			sum(a in AcquisitionWindows_SAT1 : CandidateAcquisitionIdx_SAT1[a] == c) selectAcq_SAT1[a]
			+
			sum(a in AcquisitionWindows_SAT2 : CandidateAcquisitionIdx_SAT2[a] == c) selectAcq_SAT2[a]
			<= 1;
	}
	
}

execute {

	//---------------------------------------------------------------------------------------------//
	//																							   //
	//																							   //
	// Results output SAT1																		   //
	//																							   //
	//---------------------------------------------------------------------------------------------//

	var ofile = new IloOplOutputFile(OutputFile_SAT1);
	for(var i=1; i <= NacquisitionWindows_SAT1; i++) { 
		if(selectAcq_SAT1[i] == 1){
			ofile.writeln(CandidateAcquisitionIdx_SAT1[i] + " " + AcquisitionWindowIdx_SAT1[i] + " " + startTime_SAT1[i] + " " + (startTime_SAT1[i]+Duration_SAT1[i]));
		}
	}
	
	//---------------------------------------------------------------------------------------------//
	//																							   //
	//																							   //
	// Results output SAT2																		   //
	//																							   //
	//---------------------------------------------------------------------------------------------//
	
	var ofile = new IloOplOutputFile(OutputFile_SAT2);
	for(var i=1; i <= NacquisitionWindows_SAT2; i++) { 
		if(selectAcq_SAT2[i] == 1){
			ofile.writeln(CandidateAcquisitionIdx_SAT2[i] + " " + AcquisitionWindowIdx_SAT2[i] + " " + startTime_SAT2[i] + " " + (startTime_SAT2[i]+Duration_SAT2[i]));
		}
	}
}
