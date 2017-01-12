%% Example file for ba_interp3

mex -O ba_interp3.cpp
%% Interpolation of 3D volumes (e.g. distance transforms)

% Create Low Resolution Volume
sz=16;
[dist.x dist.y dist.z] = meshgrid(linspace(-1,1,sz), linspace(-1,1,sz), linspace(-1,1,sz));
dist.D = min(sqrt((dist.x - 0).^2 + (dist.y - 0.35).^2 + (dist.z - 0).^2) - 0.5, ...
                   sqrt((dist.x - 0).^2 + (dist.y + 0.35).^2 + (dist.z - 0).^2) - 0.5);

interpolators={@interp3, @ba_interp3};                 
methods = {'nearest', 'linear', 'cubic'};
sizes=[20:10:100];
samples=20;

for interpolator_i=1:numel(interpolators)
  interp_fun = interpolators{interpolator_i};
  figure(interpolator_i);

  subplot 221;
  cla
  hx = slice(dist.x, dist.y, dist.z, dist.D, 0.2, [], []);
  set(hx,'EdgeColor','none');
  p = patch(isosurface(dist.x,dist.y,dist.z,dist.D, 0));
  isonormals(dist.x,dist.y,dist.z,dist.D,p)
  set(p,'FaceColor','red','EdgeColor','none');
  daspect([1 1 1])
  view(3);
  axis([-1 1 -1 1 -1 1]);
  camlight
  lighting gouraud
  title('Low resolution distance image');

  %% Increase resolution by interpolation
  for size_i=1:numel(sizes)
    sz1 = sizes(size_i);
    [dist_h.x dist_h.y dist_h.z] = meshgrid(linspace(-1,1,sz1), linspace(-1,1,sz1), linspace(-1,1,sz1));
    for i=1:numel(methods)
      for sample=1:samples
        tic;
        dist_h.D = interp_fun(dist.x, dist.y, dist.z, dist.D, dist_h.x, dist_h.y, dist_h.z, methods{i});
        took(interpolator_i,size_i,i,sample)=toc;
      end

      subplot(2,2,1+i);
      cla
      hx=slice(dist_h.x, dist_h.y, dist_h.z, dist_h.D, 0.2, [], []);
      set(hx,'EdgeColor','none');
      p = patch(isosurface(dist_h.x,dist_h.y,dist_h.z,dist_h.D, 0));
      isonormals(dist_h.x,dist_h.y,dist_h.z,dist_h.D,p)
      set(p,'FaceColor','red','EdgeColor','none');
      daspect([1 1 1])
      view(3);
      axis([-1 1 -1 1 -1 1]);
      camlight
      lighting gouraud
      title({sprintf('Interpolated distance image (%s)', methods{i}), ...
             sprintf('Interpolation with %s took %.2fs', strrep(func2str(interp_fun), '_', '\_'), took(interpolator_i,size_i,i))});
      drawnow
    end
  end

end
%%
print -dpng ba_interp3.png
!trim-images ba_interp3.png -o cropped_; mv cropped_ba_interp3.png ba_interp3.png; convert ba_interp3.png -resize 500x500 ba_interp3_small.png
%%
figure(3);
clf
for i=1:numel(methods)
  subplot(numel(methods),1,i);
  errorbar(sizes.^3, mean(took(1,:,i,:),4), std(took(1,:,i,:),1,4), 'g.--', 'linewidth', 2, 'markersize', 20);
  hold on
  errorbar(sizes.^3, mean(took(2,:,i,:),4), std(took(2,:,i,:),1,4), 'b.--', 'linewidth', 2, 'markersize', 20);
  hold off
  time_steps = [0.1:0.1:0.9 1:1:9 10:5:50];
  axis([0 max(sizes.^3) 0 min(time_steps(time_steps>max(max(max(took(:,:,i,:))))))]);
  title({sprintf('Speed comparision: "%s" interpolation', methods{i}), sprintf('Average of %g runs', samples)});
  legend(cellfun(@(x) strrep(func2str(x), '_', '\_'), interpolators, 'uniformoutput', false), 'location', 'northwest');
  xlabel('Number of Interpolation points');
  ylabel('Elapsed time (s)');
  grid on
end
print -depsc ba_interp3_speed.eps
!convert ba_interp3_speed.eps ba_interp3_speed.png
!trim-images ba_interp3_speed.png -o cropped_; mv cropped_ba_interp3_speed.png ba_interp3_speed.png
