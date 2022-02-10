-- The following sqlite 3 queries serve as an example for this project
-- it may be adjusted or reused as is depending on your needs. 

BEGIN;

-- users
CREATE TABLE IF NOT EXISTS user (
    id TEXT  NOT NULL PRIMARY KEY , -- user id
    login TEXT UNIQUE, -- user login
    display_name TEXT, -- display name
    totp_seed TEXT, -- user otp seed if set to null users can't login
    created_at TEXT NOT NULL DEFAULT (datetime('now')), -- account creation date
    last_login TEXT
);

-- examples:
-- root user used for systems actions
-- this user should only be used internally and should not be able to login
-- hence we only set an id and a display name
-- login is null and unique
-- INSERT INTO user (id, display_name) VALUES ("root", "system");
-- when a user signs in you can create an activation code and disable logins where an activation code is present.
-- BEGIN; INSERT INTO user (id, login, display_name) VALUES ("some id", "email@example.com", "John Doe"); INSERT INTO activation_code (login, code) VALUES (?, ?); COMMIT;
-- example of query for selecting users able to login
-- SELECT user.id, user.login, user.display_name user.totp_seed 
-- LEFT JOIN user_archive ON user_archive.id = user.id 
-- WHERE user.login = 'email@example.com' AND user.totp_seed IS NOT NULL AND user_archive.id is NULL;

-- archive is a soft delete where an account is considered removed/inactive when present in this table
CREATE TABLE IF NOT EXISTS user_archive (
    id TEXT NOT NULL PRIMARY KEY, -- user id
    archived_at TEXT NOT NULL DEFAULT (datetime('now')), -- account removal date
    archived_by TEXT NOT NULL, -- user responsible for archiving this account
    reason TEXT, -- why this account has been archived
    FOREIGN KEY (id) REFERENCES user (id) ON DELETE CASCADE,
    FOREIGN KEY (archived_by) REFERENCES user (id) ON DELETE CASCADE
);

-- user login sessions
CREATE TABLE IF NOT EXISTS user_session (
    id TEXT NOT NULL, -- login session id
    user_id TEXT NOT NULL, -- user id
    created_at TEXT NOT NULL DEFAULT (datetime('now')), -- session creation time
    expires_at TEXT NOT NULL, -- session expiration time
    user_agent TEXT DEFAULT NULL, -- user agent responsible for creating this session
    PRIMARY KEY (id, user_id),
    FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS user_group (
    id TEXT NOT NULL PRIMARY KEY, -- group id
    label TEXT NOT NULL, -- group label/name
    description TEXT -- group description
);

CREATE TABLE IF NOT EXISTS user_has_group (
    group_id TEXT NOT NULL, -- group idd
    user_id TEXT NOT NULL, -- user id
    PRIMARY KEY (group_id, user_id),
    FOREIGN KEY (group_id) REFERENCES user_group (id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE CASCADE
);

-- definition of access modes
CREATE TABLE IF NOT EXISTS access (
    key TEXT NOT NULL PRIMARY KEY, -- a specific access ie: "View, Read, Write, Edit, any arbitrary unique string..."
    description TEXT -- access description: ie: what the key is supposed to give access to
);

-- basic permission system
-- a permission is an arbitrary string
-- each user has zero or more permissions
-- each group has zero or more permissions
-- keys should be constructed like so: `item_type.item_id`
-- a permission may have a default access
CREATE TABLE IF NOT EXISTS permission (
    perm_key TEXT NOT NULL PRIMARY KEY, -- permission key
    access TEXT NOT NULL, -- ie: a json array containing access keys
    description TEXT -- permission description
);

-- mapping table for users and permissions
CREATE TABLE IF NOT EXISTS user_permission (
    perm_key TEXT NOT NULL, -- permission id
    user_id TEXT NOT NULL, -- user id if
    given_at TEXT NOT NULL DEFAULT (datetime('now')), -- date when this permission is given
    given_by TEXT NOT NULL, -- who provided the permission
    access TEXT NOT NULL, -- a json array containing access keys
    PRIMARY KEY (perm_key, user_id),
    FOREIGN KEY (perm_key) REFERENCES permission (perm_key) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE CASCADE,
    FOREIGN KEY (given_by) REFERENCES user (id) ON DELETE CASCADE
);

-- mapping table for groups and permissions
CREATE TABLE IF NOT EXISTS user_group_permission (
    perm_key TEXT NOT NULL, -- permission key
    group_id TEXT NOT NULL, -- permission key
    given_at TEXT NOT NULL DEFAULT (datetime('now')), -- date when this permission is given
    given_by TEXT NOT NULL,
    access TEXT NOT NULL, -- a json object or array containing access keys
    PRIMARY KEY (perm_key, group_id),
    FOREIGN KEY (perm_key) REFERENCES permission (perm_key) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES user_group (id) ON DELETE CASCADE,
    FOREIGN KEY (given_by) REFERENCES user (id) ON DELETE CASCADE
);

-- uploaded items
CREATE TABLE IF NOT EXISTS items (
    id TEXT NOT NULL PRIMARY KEY, -- item id
    user_id TEXT NOT NULL, -- user that created this item
    created_at TEXT NOT NULL DEFAULT (datetime('now')), -- upload/creation time
    deleted_at TEXT , -- deletion date null if not deleted
    ressource TEXT NOT NULL, -- ie: an url to get the item
    data BLOB, -- raw data if you want to bundle it in sqlite
    FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE CASCADE
);

-- archive is a soft delete where an item is considered removed/inactive when present in this table
CREATE TABLE IF NOT EXISTS item_archive (
    item_id TEXT NOT NULL PRIMARY KEY, -- item id
    archived_at TEXT NOT NULL DEFAULT (datetime('now')), -- item removal date
    archived_by TEXT NOT NULL, -- user responsible for archiving this item
    reason TEXT NOT NULL, -- why this item has been archived
    FOREIGN KEY (item_id) REFERENCES item (id) ON DELETE CASCADE, 
    FOREIGN KEY (archived_by) REFERENCES user (id) ON DELETE CASCADE
);

-- mapping table between items and attributes
CREATE TABLE IF NOT EXISTS item_attribute (
    item_id TEXT NOT NULL, -- item id
    attribute_id TEXT NOT NULL, -- attribute id
    PRIMARY KEY (item_id, attribute_id),
    FOREIGN KEY (item_id) REFERENCES item (id) ON DELETE CASCADE,
    FOREIGN KEY (attribute_id) REFERENCES attribute (id) ON DELETE CASCADE
);

-- types usable in attributes
CREATE TABLE IF NOT EXISTS type (
    id TEXT NOT NULL PRIMARY KEY, -- type id
    label TEXT NOT NULL UNIQUE -- type label
);

-- usefull to build a type hierarchy
CREATE TABLE IF NOT EXISTS parent_types (
    type_id TEXT NOT NULL, -- current type id
    parent_id TEXT NOT NULL, -- parent type id
    PRIMARY KEY (type_id, parent_id),
    FOREIGN KEY (type_id) REFERENCES type (id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES type (id) ON DELETE CASCADE
);

-- an attribute with an arbitrary name and text value
-- many attributes may be attached to a single item
CREATE TABLE IF NOT EXISTS attribute (
    id TEXT NOT NULL PRIMARY KEY, -- attribute id
    type_id TEXT NOT NULL, -- attribute type
    value TEXT NOT NULL, -- attribute value don't forget json1 https://www.sqlite.org/json1.html
    FOREIGN KEY (type_id) REFERENCES type (id) ON DELETE CASCADE
);

CREATE INDEX attribute_index_typeid ON attribute (type_id);

CREATE INDEX attribute_index_typeid_value ON attribute (type_id, value);

COMMIT;
