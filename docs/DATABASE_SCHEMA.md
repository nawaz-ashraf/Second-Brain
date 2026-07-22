# Database Schema

## Engine: Drift (SQLite)

---

## Tables

### notes
| Column | Type | Constraints |
|---|---|---|
| id | TEXT | PRIMARY KEY |
| title | TEXT | NOT NULL |
| content_json | TEXT | nullable (Quill delta JSON) |
| content_plain | TEXT | nullable (for search) |
| color | INTEGER | NOT NULL DEFAULT 0 |
| is_pinned | BOOLEAN | NOT NULL DEFAULT false |
| is_favorite | BOOLEAN | NOT NULL DEFAULT false |
| word_count | INTEGER | NOT NULL DEFAULT 0 |
| created_at | DATETIME | NOT NULL |
| updated_at | DATETIME | NOT NULL |
| deleted_at | DATETIME | nullable |

### documents
| Column | Type | Constraints |
|---|---|---|
| id | TEXT | PRIMARY KEY |
| title | TEXT | NOT NULL |
| file_path | TEXT | NOT NULL |
| file_name | TEXT | NOT NULL |
| file_type | TEXT | NOT NULL |
| file_size | INTEGER | NOT NULL |
| is_favorite | BOOLEAN | NOT NULL DEFAULT false |
| created_at | DATETIME | NOT NULL |
| updated_at | DATETIME | NOT NULL |

### images
| Column | Type | Constraints |
|---|---|---|
| id | TEXT | PRIMARY KEY |
| title | TEXT | NOT NULL |
| file_path | TEXT | NOT NULL |
| thumbnail_path | TEXT | nullable |
| width | INTEGER | nullable |
| height | INTEGER | nullable |
| is_favorite | BOOLEAN | NOT NULL DEFAULT false |
| created_at | DATETIME | NOT NULL |
| updated_at | DATETIME | NOT NULL |

### voice_notes
| Column | Type | Constraints |
|---|---|---|
| id | TEXT | PRIMARY KEY |
| title | TEXT | NOT NULL |
| file_path | TEXT | NOT NULL |
| duration_ms | INTEGER | NOT NULL DEFAULT 0 |
| is_favorite | BOOLEAN | NOT NULL DEFAULT false |
| created_at | DATETIME | NOT NULL |
| updated_at | DATETIME | NOT NULL |

### bookmarks
| Column | Type | Constraints |
|---|---|---|
| id | TEXT | PRIMARY KEY |
| title | TEXT | NOT NULL |
| url | TEXT | NOT NULL |
| description | TEXT | nullable |
| site_name | TEXT | nullable |
| favicon_url | TEXT | nullable |
| is_favorite | BOOLEAN | NOT NULL DEFAULT false |
| created_at | DATETIME | NOT NULL |
| updated_at | DATETIME | NOT NULL |

### collections
| Column | Type | Constraints |
|---|---|---|
| id | TEXT | PRIMARY KEY |
| name | TEXT | NOT NULL |
| description | TEXT | nullable |
| color | INTEGER | NOT NULL DEFAULT 0xFF4CAF50 |
| icon | TEXT | NOT NULL DEFAULT 'folder' |
| created_at | DATETIME | NOT NULL |
| updated_at | DATETIME | NOT NULL |

### tags
| Column | Type | Constraints |
|---|---|---|
| id | TEXT | PRIMARY KEY |
| name | TEXT | NOT NULL UNIQUE |
| color | INTEGER | NOT NULL DEFAULT 0xFF4CAF50 |
| created_at | DATETIME | NOT NULL |

### recent_items
| Column | Type | Constraints |
|---|---|---|
| id | TEXT | PRIMARY KEY |
| item_id | TEXT | NOT NULL |
| item_type | TEXT | NOT NULL |
| opened_at | DATETIME | NOT NULL |

---

## Junction Tables

### note_tags
| Column | Type |
|---|---|
| note_id | TEXT REFERENCES notes |
| tag_id | TEXT REFERENCES tags |

### document_tags
| Column | Type |
|---|---|
| document_id | TEXT REFERENCES documents |
| tag_id | TEXT REFERENCES tags |

### bookmark_tags
| Column | Type |
|---|---|
| bookmark_id | TEXT REFERENCES bookmarks |
| tag_id | TEXT REFERENCES tags |

### image_tags
| Column | Type |
|---|---|
| image_id | TEXT REFERENCES images |
| tag_id | TEXT REFERENCES tags |

### collection_items
| Column | Type |
|---|---|
| collection_id | TEXT REFERENCES collections |
| item_id | TEXT |
| item_type | TEXT |

---

## Indexes

- `notes(updated_at DESC)` — for recent sorting
- `notes(is_pinned DESC, updated_at DESC)` — home screen
- `notes(is_favorite)` — favorites filter
- `bookmarks(created_at DESC)` — bookmarks list
- `tags(name)` — tag search
- `recent_items(opened_at DESC)` — recent items
