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

/** File in which the result will be written */
string OutputFile = ...;

/** Boolean variable indicating whether an acquisition window is selected */
dvar int selectDownloads[Acquisitions] in 0..1;

/** Boolean variable indicating the chosen window for each acquisition*/
dvar int AcqDlWindow [Acquisitions][DownloadWindows] in 0..1;
dvar float DlTime[Acquisitions];




dexpr float Duration[a in DownloadWindows]=AcquisitionVolumes[a] / DownloadSpeed;

execute{
	cplex.tilim = 60; // 60 seconds
}

// maximize the number of acquisition windows selected
maximize sum(a in Acquisitions) selectDownloads[a] *
    AcquisitionPriority[a] * AcquisitionUserShare[a] * AcquisitionVolumes[a];

constraints {

	
	 forall(i in Acquisitions){
	 	// Acquisitions can't be split in two DownloadWindows
	 	sum(j in DownloadWindows) AcqDlWindow[i][j] == 1;
	 	
	 	forall(j in DownloadWindows) {
	 		// Acquition has to be within the window (Big M notation)
	 		// DlTime[i] >= DownloadWindowStart[j] if download is within the window
	 		DlTime[i] >= (DownloadWindowStart[j]*AcqDlWindow[i][j]);
	 		// DlTime[i] + Duration[i] <= DownloadWindowEnd[j]
	 		(DlTime[i] + Duration[i])* AcqDlWindow[i][j] <= DownloadWindowEnd[j];	 	
	 	}
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