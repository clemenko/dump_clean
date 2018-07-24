# My back-of-the-napkin thoughts:

## Objective:

## Scripting to anonymize data collected by customers so that the data can be provided to Docker.

## Required outcomes:

- Original data must not be changed.  We make a copy and modify that.
- All changes are logged
- Sane replacement so that obfuscated IP addresses, hostnames, etc can be logically followed in the logs


## Usage :
Edit the `dump_clean.sh` to change the variables at the top of the script. Specifically the URL, data_dir and password.

Then Run...

```
./dump_clean.sh
```
