% meant to work with "vanguard images" from TWK
% 
% created by Srinivas Gorur-Shandilya at 10:14 , 29 December 2015. Contact me at http://srinivas.gs/contact/
% 
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.

function [r,rgb] = fs4(rgb,varargin)

% get options from dependencies 
options = getOptionsFromDeps(mfilename);

% options and defaults
options.min_size = 20;

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

% disp('Using blue channel...')
I = 255 - rgb(:,:,3);



% disp('Ignoring the top and sides of the image...')
I(:,1:1500) = 0;
I(:,3000:end) = 0;
I(1:50,:) = 0;

% disp('Correcting uneven illumination...')
% I=biasCorrection_bipoly(I);
I = imtophat(I,strel('square',30));

% disp('Adjusting contrast...')
% I = imadjust(I);

% disp('Thresholding image...')
% Ibw = (im2bw(I,.9));
temp = sort(I(:),'descend');
Ibw = im2bw(I,mean(temp(1:1e3))/500);
Ibw = imclose(Ibw,strel('disk',5));

L = bwlabel(Ibw);

% disp('Detecting objects...')
r0 = regionprops(L,I,'Area','Centroid','MaxIntensity','Orientation','Perimeter');
if length(r0) > 100 % a sign of something going wrong
	r0([r0.MaxIntensity] < max(max(I))/2) = [];
end
r = r0;
disp([mat2str(length(r)) ' objects found.'])

% disp('Ignoring very small objects...')
small_objects = find([r.Area]<options.min_size);
r(small_objects) = [];
r0(small_objects) = [];
for i = 1:length(small_objects)
	L(L==small_objects(i)) = 0;
end

if length(r) > 2
	% build areas using the labelled image instead of the regionprops object
	resolve_these = find([r.Perimeter]>1.5*mean([r.Perimeter]));

	if length(resolve_these)
		disp('Resolving very large objects...')
	end
	for i = 1:length(resolve_these)
		resolve_this = resolve_these(i);
		% blank out everything else
		ff = L;
		ff = cutImage(ff',r0(resolve_this).Centroid,50)';
		dominant_label = mode(nonzeros(ff(:)));
		ff(ff~=dominant_label) = 0;
		% ff(ff~=L(round(r(resolve_this).Centroid(2)),round(r(resolve_this).Centroid(1)))) = 0;
		ff(ff~=0) = 1;
		

		% keep opening the image till we split the object
		ok = false;
		for s = 1:20
			ff_open = imopen(ff,strel('disk',s,0));
			rr =  (regionprops(logical(ff_open),logical(ff_open),'Centroid','Area','MaxIntensity','Orientation','Perimeter'));
			if length(rr) > 1
				disp('Succesfully resolved overlapping flies...')
				ok = true;
				break
			end
		end

		if ~ok
			disp('Automatic object deconvolution failed. Using k-means...')			
			% use k-means to split them
			temp = regionprops(ff,'PixelList');
			[idx,C] = kmeans(temp.PixelList,2);
			rr = r(resolve_this);
			rr(1).Centroid(1) =  C(1,1);
			rr(1).Centroid(2) =  C(1,2);
			rr(1).Area = sum(idx==1);

			rr(2).Centroid(1) =  C(2,1);
			rr(2).Centroid(2) =  C(2,2);
			rr(2).Area = sum(idx==2);

			% also inherit the orientations 
			rr(1).Orientation = r0(resolve_this).Orientation;
			rr(2).Orientation = r0(resolve_this).Orientation;

		end

		if length(rr) == 0

		else
			for j = 1:length(rr)
				rr(j).Centroid(1) = rr(j).Centroid(1) + r(resolve_this).Centroid(1) - 50 ;
				rr(j).Centroid(2) = rr(j).Centroid(2) + r(resolve_this).Centroid(2) - 50;
			end
			r(resolve_this) = [];
			r = [r; rr(:)];
		end
	end
end

