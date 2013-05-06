#! /usr/bin/env python3

import argparse
from subprocess import check_call as call
from os.path import expanduser

parser = argparse.ArgumentParser()
parser.add_argument('-t')
parser.add_argument('-i')
parser.add_argument('name')

args = parser.parse_args()

if __name__ == '__main__':
    with open("/tmp/duho"+args.i, "w") as lg:
        try:
            if args.t in ("added", "present") and args.i == "05ac:022a":
                call(["xmodmap", expanduser("~/.Xmodmap")])
                lg.write("ok")
        except Exception as e:
            lg.write("nok: ", e)
