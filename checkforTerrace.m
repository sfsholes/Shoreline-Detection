% checkForTerrace.m
% By: Steven F. Sholes (sfsholes@uw.edu)
% Jan. 10, 2019

% Sholes et al. 2019 (JGR:Planets) module for use in TEA_Mars.m

%   NOTE: The input topographic data is read from left to right
%         i.e. you MUST input data going to higher elevations to the right

% This is still a bit clunky and probably buggy
% The idea is that it goes through all the peaks found and checks that
% those above the epsilon values are in the correct order. 

% I am still not convinced this works properly all the time, so I highly recommend
% manual inspection of the plots from TEA_Mars.m for the correct order of
% the peaks in the 1st and 2nd derivatives corresponding to the terrace
% components. This should be re-written to be more concise and accurate. 
% But it can be a decent first-check to see if there are any possible
% terraces in the topographic profile. 

function [RI,RC,BT,KP,BW,BTE,AAA] = checkforTerrace(x_top,y_top,sgd1,sgd2,RIIdx,RCIdx,BTIdx,KPIdx,eps1,eps2,sgd1_mean,sgd2_mean)
i = 2;
[A, B, C, D, E, F, G, H] = deal(0);
[W,X,Y,Z,W2,X2,Y2,Z2]= deal(0);
[RI,RI_idx,RI_x,RC,RC_idx,RC_x,KP,KP_idx,KP_x,BT,BT_idx,BT_x,BW,BTE,AAA] = deal([]);
while i < length(RIIdx)     % Start at the first RI peak
    [j,k,l,ii, jj, kk, ll] = deal(2);
    % Set a bunch of values to remember where you are
    ii = i - 1;
    A = RIIdx(i);
    A2 = RIIdx(ii);
    W = i;
    W2 = RIIdx(i);
    while j < length(RCIdx)  % Make sure the next value is an RC
        B = RCIdx(j);
        jj = j - 1;
        B2 = RCIdx(jj);
        if (B > A) && (B2 < A)
            X = j;
            X2 = RCIdx(j);
            %disp('Check One')
            j = length(RCIdx)+1;
        end
        j = j + 1;
    end
    while k < length(BTIdx)  % Followed by a BT
        C = BTIdx(k);
        kk = k - 1;
        C2 = BTIdx(kk);
        if (C > B) && (C2 < A)
            Y = k;
            Y2 = BTIdx(k);
            %disp('Check Two')
            k = length(BTIdx)+1;
        end
        k = k + 1;
    end
    while l < length(KPIdx) % And followed by a KP
        D = KPIdx(l);
        ll = l - 1;
        D2 = KPIdx(ll);
        if (D > C) && (D2 < A)
            Z = l;
            Z2 = KPIdx(l);
            %disp('Check Three')
            l = length(KPIdx)+1;
        end
        l = l+1;
    end
    if (W2<X2)&&(X2<Y2)&&(Y2<Z2)      % Check they are in the same order
        if (sgd1(W2)>=(sgd1_mean+eps1)) && (sgd1(Y2)<=(sgd1_mean-eps1))
            % Make sure 1st derivatives are within the epsilon values
            if (sgd2(X2)<=(sgd2_mean-eps2)) && (sgd2(Z2)>=(sgd2_mean+eps2))
                % Make sure the 2nd derivatives are within the epsilon
                % value
                %Idx_list = [Idx_list;[W2,X2,Y2,Z2]];
                bench = x_top(Z2) - x_top(X2);
                RI_idx = [RI_idx;W2];
                RI_x = [RI_x;x_top(W2)];
                RI = [RI_idx,RI_x];
                RC_idx = [RC_idx;X2];
                RC_x = [RC_x;x_top(X2)];
                RC = [RC_idx,RC_x];
                BT_idx = [BT_idx;Y2];
                BT_x = [BT_x;x_top(Y2)];
                BT = [BT_idx,BT_x];
                KP_idx = [KP_idx;Z2];
                KP_x = [KP_x;x_top(Z2)];
                KP = [KP_idx,KP_x];
                BW = [BW;bench];
                BTE = [BTE;y_top(Y2)];
                AAA = [y_top(RC_idx);y_top(KP_idx)] 
                % AAA has the elevation of the start and stop of the benchwidth
                disp('Found Possible Terraces. Number to check:')
            end
        end
    end
    i = i + 1;
end    
disp(length(RI)) % Did you find anything?
