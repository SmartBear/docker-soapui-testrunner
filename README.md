# Docker ReadyAPI Test Runner

## Table of contents

- [Docker ReadyAPI Test Runner](#docker-soapui-test-runner)
  - [Table of contents](#table-of-contents)
  - [About](#about)
  - [Required license](#required-license)
  - [Build an image](#build-an-image)
  - [Required arguments](#required-arguments)
  - [Configure an image](#configure-an-image)
    - [Add files to an image](#add-files-to-an-image)
    - [Specify a license server](#specify-a-license-server)
    - [Integrate external libraries](#integrate-external-libraries)
    - [Install plugins](#install-plugins)
    - [Specify a command line](#specify-a-command-line)
  - [Run a Docker container](#run-a-docker-container)
    - [Arguments](#arguments)
      - [Full command sample](#full-command-sample)
  - [Environment variables](#environment-variables)
  - [Exit codes](#exit-codes)
  - [Troubleshooting](#troubleshooting)

## About

Use this project to create custom Docker images to run [ReadyAPI functional tests](https://support.smartbear.com/readyapi/docs/functional/intro/about.html). The project contains a sample *Dockerfile* that you use to extend the base [_ready-api-soapui-testrunner_](https://hub.docker.com/r/smartbear/ready-api-soapui-testrunner) image.

## Required license

To use a Docker image, you must have a [ReadyAPI Test floating license](https://support.smartbear.com/readyapi/docs/general-info/licensing/file-based/activate/floating/index.html). When you run a container, it connects to the specified license server and obtains the license. The license server must be available to the container and must be properly configured. See [Configure License Server](https://support.smartbear.com/readyapi/docs/general-info/licensing/file-based/activate/floating/configure-license-server/configure-license-server.html).

## Build an image

To build an image:

1. Install [Docker](https://store.docker.com/editions/community/docker-ce-desktop-windows).
2. Clone this repository to a local folder. To do this by using [Git](https://git-scm.com/), run the following command:
  ```
  git clone https://github.com/smartbear/docker-soapui-testrunner
  ```
3. [Edit the Dockerfile](#configure-an-image) to customize the image.
4. Execute the following command in the repository root folder:
  ```
  docker build -t mycompany/docker-soapui-testrunner .\
  ```
5. After the image has been built, you can [run a container](#run-a-docker-container).

## Required arguments

To run a ReadyAPI functional test in a Docker container, you need to pass the following data to the container:

- the project file
- the address of the license server
- the command line that will run the test

Optionally, you may need to pass:

- additional files used in the project
- extension libraries

There are two ways to pass this data to a container: [add it to the base image](#configure-an-image) or [specify it in the command line](#run-a-docker-container) when you run the container.

Typically, you add data that is not changed from test to test to the image and specify variable data in the command line when you run a container.

## Configure an image

To add data to an image, edit your Dockerfile. A Dockerfile is a set of instructions for Docker on how to build an image. To learn how to build images, see [Docker documentation](https://docs.docker.com/engine/reference/builder/).

Below, you can find several examples with typical tasks:

* [Add files to an image](#add-files-to-an-image)
* [Specify a license server](#specify-a-license-server)
* [Integrate external libraries](#integrate-external-libraries)
* [Specify a command line](#specify-a-command-line)

### Add files to an image

If you add files to an image, the files will be available to each container when they start.
To add files, use the `ADD` command. For example:

```
ADD my-folder $PROJECT_FOLDER
```
This command copies all the files from the  *my-folder* directory to the project directory in an image.

**Important**: The directory you want to add must be in the folder containing the Dockerfile.

To learn more about the `$PROJECT_FOLDER` environment variable, see [below](#environment-variables).

**Tip**: Make sure you use the relative path to these files in the project. To learn more about it, see [ReadyAPI documentation](https://support.smartbear.com/readyapi/docs/testing/best-practices/root.html).

### Specify a license server

If your containers use the same license server,  you can add its address to an image. To do this, assign the license server address to the [LICENSE_SERVER](#environment-variables) environment variable in the Dockerfile:

```
ENV LICENSE_SERVER=License server address
```
For example:
```
ENV LICENSE_SERVER=10.0.21.14:1099
```

### Integrate external libraries

If you use external libraries in your project, you need to add them to the ReadyAPI installation folder. For example, if you use databases in a test, you need to install JDBC drivers. Most likely, you will use the same driver in all your test runs, so it is reasonable to include it in a Docker image. To do this:

1. Copy the needed libraries to the _ext_ folder that contains the Dockerfile.
2. Add the following instruction to the Dockerfile:
```
  ADD ext $READYAPI_FOLDER/bin/ext
```

To learn more about the `READYAPI_FOLDER` environment variable, see [below](#environment-variables).

### Install plugins

If you use plugins in your test, you must install them to ReadyAPI in a container. For example, if you run your test by using the MQTT or AMQP protocols, you must install the related plugins. It is possible to add them to a Docker image. In this case, you can omit `-v="Plugins folder":/root/.soapui/plugins` in the command line. Note that the plugin files you want to add must be in the build context.

To add plugins to a Docker image, do the following:

1. Copy the needed plugins to the _plugin_ folder that contains the Dockerfile. You can find the plugins installed in ReadyAPI in the _\<User folder\>/.soapui/plugins_ folder.
2. Add the following instruction to the Dockerfile:
```
  ADD plugins /root/.soapui/plugins
```

### Specify a command line

If your containers use the same command line, you can add it to an image. To do this, modify the `COMMAND_LINE` [environmental variable](#environment-variables):

```
ENV COMMAND_LINE="-f/%reports% '-RJUnit-Style HTML Report' -FHTML '-EDefault environment' '/%project%/sample-readyapi-project.xml'"
```
**Note**: The command line in the example above commands ReadyAPI to generate reports. To copy this report to your host machine, you need to specify the folder to which you want to copy it. See [below](#arguments) for more information.

## Run a Docker container

To run a ReadyAPI functional test in a Docker container, use the following command line:

	docker run -v="Project Folder":/project -v="Report Folder":/reports -v="Extensions Folder":/ext -v="Plugins Folder:/root/.soapui/plugins -e LICENSE_SERVER="License Server Address" -e COMMAND_LINE="Test Runner Arguments" -it mycompany/docker-soapui-testrunner

Depending on the data you [added to the image](#add-files-to-an-image), you can omit some arguments.

### Arguments

- *-v="Project Folder":/project*
  Specifies the path to the folder that contains the ReadyAPI project. When a container starts, this folder is copied to the container.
  Usage: ```-v="С:\readyapi\projects\sample-readyapi-project":/project```

  **Note**: On some systems, you may need to change the path in the following way:
  ```"C:\readyapi\projects\sample-readyapi-project" -> "/host_mnt/C/readyapi/projects/sample-readyapi-project"```

  **Tip**: Alternatively, you can include the needed files in an image (see [above](#add-files-to-an-image)).

- *-v="Extensions Folder":/ext*
    Specifies the folder whose content will be copied to the _/bin/ext_ folder of the ReadyAPI installation folder in a container. Use this argument if your project requires additional libraries, such as database drivers or plugins.<br/>
    Usage: ```-v="C:\readyapi\ext":/ext```

    **Note**: On some systems, you may need to change the path in the following way:
    ```"C:\readyapi\ext" -> "/host_mnt/C/readyapi/ext"```

    **Tip**: Alternatively, you can include the needed libraries in an image (see [above](#integrate-external-libraries)).

- *-v="Plugins Folder":/root/.soapui/plugins*
   Specifies the folder with plugins that should be installed to ReadyAPI in the container.<br/>
   Usage: ```-v="C:\Users\<User>\.soapui\plugins":/root/.soapui/plugis```

   **Note**: On some systems, you may need to change the path in the following way:
    ```"C:\Users\<User>\.soapui\plugins" -> "/host_mnt/C/Users/<User>/.soapui/plugins"```

    **Tip**: Alternatively, you can include the needed plugins in an image (see [above](#integrate-plugins)).

- *-v="Report Folder":/reports*
  Specifies the folder on a local machine to which the generated reports will be exported.<br/>
  Usage: ```-v="C:\readyapi\reports":/reports```

  **Note**: On some systems, you may need to change the path in the following way:
  ```"C:\readyapi\reports" -> "/host_mnt/C/readyapi/reports"```

- *-e LICENSE_SERVER="License Server Address"*
    Specifies the address of the license server. When a container runs, it connects to the specified server to obtain the ReadyAPI Test floating license.<br/>
    Usage: ```-e LICENSE_SERVER="10.0.10.1:1099"```

    **Tip**: Alternatively, you can specify the address of the license server in an image (see [above](#specify-a-license-server)).

- *-e COMMAND_LINE="Test Runner Arguments"*
    Specifies arguments for the test runner. The `%project%` variable refers to the container folder to which the contents of the project folder were copied. To refer to the reports volume, use the `%reports%` variable.<br/>
    Usage: ```-e COMMAND_LINE="-f/%reports% '-RJUnit-Style HTML Report' -FHTML '-EDefault environment' '/%project%/sample-readyapi-project.xml'"```

    **Tip**: Alternatively, you can specify the command line in an image (see an example [above](#specify-a-command-line))

- *-it*
    **Required.** This command enables an interactive command-line interface within a Docker container.

- *mycompany/docker-soapui-testrunner*
    **Required.** Specifies the image to create a container from.

#### Full command sample

    docker run -v="C:\readyapi\projects\sample-readyapi-project":/project -v="C:\readyapi\reports":/reports -v="C:\readyapi\ext":/ext -e LICENSE_SERVER="10.0.10.1:1099" -e COMMAND_LINE="-f/%reports% '-RJUnit-Style HTML Report' -FHTML '-EDefault environment' '/%project%/sample-readyapi-project.xml'" -it mycompany/docker-soapui-testrunner

## Environment variables

The base _ready-api-soapui-testrunner_ image uses the following environment variables:

- *READYAPI_VERSION*
    Contains the ReadyAPI version.
    Example: ```2.8.0```

- *READYAPI_FOLDER*
    Contains the folder where ReadyAPI is installed in a container.
    Example: ```/usr/local/SmartBear/ReadyAPI-2.8.0```

- *PROJECT_FOLDER*
    Contains the folder where a project and all the dependent files are located in a container.
    Default value: ```/usr/local/SmartBear/project```

- *REPORTS_FOLDER*
    Contains the folder where reports will be placed in a container. To copy these reports to a folder on a local machine, use the _-v="Report Folder":/reports_ option when you [run the container](#run-a-docker-container).
    Default value: ```/reports``` 

- *LICENSE_SERVER*
    Contains the address of the license server to get a floating license from.
    Example: ```10.0.10.1:1099```

- *COMMAND_LINE*
    Contains command-line arguments for the ReadyAPI test runner. See a complete list of possible arguments in [ReadyAPI documentation](https://support.smartbear.com/readyapi/docs/functional/running/automating/cli.html).
    Example: ```-f/%reports% '-RJUnit-Style HTML Report' -FHTML '-EDefault environment' '/%project%/sample-readyapi-project.xml'```

## Exit codes

Besides the standard Docker exit codes (see the [Docker documentation](https://docs.docker.com/engine/reference/run/#exit-status)) the *ready-api-soapui-testrunner* image uses the following codes:

| Code | Description |
| --- | --- |
| 101 | ReadyAPI running in a container cannot start due to a license issue.  Make sure the license server is properly [configured](https://support.smartbear.com/readyapi/docs/general-info/licensing/file-based/activate/floating/configure-license-server/configure-license-server.html)  and the Docker image can access it. See information on [other possible issues with a floating license](https://support.smartbear.com/readyapi/docs/general-info/licensing/file-based/troubleshooting/floating.html). |
| 102 | The ReadyAPI project was not found. Make sure you specified the correct folder for the *project* volume, and this folder contains the specified project. |
| 103 | An error occurred during the test run. See the test log for more information.|

## Troubleshooting

If you cannot run Docker due to the **Drive has not been shared** error, perform the following steps:

1. Right-click the Docker icon in the notification area and select **Settings**.
2. On the **Shared Drives** page of the **Settings** dialog, select all the drives you use to run the Docker image.
3. Click **Apply**. You may need to enter the credentials of your system account to apply the changes.

**Note**: If your drives have already been shared, but the error occurs anyway, turn off sharing. After you apply the changes, repeat these steps to share the drives again.
