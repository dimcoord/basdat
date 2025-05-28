import csv
import argparse

def escape_sql_string(value):
    """Escapes a string for SQL insertion, handling single quotes."""
    if value is None:
        return "NULL"
    return "'" + str(value).replace("'", "''") + "'"

def convert_value(value_str):
    """
    Converts a CSV value string to its SQL representation.
    - Empty strings are treated as NULL.
    - Tries to identify numbers (integers and floats) and leaves them unquoted.
    - All other values are treated as strings and are quoted.
    """
    if value_str == "" or value_str is None:
        return "NULL"
    try:
        float_val = float(value_str)
        if float_val.is_integer():
            return str(int(float_val))
        return str(float_val)
    except ValueError:
        return escape_sql_string(value_str)

def csv_to_sql_inserts(csv_file_path, table_name, output_sql_file=None,
                       delimiter=',', has_header=True, batch_size=0, category_id=None): # Added category_id
    """
    Converts a CSV file to SQL INSERT statements.

    Args:
        csv_file_path (str): Path to the input CSV file.
        table_name (str): Name of the SQL table.
        output_sql_file (str, optional): Path to save the generated SQL. Prints to console if None.
        delimiter (str, optional): Delimiter used in the CSV file. Defaults to ','.
        has_header (bool, optional): Whether the CSV file has a header row. Defaults to True.
        batch_size (int, optional): If > 0, generates multi-row INSERTs. Defaults to 0 (one INSERT per row).
        category_id (int, optional): An integer category ID to add to each row. Defaults to None.
    """
    sql_statements = []
    column_names_str = ""
    current_batch_values = []
    # Define the name for the category_id column
    category_id_col_name = 'category_id'


    try:
        with open(csv_file_path, mode='r', newline='', encoding='utf-8') as csvfile:
            reader = csv.reader(csvfile, delimiter=delimiter)
            
            final_headers = []
            if has_header:
                csv_headers = next(reader)
                final_headers.extend(csv_headers)
                print(f"Read CSV headers: {', '.join(csv_headers)}")
            else:
                # If no CSV header, we can't get column names from it.
                # The INSERT will be `INSERT INTO table VALUES (...)`
                # or `INSERT INTO table (category_id) VALUES (...)` if only category_id is effectively a "header".
                # For simplicity, if no CSV header, column_names_str will reflect that.
                print("No header row assumed in CSV.")

            if category_id is not None:
                final_headers.append(category_id_col_name)
                if not has_header:
                    # If there were no CSV headers, but category_id is added,
                    # it implies the column name 'category_id' should be specified.
                    # This setup means only 'category_id' would be named if no CSV headers.
                    # A more robust way if no CSV headers is for the user to ensure
                    # their table structure implicitly matches (CSV cols first, then category_id).
                    # The current logic will correctly add category_id to the column list if `has_header` is true,
                    # or if `has_header` is false and `category_id` is the *only* column being explicitly named.
                    # To keep it general: if there are *any* final_headers, use them.
                     print(f"Adding column: '{category_id_col_name}' for the provided category_id.")


            if final_headers: # If we have any column names (from CSV or just category_id)
                sanitized_headers = [f"`{h.strip()}`" for h in final_headers]
                column_names_str = f"({', '.join(sanitized_headers)})"
                print(f"Target SQL column names: {column_names_str}")
            else:
                # This case means no CSV header AND no category_id, or category_id provided but we are
                # relying on implicit column order for `INSERT INTO table VALUES (csv_val1, ..., category_id_val)`.
                # The value for category_id will still be appended to each row's values list later.
                 if category_id is not None:
                    print(f"Note: '{category_id_col_name}' value will be appended. Ensure table column order is CSV columns then '{category_id_col_name}'.")


            # Determine the number of rows for accurate batching at the end
            # Re-open to count rows without consuming the reader for data processing
            with open(csv_file_path, mode='r', newline='', encoding='utf-8') as count_file:
                row_counter = csv.reader(count_file, delimiter=delimiter)
                if has_header: # Skip header if it was read initially
                    next(row_counter, None)
                num_data_rows = sum(1 for _ in row_counter)


            # Resume reading data rows from the original reader object
            for i, row in enumerate(reader):
                if not any(field.strip() for field in row): # Skip empty rows
                    continue

                # Process values from CSV
                processed_csv_values = [convert_value(cell.strip()) for cell in row]

                # Add category_id value if provided
                current_row_all_values = list(processed_csv_values) # Make a mutable copy
                if category_id is not None:
                    current_row_all_values.append(str(category_id)) # Add as string, convert_value not needed as it's a known int

                values_str = f"({', '.join(current_row_all_values)})"

                if batch_size > 0:
                    current_batch_values.append(values_str)
                    # Check if it's time to write the batch
                    if len(current_batch_values) >= batch_size or (i + 1) == num_data_rows:
                        if current_batch_values:
                            insert_prefix = f"INSERT INTO `{table_name}` {column_names_str} VALUES "
                            sql_statements.append(insert_prefix + ",\n".join(current_batch_values) + ";")
                            current_batch_values = []
                else:
                    sql_statements.append(f"INSERT INTO `{table_name}` {column_names_str} VALUES {values_str};")

        if output_sql_file:
            with open(output_sql_file, mode='w', encoding='utf-8') as sqlfile:
                for stmt in sql_statements:
                    sqlfile.write(stmt + "\n")
            print(f"SQL INSERT statements saved to: {output_sql_file}")
        else:
            print("\n--- Generated SQL INSERT Statements ---")
            for stmt in sql_statements:
                print(stmt)
            print("--- End of SQL ---")

    except FileNotFoundError:
        print(f"Error: CSV file not found at '{csv_file_path}'")
    except Exception as e:
        print(f"An error occurred: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Convert a CSV file to SQL INSERT statements.")
    parser.add_argument("csv_file", help="Path to the input CSV file.")
    parser.add_argument("table_name", help="Name of the SQL table.")
    parser.add_argument("-o", "--output", help="Path to the output .sql file (optional, prints to console if not provided).")
    parser.add_argument("-d", "--delimiter", default=",", help="Delimiter used in the CSV file (default: ',').")
    parser.add_argument("--no-header", action="store_false", dest="has_header", help="Specify if the CSV file does not have a header row.")
    parser.add_argument("-b", "--batch-size", type=int, default=0, help="Number of rows per INSERT statement (0 for one INSERT per row, e.g., 100 for batch inserts).")
    parser.add_argument("--category-id", type=int, help="An integer category ID to add to each row.") # New argument

    args = parser.parse_args()

    csv_to_sql_inserts(
        args.csv_file,
        args.table_name,
        output_sql_file=args.output,
        delimiter=args.delimiter,
        has_header=args.has_header,
        batch_size=args.batch_size,
        category_id=args.category_id # Pass the new argument
    )