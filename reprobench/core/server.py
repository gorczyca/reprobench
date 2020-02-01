import click
import gevent
import zmq.green as zmq
from loguru import logger

from reprobench.console.decorators import common, server_info
from reprobench.core.observers import CoreObserver
from reprobench.utils import decode_message


class BenchmarkServer(object):
    BACKEND_ADDRESS = "inproc://backend"

    def __init__(self, frontend_address, **kwargs):
        self.frontend_address = frontend_address
        self.observers = []

    def receive_event(self):
        logger.debug('Waiting to receive events')
        address, event_type, payload = self.frontend.recv_multipart()
        logger.trace(address)
        logger.trace('Received the following event')
        logger.trace((address, event_type, decode_message(payload)))
        return address, event_type, payload

    def loop(self):
        while True:
            address, event_type, payload = self.receive_event()
            payload = decode_message(payload)
            logger.trace('Received an event of the following'
                         ' type "%s"' % event_type)
            for observer in self.observers:
                observer.handle_event(event_type, payload,
                                      address=address,
                                      context=self.context,
                                      reply=self.frontend,
                                      server=self)

    def run(self):
        self.context = zmq.Context()
        self.frontend = self.context.socket(zmq.ROUTER)
        self.frontend.bind(self.frontend_address)

        CoreObserver.observe(self)
        logger.info(f"Listening on {self.frontend_address}...")

        serverlet = gevent.spawn(self.loop)
        logger.info(f"Ready to receive events...")
        serverlet.join()


@click.command(name="server")
@server_info
@common
def cli(server_address, **kwargs):
    server = BenchmarkServer(server_address, **kwargs)
    server.run()


if __name__ == "__main__":
    cli()
