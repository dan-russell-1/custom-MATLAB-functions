function J = MP_jacob(xbase,mpc)
% Find the jacobian via numerical approximation
% input: 
    % xbase = vector of angles and voltage magnitudes around which to 
    % linearize and find jacobian
    % mpc = matpower case file - NOTE mpc must have all nodes be generators
    % for it to work
% output:
%   J = [ dA2/dP2 ... dA2/dPn  dA2/dQ2 ... dA2/dQn ]
%       [     :         :         :           :    ]
%       [ dAn/dP2 ... dAn/dPn  dAn/dQ2 ... dAn/dQn ]
%       [ dV2/dP2 ... dV2/dPn  dV2/dQ2 ... dV2/dQn ]
%       [     :         :         :           :    ]
%       [ dVn/dP2 ... dVn/dPn  dVn/dQ2 ... dVn/dQn ]
    
    % init
    delta = 1e-6;                               % very small perturbation
    n = length(xbase);                          % how many inputs/outputs are there
    J = zeros(n);                   % init jacobian
    % loop for each column of jacobian
    for i = 1:n
        % perturb the input to function
        prtrb = zeros(n,1);
        prtrb(i) = delta;                   % vector of perturbation (only 1 element)
        xbaseP = xbase + prtrb;             % plus perturb
        xbaseM = xbase - prtrb;             % minus perturb
        % calculate solution
        J(:,i) = (MPfn(xbaseP,mpc) - MPfn(xbaseM,mpc))/2/delta;
    end
end