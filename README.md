# IM-CW1


Before using the ./test.sh script:

1. The "01-pgconf-changed.conf" file in the "config" folder must be placed in "/etc/postgres/your_version/main/conf.d/":
2. sudo cp your_folder/config/01-pgsql-changes.conf /etc/postgres/your_version/main/conf.d/

3. You must copy the contents of "00-hba-changes.conf" and replace them in the "/etc/postgres/your_version/main/pg_hba.conf" file (ONLY REPLACE THE IPv4 and IPv6 LOCAL CONNECTIONS!):

4. gedit your_folder/config/00-hba-changes.conf
5. sudo gedit /etc/postgresql/14/main/pg_hba.conf

6. Run the ./test.sh script in a full screen terminal
