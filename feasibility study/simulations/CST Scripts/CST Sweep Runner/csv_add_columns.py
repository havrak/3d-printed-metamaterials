import sys
import argparse
from pathlib import Path

def main():
    parser = argparse.ArgumentParser(description="Add constant columns to CST quoted tab-separated exports.")
    parser.add_argument("input_file", help="Path to the input file (e.g. navigator.txt)")
    parser.add_argument("-o", "--output", help="Path to the output file (optional)", default=None)
    
    args, unknown = parser.parse_known_args()
    
    new_columns = {}
    i = 0
    while i < len(unknown):
        if unknown[i].startswith("--"):
            col_name = unknown[i].lstrip("-")
            if i + 1 < len(unknown) and not unknown[i+1].startswith("--"):
                new_columns[col_name] = unknown[i+1]
                i += 2
            else:
                new_columns[col_name] = ""
                i += 1
        else:
            i += 1
            
    if not new_columns:
        print("No constants to add. Specify them using the format: --ratio 1 --P_ratio -0.4")
        sys.exit(0)
        
    out_path = args.output if args.output else f"updated_{Path(args.input_file).name}"
    
    rows = []
    with open(args.input_file, 'r', encoding='utf-8-sig') as f_in:
        for line in f_in:
            line_stripped = line.strip()
            if not line_stripped:
                continue
            
            # Split strictly by tabs, then clean up leading/trailing quotes and spaces from each field
            raw_fields = line_stripped.split('\t')
            cleaned_fields = [f.strip().strip('"').strip("'") for f in raw_fields]
            rows.append(cleaned_fields)
                
    if not rows:
        print("Error: Input file is empty.")
        sys.exit(1)
        
    headers = rows[0]
    data_rows = rows[1:]
    
    # Check which new columns already exist
    existing_ignored = [k for k in new_columns.keys() if k in headers]
    columns_to_add = {k: v for k, v in new_columns.items() if k not in headers}
    
    new_headers = headers + list(columns_to_add.keys())
    
    # Write out cleanly formatted tab-separated file with professional quoting matching CST style
    with open(out_path, 'w', encoding='utf-8') as f_out:
        # Write header
        header_line = '\t'.join([f'"{h}"' for h in new_headers])
        f_out.write(header_line + '\n')
        
        # Write data rows
        for row in data_rows:
            extended_row = row + list(columns_to_add.values())
            row_line = '\t'.join([f'"{val}"' for val in extended_row])
            f_out.write(row_line + '\n')
            
    if existing_ignored:
        print(f"INFO: Skipped existing columns (kept original values): {existing_ignored}")
    
    if columns_to_add:
        print(f"SUCCESS: Added columns {list(columns_to_add.keys())} with values {list(columns_to_add.values())}")
    else:
        print("No new columns were added (all specified parameters already existed).")
        
    print(f"Output saved to: {out_path}")

if __name__ == '__main__':
    main()