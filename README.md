# flutter_gamelist_editor

A Editor to Setup a Game library.

## Prerequesites

- Have a Github Account and a personal Access Token ready to go
- create a gist with a file `"gamesList.json"` (empty gist not testet =D)
- Gist Format:
  - ```JSON 
    {
        "meta": { "lastEdit": 6165365165(Unix Timestamp) },
        "gameList" : [
            {
                "title": "Awesome Game",
                "system": "Some ENUM Value from the Editor, e.g. PC",
                "playStyle": ["List", "of ENUM", "Choosable from the Editor, e.g. Casual"]
            }
        ]
    }
    ```

