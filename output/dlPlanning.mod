/** Acquisition parameters */
int Nacquisitions = ...;
range Acquisitions = 1..Nacquisitions;
float AcquisitionVolumes[Acquisitions] = ...;
int AcquisitionPriority[Acquisitions] = ...;
int AcquisitionUserShare[Acquisitions] = ...;
float AcquisitionEndTime[Acquisitions] = ...;
string AcquisitionIds[Acquisitions] = ...;

/** Download Window parameters */
int NdownloadWindows = ...;
range DownloadWindows = 1..NdownloadWindows;
int DownloadWindowId[DownloadWindows] = ...;
float DownloadWindowStart[DownloadWindows] = ...;
float DownloadWindowEnd[DownloadWindows] = ...;

float DownloadSpeed = ...;

/** Required transition time between each pair of successive acquisitions windows */
float TransitionTimes[AcquisitionWindows][AcquisitionWindows] = ...;

/** File in which the result will be written */
string OutputFile = ...;

/** Boolean variable indicating whether an acquisition window is selected */
dvar int selectDownloads[Acquisitions] in 0..1;
/** next[a1][a2] = 1 when a1 is the selected acquisition window that follows a2 */
dvar int next[Acquisitions][Acquisitions] in 0..1;
/** Acquisition start time in each acquisition window */
dvar float startTime[a in Acquisitions] in AcquisitionEndTime[a]..inf;
/** Selected download window, zero means no window is selected */
dvar int SelectedDownloadWindow[Acquisitions] in 0..NdownloadWindows;
dexpr float Duration[a in DownloadWindows]=AcquisitionVolumes[a] / DownloadSpeed;

execute{
	cplex.tilim = 60; // 60 seconds
}

// maximize the number of acquisition windows selected
maximize sum(a in Acquisitions) selectDownloads[a] *
    AcquisitionPriority[a] * AcquisitionUserShare[a] * AcquisitionVolumes[a];

constraints {
	// an acquisition window is selected if and only if it has a (unique) precedessor and a (unique) successor in the plan
	forall(a1 in DownloadWindows){
		sum(a2 in DownloadWindows : a2 != a1) next[a1][a2] == selectDownloads[a1];
		sum(a2 in DownloadWindows : a2 != a1) next[a2][a1] == selectDownloads[a1];
		next[a1][a1] == 0;
	}

	// restriction of possible successive selected acquisition windows by using earliest and latest acquisition times
	forall(a1,a2 in AcquisitionWindows : a1 != a2 && EarliestStartTime[a1] + Duration[a1] >= LatestStartTime[a2]){
		next[a1][a2] == 0;
	}

	// temporal separation constraints between successive acquisition windows (big-M formulation)
	forall(a1,a2 in AcquisitionWindows : a1 != a2 && EarliestStartTime[a1] + Duration[a1] + TransitionTimes[a1][a2] < LatestStartTime[a2]){
		startTime[a1] + Duration[a1] + TransitionTimes[a1][a2]  <= startTime[a2]
                + (1-next[a1][a2])*(LatestStartTime[a1]+Duration[a1]+TransitionTimes[a1][a2]-EarliestStartTime[a2]);
	}

}

execute {
	var ofile = new IloOplOutputFile(OutputFile);
	for(var i=1; i <= DownloadWindows; i++) {
		if(selectDownloads[i] == 1){
			ofile.writeln(AcquisitionIds[i] + " " + SelectedDownloadWindow[i] + " " + startTime[i] + " " + (startTime[i]+Duration[i]));
		}
	}
}
