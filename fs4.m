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
r0 = regionprops(L,I,'Area','Centroid','MaxIntensity','Orientation');
if length(r0) > 100 % a sign of something going wrong
	r0([r0.MaxIntensity] < max(max(I))/2) = [];
end
r = r0;
disp([mat2str(length(r)) ' objects found.'])

% disp('Ignoring very small objects...')
r([r.Area]<options.min_size) = [];
r0([r0.Area]<options.min_size) = [];

if length(r) > 10
	disp('Resolving very large objects...')
	resolve_these = find([r.Area]>1.5*mean([r.Area]));
	for i = 1:length(resolve_these)
		resolve_this = resolve_these(i);
		% blank out everything else
		ff = L;
		ff(ff~=resolve_this) = 0;
		ff(ff~=0) = 1;
		ff = cutImage(ff',r0(resolve_this).Centroid,50)';

		% keep opening the image till iwe split the object
		for s = 1:20
			ff_open = imopen(ff,strel('disk',s,0));
			rr =  (regionprops(logical(ff_open),logical(ff_open),'Centroid','Area','MaxIntensity','Orientation'));
			if length(rr) > 1
				disp('Succesfully resolved overlapping flies...')
				break
			end
		end

		if length(rr) == 0
			% plot(r(i).Centroid(1),r(i).Centroid(2),'r+','MarkerSize',12)
		else
			for j = 1:length(rr)
				rr(j).Centroid(1) = rr(j).Centroid(1) + r(resolve_this).Centroid(1) - 50 ;
				rr(j).Centroid(2) = rr(j).Centroid(2) + r(resolve_this).Centroid(2) - 50;
			end
			r(resolve_this) = [];
			r = [r; rr];
		end
	end
end

