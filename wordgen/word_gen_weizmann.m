function word_gen_weizmann(setting_file)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This script convert clips into words
%% sontran2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
eval(setting_file);

%% Get the training
trn_f_inx = [];
for i=TRN_INX
    trn_f_inx = [trn_f_inx clips(i,1):clips(i,2)];
end
o_trn_features = features(trn_f_inx',:);
o_features     = features;
%% PCA
coeffs = [];
if PCA_RED >0
    [coeffs, o_trn_features] = princomp(o_trn_features);
    o_trn_features = o_trn_features(:,1:PCA_RED);
    o_features = features*coeffs(:,1:PCA_RED);
end
if strcmp(F_TYPE,'srbm')
    % Normalize data to have zeros mean and unit variance        
    M_ = mean(o_trn_features);
    D_ = std(o_trn_features);        
    o_features = (o_features-repmat(M_,size(o_features,1),1))./repmat(D_,size(o_features,1),1);
    o_features(isnan(o_features)) = 0;
    o_features(isinf(o_features)) = 0;
    o_trn_features = o_features(trn_f_inx',:);
end
%% Get features & labels
for iii = 1:TRIAL_NUM
    fprintf('Starting trial %d\n',iii);
    features = o_features;
    trn_features = o_trn_features;
    str_date = datestr(now, 30);
switch F_TYPE
    case 'rbm'
        % Training with RBM and return new features                        
        if rbm_conf.sNum==0, rbm_conf.sNum = size(trn_features,1); end;
        disp(rbm_conf);
        [W visB hidB] = training_rbm_(rbm_conf,trn_features);
        save(strcat(EXP_FILE,F_TYPE,'_',num2str(PCA_RED),'_',str_date,'_rbm.mat'),'W','visB','hidB');
        features = logistic(features*W + repmat(hidB,size(features,1),1));    
        trn_features = features(trn_f_inx',:);                
    case 'srbm'        
        disp(srbm_conf);
        [W visB hidB] = training_srbm_(srbm_conf,trn_features);
        save(strcat(EXP_FILE,F_TYPE,'_',num2str(PCA_RED),'_',str_date,'_srbm.mat'),'W','visB','hidB');
        features = logistic(features*W + repmat(hidB,size(features,1),1));    
        trn_features = features(trn_f_inx',:);
end

%% Visualize
MN = min(min(W));
 MX = max(max(W));
figure;show_images((W'-MN)/(MX-MN),36,54,54);
%% Run K-means to obtain the words 
    
WRD_FILE = strcat(EXP_FILE,F_TYPE,'_',num2str(PCA_RED),'_words_',num2str(WORD_NUM));
switch K_TOOL
    case 1
        % MATLAB TOOLBOX
        opts = statset('Display','final');
        [vw, C] = kmeans(double(trn_features),WORD_NUM,...
                'distance','sqEuclidean',...
                'emptyaction','drop',...
                'replicates',5,...
                'options',opts);
    case 2
        % VGG K-MEAN by Mark Everingham
        cluster_options.maxiters = MAX_ITER;
        cluster_options.verbose  = VERBOSITY;   
        [C,sse] = vgg_kmeans(double(trn_features'), WORD_NUM, cluster_options);
        C= C';       
end
% v-words for testing data
v_words = assign_words(features,C);
%% Compute occurences
trn_dat = zeros(size(TRN_INX,2),WORD_NUM);
trn_lab      = labels(TRN_INX);
for i=1:size(TRN_INX,2)    
    occ = accumarray(v_words(clips(TRN_INX(i),1):clips(TRN_INX(i),2))',1)';
    trn_dat(i,1:size(occ,2)) = occ;   
end

tst_dat = zeros(size(TST_INX,2),WORD_NUM);
tst_lab      = labels(TST_INX);
for i=1:size(TST_INX,2)
    occ = accumarray(v_words(clips(TST_INX(i),1):clips(TST_INX(i),2))',1)';
    tst_dat(i,1:size(occ,2)) = occ;    
end
%% Save file
WRD_FILE_ = strcat(WRD_FILE,'_',str_date,'.mat');
save(WRD_FILE_,'C','trn_dat','trn_lab','tst_dat','tst_lab','clips','v_words','coeffs','sse');
end
end