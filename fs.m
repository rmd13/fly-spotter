% read image
im0 = imread('DSC_0108.JPG');
im = im0;

im = im2bw(imadjust(squeeze(im(:,:,1)))); % using only the red channel
% background is 1, objects are 0

% remove the edges of the measuring cylinder
im = im - imclose(im,strel('line',50,90));
im = im - min(min(im));

% remove some junk 
im = imclose(im,strel('disk',2,0));



% make sure no flies are colliding 
L = bwlabel(1-im);
r0 = regionprops(L,'Area','Centroid');
r = r0;  % r will be modified and re-arranged as we split flies


% show the initial result
figure, hold on, imagesc(im0), axis image
for i = 1:length(r)
	plot(r(i).Centroid(1),r(i).Centroid(2),'ro','MarkerSize',14)
end


resolve_these = find([r.Area]>1.5*mean([r.Area]));
for i = 1:length(resolve_these)
	resolve_this = resolve_these(i);
	% blank out everything else
	ff = L;
	ff(ff~=resolve_this) = 0;
	ff(ff~=0) = 1;
	ff = cutImage(ff',r0(resolve_this).Centroid,50);

	% keep opening the image till iwe split the object
	for s = 1:20
		ff_open = imopen(ff,strel('disk',s,0));
		rr =  (regionprops(logical(ff_open),'Centroid','Area'));
		if length(rr) > 1

			break
		end
	end

	if length(rr) == 0
		plot(r(i).Centroid(1),r(i).Centroid(2),'r+','MarkerSize',12)
	else
		for j = 1:length(rr)
			rr(j).Centroid(1) = rr(j).Centroid(1) + r(resolve_this).Centroid(1) - 50 ;
			rr(j).Centroid(2) = rr(j).Centroid(2) + r(resolve_this).Centroid(2) - 50;
		end
		r(resolve_this) = [];
		r = [r; rr];
	end
end


% show the final result
for i = 1:length(r)
	plot(r(i).Centroid(1),r(i).Centroid(2),'b+')
end
