#!/opt/local/Library/Frameworks/Python.framework/Versions/2.7/Resources/Python.app/Contents/MacOS/Python

import imaplib
import socket
import select
import sys
import time
import re
import os
import ConfigParser
from os.path import expanduser

OFFLINEIMAP=sys.argv[1]
DEFAULT_SLEEP=int(sys.argv[2])

class mysock():
    def __init__(self, name, server, user, passwd, directory):
        self.name = name
        self.directory = directory
        self.M = imaplib.IMAP4(server)
        self.M.login(user, passwd)
        self.M.select(self.directory, readonly=True)
        self.M.send("%s IDLE\r\n"%(self.M._new_tag()))
        if not self.M.readline().startswith('+'): # expect continuation response
            exit(1)

    def fileno(self):
        return self.M.socket().fileno()

def show_notification():
    cmd = 'osascript -e \'display notification "You have a new mail" with title \
    "Mutt"\''
    os.system(cmd)

if __name__ == '__main__':
    socket.setdefaulttimeout(10)
    config = ConfigParser.RawConfigParser()
    config.read(expanduser('~/.offlineimaprc'))
    p = re.compile("Account\s+(.+)")
    sockets = []
    if config.has_option("general", "pythonfile"):
        execfile(expanduser(config.get("general", "pythonfile")))

    for a in config.sections():
        m = p.match(a)
        if m:
            x = "Repository " + config.get(a, "remoterepository")
            if config.has_option(x, "remotehost"):
                print >> sys.stderr, m.group(1)
                host = config.get(x, "remotehost")
                name = config.get(x, "remoteuser")
                pw = eval(config.get(x, "remotepasseval"))
                sockets.append(mysock(m.group(1), host, name, pw, "INBOX"))

    print >> sys.stderr, "waiting..."
    readable, _, _ = select.select(sockets, [], [], DEFAULT_SLEEP) # 11 mins timeout

    found = False
    for sock in readable:
        if sock.M.readline().startswith('* BYE '): continue
        print >> sys.stderr, "receive mail with fast mode"
        cmd = OFFLINEIMAP + " -q -u quiet -o -f %s -a %s"%(sock.directory, sock.name)
        os.system(cmd)
        show_notification()
        exit(0)

    exit(1)

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
