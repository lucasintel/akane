-- name: insert_vote(vote : Dbl::Vote)

insert into votes (user_id, weekend, type)
     values (
       {{vote.user}},
       {{vote.isWeekend}},
       {{vote.type}}
     );
