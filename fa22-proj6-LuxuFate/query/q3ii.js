// Task 3ii

db.credits.aggregate([
    {$unwind: "$cast"},
    {$match: {crew: {$elemMatch: {id: 5655, job: "Director"}}}},
    {$project: {id: "$cast.id", name: "$cast.name", _id: 0}},
    {$group: {_id: {gid: "$id", gname: "$name"}, count: {$sum: 1}}},
    {$project: {count: 1, id: "$_id.gid", name: "$_id.gname", _id: 0}},
    {$sort: {count: -1, id: 1}},
    {$limit: 5}
]);