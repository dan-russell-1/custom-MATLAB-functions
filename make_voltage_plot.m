function make_voltage_plot(V_all, fbus, tbus, Rvec, Xvec, colorvec, colors, ledge)
%% inputs:
% V_all = time x nodes matrix
% f/tbus = from and to bus lists
% r/xvec = vectors of r and x values
% colorvec = vec of 1,2,3... for colors
% colors = cell array of color triplets
% ledge = ledgend entries in cell array
%% outputs: plot
    % get network info
    iters = size(V_all,1);
    nodes = size(V_all, 2);
    edges = size(fbus,1);


    % create digraph object for path finding
    G = digraph(fbus,tbus);   % create digraph object

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
            xv_com = Xvec(common);  % pull x values using indices 
            xv_sum = sum(xv_com);   % sum the x values
            X(ii,jj) = xv_sum;      % store in X
            rv_com = Rvec(common);  % repeat for r 
            rv_sum = sum(rv_com);   
            R(ii,jj) = rv_sum;
        end
    end
    % not needed for these ops but doing it because it's needed for R X matrices
    X = X + tril(X,-1)';            % mirror values to upper tri
    R = R + tril(R,-1)';            % mirror values to upper tri
    xd = diag(X);
    rd = diag(R);
    elec_dist = sqrt(xd.^2 + rd.^2);
    elec_dist = [0; elec_dist];     % add a zero for the head node

    disp(size(elec_dist))
    disp(size(V_all))
    
    % make figure
    figure;
    hold on;
    for i = 1:iters
        scatter(elec_dist,V_all(i,:)', ...
            'filled', ...
            'MarkerFaceColor',colors{colorvec(i)}, ...
            'MarkerFaceAlpha', 0.2, ...
            'MarkerEdgeAlpha', 0.2, ...
            'HandleVisibility', 'off')
    end
    xlabel('Impedance to Head $\sqrt{r^2 + x^2}$','FontSize',14,'Interpreter','latex')
    ylabel('Voltage p.u.','FontSize',14,'Interpreter','latex')
    yline(1.05,'k:','LineWidth',2, 'HandleVisibility', 'off')
    yline(.95,'k:','LineWidth',2,'DisplayName','Limits')
    grid on;
    for i = 1:length(ledge)
        scatter(NaN, NaN, 1, ...
            'filled', ...
            'MarkerFaceColor', colors{i}, ...
            'DisplayName', ledge{i});
    end
    legend('Location','southeast','Interpreter','latex','FontSize',12)
    hold off;
end