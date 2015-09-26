import win32com.client
import os
import AssignProfiles


def init(engine, directory):

    filename = '{0}\\Networks\\Landgate\\Loadshapes\\'.format(str(directory))
    engine.text.command = 'set datapath=' + filename
    engine.text.command = 'redirect Loadshapes.txt'

    filename = '{0}\\Networks\\Landgate\\63057169\\'.format(str(directory))
    engine.text.command = "set datapath=" + filename
    engine.text.command = 'redirect Master.txt'

    filename = '{0}\\Networks\\Landgate\\63057170\\'.format(str(directory))
    engine.text.command = 'set datapath=' + filename
    engine.text.command = 'redirect Master.txt'

    filename = '{0}\\Networks\\Landgate\\63057171\\'.format(str(directory))
    engine.text.command = 'set datapath=' + filename
    engine.text.command = 'redirect Master.txt'

    filename = '{0}\\Networks\\Landgate\\63057172\\'.format(str(directory))
    engine.text.command = 'set datapath=' + filename
    engine.text.command = 'redirect Master.txt'

    filename = '{0}\\Networks\\Landgate\\63057173\\'.format(str(directory))
    engine.text.command = "set datapath=" + filename
    engine.text.command = 'redirect Master.txt'

    filename = '{0}\\Networks\\Landgate\\63057174\\'.format(str(directory))
    engine.text.command = 'set datapath=' + filename
    engine.text.command = 'redirect Master.txt'


def monitors(engine):
    engine.text.command = 'new monitor.PQtrans element=transformer.TR1 terminal=1 mode=1 ppolar=no'
    engine.text.command = 'new monitor.VI1 element=line.line169_616 terminal=2 mode=0'
    engine.text.command = 'new monitor.VI2 element=line.line170_338 terminal=2 mode=0'
    engine.text.command = 'new monitor.VI3 element=line.line171_484 terminal=2 mode=0'
    engine.text.command = 'new monitor.VI4 element=line.line172_1255 terminal=2 mode=0'
    engine.text.command = 'new monitor.VI5 element=line.line173_904 terminal=2 mode=0'
    engine.text.command = 'new monitor.VI6 element=line.line174_1164 terminal=2 mode=0'
    engine.text.command = 'new monitor.VI1s element=line.line169_1 terminal=2 mode=0'
    engine.text.command = 'new monitor.VI2s element=line.line170_1 terminal=2 mode=0'
    engine.text.command = 'new monitor.VI3s element=line.line171_1 terminal=2 mode=0'
    engine.text.command = 'new monitor.VI4s element=line.line172_1 terminal=2 mode=0'
    engine.text.command = 'new monitor.VI5s element=line.line173_1 terminal=2 mode=0'
    engine.text.command = 'new monitor.VI6s element=line.line174_1 terminal=2 mode=0'


def export_monitors(engine, iteration, directory):
    direc = directory
    directory += "\\Output"
    if not os.path.exists(directory):
        os.makedirs(directory)
        directory += "\\Landgate"
        os.makedirs(directory)
        directory += "\\%s" % iteration
        os.makedirs(directory)
    elif not os.path.exists((directory + "\\Landgate")):
        directory += "\\Landgate"
        os.makedirs(directory)
        directory += "\\%s" % iteration
        os.makedirs(directory)
    elif not os.path.exists((directory + "\\Landgate\\%s" % iteration)):
        directory += "\\Landgate\\%s" % iteration
        os.makedirs(directory)
    else:
        directory += "\\Landgate\\%s" % iteration
    engine.text.command = 'set datapath=' + directory
    engine.text.command = 'Export Monitors PQtrans'
    for i in range(1, 7):
        engine.text.command = 'Export Monitors VI%s' % i
        engine.text.command = 'Export Monitors VI%ss' % i
    engine.text.command = 'set datapath=' + direc
