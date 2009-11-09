#! /usr/bin/python
#
# Generate network service configs from libvirt network XML.
#
# Copyright (C) 2009 Satoru SATOH <satoru.satoh at gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#

import logging
import optparse
import sys

try:
    import xml.etree.ElementTree as ET  # python >= 2.5
except ImportError:
    import elementtree.ElementTree as ET  # python <= 2.4; needs ElementTree.


# future plan:
#from Cheetah.Template import Template


class ParamMissingError(Exception): pass



class LibvirtNetworkConf(dict):
    def __init__(self, netxml):
        self.parse(netxml)

    def parse(self, netxml):
        """@throw ExpatError - Invalid XML or not XML file.
        """
        tree = ET.parse(netxml)

        # must parameters:
        elem = tree.find('name')
        if elem is not None:
            self['name'] = elem.text
        else:
            raise ParamMissingError(" No 'name' is found in '%s'" % netxml)

        elem = tree.find('ip')
        if elem is not None:
            listen_address = elem.attrib.get('address')
            if listen_address:
                self['listen-address'] = listen_address
            else:
                raise ParamMissingError(" No 'address' attr is found in <ip/> in '%s'" % netxml)
        else:
            raise ParamMissingError(" No 'ip' is found in '%s'" % netxml)

        # optional parameters:
        elem = tree.find('domain')
        if elem is not None:
            domain = elem.attrib.get('name', False)
            if domain:
                self['domain'] = domain

        elem = tree.find('ip/dhcp/range')
        if elem is not None:
            (start, end) = (elem.attrib.get('start'), elem.attrib.get('end'))
            if start and end:
                self['dhcp-range'] = (start, end)

        elems = tree.findall('ip/dhcp/host')
        if elem is not None:
            hs = []
            for elem in elems:
                (mac, ip, name) = (elem.attrib.get('mac'), elem.attrib.get('ip'), elem.attrib.get('name'))
                if mac and ip and name:
                    hs.append({'mac': mac, 'ip': ip, 'name': name})
            self['hosts'] = hs



class AConf(object):
    def __init__(self, netxml):
        self.netconf = LibvirtNetworkConf(netxml)

    def format(self):
        raise NotImplementedError()

    def dump(self, output=None):
        if output is None or output == '-':
            output = sys.stdout
        else:
            output = open(output,'w')

        output.write(self.format())
        output.close()



class DnsmasqConf(AConf):
    """dnsmasq.conf writer.
    """

    def format(self):
        configs = [
            'strict-order',
            'bind-interfaces',
            'listen-address=%(listen-address)s' % self.netconf,
            'except-interface=lo',
        ]

        domain = self.netconf.get('domain', False)
        if domain:
            configs.append('domain=%s' % domain)

        range = self.netconf.get('dhcp-range', False)
        if range:
            configs.append('dhcp-range=%s,%s' % range)

        hosts = self.netconf.get('hosts')
        if hosts:
            for h in hosts:
                configs.append("dhcp-host=%(mac)s,%(ip)s,%(name)s" % h)

        configs.append('\n')

        return '\n'.join(configs)



DNSMASQ_TYPE = 'dnsmasq'


def option_parser():
    parser = optparse.OptionParser("%prog [OPTION ...] NETWORK_XML")
    parser.add_option('-T', '--type', default=DNSMASQ_TYPE, help='Config type [%default]')
    parser.add_option('-o', '--output', default='-', help='output file [%default] (stdout)')
    parser.add_option('-v', '--verbose', action="store_true",
        default=False, help='verbose mode')
    parser.add_option('-q', '--quiet', action="store_true",
        default=False, help='quiet mode')

    return parser


def main():
    loglevel = logging.INFO

    parser = option_parser()
    (options, args) = parser.parse_args()

    if options.verbose:
        loglevel = logging.DEBUG
    if options.quiet:
        loglevel = logging.WARN

    # logging.basicConfig() in python older than 2.4 cannot handle kwargs,
    # then exception 'TypeError' will be thrown.
    try:
        logging.basicConfig(level=loglevel)

    except TypeError:
        # To keep backward compatibility. See above comment also.
        logging.getLogger().setLevel(loglevel)

    if len(args) < 1:
        parser.print_help()
        sys.exit(1)

    network_xml = args[0]

    if options.type == DNSMASQ_TYPE:
        writer = DnsmasqConf(network_xml)
        writer.dump(options.output)
    else:
        pass



if __name__ == '__main__':
    main()

# vim:sw=4:ts=4:et:ft=python:
