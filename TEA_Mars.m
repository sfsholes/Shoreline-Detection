% TEA_MARS.m
% By Steven F. Sholes (sfsholes@uw.edu)
% Jan. 14, 2019
% Sholes et al. 2019 (JGR:Planets) MatLab script used to check for subtle terrace features
% from topographic profiles on HiRISE-derived DEMs

% Manual inspection is still required. There is an included script
% 'checkforTerrace.m' that is called and checks if the necessary criteria 
% are met but it is currently buggy. As discussed in the text and in Jewell
% (2016) and Hare et al. (2001), some seredipity required in choosing the 
% filter-length, polynomial degree, and epsilon values. The epsilon value
% is particularly challenging as there is no 'good value' to choose and is
% a matter of preference. We tend to be more conservative in choosing
% values that find more possible terraces to check. 

% Remember that false positives will also show up, so not all 'found terraces'
% using this script will be terraces. We tend to be conservative, but if
% the topographic data clearly shows landforms not consistent with even
% subtle coastal features (e.g. large ridges) we throw them out. Again, I
% cannot stress this enough that manual inspection of the topographic,
% residual, and derivative data is necessary.

% Input topgoraphic profiles must be of the form:
% Column 1: distance from start (in m)
% Column 2: elevation data (in m)

% ----- INPUT VARIABLES -----
% Change the variables here for your needs

DATA = DATA8; %Replace the parenthetical with the dataset you are using
% Below is an alternative if the data is in reverse order
% (re: needs to be increasing in elevation from left to right)
%DATA = flipud(DATA8);

poly_fit_deg = 3;    % Polynomial degree for the 'idealized slope' 
                     % Could also just import the residual data 
% Savitsky-Golay Filters
SG_Window = 31;      % Must be odd, is in data rows (for HiRISE DEMs 31 approx. 11 m)
SG_Poly = 4;         % Must be <= 12,  we use 4 for Mars data
eps1 = 0.02;         % Small value for excluding 1st Derivative Residual noise, 0.03 for Mars
eps2 = 0.002;        % Small value for excluding 2nd Derivative Residual noise, 0.002 for Mars
peak_win = 40;       % Window size for the 'checkforTerrace.m' module, somewhat buggy
                     %  and not necessary, checking manually works better
                     
full_Q = 0;     % If =0 then runs through all the data
                % If !=0 then runs only for a window below (centered at c)
% Optional Window Size, might be buggy
c = 500;         % Row number of feature of interest (in row number, *not* meters
d = 50;          % Window size, to either side of c (in row number, *not* meters

% ----- SETUP MODEL -----

% Limit the data if the user wants to check it all or just a window
if full_Q == 0      % Check the entire topographic profile
    DEM_min = 1;
    DEM_max = length(DATA(:,1));
else                % Check just a subset centered at c
    DEM_min = max(1,c - d);     % In case of negative values
    DEM_max = min(length(DATA(:,1)),c + d);  % In case of values greater than dataset
end

% Set up physical distance of above for cropping plots
DEM = 2;  % Elevations are in column 2
x_meters_min = DATA(DEM_min,1);
x_meters_max = DATA(DEM_max,1);
y_mean = mean(DATA(:,2));
min_y = min(DATA(DEM_min:DEM_max,DEM));
max_y = max(DATA(DEM_min:DEM_max,DEM))+1;

x_top = DATA(:,1);
y_top = DATA(:,DEM);

% -- BUILD THE TREND SURFACE --
poly_trend = polyfit(x_top, y_top,poly_fit_deg);  % Fit an 'idealized slope'
py_trend = polyval(poly_trend,x_top);             % Fit an 'idealized slope'
% Can also import the trend surface data from ArcGIS

% -- FIND & SMOOTH THE DERIVATIVES --
res = y_top - py_trend;    % Residual topography              
sgres = sgolayfilt(res,SG_Poly,SG_Window);     % Smooth the Residual Topo.
sgd1 = sgolayfilt(gradient(sgres),SG_Poly,SG_Window);   % Smooth the 1st Derivative of Residual
sgd2 = sgolayfilt(gradient(sgd1),SG_Poly,SG_Window);    % Smooth the 2nd Derivative of Residual
sgtopo = sgolayfilt(y_top,SG_Poly,SG_Window);           % Smooth the topography (not needed, but why not compare?)       

% -- CHECK FOR TERRACE MODULE - INCOMPLETE, MANUALLY INSPECT INSTEAD --
% This is just for the checkforTerrace.m module
% It is just finding the local peaks in the data that correspond to each
% feature within the user-designated window-size
[RIs,RIIdx] = findpeaks(sgd1,'MinPeakDistance',peak_win);    % Riser Inflection
[RCs,RCIdx] = findpeaks(-sgd2,'MinPeakDistance',peak_win);   % Riser Crest
[BTs,BTIdx] = findpeaks(-sgd1,'MinPeakDistance',peak_win);   % Benchtop
[KPs,KPIdx] = findpeaks(sgd2,'MinPeakDistance',peak_win);    % Knickpoint

% Find the Means for each derivative to apply the epsilon value (since not
% always centered at zero
sgd1_mean = mean(sgd1);
sgd2_mean = mean(sgd2);

% Run the checkforTerrace module. Slope must be rising to the right for it
% to work (like Figure 2 in text).
[RI,RC,BT,KP,BW,BTE,AAA] = checkforTerrace(x_top,y_top,sgd1,sgd2,RIIdx,RCIdx,BTIdx,KPIdx,eps1,eps2,sgd1_mean,sgd2_mean);
% In theory, BTE should list the benchtop elevation for all terraces picked
% up (if any). 

% ----- PLOTTING -----

figure
subplot(4,1,1)          % Plot the topography
plot(x_top,y_top,'o')   % Topodata
hold on
plot(x_top,sgtopo, 'LineWidth', 2.5)  % Smoothed topodata
%plot(x_top,y_trnd, 'LineWidth', 2)
plot(x_top,py_trend,'LineWidth', 2)   % 'Idealized Slope'
% The following will plot the components (RI,RC,BT,KP) of any terrace found
% via the checkforTerrace module (again, manual inspection is best)
ii = 1;
while ii < length(BT)
    ii;
    plot([x_top(RI(ii)) x_top(RI(ii))],get(gca,'ylim'),'-k', 'LineWidth', 1.5)
    plot([x_top(RC(ii)) x_top(RC(ii))],get(gca,'ylim'),'-b', 'LineWidth', 1.5)
    plot([x_top(BT(ii)) x_top(BT(ii))],get(gca,'ylim'),'-r', 'LineWidth', 1.5)
    plot([x_top(KP(ii)) x_top(KP(ii))],get(gca,'ylim'),'-g', 'LineWidth', 1.5)
    ii = ii + 1;
end
hold off
ylabel('Topography [m]')
xlim([x_meters_min,x_meters_max])
ylim([min_y,max_y])
xlabel('Distance [m]')
%grid

subplot(4,1,2)
plot(x_top,res,'o')     % Plot the Residual Topography
hold on
plot(x_top,sgres, 'LineWidth', 2.5)  % Smoothed Residual Data
hold off
ylabel('Residual [m]')
xlim([x_meters_min,x_meters_max])
xlabel('Distance [m]')
%grid

subplot(4,1,3)
plot(x_top,gradient(sgres),'o')     % Plot the 1st derivative of the smoothed residual data
hold on
plot(x_top,sgd1, 'LineWidth', 2.5)  % Plot the smoothed 1st derivative
%plot(x_top,-sgd1, 'LineWidth', 2.5)
hline = refline([0 sgd1_mean+eps1]);  % Add in a horizontal line for the epsilon values
hline = refline([0 sgd1_mean-eps1]);
hline.Color = 'r';
% The following will plot the components (RI,RC,BT,KP) of any terrace found
% via the checkforTerrace module (again, manual inspection is best)
ii = 1;
while ii < length(BT)
    plot([x_top(BT(ii)) x_top(BT(ii))],get(gca,'ylim'))
    plot([x_top(RI(ii)) x_top(RI(ii))],get(gca,'ylim'))
    ii = ii + 1;
end
hold off
ylabel('Residual 1st Derivative')
xlim([x_meters_min,x_meters_max])
ylim([-0.2,0.2])                    %%%  CHANGE THIS AS NEEDED
xlabel('Distance [m]')
%grid

subplot(4,1,4)
plot(x_top,gradient(sgd1),'o')      % Plot the 2nd derivative of the smoothed 1st derivative data
hold on
plot(x_top,sgd2, 'LineWidth', 2.5)  % Plot the smoothed 2nd derivative
% The following will plot the components (RI,RC,BT,KP) of any terrace found
% via the checkforTerrace module (again, manual inspection is best)
ii = 1;
while ii < length(RC)
    plot([x_top(RC(ii)) x_top(RC(ii))],get(gca,'ylim'))
    plot([x_top(KP(ii)) x_top(KP(ii))],get(gca,'ylim'))
    ii = ii + 1;
end
hold off
hline = refline([0 sgd2_mean+eps2]);    % Add in a horizontal line for the epsilon values
hline = refline([0 sgd2_mean-eps2]);
hline.Color = 'r';
ylabel('Residual 2nd Derivative')
xlim([x_meters_min,x_meters_max])
ylim([-0.01,0.01])
xlabel('Distance [m]')
%grid
