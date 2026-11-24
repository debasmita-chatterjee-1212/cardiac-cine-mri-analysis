function counts = analyse_class_balance(Y)
% Display class counts and proportions.
Y=categorical(Y); cats=categories(Y); n=zeros(numel(cats),1);
for k=1:numel(cats), n(k)=sum(Y==cats{k}); end
counts=table(string(cats),n,n/sum(n),'VariableNames',{'Class','Count','Proportion'});
disp(counts);
figure('Color','w'); bar(categorical(counts.Class),counts.Count);
ylabel('Patient count'); title('Class distribution'); grid on;
end
