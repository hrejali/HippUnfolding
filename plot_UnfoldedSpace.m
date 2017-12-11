function out = plot_UnfoldedSpace(unfolded_fn,MRimage)
% finds and plots the MRimage intensities at each A-P and P-D coordinate.
% includes average borders from current study, and rescales the
% image according to average real world size from the current study.

load('avg_borders.mat')
SEM_borders = stdev_borders./sqrt(size(borders,3));

load([unfolded_fn '/data.mat']);
MRdata = load_untouch_nii(MRimage);
MRdata = double(MRdata.img);

% crop (already done in the example image loaded here)
% MRdata = zeros(size(labelmap));
% MRdata(:) = MRdata(cropping==1);
sz = size(MRdata);

% if left, flip on sagittal (z plane, or the third dimension in this matrix)
if isleft
    MRdata = flipdim(MRdata,3);
end


%% match indices

inds=find(Laplace_PD>0 & Laplace_AP>0 & Laplace_thick>0);

u=Laplace_AP(inds);
v=Laplace_PD(inds);
w=Laplace_thick(inds);
[x,y,z]=ind2sub(sz,inds);
c = nan(size(x));
for i = 1:length(x)
    c(i) = MRdata(x(i),y(i),z(i));
end

%% set parameters

interp='linear';
extrap='none';
Nu=ceil(u*sz(2));
Nv=ceil(v*sz(3));
Nw=ceil(w*sz(1));

reduce_thickness = linspace(sz(1),10,12);

%% plot!

figure; 
lin = linspace(0,1,12);
for n = 1:12
    i = lin(n);
    j = 1-i;
    subplot(3,4,n);
    Nw=ceil(w*reduce_thickness(n)) + sz(1)/2;
    scatter3(Nu*i + x*j, Nv*i + y*j, Nw*i + z*j,[],c); 
    axis([0 sz(1) 0 sz(2) 0 sz(3)]); 
    colormap('jet'); view(-1,0);
end


%% old plots

figure; hold on;
axis([1 100 1 100]);
imagesc(flatmap_interp)
colormap('jet')

% overlay data from manual segmentations (in referenced paper) to help get oriented in UnfoldedSpace
for b = 1:4
    by = avg_borders(:,b);
    bx = [1:100]';
    plot(by,'k');
    dy = SEM_borders(:,b);
    fill([bx;flipud(bx)],[by-dy;flipud(by+dy)],[0 0 0],'FaceAlpha', 0.3,'linestyle','none');
end
bx = [5 18]; by = [1,100]; plot(bx,by,'--k'); %vertical component
bx = [20 28]; by = [1,100]; plot(bx,by,'--k'); %uncus
bx = [36 40]; by = [1,100]; plot(bx,by,'--k'); %head
bx = [84 80]; by = [1,100]; plot(bx,by,'--k'); %tail
xlabel('Anterior - Posterior (%)');
ylabel('Proximal - Distal (%)');
title(sprintf('Average subfield borders overlaid on\nintracortical myelin'));
annotation('textbox',[0.45 0.20 0.08 0.06],'String',{'Sub'},'LineStyle','none','FontWeight','bold');
annotation('textbox',[0.45 0.50 0.08 0.06],'String',{'CA1'},'LineStyle','none','FontWeight','bold');
annotation('textbox',[0.45 0.66 0.08 0.06],'String',{'CA2'},'LineStyle','none','FontWeight','bold');
annotation('textbox',[0.45 0.76 0.08 0.06],'String',{'CA3'},'LineStyle','none','FontWeight','bold');
annotation('textbox',[0.45 0.845 0.20 0.06],'String',{'DG'},'LineStyle','none','FontWeight','bold');

annotation('textbox',[0.80 0.1 0.20 0.06],'String',{'tail'},'LineStyle','none');
annotation('textbox',[0.55 0.1 0.20 0.06],'String',{'body'},'LineStyle','none');
annotation('textbox',[0.30 0.1 0.20 0.06],'String',{'head'},'LineStyle','none');
annotation('textbox',[0.18 0.1 0.20 0.06],'String',{'uncus'},'LineStyle','none');
annotation('textbox',[0.115 0.15 0.20 0.06],'String',{sprintf('vert.\nunc.')},'LineStyle','none');

end