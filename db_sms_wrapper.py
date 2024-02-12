#!/usr/bin/python
# -*- coding: ISO-8859-7 -*-


#==============================================================================
# DATABASE WRAPPER
#
# Author: Dimitris Vassiliades
#         Mediation Software Engineer
#         Information Technology
#
#==============================================================================

import os
import sys

sys.path.append('/opt/provisioning/scripts/common/lib')

import re
import MySQLdb
import pymssql

from registry import *
from log import *
from generic_classes import *

SERVICE_ELEMENTS = [ 'curbas', 'location', 'account', 'cpe', 'rater', 'ktpedu', 'ktplaptop', 'pots', 'telephony', 'llu', 'circuit', 'easyvoice', 'easyvoicepre', 'myzone', 'portin', 'iptv', 'settopbox', 'wlr', 'satellite', 'pddsl', 'holbdp', 'evoicenew', 'netvoice', 'cbt', 'fvs', 'accounting', 'vcc3060', 'odp', 'cdp', 'bdpbilling', 'tree', 'cbtbackup', 'holbundles', 'holaaa', 'portability', 'onv', 'onaa' ]
EDGES_SUBREGISTRIES = [ 'callcontrol', 'assets', 'vodafone_curbas', 'circuitflow', 'commondb', 'mediation_sql_server' ]


class db_sql(object):

	def __init__(self, service_element, protocol, log_handler=None):
		self.protocol = protocol.lower()
		self.service_element = service_element.lower()
		# Retreive Connection String
		if self.service_element in SERVICE_ELEMENTS:
			self.db_connstr = registry(self.service_element).getDBConnectionString()
		elif self.service_element in EDGES_SUBREGISTRIES:
			self.db_connstr = registry('edges', self.service_element).getDBConnectionString()
		else:
			raise ProvisioningError(1020, str(self.service_element))
		if (protocol == "mysql"):
			try:
				self.handler = MySQLdb.connect(host = self.db_connstr['host'], user = self.db_connstr['user'], passwd = self.db_connstr['password'], db = self.db_connstr['database'])
				# ##paulkats: Set charset here
				# ##TODO: We need to get this value from the registry
				self.handler.set_character_set('greek');

				self.cursor = self.handler.cursor()
			except (Exception, MySQLdb.Error), e:
				raise ProvisioningError(1022, str(e))
		elif (protocol == "sqlserver"):
			try:
				self.handler = pymssql.connect(host = self.db_connstr['host'], user = self.db_connstr['user'], password = self.db_connstr['password'], database = self.db_connstr['database'])
				self.cursor = self.handler.cursor()
			except (Exception, pymssql.Error), e:
				raise ProvisioningError(1022, str(e))
		else:
			raise ProvisioningError(1022, "protocol: '%s'" % str(protocol))
		# Keep Log Handler
		if (log_handler):
			if (log_handler.__class__.__name__ == 'logger'):
				self.log_handler = log_handler
			elif (log_handler.__class__.__name__ == 'str'):
				self.log_handler = logger(log_handler)
			else:
				raise ProvisioningError(1024, "Given: %s" % str(log_handler.__class__.__name__))
		else:
			# Create empty logger
			self.log_handler = logger()


	def __call__(self, sql_statement):
		return self.execute_sql(sql_statement)
	
	def execute_sql(self, sql_statement):
		if (self.protocol.lower() == "mysql"):
			try:
				self.log_handler("Executing (%s @ %s): %s" % (str(self.service_element), str(self.db_connstr['host']), str(sql_statement)))
				sql_statement = unicode(sql_statement, 'ISO-8859-7')
				try:
					self.cursor.execute(sql_statement)
				except (MySQLdb.OperationalError), e:
					self.handler = MySQLdb.connect(host = self.db_connstr['host'], user = self.db_connstr['user'], passwd = self.db_connstr['password'], db = self.db_connstr['database'])
					self.handler.set_character_set('greek')
					self.cursor = self.handler.cursor()
					self.cursor.execute(sql_statement)
				res = self.cursor.fetchall()
				self.log_handler("Response: " + str(res))
				return res
			except (Exception, MySQLdb.Error), e:
				raise ProvisioningError(1023, str(e))
		elif (self.protocol.lower() == "sqlserver"):
			try:
				self.log_handler("Executing (%s @ %s): %s" % (str(self.service_element), str(self.db_connstr['host']), str(sql_statement)))
				self.cursor.execute(sql_statement)
				self.handler.commit()
			except (Exception, pymssql.Error), e:
				raise ProvisioningError(1023, str(e))
		else:
			raise ProvisioningError(1022, str(self.protocol.lower()))


	def __del__(self):
		try:
			self.cursor.close()
			self.handler.close()
		except:
			pass


def get_one_element(sql_res):
	if (sql_res):
		res = str(sql_res[0][0])
	else:
		res = None
	return res



