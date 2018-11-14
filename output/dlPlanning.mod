/** Acquisition parameters */
int Nacquisitions = ...;
range Acquisitions = 1..Nacquisitions;

float AcquisitionVolumes[Acquisitions] = ...;
int AcquisitionPriority[Acquisitions] = ...;
float AcquisitionUserShare[Acquisitions] = ...;
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

/** Boolean variable indicating the chosen window for each acquisition*/
dvar int AcqDlWindow [Acquisitions][DownloadWindows] in 0..1;

/* Start of the download of an acquisition */
dvar float DlTime[Acquisitions];

/* Order of the acquisitions, if next(a1, a2) = 1 that means that a1 is
 * directly before a2 */
dvar int next[Acquisitions][Acquisitions] in 0..1;

/* Is this acquisition the last one to be downloaded? This is needed because it
 * is a special case in the next matrix */
dvar int last[Acquisitions] in 0..1;

dexpr float Duration[a in Acquisitions]=AcquisitionVolumes[a] / DownloadSpeed;
dexpr int AcqTaken[a in Acquisitions]= sum(d in DownloadWindows) AcqDlWindow[a][d];

execute{
    cplex.tilim = 60; // 60 seconds
}

// maximize the "importance" of the downloaded windows
/*maximize sum(a in Acquisitions) selectDownloads[a] *
    AcquisitionPriority[a] * AcquisitionUserShare[a] * AcquisitionVolumes[a];
*/
maximize sum(a in Acquisitions) sum(d in DownloadWindows) AcqDlWindow[a][d] *
    (2-AcquisitionPriority[a]) * AcquisitionUserShare[a] * AcquisitionVolumes[a];

constraints {
    forall(a in Acquisitions){
        // Acquisitions can't be split in two DownloadWindows
        sum(d in DownloadWindows) AcqDlWindow[a][d] <= 1;

        forall(d in DownloadWindows) {
            // Acquition has to be within the window (Big M notation)
            // DlTime[a] >= DownloadWindowStart[d] if download is within the
            // window. Check beginning of window:
            DlTime[a] >= DownloadWindowStart[d]*AcqDlWindow[a][d];

            // Check end of window:
            AcqDlWindow[a][d] == 1 => DlTime[a] + Duration[a] <=
                DownloadWindowEnd[d];
        }

        // Acquisitions can't overlap
        forall(b in Acquisitions){
            next[a][b] == 1 => DlTime[a] + Duration[a] <= DlTime[b];
        }

        // Acquisitions can't follow itself or two acquisitions at a time
        next[a][a] == 0;

        // Acquisitions must be followed by another acquisition (except for the
        // last one)
        sum(b in Acquisitions) next[b][a] == AcqTaken[a] - last[a];

         // There is only one last acquisition
    	sum(a in Acquisitions) last[a] == 1;

   		 // Download of an acquisition can't start unless it has been taken
   	 	DlTime[a] >= AcquisitionEndTime[a];
    }

}

execute {
    var ofile = new IloOplOutputFile(OutputFile);
    for(var a=1; a <= Nacquisitions ; a++) {
        for(var d=1; d <= NdownloadWindows; d++) {
            if(AcqDlWindow[a][d] == 1){
                ofile.writeln(AcquisitionIds[a] + " " + DownloadWindowId[d] +
                    " " + DlTime[a] + " " + (DlTime[a]+Duration[a]));
            }
        }
    }
}
