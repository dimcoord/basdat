#!/bin/bash

# Script to execute SQL scripts on a MariaDB server

# --- Configuration ---
DEFAULT_DB_HOST="localhost"
# DEFAULT_DB_NAME="your_database_name" # Optional: Uncomment and set if you always target the same DB

# --- Functions ---
print_usage() {
  echo "Usage: $0 <sql_script_file1> [sql_script_file2 ...]"
  echo "  Prompts for MariaDB username and password."
  echo "  Set DB_HOST and DB_NAME environment variables to override defaults or configure them below."
}

# --- Get Connection Details ---
read -p "Enter MariaDB User: " DB_USER
read -sp "Enter MariaDB Password: " DB_PASS
echo # Newline after password input

DB_HOST="${DB_HOST:-$DEFAULT_DB_HOST}"
DB_NAME_PARAM=""

# Check if DEFAULT_DB_NAME is set and not empty
if [ -n "${DEFAULT_DB_NAME-}" ]; then # Using bashism for checking if var is set
    DB_NAME_PARAM="-D ${DEFAULT_DB_NAME}"
    echo "Using default database: ${DEFAULT_DB_NAME}"
elif [ -n "${DB_NAME-}" ]; then # Check if DB_NAME env var is set
    DB_NAME_PARAM="-D ${DB_NAME}"
    echo "Using database from DB_NAME environment variable: ${DB_NAME}"
else
    echo "No specific database selected via script config or DB_NAME env var. "
    echo "Ensure your SQL scripts use 'USE database_name;' or you connect to the correct default database."
fi


# --- Check for SQL script arguments ---
if [ "$#" -eq 0 ]; then
  echo "Error: No SQL script file(s) provided."
  print_usage
  exit 1
fi

echo "--- Starting SQL Script Execution ---"

# --- Loop through each SQL script provided ---
for SQL_SCRIPT in "$@"; do
  echo "" # Newline for readability
  if [ ! -f "$SQL_SCRIPT" ]; then
    echo "Error: SQL script file '$SQL_SCRIPT' not found. Skipping."
    continue
  fi

  if [ ! -r "$SQL_SCRIPT" ]; then
    echo "Error: SQL script file '$SQL_SCRIPT' is not readable. Skipping."
    continue
  fi

  echo "Executing SQL script: $SQL_SCRIPT on host '$DB_HOST'..."

  # Construct the mysql command
  # The -s flag for silent password prompt is not used as we provide it.
  # Using --batch to produce less interactive output, suitable for scripting.
  # Using --show-warnings to get more feedback.
  COMMAND="mysql -h \"${DB_HOST}\" -u \"${DB_USER}\" -p\"${DB_PASS}\" ${DB_NAME_PARAM} --batch --show-warnings < \"${SQL_SCRIPT}\""

  # Execute the command
  # Use eval if you absolutely trust all inputs, or build command array for more safety
  # For simplicity here, using eval. Be cautious if script names or params can be malicious.
  # A safer way without eval if parameters are simple:
  # mysql -h "${DB_HOST}" -u "${DB_USER}" -p"${DB_PASS}" ${DB_NAME_PARAM} --batch --show-warnings < "${SQL_SCRIPT}"

  if eval "${COMMAND}"; then
    echo "Successfully executed: $SQL_SCRIPT"
  else
    echo "Error executing: $SQL_SCRIPT. Check output above for details."
    # Optional: Exit on first error
    # echo "Exiting due to error."
    # exit 1
  fi
done

echo "" # Newline for readability
echo "--- SQL Script Execution Finished ---"