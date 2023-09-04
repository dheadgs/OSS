#!/usr/bin/python

import sys
from db_sms_wrapper import db_sql

sys.path.append('/opt/provisioning/scripts/common/lib')
from generic_classes import ProvisioningError

class MediationSmsGateway:

        def __init__(self):
                self.db_handler = db_sql("mediation_sql_server", "sqlserver")

        def get_sms_counter(self):
                query = """select COUNT(*) from ProvisioningJDBCEvents where event_status = 0 and [OBJECT_NAME] = 'DboCurbas_Sms_DataBG'"""
                self.db_handler.cursor.execute(query)
                print self.db_handler.cursor.fetchone()[0]



if __name__ == '__main__':
        try:
                MediationSmsGateway().get_sms_counter()
        except ProvisioningError, pe:
                print "ERROR: %s - %s" % (pe.error_code, pe.error_text)
                sys.exit(1)
        except Exception, ex:
                print "ERROR: %s" % (str(ex))
                sys.exit(1)

