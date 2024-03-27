/* 
2023 / 12 / 15
Macro created by Nicolas GOUDIN - nicolas.goudin@inserm.fr
(Fiji is Just) ImageJ 2.14.0/1.54f ; Java 1.8.0_172 (64 bits);
*/

/*
Notes :

*/


///////////////////////////////////////////////////////////////////////
////////	Variables	////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
 
// From https://www.biodip.de/w/images/0/00/ImageJ_macro_cheatsheet.pdf
#@ File(label= "Select the folder containing the raw datas", style="directory") imageFolder
#@ File(label= "Select the folder where you want to save the montage", style="directory") save_folder
#@ String(label="Image format (.czi, .lif, .lsm, .nd2 ,...",description="put the format ith the point before as .czi for exemple") image_format
#@ String(label="If stack : Z Projection type",choices={"Average Intensity","Max Intensity","Min Intensity","Sum Slices","Standard Deviation","Median"},style="list") projection_type
#@ String(label="Put the name with wich you want to save the image",description="don't put symbols like : / , ]  or others") montage_name
#@ Boolean(label="Put image name on the montage") put_image_name
#@ Boolean(label="Put line border between images") put_line_border

fileList=getFileList(imageFolder);
fileList = Array.sort(fileList); // 	Sorted list thanks to array.sort (it overlay the unsorted list : raw_filelist)

// arrays creation for all images information (max chan, max Z, etc.)
array_image_name = newArray(fileList.length);
array_z_number = newArray(fileList.length);
array_chan_number = newArray(fileList.length);
array_bit_depth_value = newArray(fileList.length);

// getting the max numer of chan, Z and bit depth and the image name of the image_format list and as it will be a variable I put this code part here
clearing_the_space (); // function 0
// getting the max Z channels and bit depth of all file of the list
setBatchMode(true);
good_image_number = 0;
for(i = 0; i < fileList.length; i = i+1){ 
	path = imageFolder+File.separator+fileList[i];
	good_image_format = endsWith(path, image_format);
	if (good_image_format==1) {
		opening_virtual_image (); // f1-A
		getDimensions(width, height, channels, slices, frames);
		array_bit_depth_value[i] = bitDepth();
		array_z_number[i] = slices;
		array_chan_number[i] = channels;
		good_image_number = good_image_number +1;
	}
}	
// creation of the results array of Z,chan and bit deapth value off all images of the list and getting the max value of each columns
Array.show("Results", array_image_name, array_z_number, array_chan_number, array_bit_depth_value);
run("Summarize");
max_z_number = getResult("array_z_number", fileList.length+3);
max_chan_number = getResult("array_chan_number", fileList.length+3);
max_bit_depth_value = getResult("array_bit_depth_value", fileList.length+3);
run("Clear Results");

// creating the good image format list
array_good_image_list = newArray(good_image_number);
k=0;
for(i = 0; i < fileList.length; i = i+1){ 
	path = imageFolder+File.separator+fileList[i];
	good_image_format = endsWith(path, image_format);
	if (good_image_format==1) {
		array_good_image_list[k] = File.getName(path);	
	k=k+1;
	}
}
setBatchMode(false);
clearing_the_space (); // function 0
Array.show("Results", array_good_image_list);

//	Path needed for concatenations
image_0 = getResultString("Value", 0); // as my result table is now string instead of value I need the getResultString and not getResult
image_1 = getResultString("Value", 1); // as my result table is now string instead of value I need the getResultString and not getResult
path_1 = imageFolder+File.separator+image_0;
path_2 = imageFolder+File.separator+image_1;

// Dialog box for the montage with an indication of the number of images in the Zproj folder : pathSave
Dialog.create("Montage");
Dialog.addMessage("You have "+good_image_number+" images to mount");
Dialog.addNumber("How many columns ?", 1 );
Dialog.addNumber("How many rows ?", 1 );
Dialog.show();
C = Dialog.getNumber();
R = Dialog.getNumber();

// for adding the name on the top left corner of the image
what_font = "SansSerif";
size_font = 33;
Red_colorset = 255;
Green_colorset = 255;
Blue_colorest = 255;
x_coordinate = 43;
y_coordinate = 43;


///////////////////////////////////////////////////////////////////////
////////	code	////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


// image 1 for the concatenation
path = path_1;
title = "img1";
opening_image (path); // function 1-B
getDimensions(width, height, channels, slices, frames);
name = File.getNameWithoutExtension(path);
rename_and_Z_projection_if_stack (name); // function 2
bit_depth = bitDepth();
missing_chan = max_chan_number - channels;
fill_empty_chan (title); // function 3
condition_4_merging(max_chan_number); // function 5 using the f4 wich is into
if (put_image_name == 1) {
	drawing_name_on_image (title); // function 6
}
// image 2 for the concatenation
path = path_2;
title = "img2";
opening_image (path); // function 1-B
getDimensions(width, height, channels, slices, frames);
name = File.getNameWithoutExtension(path);
rename_and_Z_projection_if_stack (name); // function 2
bit_depth = bitDepth();
missing_chan = max_chan_number - channels;
fill_empty_chan (title); // function 3
condition_4_merging(max_chan_number); // function 5 using the f4 wich is into
if (put_image_name == 1) {
	drawing_name_on_image (title); // function 6
}
// Concatenation of the 2 first images
run("Concatenate...", "open image1=img1 image2=img2");
	rename("img1");

// doing the rest of the image for concatenation
for(j = 2; j < good_image_number; j = j+1){ 
	image_3 = getResultString("Value", j);
	path_3 = imageFolder+File.separator+image_3;
	path = path_3;
	title = "img2";
	opening_image (path); // function 1-B
	getDimensions(width, height, channels, slices, frames);
	name = File.getNameWithoutExtension(path);
	rename_and_Z_projection_if_stack (name); // function 2
	bit_depth = bitDepth();
	missing_chan = max_chan_number - channels;
	fill_empty_chan (title); // function 3
	condition_4_merging(max_chan_number); // function 5 using the f4 wich is into
	if (put_image_name == 1) {
		drawing_name_on_image (title); // function 6
	}
	// Concatenation of the first cacateneted images and the last one
	run("Concatenate...", "open image1=img1 image2=img2");
	rename("img1");
}


// Making the montage 
// if there is more than 1 channel, as it can't be done on a composite it split the chan and then make the monatge and merge it finaly
title="Big-Montage";
if (max_chan_number>1) {
	run("Split Channels");
	for(i = 1; i < max_chan_number+1; i = i+1)	{ 
		selectWindow("C"+i+"-img1");
		if (put_line_border == true) {
			run("Make Montage...", "columns=C rows=R scale=1 border=3");
		}
		else {
			run("Make Montage...", "columns=C rows=R scale=1 border=0");
		}
		selectWindow("C"+i+"-img1");
		close();
		selectWindow("Montage");
		rename("C"+i+"-"+title);
	}
}	
else {
	if (put_line_border == true) {
		run("Make Montage...", "columns=C rows=R scale=1 border=3");
	}
	else {
			run("Make Montage...", "columns=C rows=R scale=1 border=0");
	}
	selectWindow("img1");
	close();
	selectWindow("Montage");
	getDimensions(width, height, channels, slices, frames);
	rename(title);
}
missing_chan = 0;
condition_4_merging(max_chan_number);
//saving as tiff full res and low res
saveAs("Tiff", save_folder+File.separator+"full_res_"+title+"_"+montage_name+".tif");
low_res_title = "low_res_"+title;
run("Scale...", "x=0.5 y=0.5  interpolation=Bilinear average create title="+low_res_title);
saveAs("Tiff", save_folder+File.separator+low_res_title+"_"+montage_name+".tif");

///////////////////////////////////////////////////////////////////////
////////	functions	////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// f0
function clearing_the_space () {
	//print("hey I'm function 0");
	run("Close All");
	run("Clear Results");
}

// f1-A
function opening_virtual_image () {
	//print("hey I'm function 1-A");
	run("Bio-Formats Importer", "open=["+path+"] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT use_virtual_stack");
}

// f1-B
function opening_image (path) {
	// print("hey I'm function 1-B");
	good_image_format = endsWith(path, image_format);
	if (good_image_format==1) {
		run("Bio-Formats Importer", "open=["+path+"] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT");
	}
}
	
// f2
function rename_and_Z_projection_if_stack (name) {
	// print("hey I'm function 2");
	raw_name = File.getName(path);
	if (slices>1) {
		run("Z Project...", "projection=["+ projection_type + "]");
		z_proj_name = getTitle();
		selectWindow(raw_name);
		close();
		selectWindow(z_proj_name);
		rename(title);
		}
	if (slices==1) {
		selectWindow(raw_name);
		rename(title);
	}
} 
	
// f3
function fill_empty_chan (title) {
	// print("hey I'm function 3");
	if (channels>1) {
		run("Split Channels");
	}
	if (missing_chan >0) { 
		for (i = 0; i < missing_chan; i++) {
			new_chan_number = channels + i + 1 ;
			newImage("C"+new_chan_number, bit_depth , width, height, 1);
		}
	}
}	
	
// f4 : merging fonctions from 2 chan image to 7 chan image (for a total of 6 functions)
function chan_merge_7_chan() {
	// print("hey I'm function 4, 7 chan");
	if (missing_chan ==6) {
		run("Merge Channels...", "c1="+title+" c2=C2 c3=C3 c4=C4 c5=C5 c6=C6 c7=C7 create");	
	}
	if (missing_chan ==5) {
		run("Merge Channels...", "c1=C1-"+title+" c2=C2-"+title+" c3=C3 c4=C4 c5=C5 c6=C6 c7=C7 create");	
	}
	if (missing_chan ==4) {
		run("Merge Channels...", "c1=C1-"+title+" c2=C2-"+title+" c3=C3-"+title+" c4=C4 c5=C5 c6=C6 c7=C7 create");	
	}
	if (missing_chan ==3) {
		run("Merge Channels...", "c1=C1-"+title+" c2=C2-"+title+" c3=C3-"+title+" c4=C4-"+title+" c5=C5 c6=C6 c7=C7 create");	
	}
	if (missing_chan ==2) {
		run("Merge Channels...", "c1=C1-"+title+" c2=C2-"+title+" c3=C3-"+title+" c4=C4-"+title+" c5=C5-"+title+" c6=C6 c7=C7 create");	
	}		
	if (missing_chan ==1) {
		run("Merge Channels...", "c1=C1-"+title+" c2=C2-"+title+" c3=C3-"+title+" c4=C4-"+title+" c5=C5-"+title+" c6=C6-"+title+" c7=C7 create");	
	}	
	if (missing_chan ==0) {
		run("Merge Channels...", "c1=C1-"+title+" c2=C2-"+title+" c3=C3-"+title+" c4=C4-"+title+" c5=C5-"+title+" c6=C6-"+title+" c7=C7-"+title+" create");	
	}	
}

function chan_merge_6_chan(missing_chan, title) {
	// print("hey I'm function 4, 5 chan");
	if (missing_chan ==5) {
		run("Merge Channels...", "c1="+title+" c2=C2 c3=C3 c4=C4 c5=C5 c6=C6 create");	
	}
	if (missing_chan ==4) {
		run("Merge Channels...", "c1=C1-"+title+" c2=C2-"+title+" c3=C3 c4=C4 c5=C5 c6=C6 create");	
	}
	if (missing_chan ==3) {
		run("Merge Channels...", "c1=C1-"+title+" c2=C2-"+title+" c3=C3-"+title+" c4=C4 c5=C5 c6=C6 create");	
	}
	if (missing_chan ==2) {
		run("Merge Channels...", "c1=C1-"+title+" c2=C2-"+title+" c3=C3-"+title+" c4=C4-"+title+" c5=C5 c6=C6 create");	
	}
	if (missing_chan ==1) {
		run("Merge Channels...", "c1=C1-"+title+" c2=C2-"+title+" c3=C3-"+title+" c4=C4-"+title+" c5=C5-"+title+" c6=C6 create");	
	}		
	if (missing_chan ==0) {
		run("Merge Channels...", "c1=C1-"+title+" c2=C2-"+title+" c3=C3-"+title+" c4=C4-"+title+" c5=C5-"+title+" c6=C6-"+title+" create");	
	}		
}

function chan_merge_5_chan(missing_chan, title) {
	// print("hey I'm function 4, 5 chan");
	if (missing_chan ==4) {
		run("Merge Channels...", "c1="+title+" c2=C2 c3=C3 c4=C4 c5=C5 create");	
	}
	if (missing_chan ==3) {
		run("Merge Channels...", "c1=C1-"+title+" c2=C2-"+title+" c3=C3 c4=C4 c5=C5 create");	
	}
	if (missing_chan ==2) {
		run("Merge Channels...", "c1=C1-"+title+" c2=C2-"+title+" c3=C3-"+title+" c4=C4 c5=C5 create");	
	}
	if (missing_chan ==1) {
		run("Merge Channels...", "c1=C1-"+title+" c2=C2-"+title+" c3=C3-"+title+" c4=C4-"+title+" c5=C5 create");	
	}
	if (missing_chan ==0) {
		run("Merge Channels...", "c1=C1-"+title+" c2=C2-"+title+" c3=C3-"+title+" c4=C4-"+title+" c5=C5-"+title+" create");	
	}	
}

function chan_merge_4_chan(missing_chan, title) {
	// print("hey I'm function 4, 4 chan");
	if (missing_chan ==3) {
		run("Merge Channels...", "c1="+title+" c2=C2 c3=C3 c4=C4 create");	
	}
	if (missing_chan ==2) {
		run("Merge Channels...", "c1=C1-"+title+" c2=C2-"+title+" c3=C3 c4=C4 create");	
	}
	if (missing_chan ==1) {
		run("Merge Channels...", "c1=C1-"+title+" c2=C2-"+title+" c3=C3-"+title+" c4=C4 create");	
	}
	if (missing_chan ==0) {
		run("Merge Channels...", "c1=C1-"+title+" c2=C2-"+title+" c3=C3-"+title+" c4=C4-"+title+" create");	
	}	
}
	
function chan_merge_3_chan(missing_chan, title) {
	// print("hey I'm function 4, 3 chan");
	if (missing_chan ==2) {
		run("Merge Channels...", "c1="+title+" c2=C2 c3=C3 create");	
	}
	if (missing_chan ==1) {
		run("Merge Channels...", "c1=C1-"+title+" c2=C2-"+title+" c3=C3 create");	
	}
	if (missing_chan ==0) {
		run("Merge Channels...", "c1=C1-"+title+" c2=C2-"+title+" c3=C3-"+title+" create");	
	}	
}
	
function chan_merge_2_chan(missing_chan, title) {
	// print("hey I'm function 4, 2 chan");
	if (missing_chan ==1) {
		run("Merge Channels...", "c1="+title+" c2=C2 create");	
	}
	if (missing_chan ==0) {
		run("Merge Channels...", "c1=C1-"+title+" c2=C2-"+title+" create");	
	}	
}

// f5 
// conditions for merging fonctions
function condition_4_merging(max_chan_number) {
	// print("hey I'm function 5");
	if (max_chan_number==1) {
		rename(title);
	}
	if (max_chan_number==2) {
		chan_merge_2_chan(missing_chan, title);
		rename(title);
	}
	if (max_chan_number==3) {
		chan_merge_3_chan(missing_chan, title);
		rename(title);
	}
	if (max_chan_number==4) {
		chan_merge_4_chan(missing_chan, title);
		rename(title);
	}
	if (max_chan_number==5) {
		chan_merge_5_chan(missing_chan, title);
		rename(title);
	}
	if (max_chan_number==6) {
		chan_merge_6_chan(missing_chan, title);
		rename(title);
	}
	if (max_chan_number==7) {
		chan_merge_7_chan(missing_chan, title);
		rename(title);
	}
}

// f6 
// puting the name at the top left corner of the image
function drawing_name_on_image (title) {
	// print("hey I'm function 6");
	setFont(what_font, size_font);
	for (i = 1; i < channels+1; i++) {
		Stack.setChannel(i);
		setColor(Red_colorset, Green_colorset, Blue_colorest);
		drawString(name, x_coordinate, y_coordinate);
	}
}

