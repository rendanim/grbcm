function [nlpd] = nlpd(yt,m,s)

n = size(yt,1);
nlpd =0;
for i=1:n
    nlpd =nlpd-1/n*log(normpdf(yt(i),m(i),s(i)^(0.5)));
    
end
end