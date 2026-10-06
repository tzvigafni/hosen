#!/bin/bash
# Creates the Firestore indexes Dabber needs (from firestore.indexes.json).
# Run in Google Cloud Shell: bash dabber-indexes.sh <firebase-project-id>
set -u
P="${1:?usage: bash dabber-indexes.sh <firebase-project-id>}"
gcloud services enable firestore.googleapis.com --project="$P" >/dev/null 2>&1
echo "Creating composite indexes in project $P ..."
gcloud firestore indexes composite create --project="$P" --collection-group=conversations --query-scope=collection --field-config=field-path=uid,order=ascending --field-config=field-path=startedAt,order=descending --async --quiet 2>&1 | grep -v -i 'already exists' || true
gcloud firestore indexes composite create --project="$P" --collection-group=conversations --query-scope=collection --field-config=field-path=uid,order=ascending --field-config=field-path=startedAt,order=ascending --async --quiet 2>&1 | grep -v -i 'already exists' || true
gcloud firestore indexes composite create --project="$P" --collection-group=admin_audit --query-scope=collection --field-config=field-path=targetUid,order=ascending --field-config=field-path=at,order=descending --async --quiet 2>&1 | grep -v -i 'already exists' || true
gcloud firestore indexes composite create --project="$P" --collection-group=admin_audit --query-scope=collection --field-config=field-path=action,order=ascending --field-config=field-path=at,order=descending --async --quiet 2>&1 | grep -v -i 'already exists' || true
gcloud firestore indexes composite create --project="$P" --collection-group=admin_audit --query-scope=collection --field-config=field-path=adminEmail,order=ascending --field-config=field-path=at,order=descending --async --quiet 2>&1 | grep -v -i 'already exists' || true
gcloud firestore indexes composite create --project="$P" --collection-group=payments --query-scope=collection --field-config=field-path=status,order=ascending --field-config=field-path=at,order=descending --async --quiet 2>&1 | grep -v -i 'already exists' || true
gcloud firestore indexes composite create --project="$P" --collection-group=payments --query-scope=collection --field-config=field-path=kind,order=ascending --field-config=field-path=at,order=descending --async --quiet 2>&1 | grep -v -i 'already exists' || true
gcloud firestore indexes composite create --project="$P" --collection-group=payments --query-scope=collection --field-config=field-path=kind,order=ascending --field-config=field-path=status,order=ascending --field-config=field-path=at,order=descending --async --quiet 2>&1 | grep -v -i 'already exists' || true
gcloud firestore indexes composite create --project="$P" --collection-group=payments --query-scope=collection --field-config=field-path=kind,order=ascending --field-config=field-path=status,order=ascending --field-config=field-path=at,order=ascending --async --quiet 2>&1 | grep -v -i 'already exists' || true
gcloud firestore indexes composite create --project="$P" --collection-group=email_log --query-scope=collection --field-config=field-path=to,order=ascending --field-config=field-path=at,order=descending --async --quiet 2>&1 | grep -v -i 'already exists' || true
gcloud firestore indexes composite create --project="$P" --collection-group=email_log --query-scope=collection --field-config=field-path=result,order=ascending --field-config=field-path=at,order=ascending --async --quiet 2>&1 | grep -v -i 'already exists' || true
gcloud firestore indexes composite create --project="$P" --collection-group=email_log --query-scope=collection --field-config=field-path=result,order=ascending --field-config=field-path=at,order=descending --async --quiet 2>&1 | grep -v -i 'already exists' || true
gcloud firestore indexes composite create --project="$P" --collection-group=usage --query-scope=collection --field-config=field-path=key,order=ascending --field-config=field-path=count,order=ascending --async --quiet 2>&1 | grep -v -i 'already exists' || true
gcloud firestore indexes composite create --project="$P" --collection-group=support_messages --query-scope=collection --field-config=field-path=status,order=ascending --field-config=field-path=at,order=descending --async --quiet 2>&1 | grep -v -i 'already exists' || true
gcloud firestore indexes composite create --project="$P" --collection-group=groups --query-scope=collection --field-config=field-path=kind,order=ascending --field-config=field-path=createdAt,order=descending --async --quiet 2>&1 | grep -v -i 'already exists' || true
gcloud firestore indexes composite create --project="$P" --collection-group=payments --query-scope=collection --field-config=field-path=uid,order=ascending --field-config=field-path=kind,order=ascending --field-config=field-path=status,order=ascending --async --quiet 2>&1 | grep -v -i 'already exists' || true
gcloud firestore indexes composite create --project="$P" --collection-group=progress --query-scope=collection-group --field-config=field-path=lessonId,order=ascending --field-config=field-path=status,order=ascending --async --quiet 2>&1 | grep -v -i 'already exists' || true
echo "Updating single-field indexes (collection-group scope; gcloud cannot set it, so the REST API is used) ..."
T=$(gcloud auth print-access-token)
idx() { # $1 collection group, $2 field, $3 1 to also add a descending collection-group index
  local x='{"queryScope":"COLLECTION","fields":[{"fieldPath":"'$2'","order":"ASCENDING"}]},{"queryScope":"COLLECTION","fields":[{"fieldPath":"'$2'","order":"DESCENDING"}]},{"queryScope":"COLLECTION","fields":[{"fieldPath":"'$2'","arrayConfig":"CONTAINS"}]},{"queryScope":"COLLECTION_GROUP","fields":[{"fieldPath":"'$2'","order":"ASCENDING"}]}'
  [ "$3" = 1 ] && x="$x"',{"queryScope":"COLLECTION_GROUP","fields":[{"fieldPath":"'$2'","order":"DESCENDING"}]}'
  curl -s -X PATCH -H "Authorization: Bearer $T" -H "Content-Type: application/json" \
    "https://firestore.googleapis.com/v1/projects/$P/databases/(default)/collectionGroups/$1/fields/$2?updateMask=indexConfig" \
    -d '{"indexConfig":{"indexes":['"$x"']}}' | grep -E '"name"|"message"' | head -1
}
idx progress lessonId 0
idx final_exam_attempts status 0
idx final_exam_attempts result.passed 0
idx pack_enrollments createdAt 1
echo; echo "Done. Indexes build in the background (a few minutes). Status:"
echo "https://console.firebase.google.com/project/$P/firestore/indexes"
