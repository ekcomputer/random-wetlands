function [C, cm, order, k, O, A]=confusionmatStats(validation, label, class_names)
% script to compute confusion matrix from builtin function and output
% addition stats: users/producers errors, overall accuracy, kappa coeff
% makes use of Matlab File Exchange/ Github script, copied here: 
% kappa: https://www.mathworks.com/matlabcentral/fileexchange/15365-cohen-s-kappa

% Input:    validation: nx1 vector of user-supplied class names ('ground truth') 
%           label:      nx1 vector of class names assigned by classifier
%           class_names:cell array of class names

% Output:   C:          extended confusion matrix (with row/col totals)
%           cm:         confusion matrix object for plotting
%           order:      variable order
%           k:          Cohen's kappa (linear weighting, can be adjused)
%           O:          Overall accuracy
%           A:          Users/producers accuracy matrix: col one is PA, col
%                       2 is UA, rows give vars
[C, order]=confusionmat(validation,label);

%%  Layden version https://www.mathworks.com/matlabcentral/fileexchange/69943-simple-cohen-s-kappa
% C=C;
% n = sum(C(:)); % get total N
% C = C./n; % Convert confusion matrix counts to proportion of n
% r = sum(C,2); % row sum
% s = sum(C); % column sum
% expected = r*s; % expected proportion for random agree
% po = sum(diag(C)); % Observed proportion correct
% pe = sum(diag(expected)); % Proportion correct expected
% k = (po-pe)/(1-pe); % Cohen's kappa

%% Cardillo version

k=kappa(C, 0, 0.5);
%% Kyzivat version

C1=zeros(1+size(C)); C1(1:end-1, 1:end-1)=C;
C1(end,:)=sum(C1);
C1(:,end)=sum(C1,2);
O=100*sum(trace(C))/sum(C(:));


%% Kyzivat UA and PA
r = sum(C,2); % row sum
c = sum(C); % column sum
D=diag(C);
for i=1:length(D)
    for j=[1,2]
        S=sum(C,j);
       A(i,j)= 100*D(i)/S(i);
    end
end
fprintf('\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n')
fprintf('Overall accuracy: %2.1f %%\n',O)
% fprintf('User''s accuracy (1-commission error): %2.1f\n',A)
% P=zeros(2,2);
% P(1)=C(7)*C(3); %% <=========== HERE
% P(2)=C(8)*C(3);
% P(3)=C(7)*C(6);
% P(4)=C(8)*C(6);
% ex= trace(P)/sum(sum(P)); %expected chance agreement
% k=1*(.01*OA-ex)/(1-ex);

%% note 
%% Plot
% l=env.class_names; l{end+1}='ZTotal';
if exist('confusionchart')==5  % if R2018b or greater, when this function was introduced
    figure;
    cm=confusionchart(C, class_names);
    cm.RowSummary = 'row-normalized';
    cm.ColumnSummary = 'column-normalized';
    cm.FontSize=14;
    cm.XLabel='Predicted Class (Errors of ommission)';
    cm.YLabel='True Class (Errors of commission)';

        % make second copy with totals, not percents
    h=figure;
    cm1 = copyobj(cm,h);
    cm1.RowSummary = 'absolute';
    cm1.ColumnSummary = 'absolute';
else 
    cm=NaN;
end

%% Display CM table, regardless of whether or not it opens in a figure
varNames=class_names;
    varNames{end+1}='Total';
    cm_table=array2table(C1, 'VariableNames', varNames, 'RowNames', varNames);
    fprintf('\nConfusion Matrix:\n')
    disp(cm_table)
% C=C1; % for output
