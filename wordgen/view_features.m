function view_features(clips,features,row,col,i)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% View features as video                                                 %
% Input:
%     actions: list of actions
%     clips: Nx2 array where clips(i,1:2) are start/end frame features
%     features: MxF_SIZE, a features(i,:) is a frame of clip c if clips(c,1)<=i<=clips(c,2)
%     labels: label of the clip, the action of clips c is actions(labels(i))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%figure('Name',char(actions(labels(i))));
clip_fts = features(clips(i,1):clips(i,2),:);
 for i=1:size(clip_fts,1)    
        imshow(reshape(clip_fts(i,:),[row col]));
        pause(0.01);    
 end
end

