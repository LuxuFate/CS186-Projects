// Task 1iii

db.ratings.aggregate([
    {$group: {_id: "$rating", count: {$sum: 1}}},
    {$project: {rating: "$_id", count: 1, _id: 0}},
    {$sort: {rating: -1}}
]);