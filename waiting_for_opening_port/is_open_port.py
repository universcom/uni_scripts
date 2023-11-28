import socket
import time

def is_port_open(ip: str, port: int, attempts: int=10, between_attempts: int=20):
    """
    Check if a TCP port is open on the specified IP address.

    :param ip: The target IP address.
    :param port: The target TCP port.
    :param attempts: The number of attempts to check the port.
    :return: True if the port is open, False otherwise.
    """
    for _ in range(attempts):
        try:
            # Create a socket object
            sock = socket.create_connection((ip, port), timeout=10)
            # Close the connection
            sock.close()
            return True
        except (socket.timeout, ConnectionRefusedError):
            # Timeout or connection refused means the port is closed
            pass
            
        # Pause before the next attempt
        time.sleep(between_attempts)

    # If all attempts fail, return False
    return False