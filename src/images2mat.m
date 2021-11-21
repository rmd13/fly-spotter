%% images2mat.m
% combines a set of images to a giant 3D matrix
% 
function [images, full_images] = images2mat(path_name, mask, args)

arguments
	path_name (1,1) string 
	mask
	args.channel (1,1) double = 3
	args.subtract_median (1,1) logical = true
end



% find all *JPG images
allfiles = dir(fullfile(path_name,"*.JPG"));


assert(~isempty(allfiles),'No JPG images found!')

% read the first image
rgb = imread(fullfile(path_name, allfiles(1).name));

if isempty(mask)
	% load the first one to get the size right
	mask = true(size(rgb,1),size(rgb,2));
else
	rgb = mask;
end

% convert mask into crop box
crop_x = any(mask,2);
crop_y = any(mask,1);
cropped_image = rgb(crop_x,crop_y,:);

images = zeros(size(cropped_image,1),size(cropped_image,2),length(allfiles),'uint8');
full_images = zeros(size(cropped_image,1),size(cropped_image,2),3,length(allfiles),'uint8');

for i = 1:length(allfiles)
	disp(allfiles(i).name)
	rgb = imread(fullfile(path_name, allfiles(i).name));
	images(:,:,i) = 255 - rgb(crop_x,crop_y,args.channel);
	full_images(:,:,:,i) = rgb(crop_x,crop_y,:);
end

if args.subtract_median
	% subtract the median from all the images
	median_image = median(images,3);
	for i = 1:size(images,3)
		images(:,:,i) = images(:,:,i) - median_image;
	end
end





