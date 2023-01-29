# IM-CW1


Before using the ./test.sh script:

1. The "01-pgconf-changed.conf" file in the "config" folder must be placed in "/etc/postgres/<version>/main/conf.d/":
a. sudo cp <folder>/config/01-pgsql-changes.conf /etc/postgres/<version>/main/conf.d/

2. You must copy the contents of "00-hba-changes.conf" and replace them in the "/etc/postgres/<version>/main/pg_hba.conf" file (ONLY REPLACE THE IPv4 and IPv6 LOCAL CONNECTIONS!):
a. gedit <folder>/config/00-hba-changes.conf
b. sudo gedit /etc/postgresql/14/main/pg_hba.conf

3. Run the ./test.sh script in a full screen terminal
