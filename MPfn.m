% define matpower "function"
function y = MPfn(x,mpc)
% inputs:
    % x is a vector of P and Q net injections at each bus in the mpc
    % mpc is a matpower case file - note MPC must have generators at every 
    % node for this to work
% output:
    % y is a vector of voltage angles (radians) and voltage magnitudes (pu)

    % extract info
    n = size(mpc.bus,1);    % number of nodes
    Pnet = [0; x(1:n-1)];     % add 0 to front for substation
    % disp(Pnet)
    Qnet = [0; x(n:2*n-2)]; % add 0 to front for substation
    % plug into matpower case
    for i = 2:n             % start at first non-substation node    
        if Pnet(i) >= 0     % active power
            mpc.gen(i,2) = Pnet(i);     % set generation
            mpc.bus(i,3) = 0;           % set demand
        else
            mpc.gen(i,2) = 0;           % set generation
            mpc.bus(i,3) = abs(Pnet(i));% set demand
        end
        if Qnet(i) >= 0     % reactive power
            mpc.gen(i,3) = Qnet(i);     % set generation
            mpc.bus(i,4) = 0;           % set demand
        else
            mpc.gen(i,3) = 0;           % set generation
            mpc.bus(i,4) = abs(Qnet(i));% set demand
        end
    end
    % solve matpower case
    ops = mpoption('verbose', 0, 'out.all', 0);
    res = runpf(mpc,ops);
    % return results
    if res.success ~= 1         % power flow failed, warn
        disp('runpf command failed to converge :(')
        y = zeros(2*n-2,1);
    else
        delta = res.bus(2:end,9)/360*2*pi;  % pull voltage angles
        vmag = res.bus(2:end,8);            % pull voltage mag
        y = [delta; vmag];
    end 
end