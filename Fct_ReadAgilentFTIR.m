% slCharacterEncoding('UTF-8')
% File: Mdl_read_FTIR.m
% Created on Sat May 11 10:57:20 2019
% Read FTIR image aquired with Agilent 620 microscope
% Attention: all files (.dmd, .dmt, .dat) should be under the same folder
%
% Input : 	Path of the fold where are the files
%			name of the file .dat
% Output: 	Datacube 
% 			Wavenumber
%@author: Laure

%Examples:
%Path = 'F:\Mes\081909_140919\';%Folder where are the files
%fichier = '081909_140919.dat'; % name of the .dat
%[data,wavenumbers] = Fct_ReadAgilentFTIR(Path,fichier);

function [data,wavenumbers] = Fct_ReadAgilentFTIR(Path,fichier)
	filename = strcat(Path,fichier);
	% extract the wavenumers and date from the .dmt file
	[pathstr, nom, extension] = fileparts(filename);
	nom = lower(nom) % to get name in lowerletter
	dmtfilename = fullfile(pathstr,[nom '.dmt']);
	% Open the file
	[fid, message] = fopen(dmtfilename, 'r', 'l');
	if(fid == -1) 
		disp(['reading dmt file: ', dmtfilename]); % ---- ne s'affiche pas car fid = 3
		error(message); % ---- # ecrire un message d'erreur;
	end;
	% wavenumbers
    status = fseek(fid, 2228, 'bof'); % status = 0 
    if(status == -1), message = ferror(fid, 'clear'); error(message); end; % message error 
    startwavenumber = double(fread(fid, 1, 'int32'));     
    status = fseek(fid, 2236, 'bof'); 
    if(status == -1), message = ferror(fid, 'clear'); error(message); end;
    numberofpoints = double(fread(fid, 1, 'int32'));     
    status = fseek(fid, 2216, 'bof'); 
    if(status == -1), message = ferror(fid, 'clear'); error(message); end;
    wavenumberstep = fread(fid, 1, 'double'); 
    wavenumbers = 1:(numberofpoints+startwavenumber-1); 
    wavenumbers = wavenumbers * wavenumberstep;  
    wavenumbers = wavenumbers(startwavenumber:end); 
	% date
	status = fseek(fid, 0, 'bof'); 
    if(status == -1), message = ferror(fid, 'clear'); error(message); end;    
    [pathstr, nom, extension] = fileparts(filename);
	basefilename = filename;
	basefilename = fullfile(pathstr,nom);
	% compter les images sur x
	tiles_in_x_dir = 1;
	finished = false;
	counter = 0;
	while (~finished)
		current_extn = sprintf('_%04d_0000.dmd', counter);
		tempfilename = [basefilename, current_extn];
		if exist(tempfilename,'file')
			counter = counter + 1;
		else
			tiles_in_x_dir = counter;
			finished = true;
		end;
	end;
	% compter les images sur y
	tiles_in_y_dir = 1;
	finished = false;
	counter = 0;
	while (~finished)
		current_extn = sprintf('_0000_%04d.dmd', counter);
		tempfilename = [basefilename, current_extn];
		if exist(tempfilename,'file')
			counter = counter + 1; 
		else
			tiles_in_y_dir = counter; 
			finished = true;
		end;
	end;
	tilefilename = fullfile(pathstr,[nom,'_0000_0000.dmd']);
	tile = dir(tilefilename);
	bytes = tile.bytes;
	bytes = bytes / 4;
	bytes = bytes - 255;
	bytes = bytes / length(wavenumbers);
	fpaSize = sqrt(bytes);
	% creation of data array
	data = zeros(fpaSize*tiles_in_y_dir, fpaSize*tiles_in_x_dir, length(wavenumbers)); 
	[pathstr, nom, extension] = fileparts(filename);
	x = 1;
	y = 1;
	for y = 1:tiles_in_y_dir
		for x = 1:tiles_in_x_dir
			current_extn = sprintf('_%04d_%04d.dmd', x-1, y-1);
			tempfilename = fullfile(pathstr,[name, current_extn]);
			[fid, message] = fopen(tempfilename, 'r', 'l'); 
			if(fid == -1) 
				disp(['Dmd file reading: ', tempfilename]);
				error(message); 
			end;
			status = fseek(fid,255*4,'bof'); % --- status = 0
			if (status == -1)
				error(['Cannot read ', tempfilename]);
			end
			tempdata = fread(fid, inf, '*float32');
			fclose(fid);
			tempdata = reshape(tempdata,fpaSize,fpaSize,[]);
			tempdata=permute(tempdata,[2,1,3]);
			tempdata=flipdim(tempdata,1);
			% insert the tile inside the image
			data((1+((y-1)*fpaSize)) : (y*fpaSize), (1+((x-1)*fpaSize)) : (x*fpaSize), :) = tempdata;
		end;
	end;
	data = double(data);
	
