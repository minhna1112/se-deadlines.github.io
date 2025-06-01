import yaml
import json
import sys

def convert_yaml_to_json(yaml_filepath, json_filepath):
    """
    Reads a YAML file, converts its content to JSON, and saves it to a new file.

    Args:
        yaml_filepath (str): The path to the input YAML file.
        json_filepath (str): The path to the output JSON file.
    """
    try:
        with open(yaml_filepath, 'r') as yaml_file:
            # The --- at the beginning of the yaml file is not part of the data
            # and can cause issues with some loaders if not handled.
            # Reading line by line and filtering it out is one way,
            # or more simply, use safe_load_all and take the first document
            # if we are sure there's only one main document after potential directives.
            # However, the simplest for this specific file which starts with ---
            # then a list, is to just use safe_load.
            yaml_content = yaml_file.read()
            if yaml_content.startswith("---"):
                yaml_content = yaml_content[3:]

            data = yaml.safe_load(yaml_content)

            # Ensure deadlines are always lists, even if there's one or no deadline.
            # This was not explicitly requested but is good practice for consistency
            # if the consumer expects a list. However, the original request is to
            # preserve structure, so we'll stick to that.
            # The provided YAML shows deadlines are either lists of strings or null.
            # JSON handles null fine, and lists of strings are also fine.

    except FileNotFoundError:
        print(f"Error: YAML file not found at '{yaml_filepath}'")
        sys.exit(1)
    except yaml.YAMLError as e:
        print(f"Error parsing YAML file '{yaml_filepath}': {e}")
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred while reading '{yaml_filepath}': {e}")
        sys.exit(1)

    try:
        with open(json_filepath, 'w') as json_file:
            json.dump(data, json_file, indent=4)
        print(f"Successfully converted '{yaml_filepath}' to '{json_filepath}'")
    except IOError:
        print(f"Error: Could not write JSON to file at '{json_filepath}'")
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred while writing '{json_filepath}': {e}")
        sys.exit(1)

if __name__ == "__main__":
    yaml_file_path = '_data/conferences.yml'
    json_file_path = 'conferences.json'

    try:
        import yaml
    except ImportError:
        print("PyYAML library is not installed. Please install it to run this script.")
        print("You can install it using pip: pip install PyYAML")
        sys.exit(1)

    convert_yaml_to_json(yaml_file_path, json_file_path)

    # Output the content of the created JSON file
    try:
        with open(json_file_path, 'r') as f:
            print("\nContent of conferences.json:")
            print(f.read())
    except FileNotFoundError:
        print(f"Could not read the output file '{json_file_path}' to display its content.")
    except Exception as e:
        print(f"An error occurred while reading '{json_file_path}' for display: {e}")
