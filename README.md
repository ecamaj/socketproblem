# README

There is some strange Chrome/Opera + UWSGI websocket with big JSON message chunking problem.

To replicete build and run docker container. On internal port 80 is UWSGI, 81 is some basic geventwebsocket WebSocketServer.

```
docker build . -t socketproblem --memory-swap -1
docker run -it -d --name socketproblem -p 32800:80 -p 32801:81 socketproblem

docker exec -it socketproblem bash
```

Inside container, uwsgi logs:
```
tail -f /var/log/uwsgi/app.log
```
Both uwsgi and nonuwsgi servers log to /var/log/app.log if you want to check those.

In Chrome or Opera run `test_socket.html` and check console log.

----

In container log there will be several (unexpectedly?) chunked socket messages, and UWSGI client in Chrome/Safari will not get "save" message back.
If you look at the uwsgi log, somewhere in the beginning of base64 logged data will be an error.

The problem exists on Chrome, Opera, works on Safari, Firefox.

Works on other (non-uwsgi) server (tested only on one, check nonuwsgi.py)
