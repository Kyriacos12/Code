import csv
import datetime
import numpy as np
import pylab as plt

figures = 1


class Plotter:
    def __init__(self, instance):

        self.instance = instance

    def extract_from_csv(self, feeder_no, iteration):
        import sys

        caller = sys._getframe().f_back.f_code.co_name

        if caller == "plot_transformer" or caller == "monte_carlo_transformer":

            trans_data = []
            file_to_open = "%s\\Output\\%s\\%s\\%s_Mon_pqtrans.csv" % (
                self.instance["directory"], self.instance["network"], iteration, self.instance["network"])
            with open(file_to_open) as filename:
                reader = csv.reader(filename)
                rownum = 0

                for row in reader:
                    if rownum < 1:
                        pass
                    else:
                        colnum = 0
                        for col in row:
                            trans_data.append(col)
                            colnum += 1
                    rownum += 1

            TR = np.array(trans_data)
            TR = np.reshape(TR, (-1, 10))

            trans_data[:] = []

            for i in range(rownum - 1):
                trans1 = ((float(TR[i, 2]) ** 2 + float(TR[i, 3]) ** 2) ** 0.5)
                trans2 = ((float(TR[i, 4]) ** 2 + float(TR[i, 5]) ** 2) ** 0.5)
                trans3 = ((float(TR[i, 6]) ** 2 + float(TR[i, 7]) ** 2) ** 0.5)
                if float(TR[i,2]) < 0: trans1 = -trans1
                if float(TR[i,4]) < 0: trans2 = -trans2
                if float(TR[i,6]) < 0: trans3 = -trans3
                apparent = trans1 + trans2 + trans3
                trans_data.append(apparent)
            return trans_data

        elif caller == "plot_currents":
            curr_data = []
            curr_data[:] = []

            file_to_open = "%s\\Output\\%s\\%s\\%s_Mon_vi%ss.csv" % (
                self.instance["directory"], self.instance["network"], iteration, self.instance["network"], feeder_no)
            with open(file_to_open) as filename:
                reader = csv.reader(filename)
                rownum = 0

                for row in reader:
                    if rownum < 1:
                        pass
                    else:
                        colnum = 0
                        for col in row:
                            if colnum == 8 or colnum == 10 or colnum == 12:
                                curr_data.append(col)
                            colnum += 1
                    rownum += 1

                return curr_data

        elif caller == "plot_voltages":
            vol_data = []
            vol_data[:] = []

            file_to_open = "%s\\Output\\%s\\%s\\%s_Mon_vi%s.csv" % (
                self.instance["directory"], self.instance["network"], iteration, self.instance["network"], feeder_no)
            with open(file_to_open) as filename:
                reader = csv.reader(filename)
                rownum = 0

                for row in reader:
                    if rownum < 1:
                        pass
                    else:
                        colnum = 0
                        for col in row:
                            if colnum == 2 or colnum == 4 or colnum == 6:
                                vol_data.append(float(col) / 240)
                            colnum += 1
                    rownum += 1

                return vol_data

    def plot_currents(self, plot_which):

        global figures

        if plot_which == "all":
            plot_which = [i for i in range(1, self.instance["no_feeders"] + 1)]
        time_scale = [datetime.datetime(2000, 1, 1, 0) + datetime.timedelta(minutes=i) for i in range(1440)]
        plt.figure(figures)
        figures += 1
        lines_to_plot = len(plot_which)

        for i in range(lines_to_plot):

            CR = np.array(self.extract_from_csv(plot_which[i], self.instance["iteration"]))
            CR = np.reshape(CR, (-1, 3))

            plt.subplot(lines_to_plot, 1, 1 + i)
            if (i + 1) != lines_to_plot:
                plt.plot(time_scale, CR)
                plt.tick_params(axis='x', which='both', bottom='off', top='off', labelbottom='off')
            else:
                plt.plot(time_scale, CR)

        plt.subplot(lines_to_plot, 1, 1)
        plt.title("Current at the head of the Feeders")

    def plot_voltages(self, plot_which):

        global figures

        if plot_which == "all":
            plot_which = [i for i in range(1, self.instance["no_feeders"] + 1)]
        time_scale = [datetime.datetime(2000, 1, 1, 0) + datetime.timedelta(minutes=i) for i in range(1440)]
        plt.figure(figures)
        figures += 1
        lines_to_plot = len(plot_which)

        for i in range(lines_to_plot):

            VL = np.array(self.extract_from_csv(plot_which[i], self.instance["iteration"]))
            VL = np.reshape(VL, (-1, 3))

            plt.subplot(lines_to_plot, 1, 1 + i)
            if (i + 1) != lines_to_plot:
                plt.plot(time_scale, VL)
                plt.tick_params(axis='x', which='both', bottom='off', top='off', labelbottom='off')
            else:
                plt.plot(time_scale, VL)

        plt.subplot(lines_to_plot, 1, 1)
        plt.title("Voltages at the end of the Feeders")

    def plot_transformer(self):

        global figures

        trans_data = self.extract_from_csv(0, self.instance["iteration"])
        time_scale = [datetime.datetime(2000, 1, 1, 0) + datetime.timedelta(minutes=i) for i in range(1440)]

        plt.figure(figures)
        figures += 1
        trans = plt.plot(time_scale, trans_data, '-b', label='Transformer Power')
        limit = plt.plot(time_scale, [500 for i in range(1440)], '-r', label='Limit')
        plt.legend(loc='upper right')
        plt.xlabel("Time")
        plt.ylabel("Apparent Power (kVA)")

    def monte_carlo_transformer(self, iterations):

        global figures

        for i in range(iterations):
            trans_data = self.extract_from_csv(0, i)
            if i == 0:
                tr_total = np.array(trans_data)
            else:
                tr_total = np.append(tr_total, trans_data)
        tr_total = np.reshape(tr_total, (iterations, -1))
        tr_total = np.transpose(tr_total)

        tr_max = np.amax(tr_total, axis=1)
        tr_min = np.amin(tr_total, axis=1)

        time_scale = [datetime.datetime(2000, 1, 1, 0) + datetime.timedelta(minutes=i) for i in range(1440)]
        plt.figure(figures)
        figures += 1

        minima = plt.plot(time_scale, tr_min, '-b', label='Minimum')
        maxima = plt.plot(time_scale, tr_max, '-r', label='Maximum')
        plt.legend(loc='upper right')
        plt.xlabel("Time")
        plt.ylabel("Apparent Power (kVA)")
        plt.grid()
