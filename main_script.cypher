// Criação de constraints

CREATE CONSTRAINT user_id IF NOT EXISTS
FOR (u:User) REQUIRE u.id IS UNIQUE;

CREATE CONSTRAINT song_id IF NOT EXISTS
FOR (s:Song) REQUIRE s.id IS UNIQUE;

CREATE CONSTRAINT artist_id IF NOT EXISTS
FOR (a:Artist) REQUIRE a.id IS UNIQUE;

CREATE CONSTRAINT genre_name IF NOT EXISTS
FOR (g:Genre) REQUIRE g.name IS UNIQUE;


// Criação dos nós principais

CREATE
(u1:User {id: 1, name: "Ana"}),
(u2:User {id: 2, name: "Bruno"}),

(a1:Artist {id: 1, name: "Drake"}),
(a2:Artist {id: 2, name: "Coldplay"}),

(g1:Genre {name: "Hip-Hop"}),
(g2:Genre {name: "Pop"}),

(s1:Song {id: 1, title: "God's Plan"}),
(s2:Song {id: 2, title: "Yellow"}),
(s3:Song {id: 3, title: "Viva La Vida"});


// Relacionamentos musicais

MATCH
(s1:Song {id: 1}),
(s2:Song {id: 2}),
(s3:Song {id: 3}),
(a1:Artist {id: 1}),
(a2:Artist {id: 2}),
(g1:Genre {name: "Hip-Hop"}),
(g2:Genre {name: "Pop"})
CREATE
(s1)-[:BY]->(a1),
(s2)-[:BY]->(a2),
(s3)-[:BY]->(a2),

(s1)-[:IN_GENRE]->(g1),
(s2)-[:IN_GENRE]->(g2),
(s3)-[:IN_GENRE]->(g2);

// Interações dos utilizadores (arestas com propriedades)

MATCH
(u1:User {id: 1}),
(u2:User {id: 2}),
(s1:Song {id: 1}),
(s2:Song {id: 2}),
(s3:Song {id: 3}),
(a2:Artist {id: 2})
CREATE
(u1)-[:LISTENED {times: 15, lastPlayed: date()}]->(s1),
(u1)-[:LIKED {at: datetime()}]->(s1),

(u1)-[:LISTENED {times: 5, lastPlayed: date()}]->(s2),

(u2)-[:LISTENED {times: 20, lastPlayed: date()}]->(s2),
(u2)-[:LIKED {at: datetime()}]->(s2),

(u1)-[:FOLLOWS]->(a2);


// Recomendação por género (baseada em escuta)

MATCH (u:User {id: 1})-[:LISTENED]->(:Song)-[:IN_GENRE]->(g)<-[:IN_GENRE]-(rec:Song)
WHERE NOT (u)-[:LISTENED]->(rec)
RETURN rec.title AS recomendacao, g.name AS genero
LIMIT 5;

// Recomendação por artistas seguidos

MATCH (u:User {id: 1})-[:FOLLOWS]->(a:Artist)<-[:BY]-(s:Song)
WHERE NOT (u)-[:LISTENED]->(s)
RETURN s.title AS recomendacao, a.name AS artista;

// Recomendação colaborativa (users parecidos)

MATCH (u:User {id: 1})-[:LIKED]->(s:Song)<-[:LIKED]-(other:User)-[:LIKED]->(rec:Song)
WHERE NOT (u)-[:LIKED]->(rec)
RETURN DISTINCT rec.title AS recomendacao, other.name AS baseado_em
LIMIT 5;

// Top músicas mais ouvidas

MATCH (:User)-[l:LISTENED]->(s:Song)
RETURN s.title, sum(l.times) AS total_plays
ORDER BY total_plays DESC;
