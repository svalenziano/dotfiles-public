Most scripts in this directory can be invoked by executing the python file without specifying an interpreter.  The hashbang tells the system to use `uv`, and to install dependencies before running.

For a script called `executable_script.py`, you'll be able to simply type `script.py` from anywhere, and run the script.

Since this is a chezmoi repo, chezmoi strips the `executable_` prefix after you do `chezmoi apply`

Here's a hashbang example:
```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "pillow",
# ]
# ///
```