source .venv/bin/activate
DATA_DIR=$(python -c "import open_webui; from pathlib import Path; print(Path(open_webui.__file__).parent / 'data')")
echo "Data directory to be deleted: $DATA_DIR"
read -p "Are you sure you want to delete this directory? [y/N]: " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Aborted. Data directory not deleted."
    deactivate 2>/dev/null
    exit 1
fi

rm -rf $DATA_DIR
echo "Data directory cleaned: $DATA_DIR"