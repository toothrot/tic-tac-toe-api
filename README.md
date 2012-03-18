# Tic Tac Toe

## Creating a new Game

First, to create a new game, complete the following request:

  POST http://quiet-sword-2122.heroku.com/v1/games
  {"players":[{"id": "alex"},{"id":"evan"}]

In the response, you receive an "id" for your game of tic-tac-toe. This ID should be used in all future moves against this instance of the game.

  {
    "game": {
      "status": "in_progress",
      "id": "aab1de70-52bd-012f-6231-12313d054231",
      "created_at": 1332029847,
      "players": [
        {
          "id": "alex"
        },
        {
          "id": "evan"
        }
      ],
      "board": [
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null
      ],
      "winner": null
    }
  }


## Making a Move
  
  POST http://quiet-sword-2122.heroku.com/v1/games/aab1de70-52bd-012f-6231-12313d054231/actions
  {"player":"alex","position":0}

In the response, you'll get back an "action object" if it was a success.

  {
    "action": {
      "player": "alex",
      "game_id": "aab1de70-52bd-012f-6231-12313d054231",
      "position": 0,
      "id": "e7c11270-52bd-012f-6231-12313d054231",
      "created_at": 1332029949
    }
  }

## Error messaging

  If we make a duplicate move, or another kind of bad request, we will receive an error:

  POST http://quiet-sword-2122.heroku.com/v1/games/aab1de70-52bd-012f-6231-12313d054231/actions
  {"player":"alex","position":0}

  POST http://quiet-sword-2122.heroku.com/v1/games/aab1de70-52bd-012f-6231-12313d054231/actions
  {"player":"alex","position":0}

The error messages are formatted consistently through all APIs:

  {
    "error": {
      "message": "Duplicate Move and It's not your turn",
      "code": 400
    }
  }
