#!/usr/bin/env python

import argparse
import os
import re
import subprocess
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.join(SCRIPT_DIR, '..', 'vim')
SOURCES_DIR = os.path.join(ROOT_DIR, 'src')

VERSION_REGEX = re.compile('([0-9]+).([0-9]+)(.([0-9]+)){0,2}')


def get_major_minor_version(version):
    matches = VERSION_REGEX.match(version)
    if not matches:
        raise RuntimeError('Wrong version format: {0}'.format(version))
    return matches.group(1) + '.' + matches.group(2)


def check_interface_version(interface_name,
                            command,
                            version_regex,
                            expected_version):
    try:
        output = check_vim_command(command)
    except subprocess.CalledProcessError as error:
        if not expected_version:
            return None
        sys.exit(error.output.decode('utf8'))
    match = re.match(version_regex, output)
    if not match:
        sys.exit('Cannot match {0} version "{1}" returned by Vim. '
                 'Fix the script!'.format(interface_name, output))
    groups = match.groups()
    interface_version = '.'.join( [ group for group in groups if group ] )
    if not expected_version:
        return interface_version
    expected_version = '.'.join(expected_version.split('.')[:len(groups)])
    if interface_version != expected_version:
        sys.exit('{0} versions do NOT match: interface is {1} '
                 'but given version is {2}'.format(interface_name,
                                                   interface_version,
                                                   expected_version))
    return interface_version


def check_python2_interface_version(version):
    return check_interface_version('Python 2',
                                   'python print(sys.version)',
                                   '(\d+).(\d+).(\d+)',
                                   version)


def check_python3_interface_version(version):
    return check_interface_version('Python 3',
                                   'python3 print(sys.version)',
                                   '(\d+).(\d+).(\d+)',
                                   version)


def check_tcl_interface_version(version):
    return check_interface_version('Tcl',
                                   'tcl puts [info patchlevel]',
                                   '(\d+).(\d+).(\d+)',
                                   version)


def check_interfaces(args):
    print('Checking interfaces...')
    print("Python 2 interface: {0}".format(
        check_python2_interface_version(args.python2_version)))
    print("Python 3 interface: {0}".format(
        check_python3_interface_version(args.python3_version)))
    print("Tcl interface: {0}".format(
        check_tcl_interface_version(args.tcl_version)))


def parse_arguments():
    parser = argparse.ArgumentParser(description='Check Vim interfaces and '
                                                 'features.')
    parser.add_argument('--python2-version', type=str,
                        help='check Python2 version')
    parser.add_argument('--python3-version', type=str,
                        help='check Python3 version')
    parser.add_argument('--tcl-version', type=str,
                        help='check Tcl version')

    return parser.parse_args()


def main():
    args = parse_arguments()
    check_interfaces(args)


if __name__ == '__main__':
    main()
