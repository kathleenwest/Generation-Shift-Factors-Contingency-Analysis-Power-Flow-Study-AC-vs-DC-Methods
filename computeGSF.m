function [deltPflo,gsfvalues] = computeGSF(gennumber,swingbus,bprimematrix,bprimematrixnoswing,branchpqflows,branch)
%computeGSF    Computes the Generation Shift Factors
%   Returns (nbranch x 1) vector plus a (nbranch x 3) matrix with the from
%   bus, to bus, and GSF
%   Input is the generator number to be outaged
%   gennumber,swingbus,bprimematrix,bprimematrixnoswing,branchpqflows,
%   branch the input paramters may be combined into a simplier input matrix in a revised version. 
%   Assumes input matrices are mathematically correct
%   Assumes the user input for the bus is a valid generator number

%------------------------------------
% Formulate the P Matrix
%------------------------------------

D = size(bprimematrix);
P = zeros(D(1),1);
for i=1:D(1)
    if i == swingbus
        P(i,1) = -1;
    else
        if i == gennumber
          P(i,1) = 1;
        else
        end;
    end;
end;

% Reduce the matrix for the swing bus

Ptemp = zeros(D(1)-1,1);

for i=1:D(1)
    if i < swingbus
        Ptemp(i,1) = P(i,1) ;
    else
        if i > swingbus
          Ptemp(i-1,1) = P(i,1);
        else
        end;
    end;
    
end;
P = Ptemp;

%----------------------------------------------------
% Solve for the Theta Values
%----------------------------------------------------
% P = B'*Theta

% Computes the Theta Matrix
thetavalues = bprimematrixnoswing\P;
D = size(thetavalues);
thetavalues2 = zeros(D(1)+1,1);
for i=1:D(1)+1
    if i < swingbus
        thetavalues2(i,1) = thetavalues(i,1);
    else
        if i > swingbus
         thetavalues2(i,1) = thetavalues(i-1,1);  
        else
            if i == swingbus
              thetavalues2(i,1) = 0;  
            else
            end;
        end;
    end;
end;

% this holds all the delta thetas for each bus including the zero value for
% the swing bus
thetavalues = thetavalues2;
D = size(thetavalues);
thetavalues2 = zeros(D(1),2);
for i=1:D(1)
    for j=1:2
        if j==1
         thetavalues2(i,j) = i;    
        else
          thetavalues2(i,j) = thetavalues(i,1);  
        end;
    end;
end;

thetavalues = thetavalues2;
%----------------------------------------------------
% Calculates the GSF's
%----------------------------------------------------

% Find the Branch Series Reactance
D = size(branch);
branchr = [branch(:,1) zeros(D(1),1) branch(:,2) zeros(D(1),1) branch(:,4)];
D = size(branchr);
F = size(thetavalues);
gsfvalues = [branchr zeros(D(1),1)];

% This part assigns the theta values to the columns corresponding to the
% branch t, from
for i=1:D(1)
    for m=1:F(1)
        if gsfvalues(i,1) == thetavalues(m,1)  
             gsfvalues(i,2) = thetavalues(m,2);  
        else
                    if gsfvalues(i,3) == thetavalues(m,1)  
                        gsfvalues(i,4) = thetavalues(m,2);  
                    else   
                    end;     
        end;   
    end;
    
end;

% This calculates the GSF in the final column

D = size(gsfvalues);

for i=1:D(1)
    gsfvalues(i,6) = (gsfvalues(i,2) - gsfvalues(i,4))/gsfvalues(i,5);
end;

%-----------------------------------------------------------------------
% Final Results
%-----------------------------------------------------------------------

% This is the GSF (nbranch x 1) vector per the assignment
deltPflo = [gsfvalues(:,6)];

% This is the GSF (nbranch x 3) including the from bus, to bus, and GSF

gsfvalues = [gsfvalues(:,1) gsfvalues(:,3) gsfvalues(:,6) ];

return;