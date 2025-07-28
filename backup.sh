#!/bin/bash
# Bash Backup Script - by Amirhossein Soroushnejad

EXTENSION="$1"
SEARCH_PATH="$2"
DEST_PATH="$3"
RETENTION_DAYS=7

NOW=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_NAME="backup_$NOW.tar.gz"
TEMP_DIR="/tmp/backup_$NOW"
BACKUP_LOG="$DEST_PATH/backup.log"
BACKUP_CONF="$DEST_PATH/backup.conf"

mkdir -p "$TEMP_DIR"
mkdir -p "$DEST_PATH"

START_TIME=$(date +%s)

find "$SEARCH_PATH" -type f -name "*.$EXTENSION" > "$BACKUP_CONF"

while IFS= read -r file; do
  mkdir -p "$TEMP_DIR/$(dirname "$file" | sed "s|$SEARCH_PATH||")"
  cp "$file" "$TEMP_DIR/$(dirname "$file" | sed "s|$SEARCH_PATH||")"
done < "$BACKUP_CONF"

tar -czf "$DEST_PATH/$BACKUP_NAME" -C "$TEMP_DIR" .

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
FILE_SIZE=$(du -sh "$DEST_PATH/$BACKUP_NAME" | cut -f1)

echo "[SUCCESS] Backup completed at $NOW" >> "$BACKUP_LOG"
echo "         File: $BACKUP_NAME" >> "$BACKUP_LOG"
echo "         Size: $FILE_SIZE" >> "$BACKUP_LOG"
echo "         Duration: ${DURATION}s" >> "$BACKUP_LOG"
echo "" >> "$BACKUP_LOG"

rm -rf "$TEMP_DIR"
find "$DEST_PATH" -name "backup_*.tar.gz" -mtime +$RETENTION_DAYS -exec rm {} \;

echo "[DONE] Backup process finished."
exit 0
