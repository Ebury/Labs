Files related to the Ebury Labs blog post "Development with Docker containers"
https://labs.ebury.rocks/2016/04/20/development-with-docker-containers-ebury-macosx/

Files have been slightly edited to explain usage, and would need to be edited to make them work for your situation.

Host files are used by hostswitch.sh and should be copied to /etc, when copied to another location, the path should be changed in hostswitch.sh to match

Since the demo environment where the orginal project has been set up, uses Wordpress therefor hostswitch.sh has logic to copy the wp-config file upon switching enviroments. You should include those files yourself, when going through the hostswitch.sh file it should be clear what is needed.
