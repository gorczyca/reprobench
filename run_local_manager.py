from reprobench.managers.local import LocalManager

m = LocalManager(num_workers=1, server_address="tcp://localhost:31313", output_dir="output", processes=1,
                 config="./benchmark-clasp.yml", tunneling=None, repeat=1, rbdir="")

m.run()