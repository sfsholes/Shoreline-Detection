# Shoreline-Detection
Tools for detecting paleoshorelines from Sholes et al. (2019, JGR:Planets)
doi:10.1029/2018JE005837
Can also cite the permanent repository:
http://hdl.handle.net/1773/42764

Requires: MatLab

This is the topographic expression analysis (TEA) toolkit for detecting paleoshorelines on Mars based on the work of Hare et al. (2001). Full details can be found in the main paper. This parses a topographic profile for the explicit inflection points that are indicative of even subtle terrace and bench landforms associated with erosional coastlines. 

However, this work is still in its infancy and thus we recommend checking the results by eye. Window size (for the filter), chosen epsilon (for the derivative residual topography), and polynomial choice (for the filter) will all drastically affect the results. 

To RUN:
  - Import your topographic profile into the MATLAB dataset. 
    *IMPORTANT* this profile should be with lower elevations at the start. 
    Column A should be distance from start (in m)
    Column B should be elevation (in m)
  - Edit the poly_fit_deg, SG_Window, SG_Poly, eps1, eps2, peak_win variables as necessary (in TEA_Mars.m)
  - Run the TEA_Mars.m script

This will create a few new datasets that list the locations of the found terrace candidates: RI (riser inflection location), RC (riser crest location), BT (bench top location), KP (knickpoint location), and BTE (benchtop elevation). 

TO DO:
This is currently the published version, but could be improved where commented as such in the files to work more efficiently and better parse out false positives and false negatives. 

