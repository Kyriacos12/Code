# Simulation Settings
import os

networks = ["Landgate"]
t_days = [1]
months = [1]
no_of_iterations = 6

pv_values = {}
pv_values["penetration"] = [0]
pv_values["clearness"] = [1]
pv_values["pv_mode"] = "clear"  # clear for clearness, iter for iterations

#change the directory where the input files are by commenting the os.path.dir part and adding the directory manually
#below
directory = os.path.dirname(os.path.realpath(__file__))
#directory = 'C:\\Users\\Kyriacos\\Desktop\\Project\\something'


if __name__ == '__main__':
    # Simulation Starts here
    import time
    from Callers import dss_engine, plot, monte_carlo_same_network
    from multiprocessing import Pool
    from pylab import show

    simulation = []
    start_time = time.time()
    pool = Pool()
    data = [0 for i in range(no_of_iterations)]

    # Check that values are correct:
    if not all(p == 1 or p == 2 for p in t_days):
        raise TypeError('Wrong value in T_days')
    if not all(p < 13 and p > 0 for p in months):
        raise TypeError('Wrong value in Months')
    if not all((p <= 1) and (p >= 0) for p in pv_values["penetration"]):
        raise TypeError('Wrong PV penetration value')
    if not all(p <= 4 and p >= 1 for p in pv_values["clearness"]):
        raise TypeError('Wrong clearness value')

    for i in range(no_of_iterations):
        try:
            simulation.append(pool.apply_async(dss_engine, (networks[i], t_days[i], months[i], i, pv_values,directory)))
        except:
            try:
                simulation.append(pool.apply_async(dss_engine, (networks[0], t_days[0], months[i], i, pv_values,directory)))
            except:
                simulation.append(pool.apply_async(dss_engine, (networks[0], t_days[0], months[0], i, pv_values,directory)))
    for i in range(no_of_iterations):
        data[i] = simulation[i].get(timeout=None)

    # Plotting Starts here
    # plot(data[0])
    monte_carlo_same_network(no_of_iterations, data[0])

    # End of Simulation
    print("--- %s seconds ---" % (time.time() - start_time))
    show()
