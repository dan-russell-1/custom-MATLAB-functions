function [R,X] = mpc_RX_incidence(mpc)
% following procedure from Kekatos LDF slides
    % extract values from MPC
    n = size(mpc.bus,1);                % number of nodes
    b = size(mpc.branch,1);             % number of branches
    fbus = mpc.branch(:,1);
    tbus = mpc.branch(:,2);
    Rv = mpc.branch(:,3);
    Xv = mpc.branch(:,4);
    % init incidence matrix
    incdnc = zeros(b,n);
    % form incidence matrix
    for ii = 1:b
        incdnc(ii, fbus(ii)) = 1;
        incdnc(ii, tbus(ii)) = -1;
    end
    % use matrix multiplication to get R and X
    A = incdnc(:,2:end);
    R = (A \ diag(Rv)) / A';
    X = (A \ diag(Xv)) / A';
end