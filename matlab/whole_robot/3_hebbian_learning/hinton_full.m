function h=hinton_full(weights_robotis,weights_pos_robotis,parms)

n_iter = parms.n_twitches;
weights = weights_robotis{n_iter};
weights_pos = weights_pos_robotis{n_iter};

%% rescaling
weights = weights';
weights_pos = weights_pos';
weights_lc = weights(:,1:parms.n_lc*3);
weights_acc = weights(:,parms.n_lc*3+1:parms.n_lc*3+3);
weights_gyro = weights(:,parms.n_lc*3+4:parms.n_lc*3+6);

weights_rescaled = [rescale(weights_pos) rescale(weights_lc) rescale(weights_acc) rescale(weights_gyro)];

[h,fig_parms]=hinton_raw(weights_rescaled);
hold on;
x_min = fig_parms.xmin-0.2;
x_max = fig_parms.xmax+0.2;
y_min = fig_parms.ymin-0.2;
y_max = fig_parms.ymax+0.2;
fontSize = 18;

%line labels
x_shift = 1.5;
for i=1:parms.n_m
    text(x_min-x_shift,2*i-0.5,['M' num2str(parms.n_m+1-i) ' -'],'FontSize',fontSize-2,'HorizontalAlignment','left');
    text(x_min-x_shift,2*(i-1)+0.5,['M' num2str(parms.n_m+1-i) ' +'],'FontSize',fontSize-2,'HorizontalAlignment','left');
    if i<parms.n_m
        plot([x_min x_max],[2*i 2*i],'k--')
    end
end

%column labels
y_shift_motors = 0.9;
for i=1:parms.n_m
    text(i,y_max+y_shift_motors,['M' num2str(i)],'FontSize',fontSize-2,'HorizontalAlignment','right');
end

y_shift_1 = 0.6;
y_shift_2 = 1.2;
x_shift_motors = parms.n_m;
plot(x_shift_motors+[0 0],[y_min y_max],'k--');
for i=1:parms.n_lc
    text(x_shift_motors+3*(i-1)+1.5,y_max+y_shift_2,sprintf(['Loadcell ' num2str(i)]),'FontSize',fontSize-2,'HorizontalAlignment','center');
    plot(x_shift_motors+[3*i 3*i],[y_min y_max],'k--');
end

text(x_shift_motors+3*parms.n_lc+1.5,y_max+y_shift_2,sprintf('Accelero.'),'FontSize',fontSize-2,'HorizontalAlignment','center');
plot(x_shift_motors+[3*(parms.n_lc+1) 3*(parms.n_lc+1)],[y_min y_max],'k--');
text(x_shift_motors+3*(parms.n_lc+1)+1.5,y_max+y_shift_2,sprintf('Gyro.'),'FontSize',fontSize-2,'HorizontalAlignment','center');

for i=1:parms.n_lc+1
    text(x_shift_motors+3*(i-1)+0.5,y_max+y_shift_1,'X','FontSize',fontSize-4,'HorizontalAlignment','center');
    text(x_shift_motors+3*(i-1)+1.5,y_max+y_shift_1,'Y','FontSize',fontSize-4,'HorizontalAlignment','center');
    text(x_shift_motors+3*(i-1)+2.5,y_max+y_shift_1,'Z','FontSize',fontSize-4,'HorizontalAlignment','center');
end
text(x_shift_motors+3*(parms.n_lc+1)+0.5,y_max+y_shift_1,'Roll','FontSize',fontSize-6,'HorizontalAlignment','center');
text(x_shift_motors+3*(parms.n_lc+1)+1.5,y_max+y_shift_1,'Pitch','FontSize',fontSize-6,'HorizontalAlignment','center');
text(x_shift_motors+3*(parms.n_lc+1)+2.5,y_max+y_shift_1,'Yaw','FontSize',fontSize-6,'HorizontalAlignment','center');
  
h.Color = 'w';
hold off;
end

function weights_rescaled = rescale(weights)
weights_rescaled = weights/(max(max(abs(weights))));
end