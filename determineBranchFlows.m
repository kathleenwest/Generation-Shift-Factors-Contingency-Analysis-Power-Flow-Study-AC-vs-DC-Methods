function [newbranchflows] = determineBranchFlows(gsfvalues, baseMWflows, genMW)
D = size(baseMWflows);
newbranchflows = zeros(D(1),D(2));
for i=1:D(1)
    newbranchflows(i,1) = baseMWflows(i,1);
    newbranchflows(i,2) = baseMWflows(i,2);
    newbranchflows(i,3) = baseMWflows(i,3) + gsfvalues(i,3)*(-genMW);
end;

return;