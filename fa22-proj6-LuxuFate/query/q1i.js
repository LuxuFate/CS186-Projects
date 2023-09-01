// Task 1i

db.keywords.aggregate([
    {$match: {$or: [{keywords: {$elemMatch: {name: "mickey mouse"}}},
                    {keywords: {$elemMatch: {name: "marvel comic"}}}]}},
    {$sort: {movieId: 1}},
    {$project: {movieId: 1, _id: 0}}
]);