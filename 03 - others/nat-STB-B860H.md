# SETUP NAT STB b860H

- **Enable IP Forward**
    ```bash
    echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
    ```
- **Set IP ETH0**
    ```bash
    sudo ip address add 192.168.1.1/24 dev eth0
    ```

- **Activate ETH0**
    ```bash
    sudo ip link set eth0 up
    ```

- **Iptables**
    ```bash
    sudo iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
    ```
