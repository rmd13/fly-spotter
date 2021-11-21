%% batchSpot
% fast, batch-based particle spotter
% batchSpot spots particles in a batch of images
% it assumes that noise, background, etc. are the same in
% all images, and uses this to subtract backgrounds and find objects
% usage:
% batchSpot

function batchSpot(args)

arguments
	args.min_size = 10;
	args.x_scale = 1;
	args.y_scale = 1;
	args.threshold = 100;
	args.chosen_folder (1,1) string = ""
end



if ~isfolder(args.chosen_folder)
	args.chosen_folder = uigetdir(pwd,'Choose folder with JPG images');
end



if ~(isstring(args.chosen_folder) && isfolder(args.chosen_folder))
	disp('No folder chosen, quitting')
	return
end
allfiles = dir(strcat(args.chosen_folder,filesep,'*.JPG'));

% make a movie analyser GUI to get a crop box
m = markCropBox;

m.folder_name = char(args.chosen_folder);
m.createGUI;

uiwait(m.ui_handles.fig)

m.quitMovieAnalyser;
drawnow

% % convert images to matrix
[images,full_images] = images2mat(args.chosen_folder, m.mask);

% find all the flies, etc. 
all_objects = struct;

tic;
for i = 1:size(images,3)
    I = images(:,:,i);

    I = I > 255*graythresh(images(:,:,i));
    r = regionprops(I,'Area','Orientation','Centroid');
    r([r.Area] < args.min_size) = [];
    all_objects(i).r = r;


end
t = toc;
disp(['Finished analyzing ' mat2str(size(images,3)) 'images in ' mat2str(t) 'sec'])

v = verifyFlyPositions;
v.original_file_names = {allfiles.name};
v.parent_dir = args.chosen_folder;
v.x_scale = 1;
v.y_scale  = 1;
v.nframes = length(all_objects);
v.all_objects = all_objects;
v.full_images = full_images;
v.createGUI;


