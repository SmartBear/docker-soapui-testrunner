FROM smartbear/ready-api-soapui-testrunner:latest

RUN apt-get update -y && apt-get upgrade -y

##### USE CASE 1: integrating a ReadyAPI project into an image

# By default a project and all the dependent files are placed inside some folder
# on a local machine that will be copied to a container when it is started. This
# folder is defined by the command line option -v="Project Folder":/project. But
# it is possible to integrate all the necessary files into an image (you will
# need to specify the project file name in the command line option
# -e COMMAND_LINE="Test Runner Arguments"):

# ADD /readyapi/projects/sample-readyapi-project $PROJECT_FOLDER


##### USE CASE 2: specifying a license server address inside an image

# To run SoapUI tests a floating license is required. The address of the license
# server can be specified either by the command line option
# -e LICENSE_SERVER="License Server Address" or by setting the environment variable:

# ENV LICENSE_SERVER=10.0.10.1:1099


##### USE CASE 3: adding external libraries to ReadyAPI's ext folder

# Some SoapUI tests require external libraries to be executed. For example,
# it is necessary to put the appropriate driver JAR files to ReadyAPI's ext folder
# in case JDBC Request test steps need them. If the command line option
# -v="Extensions Folder":/ext is used then the libaries will be copied to a container
# to the appropriate ReadyAPI folder. The next command can be used to integrate the
# libraries to an image to speed up containers start:

# ADD /readyapi/ext $READYAPI_FOLDER/bin/ext