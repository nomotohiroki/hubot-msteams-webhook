{Adapter} = require 'hubot'
yml = require 'js-yaml'
fs = require 'fs'


class MSTeams extends Adapter
  constructor: ->
    super

  send: (envelope, messages...) ->
    settings = yml.safeLoad fs.readFileSync('./settings/room2webhookurl.yaml')
    room = settings.rooms.find (e) ->
      return e.name == envelope.room

    if !room
      @robot.logger.warning "No setting for room #{envelope.room}"
      return

    @robot.logger.info "Calling send"
    for msg in messages
      # 1行目をタイトルとする
      title = msg.split('\n')[0]
      # 2行目以降はmarkdownにするため改行、リンク等を修正
      msg = msg.split('\n')
               .slice(1)
               .join('\n')
               .replace(/\n/gi, '   \n')
               .replace(/(https?:\/\/[\w\/:%#\$&\?\(\)~\.=\+\-]+)/gi, '[$1]($1)')
               .replace(/_/gi, '\\_')

      # outlook MessageCard形式のjsonに加工
      # see. https://docs.microsoft.com/ja-jp/outlook/actionable-messages/message-card-reference
      data = JSON.stringify({
        "@context": "http://schema.org/extensions"
        "@type": "MessageCard"
        "summary": title
        "sections": [
          {
            "activityTitle": title
            "text": msg
            "markdown": true
          }
        ]
      })

      @robot.http(room.url)
        .header('Content-Type', 'application/json')
        .post(data) (err, res, body) =>
          if err
            @robot.logger.error err
          @robot.logger.info body

  run: ->
    @robot.logger.info "Started"
    @emit "connected"

exports.use = (robot) ->
  new MSTeams robot
