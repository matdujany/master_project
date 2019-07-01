function h_plot = check_limb_assignment(weights_fused,parms,recordID)

weights_fused_norm = zeros(size(weights_fused,1)/3,parms.n_m);
for j=1:size(weights_fused,1)/3
    weights_fused_norm(j,:)=sqrt(sum( weights_fused([1:3]+3*(j-1),:).^2 ));
end

weights_fused_limbass = weights_fused_norm;

%%
[~,closest_LC] = max(weights_fused_limbass,[],1);

likelihood_LC = zeros(1,parms.n_m);
for i=1:parms.n_m
    values = maxk(weights_fused_limbass(:,i),2);
    likelihood_LC(i) = values(1)/values(2);
end
format bank;
disp(likelihood_LC);
format;
disp(min(likelihood_LC));

%%
good_closest_LC = get_good_closest_LC(parms,recordID);

score_LC = sum(closest_LC' == good_closest_LC)
if sum(abs(good_closest_LC'-closest_LC))~=0
    disp('Problem with closest LCs found');
end

%%
h_plot=plot_weights_limb_assignment(weights_fused_limbass,parms);
h_plot.Colormap = [1 1 1; 1 0 0; 0 1 0; 1 1 0];%white, red, green, yellow
caxis('manual');
set(gca,'CLim',[1 4]);
patches = findobj(gca, 'type', 'patch');
patches.CData=ones(parms.n_m*parms.n_lc,1);
for i=1:parms.n_m
    if good_closest_LC(i) == closest_LC(i)
        patches.CData(parms.n_lc*i - closest_LC(i) +1) = 3;
    else
        patches.CData(parms.n_lc*i -  closest_LC(i) + 1) = 2;
        patches.CData(parms.n_lc*i -  good_closest_LC(i) + 1) = 4;
    end
end
h_plot;
hold on;
for i=1:parms.n_m
   text(i-0.5,-0.5,num2str(likelihood_LC(i),'%.2f'),'FontSize',15,'HorizontalAlignment','center');
end
text(-0.5,-0.5,'Ratio','FontSize',15,'HorizontalAlignment','center');