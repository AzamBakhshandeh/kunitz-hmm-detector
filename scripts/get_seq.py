#!/usr/bin/python

import sys

def get_ids(idlist):
    with open(idlist) as f:
        return f.read().strip().split('\n')

def getseq(pidlist, seqfile):
    with open(seqfile) as f:
        s = 0
        for line in f:
            if line.startswith('>'):
                pid = line.split('|')[1]
                s = 0
                if pid in pidlist:   # ✅ تغییر اینجا
                    s = 1
            if s == 1:
                print(line.strip())

if __name__ == '__main__':
    idlist = sys.argv[1]
    seqfile = sys.argv[2]
    pidlist = get_ids(idlist)
    getseq(pidlist, seqfile)
