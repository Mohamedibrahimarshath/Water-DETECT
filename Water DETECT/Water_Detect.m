function Water_Detect()
if(~isdeployed)
	cd(fileparts(which(mfilename))); % From Brett
end

ver 
global maskedRGBImage;
message = sprintf('This BPNN based water Detection..\nIt requires the Image Processing Toolbox.\nDo you wish to continue?');
reply = questdlg(message, 'Run?', 'OK','Cancel', 'OK');
if strcmpi(reply, 'Cancel')
	return;
end

try
	hasIPT = license('test', 'image_toolbox');
	if ~hasIPT
		message = sprintf('Sorry, but you do not seem to have the Image Processing Toolbox.\nDo you want to try to continue anyway?');
		reply = questdlg(message, 'Toolbox missing', 'Yes', 'No', 'Yes');
		if strcmpi(reply, 'No')
			% User said No, so exit.
			return;
		end
	end

	fontSize = 10;
	figure;
	set(gcf, 'units','normalized','outerposition',[0 0 1 1]); 
	if(~isdeployed)
		cd(fileparts(which(mfilename)));
	end

	message = sprintf('Select any one image,\nOr pick one of your own?');
	reply2 = questdlg(message, 'Which Image?', 'Avaliable','My Own', 'Avaliable');
	% Open an image.
	if strcmpi(reply2, 'Avaliable')
	else
		originalFolder = pwd; 
		folder = 'C:\Program Files\MATLAB\R2010a\toolbox\images\imdemos'; 
		if ~exist(folder, 'dir') 
			folder = pwd; 
		end 
		cd(folder); 
		% Browse for the image file. 
		[baseFileName, folder] = uigetfile('*.*', 'Specify an image file'); 
		fullImageFileName = fullfile(folder, baseFileName); 
		% Set current folder back to the original one. 
		cd(originalFolder);
		selectedImage = 'My own image'; % Need for the if threshold selection statement later.

	end

	% Check to see that the image exists.  (Mainly to check on the Avaliable images.)
	if ~exist(fullImageFileName, 'file')
		message = sprintf('This file does not exist:\n%s', fullImageFileName);
		uiwait(msgbox(message));
		return;
	end

	% Read in image into an array.
	[rgbImage, storedColorMap] = imread(fullImageFileName); 
	[rows, columns, numberOfColorBands] = size(rgbImage); 
	% If it's monochrome (indexed), convert it to color. 
	% Check to see if it's an 8-bit image needed later for scaling).
	if strcmpi(class(rgbImage), 'uint8')
		% Flag for 256 gray levels.
		eightBit = true;
	else
		eightBit = false;
	end
	if numberOfColorBands == 1
		if isempty(storedColorMap)
			% Just a simple gray level image, not indexed with a stored color map.
			% Create a 3D true color image where we copy the monochrome image into all 3 (R, G, & B) color planes.
			rgbImage = cat(3, rgbImage, rgbImage, rgbImage);
		else
			% It's an indexed image.
			rgbImage = ind2rgb(rgbImage, storedColorMap);
			% ind2rgb() will convert it to double and normalize it to the range 0-1.
			% Convert back to uint8 in the range 0-255, if needed.
			if eightBit
				rgbImage = uint8(255 * rgbImage);
			end
		end
	end 
	
	% Display the original image.
	subplot(3, 4, 1);
	hRGB = imshow(rgbImage);
	% Set up an infor panel so you can mouse around and inspect the value values.
	hrgbPI = impixelinfo(hRGB);
	set(hrgbPI, 'Units', 'Normalized', 'Position',[.15 .69 .15 .02]);
	drawnow; % Make it display immediately. 
	if numberOfColorBands > 1 
		title('Original Color Image', 'FontSize', fontSize); 
	else 
		caption = sprintf('Original Indexed Image\n(converted to true color with its stored colormap)');
		title(caption, 'FontSize', fontSize);
	end

	% Convert RGB image to HSV
	hsvImage = rgb2hsv(rgbImage);
	% Extract out the H, S, and V images individually
	hImage = hsvImage(:,:,1);
	sImage = hsvImage(:,:,2);
	vImage = hsvImage(:,:,3);
	
	% Display the hue image.
	subplot(3, 4, 2);
	h1 = imshow(hImage);
	title('Hue Image', 'FontSize', fontSize);
	% Set up an infor panel so you can mouse around and inspect the hue values.
	hHuePI = impixelinfo(h1);
	set(hHuePI, 'Units', 'Normalized', 'Position',[.34 .69 .15 .02]);
	
	% Display the saturation image.
	h2 = subplot(3, 4, 3);
	imshow(sImage);
	title('Saturation Image', 'FontSize', fontSize);
	% Set up an infor panel so you can mouse around and inspect the saturation values.
	hSatPI = impixelinfo(h2);
	set(hSatPI, 'Units', 'Normalized', 'Position',[.54 .69 .15 .02]);
	
	% Display the value image.
	h3 = subplot(3, 4, 4);
	imshow(vImage);
	title('Value Image', 'FontSize', fontSize);
	% Set up an infor panel so you can mouse around and inspect the value values.
	hValuePI = impixelinfo(h3);
	set(hValuePI, 'Units', 'Normalized', 'Position',[.75 .69 .15 .02]);

	message = sprintf('These are the individual HSV color bands.\nNow we will compute the image histograms.');
	reply = questdlg(message, 'Continue with Avaliable?', 'OK','Cancel', 'OK');
	if strcmpi(reply, 'Cancel')
		% User canceled so exit.
		return;
	end

	% Compute and plot the histogram of the "hue" band.
	hHuePlot = subplot(3, 4, 6); 
	[hueCounts, hueBinValues] = imhist(hImage); 
	maxHueBinValue = find(hueCounts > 0, 1, 'last'); 
	maxCountHue = max(hueCounts); 
	area(hueBinValues, hueCounts, 'FaceColor', 'r'); 
	grid on; 
	xlabel('Hue Value'); 
	ylabel('Pixel Count'); 
	title('Histogram of Hue Image', 'FontSize', fontSize);

	% Compute and plot the histogram of the "saturation" band.
	hSaturationPlot = subplot(3, 4, 7); 
	[saturationCounts, saturationBinValues] = imhist(sImage); 
	maxSaturationBinValue = find(saturationCounts > 0, 1, 'last'); 
	maxCountSaturation = max(saturationCounts); 
% 	bar(saturationBinValues, saturationCounts, 'g', 'BarWidth', 0.95); 
	area(saturationBinValues, saturationCounts, 'FaceColor', 'g'); 
	grid on; 
	xlabel('Saturation Value'); 
	ylabel('Pixel Count'); 
	title('Histogram of Saturation Image', 'FontSize', fontSize);

	% Compute and plot the histogram of the "value" band.
	hValuePlot = subplot(3, 4, 8); 
	[valueCounts, valueBinValues] = imhist(vImage); 
	maxValueBinValue = find(valueCounts > 0, 1, 'last'); 
	maxCountValue = max(valueCounts); 
% 	bar(valueBinValues, valueCounts, 'b'); 
	area(valueBinValues, valueCounts, 'FaceColor', 'b'); 
	grid on; 
	xlabel('Value Value'); 
	ylabel('Pixel Count'); 
	title('Histogram of Value Image', 'FontSize', fontSize);

	% Set all axes to be the same width and height.
	% This makes it easier to compare them.
	maxCount = max([maxCountHue,  maxCountSaturation, maxCountValue]); 
	axis([hHuePlot hSaturationPlot hValuePlot], [0 1 0 maxCount]); 

	% Plot all 3 histograms in one plot.
	subplot(3, 4, 5); 
	plot(hueBinValues, hueCounts, 'r', 'LineWidth', 2); 
	grid on; 
	xlabel('Values'); 
	ylabel('Pixel Count'); 
	hold on; 
	plot(saturationBinValues, saturationCounts, 'g', 'LineWidth', 2); 
	plot(valueBinValues, valueCounts, 'b', 'LineWidth', 2); 
	title('Histogram of All Bands', 'FontSize', fontSize); 
	maxGrayLevel = max([maxHueBinValue, maxSaturationBinValue, maxValueBinValue]); % Just for our information....
	% Make x-axis to just the max gray level on the bright end. 
	xlim([0 1]); 

	% Now select thresholds for the 3 color bands.
	message = sprintf('Now we will select some color threshold ranges\nand display them over the histograms.');
	reply = questdlg(message, 'Continue with Avaliable?', 'OK','Cancel', 'OK');
	if strcmpi(reply, 'Cancel')
		% User canceled so exit.
		return;
	end

	% Assign the low and high thresholds for each color band.
	if strcmpi(reply2, 'My Own') || strcmpi(selectedImage, 'Kids') > 0
		% Take a guess at the values that might work for the user's image.
		hueThresholdLow = 0;
		hueThresholdHigh = graythresh(hImage);
		saturationThresholdLow = graythresh(sImage);
		saturationThresholdHigh = 1.0;
		valueThresholdLow = graythresh(vImage);
		valueThresholdHigh = 1.0;
	else
		% Use values that I know work for the onions and peppers Avaliable images.
		[hueThresholdLow, hueThresholdHigh, saturationThresholdLow, saturationThresholdHigh, valueThresholdLow, valueThresholdHigh] = SetThresholds()
	end

	PlaceThresholdBars(6, hueThresholdLow, hueThresholdHigh);
	PlaceThresholdBars(7, saturationThresholdLow, saturationThresholdHigh);
	PlaceThresholdBars(8, valueThresholdLow, valueThresholdHigh);

	message = sprintf('Next we will apply each color band threshold range to its respective color band.');
	reply = questdlg(message, 'Continue with Avaliable?', 'OK','Cancel', 'OK');
	if strcmpi(reply, 'Cancel')
		% User canceled so exit.
		return;
	end

	% Now apply each color band's particular thresholds to the color band
	hueMask = (hImage >= hueThresholdLow) & (hImage <= hueThresholdHigh);
	saturationMask = (sImage >= saturationThresholdLow) & (sImage <= saturationThresholdHigh);
	valueMask = (vImage >= valueThresholdLow) & (vImage <= valueThresholdHigh);

	coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

	smallestAcceptableArea = 100; % Keep areas only if they're bigger than this.
	message = sprintf('Note the small regions in the image in the lower left.\nNext we will eliminate regions smaller than %d pixels.', smallestAcceptableArea);
	reply = questdlg(message, 'Continue with Avaliable?', 'OK','Cancel', 'OK');
	if strcmpi(reply, 'Cancel')
		% User canceled so exit.
		return;
	end

	coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));

	structuringElement = strel('disk', 4);
	coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);

	coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

	message = sprintf('This is the filled, size-filtered mask.\nNext we will apply this mask to the original RGB image.');
	reply = questdlg(message, 'Continue with Avaliable?', 'OK','Cancel', 'OK');
	if strcmpi(reply, 'Cancel')
		% User canceled so exit.
		return;
    end
	coloredObjectsMask = cast(coloredObjectsMask, 'like', rgbImage); 
% 	coloredObjectsMask = cast(coloredObjectsMask, class(rgbImage));

	% Use the colored object mask to mask out the colored-only portions of the rgb image.
	maskedImageR = coloredObjectsMask .* rgbImage(:,:,1);
	maskedImageG = coloredObjectsMask .* rgbImage(:,:,2);
	maskedImageB = coloredObjectsMask .* rgbImage(:,:,3);
	maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);
    subplot(3, 4, 9); imshow(maskedRGBImage);
catch ME
	errorMessage = sprintf('Error in function %s() at line %d.\n\nError Message:\n%s', ...
		ME.stack(1).name, ME.stack(1).line, ME.message);
	fprintf(1, '%s\n', errorMessage);
	uiwait(warndlg(errorMessage));
end
return;
	
	
%----------------------------------------------------------------------------
% Function to show the low and high threshold bars on the histogram plots.
function PlaceThresholdBars(plotNumber, lowThresh, highThresh)
try
	% Show the thresholds as vertical red bars on the histograms.
	subplot(3, 4, plotNumber); 
	hold on;
	yLimits = ylim;
	line([lowThresh, lowThresh], yLimits, 'Color', 'r', 'LineWidth', 3);
	line([highThresh, highThresh], yLimits, 'Color', 'r', 'LineWidth', 3);
	% Place a text label on the bar chart showing the threshold.
	fontSizeThresh = 10;
	annotationTextL = sprintf('%d', lowThresh);
	annotationTextH = sprintf('%d', highThresh);
	% For text(), the x and y need to be of the data class "double" so let's cast both to double.
	text(double(lowThresh + 5), double(0.85 * yLimits(2)), annotationTextL, 'FontSize', fontSizeThresh, 'Color', [0 .5 0], 'FontWeight', 'Bold');
	text(double(highThresh + 5), double(0.85 * yLimits(2)), annotationTextH, 'FontSize', fontSizeThresh, 'Color', [0 .5 0], 'FontWeight', 'Bold');
	
	% Show the range as arrows.
	% Can't get it to work, with either gca or gcf.
% 	annotation(gca, 'arrow', [lowThresh/maxXValue(2) highThresh/maxXValue(2)],[0.7 0.7]);

catch ME
	errorMessage = sprintf('Error in function %s() at line %d.\n\nError Message:\n%s', ...
		ME.stack(1).name, ME.stack(1).line, ME.message);
	fprintf(1, '%s\n', errorMessage);
	uiwait(warndlg(errorMessage));
end
return; % from PlaceThresholdBars()


%---------------------------------------------------------------------------------------------------------------------------------
% Ask user what color they want for the onions and peppers images and set up pre-defined threshold values.
function [hueThresholdLow, hueThresholdHigh, saturationThresholdLow, saturationThresholdHigh, valueThresholdLow, valueThresholdHigh] = SetThresholds()
try
% 	button = menu('What color do you want to find?', 'yellow', 'green', 'red', 'white');
	% Menu with purple commented out because it's all around and the regionfill just ends up selecting the whole image.
	button = menu('What color do you want to find?', 'yellow', 'green', 'red', 'white', 'purple');
	% Use values that I know work for the onions and peppers Avaliable images.
	switch button
		case 1
			% Yellow
			hueThresholdLow = 1;% 0.10
			hueThresholdHigh = 1;% 0.14
			saturationThresholdLow = 4;% 0.4
			saturationThresholdHigh = 1;% 1
			valueThresholdLow = 8;% 0.8
			valueThresholdHigh = 1;% 1.0
		case 2
			% Green
			hueThresholdLow = 0.15;
			hueThresholdHigh = 0.60;
			saturationThresholdLow = 0.36;
			saturationThresholdHigh = 1;
			valueThresholdLow = 0;
			valueThresholdHigh = 0.8;
		case 3
		hueThresholdLow = 0.80;
			hueThresholdHigh = 1;
			saturationThresholdLow = 0.58;
			saturationThresholdHigh = 1;
			valueThresholdLow = 0.55;
			valueThresholdHigh = 1.0;
		case 4
			% White
			hueThresholdLow = 0.0;
			hueThresholdHigh = 1;
			saturationThresholdLow = 0;
			saturationThresholdHigh = 0.36;
			valueThresholdLow = 0.7;
			valueThresholdHigh = 1.0;
		otherwise
			% Purple
			hueThresholdLow = 0.76;
			hueThresholdHigh = 0.94;
			saturationThresholdLow = 0.33;
			saturationThresholdHigh = 0.67;
			valueThresholdLow = 0.1;
			valueThresholdHigh = 0.7;
	end
catch ME
	errorMessage = sprintf('Error in function %s() at line %d.\n\nError Message:\n%s', ...
		ME.stack(1).name, ME.stack(1).line, ME.message);
	fprintf(1, '%s\n', errorMessage);
	uiwait(warndlg(errorMessage));
end
return; % From SetThresholds()


function ShowCredits()
try
% 	xpklein;
% 	surf(peaks(30));
	logoFig = subplot(3,3,9);
	caption = sprintf('A MATLAB Avaliable');
	text(0.5,1.15, caption, 'Color','r', 'FontSize', 10, 'FontWeight','b', 'HorizontalAlignment', 'Center') ;
	positionOfLowerRightPlot = get(logoFig, 'position');
	L = 40*membrane(1,25);
	logoax = axes('CameraPosition', [-193.4013 -265.1546  220.4819],...
		'CameraTarget',[26 26 10], ...
		'CameraUpVector',[0 0 1], ...
		'CameraViewAngle',9.5, ...
		'DataAspectRatio', [1 1 .9],...
		'Position', positionOfLowerRightPlot, ...
		'Visible','off', ...
		'XLim',[1 51], ...
		'YLim',[1 51], ...
		'ZLim',[-13 40], ...
		'parent',gcf);
	s = surface(L, ...
		'EdgeColor','none', ...
		'FaceColor',[0.9 0.2 0.2], ...
		'FaceLighting','phong', ...
		'AmbientStrength',0.3, ...
		'DiffuseStrength',0.6, ... 
		'Clipping','off',...
		'BackFaceLighting','lit', ...
		'SpecularStrength',1.0, ...
		'SpecularColorReflectance',1, ...
		'SpecularExponent',7, ...
		'Tag','TheMathWorksLogo', ...
		'parent',logoax);
	l1 = light('Position',[40 100 20], ...
		'Style','local', ...
		'Color',[0 0.8 0.8], ...
		'parent',logoax);
	l2 = light('Position',[.5 -1 .4], ...
		'Color',[0.8 0.8 0], ...
		'parent',logoax);
catch ME
	errorMessage = sprintf('Error in function %s() at line %d.\n\nError Message:\n%s', ...
		ME.stack(1).name, ME.stack(1).line, ME.message);
	fprintf(1, '%s\n', errorMessage);
	uiwait(warndlg(errorMessage));
end
return; 

	