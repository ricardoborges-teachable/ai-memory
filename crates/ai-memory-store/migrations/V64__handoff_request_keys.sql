-- V64: bind an explicit handoff publish request key to the handoff it created.
--
-- `publisher` is a storage identity key when the caller is authenticated and
-- an empty string for an anonymous caller. Keeping that bucket non-NULL makes
-- the primary key enforce idempotency for both authenticated and anonymous
-- requests (SQLite treats NULL values as distinct in UNIQUE constraints).
-- The handoff reference is deliberately nullable: deleting a handoff leaves a
-- tombstone so a retry cannot recreate it or disclose the old id.
CREATE TABLE handoff_request_keys (
    workspace_id    BLOB NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    project_id      BLOB NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    publisher       TEXT NOT NULL,
    request_key     TEXT NOT NULL,
    payload_sha256  BLOB NOT NULL,
    handoff_id      BLOB REFERENCES handoffs(id) ON DELETE SET NULL,
    created_at      INTEGER NOT NULL,
    PRIMARY KEY (workspace_id, project_id, publisher, request_key)
);

CREATE INDEX idx_handoff_request_keys_handoff
    ON handoff_request_keys(handoff_id)
    WHERE handoff_id IS NOT NULL;
