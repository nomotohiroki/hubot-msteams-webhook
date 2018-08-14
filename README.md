# hubot-msteams-webhook

hubot adapter for Microsoft Teams Incoming Webhook.

## これは？

* slack用に利用していたhubotで、room名指定のsendがほとんどだった
* slackからMS Teamsに移行しなくてはいけなくなった

ので作りました。

## 例

```coffee
  robot.send {room: 'sample_room'} "Your Great Message"
```

