%% markCropBox
% video annotation GUI built on top of movieAnalyser


classdef markCropBox < movieAnalyser

	properties
		folder_name
		mask
	end % end properties

	methods

		function a = createGUI(a)
			createGUI@movieAnalyser(a);

			p = a.ui_handles.pause_button.Position;
			a.ui_handles.mark_roi_button = uicontrol(a.ui_handles.fig,'Units',a.ui_handles.next_button.Units,'Position',p,'Style','pushbutton','String','Mark Crop','Callback',@a.markCrop);

			delete(a.ui_handles.next_button); %.Position;
			delete(a.ui_handles.prev_button);
			delete(a.ui_handles.pause_button);
			delete(a.ui_handles.scrubber);

			allfiles = dir([a.folder_name   filesep '*.jpg']);
			rgb = imread([a.folder_name filesep allfiles(1).name]);

			% load the first file. 
			a.plot_handles.im.CData = rgb;

		end % end create GUI

		function a = markCrop(a,~,~)
			h = imrect(a.plot_handles.ax);
        	crop_box = wait(h);
        	a.mask = createMask(h);
       
		end




	end % end methods
end