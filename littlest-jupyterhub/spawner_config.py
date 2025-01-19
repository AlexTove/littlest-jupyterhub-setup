"""
JupyterHub config to change where user notebooks are saved.
"""

import os
import grp
import pwd
import subprocess
from os.path import expanduser

from systemdspawner import SystemdSpawner
from traitlets import Dict, List, Unicode

from tljh import user
from tljh.normalize import generate_system_username

NOTEBOOK_HOME="/srv/notebooks/{username}"

class CustomUserCreatingSpawner(SystemdSpawner):
    """
    SystemdSpawner with user creation and workspace dir change on spawn.
    """

    user_groups = Dict(key_trait=Unicode(), value_trait=List(Unicode()), config=True)

    def ensure_user(self, username):
        """
        Make sure a given user exists
        """
        # Check if user exists
        try:
            pwd.getpwnam(username)
            # User exists, nothing to do!
            return
        except KeyError:
            # User doesn't exist, time to create!
            pass

        subprocess.check_call(["useradd", "-d", NOTEBOOK_HOME.format(username=username), "-m", username])

        subprocess.check_call(["chown", "-R", f"{username}:{username}", NOTEBOOK_HOME.format(username=username)])

        subprocess.check_call(["chmod", "o-rwx", NOTEBOOK_HOME.format(username=username)])

    def start(self):
        """
        Perform system user activities before starting server
        """
        system_username = generate_system_username("jupyter-" + self.user.name)

        self.username_template = system_username
        self.ensure_user(system_username)
        user.ensure_user_group(system_username, "jupyterhub-users")
        if self.user.admin:
            self.disable_user_sudo = False
            user.ensure_user_group(system_username, "jupyterhub-admins")
        else:
            self.disable_user_sudo = True
            user.remove_user_group(system_username, "jupyterhub-admins")
        if self.user_groups:
            for group, users in self.user_groups.items():
                if self.user.name in users:
                    user.ensure_user_group(system_username, group)

        return super().start()

c = get_config()  # noqa
c.JupyterHub.spawner_class = CustomUserCreatingSpawner
