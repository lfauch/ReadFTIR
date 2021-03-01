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

clear all
close all
clc

Path = 'F:\Mes\081909_140919\';%Folder where are the files
file = '081909_140919.dat'; % name of the .dat
[Datacube,wavenumbers] = Fct_ReadAgilentFTIR(Path,file);
