clear all
rng(100);

run('../gpml-matlab-v4.2-2018-06-11/startup.m')


filelist = {'./uci/concrete/concrete.mat';'./uci/airline/airline.mat';'./uci/airfoil/airfoil.mat';'./uci/kin40k/kin40k.mat';'./uci/energy/energy.mat';'./uci/protein/protein.mat';};


%%
rBCM_nlpd = zeros(4,10);
GRBCM_nlpd = zeros(4,10);
%NPAE_nlpd = zeros(4,10);

GPoE_nlpd = zeros(4,10);


rBCM_RMSE = zeros(4,10);
GRBCM_RMSE = zeros(4,10);
%NPAE_RMSE = zeros(4,10);
GPoE_RMSE = zeros(4,10);



%%

for j= 1:4
    data_file = load(filelist{j});
    data = data_file.data;
    data = normalize(data);

    [n,m] = size(data);

    cv0 = cvpartition(n, 'k', 10);
    sf2 = 1 ; ell = 1 ; sn2 = 0.1 ; 
    partitionCriterion = 'random' ; % 'random', 'kmeans'

    % train
    opts.Xnorm = 'Y' ; opts.Ynorm = 'Y' ;
    opts.Ms = round(n/100) ; opts.partitionCriterion = partitionCriterion ;
    opts.ell = ell ; opts.sf2 = sf2 ; opts.sn2 = sn2 ;
    opts.meanfunc = []; opts.covfunc = @covSEard; opts.likfunc = @likGauss; opts.inffunc = @infGaussLik ;
    opts.numOptFC = 100;
    batch_size = 1000;

    for i=1: cv0.NumTestSets
        trainIdx = cv0.training(i);
        testIdx = cv0.test(i);
        x = data(trainIdx, 1:end-1);
        y = data(trainIdx, end);
        xt = data(testIdx, 1:end-1);
        yt = data(testIdx, end);
        [models,t_dGP_train] = aggregation_train(x,y,opts) ;
         % PoE, GPoE, BCM, RBCM, GRBCM, NPAE
        %[mu_GPoE,s2_GPoE,t_GPoE_predict] = aggregation_predict(xt,models,'GPoE') ;
        num_batches = ceil(size(xt,1)/batch_size);
        if size(xt,1)> batch_size
            for k=1:num_batches
                [mu_GRBCM_k,s2_GRBCM_k,t] = aggregation_predict(xt((k-1)*batch_size+1:(k)*batch_size,:),models,'GRBCM');
                [mu_GPoE_k,s2_GPoE_k,t] = aggregation_predict(xt((k-1)*batch_size+1:(k)*batch_size,:),models,'GPoE');
                %[mu_NPAE_k,s2_NPAE_k,t] = aggregation_predict(xt((k-1)*batch_size+1:(k)*batch_size,:),models,'NPAE');

                if k==1
                    mu_GRBCM = mu_GRBCM_k;
                    s2_GRBCM = s2_GRBCM_k;
                    mu_GPoE = mu_GPoE_k;
                    s2_GPoE = s2_GPoE_k;
                 %   mu_NPAE = mu_NPAE_k;
                  %  s2_NPAE = s2_NPAE_k;
                else
                     mu_GRBCM = vertcat(mu_GRBCM, mu_GRBCM_k);
                     s2_GRBCM = vertcat(s2_GRBCM,s2_GRBCM_k);
                      mu_GPoE = vertcat(mu_GPoE, mu_GPoE_k);
                     s2_GPoE = vertcat(s2_GRBCM,s2_GPoE_k);
                   %   mu_NPAE = vertcat(mu_NPAE, mu_NPAE_k);
                    % s2_NPAE = vertcat(s2_NPAE,s2_NPAE_k);
                end
            end
        else
            [mu_GRBCM,s2_GRBCM,t] = aggregation_predict(xt,models,'GRBCM');
            [mu_GPoE,s2_GPoE,t] = aggregation_predict(xt,models,'GPoE');
               
        end
        %rBCM_RMSE(j,i) = sqrt(mean((yt- mu_RBCM).^2));
        GRBCM_RMSE(j,i) =sqrt(mean((yt- mu_GRBCM).^2));
        %NPAE_RMSE(j,i) = sqrt(mean((yt -mu_NPAE).^2));
        GPoE_RMSE(j,i) = sqrt(mean((yt -mu_GPoE).^2));
        %rBCM_nlpd(j,i) = nlpd(yt,mu_RBCM, s2_RBCM);
        GPoE_nlpd(j,i) = nlpd(yt,mu_GPoE, s2_GPoE);
        %NPAE_nlpd(j,i) = nlpd(yt,mu_NPAE, s2_NPAE);
        GRBCM_nlpd(j,i) = nlpd(yt,mu_GRBCM, s2_GRBCM);    
    end
end
    




%%
%nlpds =[mean(GRBCM_nlpd), mean(GPoE_nlpd), mean(NPAE_nlpd)];
%rmses =[mean(GRBCM_RMSE), mean(GPoE_RMSE), mean(NPAE_RMSE)];
X = categorical({'GRBCM','GPOE'});
X = reordercats(X,{'GRBCM','GPOE'});

save nlpds.mat GRBCM_nlpd GPoE_nlpd
save rmse.mat GRBCM_RMSE GPoE_RMSE X

