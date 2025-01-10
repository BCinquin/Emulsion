//This macro has been written by Bertrand Cinquin (Technological platform IPGG).
//contact bertrand.cinquin@espci.fr for further questions or requests.
//Any use of IPGG platform, its facilities and or produced items, data, code,...
//has to be mentionned in the corresponding publication.


//Open folder with files
#@ String(value="Welcome to Emulsion Distribution Analyser", visibility = "MESSAGE") hint;
#@ File (label = "Source of Raw Images", style = "directory") DirSrc
#@ String (choices={"Red channel", "Green channel", "Blue channel"}) Chosenchannel

requires("1.53u");



//List of image to open
DirSrc = DirSrc+"\\"
DirOut = File.getParent(DirSrc)+ "\\Output\\";
File.makeDirectory(DirOut);

Nmbfile = 0;
count = newArray(1);
countFile(DirSrc,count);
finalList = newArray(count[0]);
Nmbfile = 0;
listFiles(DirSrc,finalList);
Array.show(finalList);
// open image i
for (i = 0; i<finalList.length; i++){
	setBatchMode(true);
	open(finalList[i]);
	Filename = getInfo("image.filename");
	// substract background (homogeneisation)
	/*run("16-bit");
	run("Duplicate...", " ");
	run("Subtract Background...", "rolling=50 light sliding");;
	rename("Cleaned");
	selectWindow(Filename);
	run("Gaussian Blur...", "sigma=80");
	rename("Blurred");
	imageCalculator("Subtract create 32-bit","Cleaned","Blurred");
	close("Blurred");
	Filenameshort = File.getNameWithoutExtension(Filename);
	rename(Filenameshort+"_Bck_sub.tif");
	*/
	//Split RGB
	run("Make Composite");
	run("Split Channels");
	//work on C3
		Colorchannel1 = "C1-"+Filename;
		Colorchannel2 = "C2-"+Filename;
		Colorchannel3 = "C3-"+Filename;
	selectWindow(Colorchannel1);
	run("Duplicate...", " ");
	run("Gaussian Blur...", "sigma=80");
	rename("Blurred");
	selectWindow(Colorchannel1);
	run("Subtract Background...", "rolling=50 light sliding");
	rename("RollingBall");
	imageCalculator("Subtract create 32-bit","RollingBall","Blurred");
	setAutoThreshold("Otsu");
	run("Convert to Mask");
	rename(Colorchannel1+"_mask");
	selectWindow(Colorchannel2);
	run("Duplicate...", " ");
	run("Gaussian Blur...", "sigma=80");
	rename("Blurred");
	selectWindow(Colorchannel2);
	run("Subtract Background...", "rolling=50 light sliding");
	rename("RollingBall");
	imageCalculator("Subtract create 32-bit","RollingBall","Blurred");
	setAutoThreshold("Otsu");
	run("Convert to Mask");
	rename(Colorchannel2+"_mask");
	imageCalculator("OR create 32-bit", Colorchannel1+"_mask",Colorchannel2+"_mask");
	
	run("Remove Outliers...", "radius=3 threshold=50 which=Dark");
	run("8-bit");
	run("Watershed");

	

//Segmentation (Objects touching the sides are not considered))
 	setAutoThreshold("Otsu");
 	run("Analyze Particles...", "size=10-5000 pixel circularity=0.7-1.00 exclude clear include add");
 	run("Set Measurements...", "area fit redirect=None decimal=3");
 	roiManager("Measure");
 	run("Distribution...", "parameter=Area automatic");
 	//diameter = sqrt(area/PI)*2;
	saveAs("TIFF", DirOut+Filename+"_Distribution.tif");
	
	saveAs("Results", DirOut+Filename+"_List.csv");
	roiManager("Save", DirOut+Filename+"_RoiSet.zip");
	run("Close All");
	}
// segmentation 
// Measurements of sizes/roundness
// Data visualisation (histogram) distribution metrics (average, std)
// close image i
// push relevant information in a table 

//close macro
function countFile(dir, count) {
	list = getFileList(dir);
	for (i=0; i<list.length; i++){
		if (File.isDirectory(dir+list[i])){
			countFile(""+dir+list[i], count);
		}
		else {
			print((Nmbfile++) + ": "+dir+list[i]);
			count[0]= Nmbfile;
		}
	}
}

function listFiles(dir,finalList) {
	list = getFileList(dir); 
	for (i=0;i<list.length; i++){
		if (File.isDirectory(dir+list[i])){
			listFiles(""+dir+list[i],finalList);
		}
		else {
			finalList[Nmbfile] =dir+list[i];
				print((Nmbfile++) +": "+dir+list[i]);
		}
	}
}
		
	

