using SolveDSGE

filename = "model1a.txt"
path = joinpath(@__DIR__,filename)
process_model(path)
dsge = retrieve_processed_model(path)

x = [0.05, 3.05, 0.7]

tol = 1e-8
maxiters = 1000
ss = compute_steady_state(dsge,x,tol,maxiters)
ss = ss.zero

N   = PerturbationScheme(ss,1.0,"first")
NN  = PerturbationScheme(ss,1.0,"second")
NNN = PerturbationScheme(ss,1.0,"third")

soln_fo = solve_model(dsge,N)
soln_so = solve_model(dsge,NN)
soln_to = solve_model(dsge,NNN)

P = ChebyshevSchemeStoch(ss,chebyshev_nodes,[21,21],9,3,[0.0960769 26.0; -0.0960769 8.0],tol,1e-6,maxiters)
PP = ChebyshevSchemeStoch(ss,chebyshev_extrema,[21,21],9,4,[0.0960769 26.0; -0.0960769 8.0],tol,1e-6,maxiters)
PPP = ChebyshevSchemeStoch(ss,chebyshev_extended,[71,71],9,6,[0.0960769 26.0; -0.0960769 8.0],tol,1e-6,maxiters)

soln_nla = solve_model(dsge,P,2)
soln_nlb = solve_model(dsge,soln_fo,PP)
soln_nlc = solve_model(dsge,soln_so,PPP)
soln_nld = solve_model(dsge,soln_to,P,2)
soln_nle = solve_model(dsge,soln_nld,PP)
soln_nlf = solve_model(dsge,soln_nle,PPP)

L = SmolyakSchemeStoch(ss,chebyshev_gauss_lobatto,9,4,[0.0960769 26.0; -0.0960769 8.0],tol,1e-6,maxiters)
LL = SmolyakSchemeStoch(ss,clenshaw_curtis_equidistant,9,4,[0.0960769 26.0; -0.0960769 8.0],tol,1e-6,maxiters)
LLL = SmolyakSchemeStoch(ss,chebyshev_gauss_lobatto,9,5,[0.0960769 26.0; -0.0960769 8.0],tol,1e-6,maxiters)

soln_nlg = solve_model(dsge,L,2)
soln_nlh = solve_model(dsge,soln_to,LL,2)
soln_nli = solve_model(dsge,soln_nlh,LLL)
soln_nlj = solve_model(dsge,soln_nlf,LL)

M = PiecewiseLinearSchemeStoch(ss,[21,21],9,[0.0960769 26.0; -0.0960769 8.0],tol,1e-6,maxiters)
MM = PiecewiseLinearSchemeStoch(ss,[31,31],9,[0.0960769 26.0; -0.0960769 8.0],tol,1e-6,maxiters)

soln_nlk = solve_model(dsge,M,2)
soln_nll = solve_model(dsge,soln_to,MM,2)
soln_nlm = solve_model(dsge,soln_nlf,MM)
soln_nln = solve_model(dsge,soln_nlj,MM)
soln_nlo = solve_model(dsge,soln_nln,MM)

simulated_data1 = simulate(soln_nlf,ss[1:2],100000)
pos_imps, neg_imps = impulses(soln_nlf,50,[1],10000)

nodesf, f = approximate_density(simulated_data1[3,:],10,1.95,1.99)
nodesF, F = approximate_distribution(simulated_data1[3,:],10,1.95,1.99)
