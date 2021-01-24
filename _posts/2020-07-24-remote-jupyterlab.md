---
title: Remote jupyterlab without SSH and sudo
key: A10010
tags: python Jupyterlab Linux
category: Tech
date: 2020-07-24
---

*Disclaimer: this guideline is only suggested for servers within secure local connections, e.g. within an institution or corporation's network*.

[SSH port forwarding](https://www.ssh.com/ssh/tunneling/example) is a common way of connecting to remote jupyter notebooks. This typically takes three steps: run jupyter on the server, ssh tunneling to the jupyter instance, and then type the localhost link to your browser. That actually doesn't sound satisfying, and it could be simpler. In this post, I'll guide you through setting up a remote jupyterlab workspace for Python3 from scratch. Since you want to set remote notebooks, I'll assume you feel comfortable with command lines and remote editing. 

## Check your python version on server
As of 2020, Python3 is strongly recommended.

If you are using RedHat Enterprise 7, the system-wide default version is Python2.7, but your system administrator usually should have installed python3. Suppose python3.6 is installed, you can enable python3 by `scl enable rh-python36 bash`.

If you are using Debian or Ubuntu, python3 comes with the system. In case you want to make python3 as default, add the following line to your `.bashrc` file:
```alias python=python3```

## Manage python environments
Working with python [virtual environments](https://realpython.com/python-virtual-environments-a-primer/) is good practice. 
Here `venv` module and `conda` are briefly introduced, which use `pip` and `conda` as package manager respectively. 
This [post](https://www.anaconda.com/blog/understanding-conda-and-pip#:~:text=Pip%20installs%20Python%20packages%20whereas,software%20written%20in%20any%20language.&text=Another%20key%20difference%20between%20the,the%20packages%20installed%20in%20them.) from Anaconda summarizes the differences between pip and conda nicely.
Note that `pip` and `conda` are direct competitors in terms of managing packages. Within a venv environment, doing `pip install conda` wouldn't give you a standalone `conda` command for your venv environment. 

### The venv way
- cd to your project directory, e.g. "myProject"
- Create virtual environments: `python -m venv project-venv`
- Activate the environments: `source ./project-venv/bin/activate`
- Install packages to the venv with pip, e.g. `pip install jupyterlab`
- To quit the venv: `deactivate`

### The conda way
- Go to home folder: `cd $HOME`
- Create a temporary folder to keep home folder clean: `mkdir temp && cd temp`
- Get the [anaconda](https://repo.anaconda.com/archive/) or miniconda linux installer, e.g. for Anaconda3: `wget https://repo.anaconda.com/archive/Anaconda3-2020.07-Linux-x86_64.sh`
- Install the downloaded: `TMPDIR=./ bash ./Anaconda3-2020.07-Linux-x86_64.sh`. Note that `TMPDIR` is specified to avoid permission issue caused by limited space of the default TMPDIR. 
- Hit enter until you are asked to type "yes".
- The default path is usually `$HOME/anaconda3/`
- At the end of installation, say "yes" to have conda initializer. But that would set Anaconda python3 as your default python
- Logout and login again, you'll enter the conda base environment.
- If you hate anaconda to change your default python and automatically activate base environment like me, run this command to remedy: `conda config --set auto_activate_base false`
- Create conda virtual environment: `conda create -n myCondaEnv python=3.7 anaconda`
- Activate environment `conda activate myCondaEnv`
- Intall packages to `myCondaEnv`, including `conda install jupyterlab`

## Configure Jupyter
Up to this point, you are set to use ssh tunneling for remote connecting, but we can get around that by a few configurations for jupyter notebooks.  

### Generate jupyter notebook configuration file
```
jupyter notebook --generate-config
```
This command creates a configuration file at `$HOME/.jupyter/jupyter_notebook_config.py` with all defaults commented out.
### Customize the config file
  Put the following lines to `jupyter_notebook_config.py`:
```python
c = get_config()
c.NotebookApp.ip = '*' #use the system IP address for accessing 
c.NotebookApp.port = 8890 #if the specified port is occupied,incrementally get next one
c.NotebookApp.open_browser = False #no browser
from IPython.lib import passwd
password = passwd("yourpassword")
c.NotebookApp.password = password #use password instead of access token.  
```

To avoid hard-coding your password to a file, comment last three lines to disable password. Then Juypyter will generate a one-time token for accessing the jupyterlab instance.  

## Run jupyterlab in the background
```
nohup jupyter lab &
```
This command will run jupyterlab in the background, and the printouts will be forwarded to a generated file "nohup.out" in which you will see something like this 
```
[I 16:45:57.163 LabApp] http://yourIPorDomainName:8890/
```
This is your accesible link to the jupyter instance. Now you can safely logout the server.  

If you choose to use token for accessing, you'll need to copy the full link with token to your browser. And the token will be used to set a [cookie](https://jupyter-notebook.readthedocs.io/en/stable/security.html#:~:text=If%20a%20generated%20token%20doesn,notebook%20password%20command%20is%20added.) for your browser.

## Connect to remote jupyterlab
Type `http://yourIPorDomainName:8890/` or `link with token` in your browser.

You'll be asked to enter the password you have put into the jupyter config file on the server.

Now enjoy working with the remote jupyterlab. As long as the server is running, you only need the link to access.  

## Kill the process of jupyterlab if needed
You might want to kill the process at some point.
With this command you can find the `pid` of process for jupyterlab:
```
netstat -tulpn | grep '8890'
```
Then use `top` or `kill` command to end the process. 

## Manage multiple environments in one Jupyter instance
You'll probably notice that starting a Jupyter instance for every environment is actually annoying, because we often times need to work on several projects with different settings. 
It is better that one can link conda environments to ipython kernels such that the environments can show up in one jupyter instance. For instance, I use miniconda3, and `conda env list` tells me following:
```
base                  *  /path/to/miniconda3
rdkit                    /path/to/miniconda3/envs/rdkit
yolo                     /path/to/miniconda3/envs/yolo
```
The idea is that when I start a jupyterlab instance in the base environment, I can also access `rdkit` and `yolo` envs.
```bash
conda activate base
conda install ipykernel
ipython kernel install --user --name=yolo
ipython kernel install --user --name=rdkit
```
Next step is to make sure the ipython kernels are linked to the right envs, for example, in the json file `.local/share/jupyter/kernels/rdkit/kernel.json`, the first entry for `argv` should point to `/path/to/miniconda3/envs/rdkit`. If not, change that accordingly.

Now `rdkit` and `yolo` will show up in jupyterlab.



## The end
- The method has been tested on RHEL7 and Debian servers. 
- It also works for Windows Subsystems for Linux (WSL) Ubuntu 18.04.
- For downloading files from remote, besides `scp`, you can right click the file to create a downloadable link in jupyterlab.

Hope you'll find this guide helpful.  
