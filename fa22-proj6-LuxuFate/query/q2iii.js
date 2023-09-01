// Task 2iii

db.movies_metadata.aggregate([
    {$project: {budget: {$cond:
                                {if: {$and: [{$ne: ["$budget", false]},
                                             {$ne: ["$budget", null]},
                                             {$ne: ["$budget", ""]},
                                             {$ne: ["$budget", undefined]},
                                            ]
                                      },
                                 then: {$round: [{$cond:
                                               {if: {$isNumber: "$budget"},
                                                then: "$budget",
                                                else: {$toInt: {$trim: {input: "$budget", chars: "U$S D"}}}
                                               }
                                        }, -7]},
                                 else: "unknown"
                                }
                         }
                }
    },
    {$group: {_id: "$budget", count: {$sum: 1}}},
    {$project: {budget: "$_id", count: 1, _id: 0}},
    {$sort: {budget: 1}}
]);