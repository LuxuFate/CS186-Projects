// Task 1iv

db.ratings.aggregate([
    {$match: {userId: 186}},
    {$sort: {timestamp: -1}},
    {$limit: 5},
    {$group: {_id: null, movieIds: {$push: "$movieId"}, ratings: {$push: "$rating"}, timestamps: {$push: "$timestamp"}}},
    {$project: {movieIds: 1, ratings: 1, timestamps: 1, _id: 0}}
]);