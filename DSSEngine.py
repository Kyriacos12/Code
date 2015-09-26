import win32com.client
import os
import AssignProfiles


class DSSEngine:
    def __init__(self, network, tday, tmonth, iteration, directory):

        self.iteration = iteration
        self.network = network
        self.clearness = None
        self.pv_penetration = None
        self.pv_mode = None

        win32com.client.pythoncom.CoInitialize()
        self.engine = win32com.client.Dispatch("OpenDSSEngine.DSS")

        self.engine.Start("0")

        self.text = self.engine.Text
        self.text.Command = "clear"
        self.circuit = self.engine.ActiveCircuit

        self.directory = directory
        compiler = "%s\\Networks\\%s\\main.dss" % (self.directory, self.network)

        self.text.Command = "compile " + compiler
        self.engine.text.command = 'Set ControlMode=time'
        self.engine.text.command = 'Reset'
        self.engine.text.command = 'Set Mode=daily stepsize=1m number=1'

        self.customers_per_feeder = []

        with open("%s\\Networks\\%s\\settings.txt" % (self.directory, self.network)) as f:
            self.no_customers = int(f.readline())
            self.no_feeders = int(f.readline())

            for i in range(self.no_feeders):
                self.customers_per_feeder.append(int(f.readline()))

        self.tday = tday
        self.tmonth = tmonth

    def solve(self):
        self.text.command = "solve"

    def assign_profiles_house(self):
        AssignProfiles.house_profiles(self.engine, self.network, self.no_feeders,
                                      self.customers_per_feeder, self.tmonth, self.tday, self.directory)

    def assign_profiles_pv(self, pv_values):
        self.pv_mode = pv_values["pv_mode"]

        if len(pv_values["clearness"]) >= self.iteration + 1:
            self.clearness = pv_values["clearness"][self.iteration]
        else:
            self.clearness = pv_values["clearness"][0]

        if len(pv_values["penetration"]) >= self.iteration + 1:
            self.pv_penetration = pv_values["penetration"][self.iteration]
        else:
            self.pv_penetration = pv_values["penetration"][0]

        if self.pv_mode == "clear":
            AssignProfiles.pv_clear(self.engine, self.network, self.no_feeders, self.customers_per_feeder, self.tmonth,
                                self.clearness, self.pv_penetration, self.directory)
        else:
            AssignProfiles.pv_iter(self.engine,self.network,self.no_feeders,self.customers_per_feeder,self.tmonth,self.pv_penetration, self.directory)

    def setup_network(self):
        module = __import__(self.network)

        func = getattr(module, 'init')
        func(self.engine, self.directory)

        func = getattr(module, 'monitors')
        func(self.engine)
        self.assign_profiles_house()

    def export_monitors(self):
        module = __import__(self.network)

        func = getattr(module, 'export_monitors')
        func(self.engine, self.iteration, self.directory)

    def return_values(self):
        d = {}
        d["network"] = self.network
        d["no_customers"] = self.no_customers
        d["no_feeders"] = self.no_feeders
        d["customers_per_feeder"] = self.customers_per_feeder
        d["iteration"] = self.iteration
        d["directory"] = self.directory
        d["tday"] = self.tday
        d["tmonth"] = self.tmonth
        d["pv_penetration"] = self.pv_penetration
        d["clearness"] = self.clearness
        d["pv_mode"] = self.pv_mode
        return d
