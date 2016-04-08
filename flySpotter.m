% fly-spotter
% spots flies in images
% 
% created by Srinivas Gorur-Shandilya at 1:53 , 21 December 2015. Contact me at http://srinivas.gs/contact/
% 
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.

function  [varargout] = flySpotter(varargin)

% get options from dependencies 
options = getOptionsFromDeps(mfilename);

% defaults
options.show_figure = false;

if nargout && ~nargin 
	varargout{1} = options;
    return
end

% validate and accept options
if iseven(length(varargin))
	for ii = 1:2:length(varargin)-1
	temp = varargin{ii};
    if ischar(temp)
    	if ~any(find(strcmp(temp,fieldnames(options))))
    		disp(['Unknown option: ' temp])
    		disp('The allowed options are:')
    		disp(fieldnames(options))
    		error('UNKNOWN OPTION')
    	else
    		options = setfield(options,temp,varargin{ii+1});
    	end
    end
end
elseif isstruct(varargin{1})
	% should be OK...
	options = varargin{1};
else
	error('Inputs need to be name value pairs')
end

p = uigetdir(pwd,'Choose filter with JPG images');
if ~p
	disp('No folder chosen, quitting')
	return
end

% find all *JPG images
allfiles = dir([p oss '*.JPG']);

assert(~isempty(allfiles),'No JPG images found!')

% make placeholders for positions, areas and orienatons. first dimensions is a dummy (for number of flies in each file, and second dimension is as long as there are files.)
all_positions = NaN(100,length(allfiles));
all_areas = NaN(100,length(allfiles));
all_orientations = NaN(100,length(allfiles));
all_names = {};

for i = 1:length(allfiles)
	disp(allfiles(i).name)
	rgb = imread([p oss allfiles(i).name]);
	all_names = [all_names allfiles(i).name];
	try
		[r,rgb] = fs4(rgb);

		all_y = [];
		all_area = [];
		all_orientation = [];

		if options.show_figure
			% save another image
			figure, hold on
			imagesc(rgb), axis image, axis ij
		end
		for j = 1:length(r)
			if options.show_figure
				plot(r(j).Centroid(1),r(j).Centroid(2),'ro','MarkerSize',10)
			end
			all_y = [all_y r(j).Centroid(2)];
			all_area = [all_area r(j).Area];
			all_orientation = [all_orientation r(j).Orientation];
		end
		if options.show_figure
			saveas(gcf,[p oss allfiles(i).name '_results.png'])
			close all
		end

		% find distances from bottom
		all_y = size(rgb,1) - round(all_y);

		% add to database
		all_positions(1:length(all_y),i) = all_y;
		all_areas(1:length(all_y),i) = all_area;
		all_orientations(1:length(all_y),i) = all_orientation;

	catch me
		disp('Something went wrong with this file. The error is:')
		disp(me.message)

	end
end


% write sheet 1 -- positions on Y axis
temp = all_positions(:,1:length(all_names));
z = find(sum((~isnan(temp)),2) == 0,1,'first');
temp = temp(1:z-1,:);
write_me = [all_names; num2cell(temp)];
for i = 1:size(write_me,1)
	for j = 1:size(write_me,2)
		write_me{i,j} = mat2str(write_me{i,j});
	end
end
if ispc
	xlswrite([p oss 'results.xls'],write_me,'Positions');
else
	cell2csv([p oss 'results_positions.csv'],write_me);
end


% write sheet 2 -- areas
temp = all_areas(:,1:length(all_names));
z = find(sum((~isnan(temp)),2) == 0,1,'first');
temp = temp(1:z-1,:);
write_me = [all_names; num2cell(temp)];
for i = 1:size(write_me,1)
	for j = 1:size(write_me,2)
		write_me{i,j} = mat2str(write_me{i,j});
	end
end
if ispc
	xlswrite([p oss 'results.xls'],write_me,'Areas');
else	
	cell2csv([p oss 'results_areas.csv'],write_me);
end


% write sheet 2 -- orientations
temp = all_orientations(:,1:length(all_names));
z = find(sum((~isnan(temp)),2) == 0,1,'first');
temp = temp(1:z-1,:);
write_me = [all_names; num2cell(temp)];
for i = 1:size(write_me,1)
	for j = 1:size(write_me,2)
		write_me{i,j} = mat2str(write_me{i,j});
	end
end
if ispc
	xlswrite([p oss 'results.xls'],write_me,'Orientations');
else
	cell2csv([p oss 'results_orientations.csv'],write_me);
end



