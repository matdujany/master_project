AllChannels = 1;

%% fused part
splitDirections =0;
%for each motor, determine on which LC it has the highest connection
%weights
closest_LC.dirfused_allc = find_closest_LC(weights,n_iter,splitDirections,1,parms);
closest_LC.dirfused_Zc  = find_closest_LC(weights,n_iter,splitDirections,0,parms);

%create empty graph
G_fused = digraph;
for m=1:parms.n_m
    G_fused = addnode(G_fused,{strcat('M',num2str(m))});
end

for sensor_LC = 1:parms.n_lc
    G_fused=addnode(G_fused,{strcat('S',num2str(sensor_LC))});
end

for m=1:parms.n_m
    if AllChannels == 1
        G_fused = addedge(G_fused,m,parms.n_m+closest_LC.dirfused_allc(m),1);
    else
        G_fused = addedge(G_fused,m,parms.n_m+closest_LC.dirfused_Zc(m),1);
    end
end

%here we sort the actuators, the first are the closest to the IMU.
sorted_actuators_IMU_fused = find_closest_IMU(weights,n_iter,splitDirections,AllChannels,parms);

G_fused = addnode(G_fused,{'IMU'});
for i=1:parms.n_m/2
    G_fused = addedge(G_fused,sorted_actuators_IMU_fused(i),parms.n_m+parms.n_lc+1,1);
end

%% split part
splitDirections=1;
closest_LC.dirsplit_allc = find_closest_LC(weights,n_iter,splitDirections,1,parms);
closest_LC.dirsplit_Zc  = find_closest_LC(weights,n_iter,splitDirections,0,parms);

%create empty graph
G_split = digraph;
for m=1:parms.n_m
    G_split = addnode(G_split,{strcat('M',num2str(m),'-')});
    G_split = addnode(G_split,{strcat('M',num2str(m),'+')});
end

for sensor_LC = 1:parms.n_lc
    G_split=addnode(G_split,{strcat('S',num2str(sensor_LC))});
end

for m=1:parms.n_m*2
    if AllChannels == 1
        G_split = addedge(G_split,m,2*parms.n_m+closest_LC.dirsplit_allc(m),1);
    else
        G_split = addedge(G_split,m,2*parms.n_m+closest_LC.dirsplit_Zc(m),1);
    end
end

%here we sort the actuators, the first are the closest to the IMU.
sorted_actuators_IMU_split = find_closest_IMU(weights,n_iter,splitDirections,AllChannels,parms);

G_split = addnode(G_split,{'IMU'});
for i=1:parms.n_m
    G_split = addedge(G_split,sorted_actuators_IMU_split(i),2*parms.n_m+parms.n_lc+1,1);
end

%%
figure;
subplot(1,2,1)
plot(G_fused);
title('With fused directions');
subplot(1,2,2)
plot(G_split);
title('With split directions');
%sgtitle('Motor sensor graph');
