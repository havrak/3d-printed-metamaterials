# Data directory
This directory stores output of simulations from CST.
Since CST's touchstone export functionality is terrible - I need to export with custom VBA macros where I don't have parameter configuration is accompanying `-paramter.txt` files.
Thus I need to export parameter configuration from result navigator - outputing a `.csv` file.
However CST lists in result navigator only those parameters that are chaining.
Thus `./csv_add_columns.py` script is used to add missing columns to the `.csv` file.

