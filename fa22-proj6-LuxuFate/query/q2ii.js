// Task 2ii

db.movies_metadata.aggregate([
    {$project: {words: {$split: ["$tagline", " "]}}},
    {$unwind: "$words"},
    {$project: {trimmed:
                {$trim: {input: {$toLower: "$words"}, chars: ".,!?"}}
               }
    },
    {$project: {trimmed: 1, length: {$strLenCP: "$trimmed"}}},
    {$match: {length: {$gt: 3}}},
    {$group: {_id: "$trimmed", count: {$sum: 1}}},
    {$sort: {count: -1}},
    {$limit: 20}
]);