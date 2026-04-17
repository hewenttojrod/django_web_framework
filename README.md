The web UI will be available at http://localhost:8000 and MySQL at port 3306.

# Description

Project to store core django functionality. Used to store all administration functionality, docker containers, components that are required by multiple apps. 

Attempting to not have to recreate large chunks code when I create a new project (that I may abandon in 2 weeks)

Workspace folder is designed to hold git submodules and any django apps in that folder should be added automatically to core framework.

## Scripts

Scripts folder holds commonly used scripts that need to be run often and are run in docker containers to lower required tools on local machine. run scripts out of the scripts folder.

build.bat - builds/starts docker containers
migrate_taskboard.bat - builds/runs migration for taskboard module db TODO: deprecate and move to a more generic script
start.bat - start containers

other scripts - TODO: fix up these and give a proper description

## Docker

Docker is used for lower overhead when swapping to a new pc.

web - web server handling website
db - runs database, stores database on host machine so recreating container doesn't destroy existing data
redis - unused, there in case a cashing database is needed

web_test - separate test server, uses sqlite database to keep testing data separate from production data
ui - ?



# TODO list/feature list

- Convert django web to use https (required for some projects)
- Fix test suite to be in each app and run from there (core tests should be run here though)
- Convert from Mysql to Postgresql
- Clean up scripts folder
- Add a git importer for submodules that are under https://github.com/stars/hewenttojrod/lists/django-web-app (or custom list provided by user)
- Add standardized web components in core and ui testing for the components
- Add user functionality (log in/storage) and Oauth2
- build an actual working project
- clean up ai code and limit agent usage