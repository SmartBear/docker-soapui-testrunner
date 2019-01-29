# Docker SoapUI Test Runner

## Table of content

* [About](#about)
* [Required license](#required-license)
* [Building an image](#building-an-image)
* [Running containers](#running-containers)
  * [Arguments](#arguments)
  * [Full command sample](#full-command-sample)
  * [Environment variables](#environment-variables)
  * [Exit codes](#exit-codes)
  * [Troubleshooting](#troubleshooting)

## About

This project can be used to build custom Docker images to run [SoapUI functional tests](https://support.smartbear.com/readyapi/docs/soapui/intro/about.html) within containers. The examples of image customization can be found in the Dockerfile.

## Required license

To use the image, you must have a [SoapUI floating license](https://support.smartbear.com/readyapi/docs/general-info/licensing/activate/floating/index.html). When you run a container, it connects to the specified license server and obtains the license. The license server must be available to the container and properly configured. See [Configure License Server](https://support.smartbear.com/readyapi/docs/general-info/licensing/activate/floating/configure-license-server.html).

## Building an image

Perform the following steps to build an image:

* Install [Docker](https://store.docker.com/editions/community/docker-ce-desktop-windows)
* Clone this repository to a local folder
  ```
  git clone https://github.com/smartbear/docker-soapui-testrunner
  ```
* Execute the following command in the repository root folder:
  ```
  docker build -t mycompany/docker-soapui-testrunner .\
  ```

## Running containers

To run a SoapUI functional test in a Docker container, use the following command line:

	docker run -v="Project Folder":/project -v="Report Folder":/reports -v="Extensions Folder":/ext -e LICENSE_SERVER="License Server Address" -e COMMAND_LINE="Test Runner Arguments" -it mycompany/docker-soapui-testrunner

### Arguments

- *-v="Project Folder":/project*
	**Required.** Specifies the path to the folder that contains the ReadyAPI project. When a container starts this folder is copied to the container.
	Usage: ```-v="/readyapi/projects/sample-readyapi-project":/project```
	
	**Note**: On some systems, you may need to change the path in the following way:
	```"/readyapi/projects/sample-readyapi-project" -> "/host_mnt/readyapi/projects/sample-readyapi-project"```

- *-v="Extensions Folder":/ext*
    Specifies the folder whose content will be copied to the /bin/ext folder of the ReadyAPI installation in the container. Use this argument if your project requires additional libraries, such as database drivers or plugins.
    Usage: ```-v="/readyapi/ext":/ext```
    
	**Note**: On some systems, you may need to change the path in the following way:
	```"/readyapi/ext" -> "/host_mnt/readyapi/ext"```

- *-v="Report Folder":/reports*
	Specifies the folder on a local machine to which the generated reports will be exported.
	Usage: ```-v="/readyapi/reports":/reports```
	 
	**Note**: On some systems, you may need to change the path in the following way:
	```"/readyapi/reports" -> "/host_mnt/readyapi/reports"```

- *-e LICENSE_SERVER="License Server Address"*
    **Required.** Specifies the address of the license server. When a container runs, it connects to the specified server to obtain the Floating SoapUI license.
    Usage: ```-e LICENSE_SERVER="10.0.10.1:1099"```

- *-e COMMAND_LINE="Test Runner Arguments"*
    **Required.** Specifies arguments for the test runner. The %project% variable refers to the container folder to which the contents of the project folder were copied. To refer to the reports volume, use the %reports% variable.
    Usage: ```-e COMMAND_LINE="-f/%reports% '-RJUnit-Style HTML Report' -FHTML '-EDefault environment' '/%project%/sample-readyapi-project.xml'"```

- *-it*
    **Required.** This command enables an interactive command-line interface within the Docker container.

- *mycompany/docker-soapui-testrunner*
    **Required.** Specifies the image to create a container from.

#### Full command sample

    docker run -v="/readyapi/projects/sample-readyapi-project":/project -v="/readyapi/reports":/reports -v="/readyapi/ext":/ext -e LICENSE_SERVER="10.0.10.1:1099" -e COMMAND_LINE="-f/%reports% '-RJUnit-Style HTML Report' -FHTML '-EDefault environment' '/%project%/sample-readyapi-project.xml'" -it mycompany/docker-soapui-testrunner

### Environment variables

- *READYAPI_VERSION*.
    Contains the ReadyAPI version.
    Example: ```2.6.0```
   
- *READYAPI_FOLDER*.
    Contains the folder where ReadyAPI is installed.
    Example: ```/usr/local/SmartBear/ReadyAPI-2.6.0```
   
- *PROJECT_FOLDER*.
    Contains the folder where a project and all the dependent files are located.
    Default value: ```/usr/local/SmartBear/project```
    
- *REPORTS_FOLDER*.
    Contains the container folder where reports will be placed. If the command line option _-v="Report Folder":/reports_ is used then this folder will be mapped to a folder on a local machine.
    Default value: ```/reports``` 

- *LICENSE_SERVER*.
    Contains the address of the license server to get a floating license from.
    Example: ```10.0.10.1:1099```
    
- *COMMAND_LINE*.
    Contains the SoapUI test runner arguments.
    Example: ```-f/%reports% '-RJUnit-Style HTML Report' -FHTML '-EDefault environment' '/%project%/sample-readyapi-project.xml'```

### Exit codes

Besides the standard Docker exit codes (see the [Docker documentation](https://docs.docker.com/engine/reference/run/#exit-status)) the *docker-soapui-testrunner* image uses the following codes:

| Code | Description |
| --- | --- |
| 101 | ReadyAPI running in a container cannot start due to a license issue.  Make sure the license server is properly [configured](https://support.smartbear.com/readyapi/docs/general-info/licensing/activate/floating/configure-license-server.html)  and the Docker image can access it. See information on [other possible issues with a floating license](https://support.smartbear.com/readyapi/docs/general-info/licensing/troubleshooting/floating.html). |
| 102 | The ReadyAPI project was not found. Make sure you specified the correct folder for the *project* volume, and this folder contains the specified project. |
| 103 | An error occurred during the test run. See the test log for more information.|

### Troubleshooting

If you cannot run Docker due to the **Drive has not been shared** error, perform the following steps:

1. Right-click the Docker icon in the notification area and select **Settings**.
2. On the **Shared Drives** page of the **Settings** dialog, select all the drives you use to run the Docker image.
3. Click **Apply**. You may need to enter the credentials of your system account to apply the changes.

**Note**: If your drives have already been shared, but the error occurs anyway, turn off sharing. After you apply the changes, repeat these steps to share the drives again.