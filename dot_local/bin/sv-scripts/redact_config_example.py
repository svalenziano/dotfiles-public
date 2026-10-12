
IN_DIR = "~/temp/to-redact"
OUT_DIR = "~/temp/redacted"

# DON'T FORGET THE TRAILING COMMAS!
WORDS_TO_REDACT = [
    '12345687', # account number
]

REGEXES_TO_REDACT = [
    '123.*45.*6789',  # ssn
    'The treasure is in.*$'
]