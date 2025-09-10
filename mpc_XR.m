function [X, R] = mpc_XR(mpc)
    % input: a matpower case file
    % output: X, R matrices 
    % extract MPC elements
    branch = mpc.branch;
    ft = branch(:,1:2);
    rvec = branch(:,3);
    xvec = branch(:,4);
    nodes = size(mpc.bus,1);
    edges = size(branch,1);
    % create digraph object for path finding
    G = digraph(ft(:,1),ft(:,2));   % create digraph object
    % get shortest paths
    paths = cell(nodes,1);
    for i = 1:nodes
        p = shortestpath(G,1,i);
        paths{i} = p(2:end) - 1;    % rm first element b/c needed, -1 to start at 0
    end
    paths(1) = [];      % rm first entry because empty
    % create X,R matrices
    R = zeros(edges); X = zeros(edges);     % init
    for ii = 1:edges                        % loop all rows
        for jj = 1:ii                       % loop columns from left edge to diagonal
            common = intersect(paths{ii},paths{jj});    % find common path
            xv_com = xvec(common);  % pull x values using indices 
            xv_sum = sum(xv_com);   % sum the x values
            X(ii,jj) = xv_sum;      % store in X
            rv_com = rvec(common);  % repeat for r 
            rv_sum = sum(rv_com);   
            R(ii,jj) = rv_sum;
        end
    end
    X = X + tril(X,-1)';            % mirror values to upper tri
    R = R + tril(R,-1)';            % mirror values to upper tri
    disp('Warning!!! This function can spit out incorrect X,R values depending on the ordering of the from and to bus!!!')
    disp('Use mpc_RX_incidence instead. Its also WAY faster. Youre welcome')
end
