% fly-spotter
% spots flies in images
% 
% created by Srinivas Gorur-Shandilya at 1:53 , 21 December 2015. Contact me at http://srinivas.gs/contact/
% 
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.

function  [] = flySpotter(varargin)

% defaults
show_figure = true;

if ~nargin

else
    if iseven(length(varargin))
    	for ii = 1:2:length(varargin)-1
        	temp = varargin{ii};
        	if ischar(temp)
            	eval(strcat(temp,'=varargin{ii+1};'));
        	end
    	end
	else
    	error('Inputs need to be name value pairs')
	end
end



p = uigetdir(pwd,'Choose filter with JPG images');
if ~p
	disp('No folder chosen, quitting')
	return
end

% find all *JPG images
allfiles = dir([p oss '*.JPG']);

assert(length(allfiles)>0,'No JPG images found!s')

all_positions = NaN(100,100);
all_areas = NaN(100,100);
all_orientations = NaN(100,100);
all_names = {};

for i = 1:length(allfiles)
	disp(allfiles(i).name)
	rgb = imread([p oss allfiles(i).name]);

	try
		[r,rgb] = fs4(rgb);

		all_y = [];
		all_area = [];
		all_orientation = [];

		if show_figure
			% save another image
			figure, hold on
			imagesc(rgb), axis image, axis ij
		end
		for j = 1:length(r)
			if show_figure
				plot(r(j).Centroid(1),r(j).Centroid(2),'ro','MarkerSize',10)
			end
			all_y = [all_y r(j).Centroid(2)];
			all_area = [all_area r(j).Area];
			all_orientation = [all_orientation r(j).Orientation];
		end
		if show_figure
			saveas(gcf,[p oss allfiles(i).name '_results.png'])
			close all
		end
		all_names = [all_names allfiles(i).name];

		% find distances from bottom
		all_y = size(rgb,1) - round(all_y);

		% add to database
		all_positions(1:length(all_y),i) = all_y;
		all_areas(1:length(all_y),i) = all_area;
		all_orientations(1:length(all_y),i) = all_orientation;

	catch
		disp('Something went wrong with this file...')
	end
end

% write sheet 1 -- positions on Y axis
xlwrite([p oss 'results.xlsx'],all_names,1)
xlwrite([p oss 'results.xlsx'],all_positions,1,'A2:DD100');

% write sheet 2 -- areas
xlwrite([p oss 'results.xlsx'],all_names,2)
xlwrite([p oss 'results.xlsx'],all_areas,2,'A2:DD100');

% write sheet 2 -- orientations
xlwrite([p oss 'results.xlsx'],all_names,3)
xlwrite([p oss 'results.xlsx'],all_orientations,3,'A2:DD100');




