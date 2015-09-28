from random import randint, shuffle, choice
import os
from scipy import stats
import DSSEngine


def house_profiles(engine, network, no_feeders, customers_per_feeder, t_month, t_day, directory):
    house = 0
    buses = extract_customer_buses(network, no_feeders, directory)
    occupants_probability = stats.rv_discrete(name='occupants_probability',
                                              values=([i for i in range(1, 6)], (0.30, 0.35, 0.15, 0.13, 0.07)))
    engine.text.command = "set datapath=%s\\Profiles\\House\\" %directory
    for i in range(no_feeders):
        for y in range(customers_per_feeder[i]):
            house += 1
            loadshape = randint(1, 500)
            occupants = occupants_probability.rvs()

            engine.text.command = "new loadshape.Houseload%s npts=1440 minterval=1.0 csvfile=House%s_%s_%s_%s.txt" % (
                house, t_month, t_day, occupants, loadshape)
            engine.text.command = "new load.House%s %s Phases=1 kV=0.23 kW=10 PF=0.97 Daily=Houseload%s" % (
                house, buses[i][y], house)


def pv_clear(engine, network, no_feeders, customers_per_feeder, t_month, clearness, penetration, directory):
    pene_customers = []
    if type(penetration) is float or type(penetration) is int:
        for i in range(no_feeders):
            pene_customers.append(penetration_per_feeder(customers_per_feeder[i], penetration))
    else:
        try:
            for i in range(no_feeders):
                pene_customers.append(penetration_per_feeder(customers_per_feeder[i], penetration[i]))
        except:
            pass
    buses = extract_customer_buses(network, no_feeders)
    engine.text.command = "set datapath=%s\\Profiles\\PV\\Clearness\\" %directory
    iteration = randint(1, 10)
    house = 1

    for i in range(no_feeders):
        shuffle(buses[i])
        for y in range(pene_customers[i]):
            house += 1
            pvsize = randint(1, 4)
            engine.text.command = "new loadshape.PVload%s npts=1440 minterval=1.0 csvfile=PVclear_%s_%s_%s_%s.txt" % (
                house, t_month, clearness, iteration, pvsize)
            engine.text.command = "new generator.PV%s %s Phases=1 kV=0.23 kW=10 PF=1 Daily=PVload%s" % (
            house, buses[i][y], house)


def pv_iter(engine, network, no_feeders, customers_per_feeder, t_month, penetration, directory):
    pene_customers = []
    if type(penetration) is float or type(penetration) is int:
        for i in range(no_feeders):
            pene_customers.append(penetration_per_feeder(customers_per_feeder[i], penetration))
    else:
        try:
            for i in range(no_feeders):
                pene_customers.append(penetration_per_feeder(customers_per_feeder[i], penetration[i]))
        except:
            pass
    buses = extract_customer_buses(network, no_feeders)
    engine.text.command = "set datapath=%s\\Profiles\\PV\\Iterations\\" %directory
    iteration = randint(1, 100)
    house = 1

    for i in range(no_feeders):
        shuffle(buses[i])
        for y in range(pene_customers[i]):
            house += 1
            pvsize = randint(1, 4)
            pvefficiency = choice([1,2])
            engine.text.command = "new loadshape.PVload%s npts=1440 minterval=1.0 csvfile=PViter_%s_%s_%s_%s.txt" % (
            house, t_month, iteration, pvsize, pvefficiency)
            engine.text.command = "new generator.PV%s %s Phases=1 kV=0.23 kW=10 PF=1 Daily=PVload%s" % (
            house, buses[i][y], house)


def extract_customer_buses(network, no_feeders, directory):
    starting_feeder = 63057169

    whole_network = []
    for i in range(no_feeders):
        feeders = []
        with open("%s\\Networks\\%s\\%s\\Loads.txt" % (
                directory, network, (starting_feeder + i))) as f:
            for line in f:
                feeders.append(line.split(" ")[3])

        whole_network.append(feeders)
    return whole_network


def penetration_per_feeder(no_customers, penetration):
    pene_double = penetration * float(no_customers)
    pene_int = int(penetration * no_customers)
    pene_percentage = float(pene_double - pene_int)

    if pene_percentage == 0:
        return pene_int
    else:
        probab = stats.rv_discrete(name='probab',
                                   values=([pene_int, (pene_int + 1)], ((1 - pene_percentage), pene_percentage)))
        return probab.rvs()
