import DSSEngine
import Plotter
import Main

solve_new = True
add_pv = False

# Plots
plot_transformer = False
plot_current = False
plot_voltages = False

plot_which_currents = "all"
plot_which_voltages = [1]


def dss_engine(network, type_of_day, month, iteration, pv_values, directory):
    # Call DSSEngine
    dssnetwork = DSSEngine.DSSEngine(network, type_of_day, month, iteration, directory)
    dssnetwork.setup_network()
    if add_pv: dssnetwork.assign_profiles_pv(pv_values)

    # Call Solver
    if solve_new == True:
        for i in range(1440):
            dssnetwork.solve()
        dssnetwork.export_monitors()

    return dssnetwork.return_values()


def plot(d):
    # Call plotting class
    plot = Plotter.Plotter(d)

    if plot_transformer: plot.plot_transformer()
    if plot_current: plot.plot_currents(plot_which_currents)
    if plot_voltages: plot.plot_voltages(plot_which_voltages)


def monte_carlo_same_network(number_of_iterations, d):
    plot = Plotter.Plotter(d)
    plot.monte_carlo_transformer(number_of_iterations)
