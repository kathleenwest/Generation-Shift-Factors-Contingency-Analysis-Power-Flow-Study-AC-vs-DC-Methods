% Project # 1
% Kathleen Williams
% ECE 557

% Determines Topology of the System
[baseMVA, bus, gen, branch, area, gencost] = wscc9bus;

% Determines the Swing Bus
D = size(bus);
swingbus = -1;
for i=1:D(1)
    if bus(i,2) == 3;
        swingbus = bus(i,1);
    else
    end;
end;
% swingbus is now a global variable storing the reference bus

%--------------------------------------------------------------------------
% Set-Up B-Prime Matrix 
%--------------------------------------------------------------------------

%-------------------------------------------------------------------------
% Code for Computing the B-Prime Matrix Per Class Discussion on 09-15-2005
%-------------------------------------------------------------------------
alg = 2; % BX Method
[Bp, Bpp] =  makeB(baseMVA, bus, branch, alg);

%--------------------------------------------------------------------------
% This is my original code for creating the bprime matrix from scratch
% This code is only specific for a BX Method
%--------------------------------------------------------------------------

temp = [branch(:,1) branch(:,2) branch(:,4)];
clear baseMVA, clear gen, clear branch, clear area, clear gencost;
D = size(temp);

%Initialize the B' Prime Matrix to Zero
for i=1:9
    for j=1:9
    bus1(i,j) = [0];
    end;
end;

for i=1:9
    for j=1:9
        if (i == j)
            % Busii
            for m=1:9
                if temp(m,1) == i | temp(m,2) == i
                 bus1(i,j) = bus1(i,j) + 1/temp(m,3);
                else

                end;        
            end; 
                    
        else
            % Busij
               for k=1:9 
                   if (temp(k,1) == i & temp(k,2) == j)
                     bus1(i,j) = -1/temp(k,3);
                     bus1(j,i) = -1/temp(k,3);
                   else  
                   end;
               end ;           
        end;
    end;
end;

bprimematrix = bus1;
clear bus1, clear temp, clear i, clear j, clear l, clear k, clear m, clear bus, clear D; 

% The B prime matrix is designated as bprimematrix variable

%--------------------------------------------------------------------------
% Set-Up B-Prime Matrix Minus Swing Bus
%--------------------------------------------------------------------------

bprimematrixnoswing = zeros(8,8);

for i=1:9
    for j = 1:9
     if (i ~= swingbus & j ~= swingbus)    
        if (i < swingbus & j < swingbus)
          bprimematrixnoswing(i,j) = bprimematrix(i,j);  
        else
            if (i > swingbus & j < swingbus)  
                bprimematrixnoswing(i-1,j) = bprimematrix(i,j); 
              else
                  if (i < swingbus & j > swingbus)   
                   bprimematrixnoswing(i,j-1) = bprimematrix(i,j); 
                  else
                       if (i > swingbus & j > swingbus)  
                          bprimematrixnoswing(i-1,j-1) = bprimematrix(i,j);
                       else
                       end;
                   end;                  
                end;
            end;
        end;
     end;

end;
% bprimematrixnoswing holds the matrix with the swing bus removed


%--------------------------------------------------------------------------
% Normal Case Power Flow Using Fast-Decoupled
%--------------------------------------------------------------------------

% Set-up the options for Fast-Decoupled Power Flow
options = mpoption('PF_ALG', 2);

% Run a Fast-Decoupled Power Flow for the 9-Bus system
[baseMVA, bus, gen, branch, success] = runpf('wscc9bus',options);

%--------------------------------------------------------------------------
% Save the Branch Flows and Compute the Max Flow
%--------------------------------------------------------------------------
temp = [branch(:,1) branch(:,2) abs(branch(:,12)) abs(branch(:,14)) abs(branch(:,13)) abs(branch(:,15))];
D = size(temp);
temp2 = temp;
for i=1:D(1)
    if temp(i,3) > temp(i,4)
        temp(i,3) = temp(i,3);    
    else
        if temp(i,3) < temp(i,4)
            temp(i,3) = temp(i,4);
        else
        end;
    end;
        if temp(i,5) > temp(i,6)
        temp(i,5) = temp(i,5);    
    else
        if temp(i,5) < temp(i,6)
            temp(i,5) = temp(i,6);
        else
        end;
    end;
end;

temp3 = [branch(:,1) branch(:,2) temp(:,3) temp(:,5)];
branchpqflows = temp3;
clear temp, clear temp2, clear temp3, clear success, clear i, clear j, clear D;
D = size(branchpqflows);

%--------------------------------------------------------------------------
% Use the From Bus as the P,Q Flows Per Class Discussion on 09-15-2005
%--------------------------------------------------------------------------

% The Branch flows were changed from the maximums of each bus to just the
% values of the from bus

%--------------------------------------------------------------------------
% Print the Branch Flows 
%--------------------------------------------------------------------------


    fprintf('\n=============================================');
    fprintf('\n|     Branch Flow Data                      |');
    fprintf('\n=============================================');
    fprintf('\n From Bus \tTo Bus   \tP (MW)  \tQ (MVAr) ');
    fprintf('\n -------- \t-------- \t------- \t-------- ');
for i=1:D(1)
    fprintf('\n %1.0f \t\t\t%1.0f \t\t%6f \t\t%6f', branchpqflows(i,1), branchpqflows(i,2), branch(i,12), branch(i,13));
end;

clear i, clear D;
fprintf('\n\n');
fprintf('\n\n');
    fprintf('\n=============================================');
    fprintf('\n|     Contingency Analysis  - XB            |');
    fprintf('\n=============================================');


%---------------------------------------------------------------------
% Retrieve GSF Values
%---------------------------------------------------------------------

gennumber = 3; % You must define the outaged generator bus number here

fprintf('\n\n');
fprintf('Generator Bus Number ');
fprintf('%1.0f', gennumber); 
fprintf(' is currently out of service');

[deltPflo,gsfvalues] = computeGSF(gennumber,swingbus,bprimematrix,bprimematrixnoswing,branchpqflows,branch);
fprintf('\n\n');


    fprintf('\n=============================================');
    fprintf('\n|    GSF Values By Branch                   |');
    fprintf('\n=============================================');
    fprintf('\n From Bus \tTo Bus   \tValue ');
    fprintf('\n -------- \t------ \t  --------');
    D = size(gsfvalues);
for i=1:D(1)
    fprintf('\n %1.0f \t\t\t%1.0f \t\t\t%6f', gsfvalues(i,1), gsfvalues(i,2), gsfvalues(i,3));
end;



%----------------------------------------------------------------------
% Retrieve Post-Contingency MW branch flows
%----------------------------------------------------------------------
branchpqflows = [branchpqflows(:,1), branchpqflows(:,2), branch(:,12), branch(:,13)];
baseMWflows = [branchpqflows(:,1), branchpqflows(:,2) branchpqflows(:,3)];

% Determine the GenMW for the Outaged Generator
D = size(gen);
for i=1:D(1)
    if gen(i,1) == gennumber
        genMW = gen(i,2);
    else
    end;
end;
fprintf('\n\n');
[newbranchflows] = determineBranchFlows(gsfvalues, baseMWflows, genMW);

    fprintf('\n=============================================');
    fprintf('\n|    Post-Contingency MW branch flows       |');
    fprintf('\n=============================================');
    fprintf('\n From Bus \tTo Bus   \tMW ');
    fprintf('\n -------- \t------ \t  --------');
    D = size(newbranchflows);
for i=1:D(1)
    fprintf('\n %1.0f \t\t\t%1.0f \t\t\t%6f', newbranchflows(i,1), newbranchflows(i,2), newbranchflows(i,3));
end

