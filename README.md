

<h1>Plex-Cleaner-Script</h1>

<h2>Purpose: The script is designed to manage storage space by monitoring specific directories containing TV shows and Movies. It checks the available free space and deletes old files if the space falls below a defined threshold. It supports up to 4 directories, only 2 are enabled by default.</h2>

<h2>Configuration:</h2>

It allows users to configure the following aspects:

-Directory paths where TV shows and movies are stored.

-The minimum free space threshold in gibibytes (GiB).

-The time period in days after which files should be considered old and eligible for deletion.

-Whether to perform a dry run (simulate without actual deletion) or a real cleanup.


<h2>Usage:</h2>

Users can specify the directories they want to monitor by customizing the script variables at the top.
They can also adjust the minimum free space and time period as needed.
By setting dry_run to true, they can simulate the cleanup without deleting files. Setting it to false will perform actual deletions.
Users can run the script manually or schedule it to run periodically (e.g., via cron) to maintain storage space.
Important Note: When setting dry_run to false, be cautious, as it will delete files. Always ensure that you have proper backups or copies of your data before enabling this mode.



<h1>DEPENDENCIES</h1>

The script has a dependency on the bc utility for floating-point calculations. This utility is used to perform floating-point comparisons when checking the size of directories against the required minimum free space.



<h2>Installation on Unraid:</h2>

  -Install the NerdTools plugin from the Communinty Applications page.

  -Navigate to the NerdTools plugin and enable bc-1.07.1-x86_64-5.txz plugin.

To install bc on most Linux distributions, you can use the package manager specific to your distribution. Here are some examples:

On Debian/Ubuntu-based systems:

    bash
    sudo apt-get install bc

On Red Hat/CentOS-based systems:

    bash
    sudo yum install bc

On Arch Linux:

    bash
    sudo pacman -S bc

If you're using a different Linux distribution, you may need to consult your distribution's documentation or package manager to install bc.



<h1>Running the Script on Unraid:</h1>

**Install the User Scripts Plugin:**

-If you haven't already, you can install the User Scripts plugin from the Unraid Community Applications Tab.

-In the web interface, go to Plugins in the sidebar.

**Create a User Script:**

-After installing the plugin, you can find it under the Settings section in the sidebar.

-Click on User Scripts to access the User Scripts page.

-Click the Add New Script button to create a new script.

**Configure the Script:**

-Give your script a name and description.

-In the Script field, paste the code of the cleanup script.

-Adjust the variables as described under Configuration

-Set the Schedule for when you want the script to run. For example, you can choose "Daily" to run it every day.

**Save and Run:**

After configuring the script, click the Apply button to save it.
You can also manually run the script by clicking the **RUN IN BACKGROUND** button next to it on the User Scripts page.

**Monitor Logs:**

You can access the script's logs by clicking on the script in the User Scripts page. This can help you track the script's execution and any output it generates.

**Edit or Disable:**

You can edit or disable the script at any time by going back to the User Scripts page.
Using the User Scripts plugin makes it easy to manage and schedule scripts on your Unraid server, and it provides a user-friendly interface for configuring and running scripts. Once your script is set up as a user script, it will run automatically based on the schedule you specified.

               
