clear all
rng(100);

run('../gpml-matlab-v4.2-2018-06-11/startup.m')


filelist = {'./uci/airfoil/airfoil.mat';'.uci/kin40k/kin40k.mat';'./uci/energy/energy.mat';'./uci/protein/protein.mat';};


%%
rBCM_nlpd = zeros(4,10);
GRBCM_nlpd = zeros(4,10);
NPAE_nlpd = zeros(4,10);
GPoE_nlpd = zeros(4,10);


rBCM_RMSE = zeros(4,10);
GRBCM_RMSE = zeros(4,10);
NPAE_RMSE = zeros(4,10);
GPoE_RMSE = zeros(4,10);



%%

for j= 1:4
    data_file = load(filelist{j});
    data = data_file.data;
    data = normalize(data);

    [n,m] = size(data);

    cv0 = cvpartition(n, 'k', 10);
    sf2 = 1 ; ell = 1 ; sn2 = 0.1 ; 
    partitionCriterion = 'kmeans' ; % 'random', 'kmeans'

    % train
    opts.Xnorm = 'Y' ; opts.Ynorm = 'Y' ;
    opts.Ms = round(n/100) ; opts.partitionCriterion = partitionCriterion ;
    opts.ell = ell ; opts.sf2 = sf2 ; opts.sn2 = sn2 ;
    opts.meanfunc = []; opts.covfunc = @covSEard; opts.likfunc = @likGauss; opts.inffunc = @infGaussLik ;
    opts.numOptFC = 100;
    
    for i=1: cv0.NumTestSets
        trainIdx = cv0.training(i);
        testIdx = cv0.test(i);
        x = data(trainIdx, 1:end-1);
        y = data(trainIdx, end);
        xt = data(testIdx, 1:end-1);
        yt = data(testIdx, end);
        [models,t_dGP_train] = aggregation_train(x,y,opts) ;
         % PoE, GPoE, BCM, RBCM, GRBCM, NPAE
        [mu_GPoE,s2_GPoE,t_GPoE_predict] = aggregation_predict(xt,models,'GPoE') ;
        [mu_GRBCM,s2_GRBCM,t_GRBCM_predict] = aggregation_predict(xt,models,'GRBCM') ;
        [mu_RBCM,s2_RBCM,t_RBCM_predict] = aggregation_predict(xt,models,'RBCM') ;
        [mu_NPAE,s2_NPAE,t_NPAE_predict] = aggregation_predict(xt,models,'NPAE') ;
        rBCM_RMSE(j,i) = sqrt(mean((yt- mu_RBCM).^2));
        GRBCM_RMSE(j,i) =sqrt(mean((yt- mu_GRBCM).^2));
        NPAE_RMSE(j,i) = sqrt(mean((yt -mu_NPAE).^2));
        GPoE_RMSE(j,i) = sqrt(mean((yt -mu_GPoE).^2));
        rBCM_nlpd(j,i) = nlpd(yt,mu_RBCM, s2_RBCM);
        GPoE_nlpd(j,i) = nlpd(yt,mu_GPoE, s2_GPoE);
        NPAE_nlpd(j,i) = nlpd(yt,mu_NPAE, s2_NPAE);
        GRBCM_nlpd(j,i) = nlpd(yt,mu_GRBCM, s2_GRBCM);    
    end
end
    




%%
nlpds =[mean(GRBCM_nlpd), mean(GPoE_nlpd), mean(NPAE_nlpd)];
rmses =[mean(GRBCM_RMSE), mean(GPoE_RMSE), mean(NPAE_RMSE)];
X = categorical({'GRBCM','GPOE','NPAE'});
X = reordercats(X,{'GRBCM','GPOE','NPAE'});

save nlpds.mat GRBCM_nlpd NPAE_nlpd GPoE_nlpd
save rmse.mat GRBCM_RMSE NPAE_RMSE GPoE_RMSE X

