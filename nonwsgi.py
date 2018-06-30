import socketio
import logging
import logging.config

logging.config.fileConfig('logging.conf')


def application(env, start_response):
    start_response('200 OK', [('Content-Type', 'text/html'), ('Access-Control-Allow-Origin', '*')])
    return []


class Messaging(socketio.Namespace):
    logger = logging.getLogger(__name__)

    def __init__(self, *args, **kwargs):
        super(Messaging, self).__init__(*args, **kwargs)

    def on_connect(self, sid, environ):
        Messaging.logger.info("Socket connected %s", sid)
        pass

    def on_disconnect(self, sid):
        Messaging.logger.info("Socket disconnected %s", sid)

    def on_message(self, sid, data):
        Messaging.logger.info("Message received %s", str(data))

    def on_save(self, sid, data):
        with open("NONUWSGI_SAVED_DATA.txt", "w+") as f:
            f.write(str(data))
        Messaging.logger.info("Saving data: %s", str(data))
        self.emit("save", {"saved": True}, room=sid)

# async_handlers so that socketio sends emits as soon as that line is processed, not to wait for whole method to finish
sio = socketio.Server(logger=logging.getLogger(), engineio_logger=logging.getLogger(),
                      ping_timeout=120, ping_interval=10, async_handlers=True)
handler = Messaging('/socket2')
handler.server = sio
sio.register_namespace(handler)

# wrap WSGI application with socketio's middleware
application = socketio.Middleware(sio, application)

from geventwebsocket import WebSocketServer
WebSocketServer(('', 8001), application).serve_forever()
