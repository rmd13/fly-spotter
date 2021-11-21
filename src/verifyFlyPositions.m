%% markCropBox
% video annotation GUI built on top of movieAnalyser


classdef verifyFlyPositions < movieAnalyser

	properties
		all_objects
		full_images
		parent_dir
		x_scale
		y_scale
		original_file_names
	end % end properties

	methods

		function a = createGUI(a)
			createGUI@movieAnalyser(a);

			a.ui_handles.fig.WindowButtonDownFcn = @a.mouseCallback;

			delete(a.ui_handles.scrubber);
			delete(a.ui_handles.pause_button);

			a.ui_handles.add_fly_button = uicontrol('Style','togglebutton','Units','normalized','Position',[0.2 .01 .1 .05],'Callback',@a.addFlyCallback,'String','+Fly');

			a.ui_handles.remove_fly_button = uicontrol('Style','togglebutton','Units','normalized','Position',[0.35 .01 .1 .05],'Callback',@a.removeFlyCallback,'String','-Fly');

			a.ui_handles.export_data_button = uicontrol('Style','pushbutton','Units','normalized','Position',[0.55 .01 .1 .05],'Callback',@a.exportData,'String','Save Data');

			a.plot_handles.ax.XTick = [];
			a.plot_handles.ax.YTick = [];

			a.ui_handles.prev_button.Position = [0.01 0.05 0.05 0.9];
			a.ui_handles.next_button.Position = [.94 .05 .05 .9];
			a.ui_handles.next_button.FontSize = 40;
			a.ui_handles.prev_button.FontSize = 40;



			a.operateOnFrame;



		end % end create GUI


		function a = operateOnFrame(a)
			cla(a.plot_handles.ax)

			I = a.full_images(:,:,:,a.current_frame);
			a.plot_handles.im = imagesc(I);
			hold on

			r = a.all_objects(a.current_frame).r;
			for j = 1:length(r)
				plot(r(j).Centroid(1),r(j).Centroid(2),'ro','MarkerSize',10)
			end

			a.ui_handles.fig.Name = a.original_file_names{a.current_frame};

		end


		function v = mouseCallback(v,~,~)
			% simply add a point
			p = v.plot_handles.ax.CurrentPoint;
			p = p(1,1:2);

			if min(p) < 1
				return
			end
			if p(1) > size(v.full_images,2)
				return
			end
			if p(2) > size(v.full_images,1)
				return
			end

			if v.ui_handles.add_fly_button.Value == 1
				r = v.all_objects(v.current_frame).r;
				r(end+1).Centroid = p;
				v.all_objects(v.current_frame).r = r;
				v.operateOnFrame;

			elseif v.ui_handles.remove_fly_button.Value == 1
				r = v.all_objects(v.current_frame).r;
				% find the closest object
				centroid_locs = reshape([r.Centroid],2,length(r));
				[~,idx] = min((centroid_locs(1,:) - p(1)).^2 + (centroid_locs(2,:) - p(2)).^2);
				idx = idx(1);
				r(idx) = [];
				v.all_objects(v.current_frame).r = r;
				v.operateOnFrame;

			end

		end

		function v = addFlyCallback(v,~,~)
			if v.ui_handles.add_fly_button.Value == 1
				v.ui_handles.add_fly_button.FontWeight = 'bold';
				v.ui_handles.add_fly_button.FontSize = 20;
				v.ui_handles.remove_fly_button.Value = 0;
				v.ui_handles.remove_fly_button.FontWeight = 'normal';
				v.ui_handles.remove_fly_button.FontSize = 10;
			else
				v.ui_handles.add_fly_button.FontWeight = 'normal';
				v.ui_handles.add_fly_button.FontSize = 10;
			end

		end

		function v = removeFlyCallback(v,~,~)
			if v.ui_handles.remove_fly_button.Value == 1
				v.ui_handles.remove_fly_button.FontWeight = 'bold';
				v.ui_handles.remove_fly_button.FontSize = 20;
				v.ui_handles.add_fly_button.Value = 0;
				v.ui_handles.add_fly_button.FontWeight = 'normal';
				v.ui_handles.add_fly_button.FontSize = 10;
			else
				v.ui_handles.remove_fly_button.FontWeight = 'normal';
				v.ui_handles.remove_fly_button.FontSize = 10;
			end
		end

		function v = exportData(v,~,~)
			v.ui_handles.fig.Name = 'Saving...';
			drawnow
			% determine the maximum number of flies in the entire dataset
			nflies_max = 0;
			for i = 1:length(v.all_objects)
				nflies_max = max([nflies_max length(v.all_objects(i).r)]);
			end

			% save X positions
			temp = cell(nflies_max+1,length(v.all_objects));
			for i = 1:length(v.all_objects)
				temp(1,i) = v.original_file_names(i);
				for j = 1:length(v.all_objects(i).r)
					temp{j+1,i} = v.x_scale*v.all_objects(i).r(j).Centroid(1);
				end
			end
			cell2csv(fullfile(v.parent_dir, 'results_X.csv'),temp);

			% save Y positions
			temp = cell(nflies_max+1,length(v.all_objects));
			for i = 1:length(v.all_objects)
				temp(1,i) = v.original_file_names(i);
				for j = 1:length(v.all_objects(i).r)
					temp{j+1,i} = v.y_scale*v.all_objects(i).r(j).Centroid(2);
				end
			end
			cell2csv(fullfile(v.parent_dir, 'results_Y.csv'),temp);

			% save Areas
			temp = cell(nflies_max+1,length(v.all_objects));
			for i = 1:length(v.all_objects)
				temp(1,i) = v.original_file_names(i);
				for j = 1:length(v.all_objects(i).r)
					temp{j+1,i} = v.all_objects(i).r(j).Area;
				end
			end
			cell2csv(fullfile(v.parent_dir, 'results_Areas.csv'),temp);

			v.ui_handles.fig.Name = 'Data exported!';
			drawnow
		end




	end % end methods
end