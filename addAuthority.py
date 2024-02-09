#!/usr/bin/python
#-*- coding: iso-8859-7 -*-



import MySQLdb
import signal
import sys



from genericFunctions import handleSignals
from registry import registry



def main():
	# Signal handling
	signal.signal(signal.SIGINT, handleSignals)

	# Argument validation
	if (len(sys.argv) == 3):
		element = sys.argv[1]
		login = sys.argv[2]
	else:
		print 'Syntax error. Syntax is addAuthority.py <element> <login>'
		sys.exit(1)

	# Initialize provisioning connection
	provisioningConnectionString = registry(element).getDBConnectionString()
	provisioningConnection = MySQLdb.connect(host = provisioningConnectionString['host'], user = provisioningConnectionString['user'], passwd = provisioningConnectionString['password'], db = provisioningConnectionString['database'])
	provisioningCursor = provisioningConnection.cursor()

	# Initialize CURBAS connection
	curbasConnectionString = registry('curbas').getDBConnectionString()
	curbasConnection = MySQLdb.connect(host = curbasConnectionString['host'], user = curbasConnectionString['user'], passwd = curbasConnectionString['password'], db = curbasConnectionString['database'])
	curbasCursor = curbasConnection.cursor()

	# Retrieve max authority ID
	provisioningCursor.execute('SELECT MAX(id) + 1 FROM authorities')
	maxAuthorityID = provisioningCursor.fetchone()[0]

	# Add the record
	# To make people's lives easier, retrieve their password from CURBAS
	curbasCursor.execute('SELECT password FROM personnel_usernames WHERE login = "%s"' % login)
	password = curbasCursor.fetchone()[0]
	# If no password could be retrieved, set it to the encrypted form of '123abc!' and notify accordingly
	if (password):
		print 'Password was set to the corresponding CURBAS password for user %s' % login
		password = '"%s"' % password
	else:
		print 'Password was set to 123abc@'
		password = 'ENCRYPT("123abc!")'
	
	print 'INSERT INTO authorities VALUES ("%s", "%s", %s, %s, NULL, NULL, NULL, NULL, "se_admin", UNIX_TIMESTAMP(NOW()), "gedaskalakis", 1, NULL, NULL);' % (login, login, maxAuthorityID, password)
	provisioningCursor.execute('INSERT INTO authorities VALUES ("%s", "%s", %s, %s, NULL, NULL, NULL, NULL, "se_admin", UNIX_TIMESTAMP(NOW()), "gedaskalakis", 1, NULL, NULL);' % (login, login, maxAuthorityID, password))
	provisioningCursor.execute('INSERT INTO usergroup_specs VALUES ("%s", 1, %s);' % (login, maxAuthorityID))

	# Commit, clean up and terminate
	provisioningConnection.commit()
	provisioningCursor.close()
	provisioningConnection.close()
	curbasCursor.close()
	curbasConnection.close()



if (__name__ == '__main__'):
	main()
