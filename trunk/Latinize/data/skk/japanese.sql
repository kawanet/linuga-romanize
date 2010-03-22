PRAGMA default_synchronous = OFF;
DROP TABLE IF EXISTS romanize;
CREATE TABLE romanize (
        word TEXT NOT NULL COLLATE NOCASE,
        ruby TEXT NOT NULL COLLATE NOCASE
);
.separator ,
.import japanese.csv romanize
SELECT count(*) FROM romanize;
CREATE INDEX idx_romanize ON romanize (word COLLATE NOCASE);
VACUUM;
