function plotMPC_digraph(mpc_results, scale, iter, show_ledg_title, show_arrows)
%% function for plotting a MATPOWER case
% Dan Russell - 2024
% University of Vermont Dept. of Electrical Engineering

%% pull relevant data from MP results
s = mpc_results.branch(:,1);            % source
t = mpc_results.branch(:,2);            % to
gen = mpc_results.gen(:,1);             % node numbers of generators
genPMax = mpc_results.gen(:,9);
Pbranch = mpc_results.branch(:,14);
Qbranch = mpc_results.branch(:,15);
Sbranch = (Pbranch.^2 + Qbranch.^2).^(0.5);
% disp(Sbranch)

%% Set arrow direction based on Active Power Sign
% loop through all branches
for i = 1:length(s)
    if Pbranch(i) < 0                           % if P negative
        tmp = [s(i) t(i)];                      % store from/to
        [t(i), s(i)] = deal(tmp(1), tmp(2));    % swap from/to
    end
end

%% Create a directed graph object
G = digraph(s, t);
% handle G being re-ordered
edges_ML = G.Edges.EndNodes;  % pull end nodes 
[~, edge_idx] = ismember(edges_ML, [s t], 'rows'); % compare order? GPT code
Sbranch = Sbranch(edge_idx);    % rearrange Sbranch to match G

%% Set up plotting customization
% init colors, markers of nodes
ncolor = zeros(numnodes(G),3);
nmarker = ncolor(:,1);
% set to blue/6 default
for i = 1:numnodes(G)
    ncolor(i,:) = [0 0.4470 0.7410];
    nmarker(i) = 6;
end
% set gens to orange/sized
j = 1;
for i = gen'
    ncolor(i,:) = [0.8500 0.3250 0.0980];
    nmarker(i) = 6 + 6 * genPMax(j)/max(genPMax);
    j = j + 1;
end

% init edge colors and sizes
esize = zeros(numedges(G),1);
arrowsize = zeros(numedges(G),1);
% set default width and style
for i = 1:numedges(G)
    % set size
    esize(i) = 1 + 3 * Sbranch(i)/max(Sbranch);
    arrowsize(i) = 7 + 7 * Sbranch(i)/max(Sbranch);
end
% disp(esize)

%% Plot the graph
figure('Position',[100, 100, 800, 700]);
% plot apparent power
plot_P = plot(G, 'Layout', 'force', 'Iterations', iter);
plot_P.NodeFontSize = 4;
% Use customized stuff from above 
if show_arrows
    plot_P.ArrowSize = arrowsize*scale; % set arrow size
else
    plot_P.ArrowSize = 0;
end
plot_P.LineWidth = esize*scale;     % set linewidth
plot_P.NodeColor = ncolor;          % set all node colors
plot_P.MarkerSize = nmarker*scale;  % set node marker size
plot_P.NodeFontSize = 14;           % set node font size
plot_P.EdgeColor = [0, 0.294, 0.235];   % set edge color
if show_ledg_title
    title('Apparent Power Flow', 'FontSize', 18); % set title
    % legend
    annotation('textbox', [0.14, 0.81, .1, .1], 'String', {'Legend:', 'Load: Blue',... 
        'Generator: Red', 'Gen Size: ~P Cap.' 'Width: ~S Flow',... 
        '=> : P Flow Direction'},'EdgeColor', 'k', 'FontSize', 12,... 
        'HorizontalAlignment', 'left');
end

%% Legend: 
% blue are load buses
% red are generators
% size of marker at generator is proportional to max active power gen
% arrows indicate flow direction of ACTIVE power only
% width of edge ~ apparent power on branch

% disp('Digraph order')
% disp(G.Edges)  % MATLAB's internal edge order
% disp('Original order')
% disp(table(s, t, Sbranch, esize, arrowsize)) % Original order