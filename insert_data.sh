#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo "$($PSQL "TRUNCATE TABLE games, teams;")";

cat games.csv | while IFS="," read year round winner opponent winner_goals opponent_goals
do
  
  if [[ $year != 'year' ]]
  then

    #----------- Insert Teams -----------------
    INSERT_TEAM_QUERY="insert into teams(name) values"

    CHECK_WINNER_EXIST=$($PSQL "select team_id from teams where name = '$winner';")

    CHECK_OPPONENT_EXIST=$($PSQL "select team_id from teams where name = '$opponent';")

    OTHERVALUE_FLAG=1

    #echo "check winner exist : "$CHECK_WINNER_EXIST

    #echo "check opponent exist : "$CHECK_OPPONENT_EXIST

    #echo "otherflag value : "$OTHERVALUE_FLAG


    if [[ -z $CHECK_WINNER_EXIST || -z $CHECK_OPPONENT_EXIST ]]
    then
      if [[ -z $CHECK_WINNER_EXIST ]]
      then
        INSERT_TEAM_QUERY+=" ('$winner')"
        OTHERVALUE_FLAG=0
      fi
      
      #echo "otherflag value : "$OTHERVALUE_FLAG

      if [[ -z $CHECK_OPPONENT_EXIST ]]
      then
        if [[ $OTHERVALUE_FLAG != 1 ]]
        then
          INSERT_TEAM_QUERY+=", ('$opponent')"
        else
          INSERT_TEAM_QUERY+=" ('$opponent')"
        fi
      fi

      INSERT_TEAM_QUERY+=";"
      
      echo $INSERT_TEAM_QUERY
      echo "$($PSQL "$INSERT_TEAM_QUERY")"
    fi
  #---------------------------------------------
  #----------- Insert Games -----------------

  WINNER_ID=$($PSQL "select team_id from teams where name = '$winner';") 

  OPPONENT_ID=$($PSQL "select team_id from teams where name = '$opponent';") 

  CHECK_GAME_EXIST=$($PSQL "select game_id from games where year=$year and round='$round' and winner_id=$WINNER_ID and opponent_id=$OPPONENT_ID and winner_goals=$winner_goals and opponent_goals=$opponent_goals ;");

  if [[ -z $CHECK_GAME_EXIST ]]
  then
    INSERT_GAME_QUERY=$($PSQL "insert into games (year,round,winner_id,opponent_id,winner_goals,opponent_goals) values ($year,'$round',$WINNER_ID,$OPPONENT_ID,$winner_goals,$opponent_goals);")
    echo $INSERT_GAME_QUERY
  fi

  #---------------------------------------------

  fi

done
