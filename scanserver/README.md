Add wifi password after clean image, while mounted in `/media/.../etc/wpa_supplicant/`:
```
echo 'network={                                              
  ssid="[SSID]"
  psk="[PASSWORD]"
}' | sudo tee -a wpa_supplicant.conf
```

Copy ssh key:
```
ssh-copy-id -i ~/.ssh/id_rsa.pub pi@raspberrypi
```

Disable password:
```
ssh pi@raspberrypi "sudo sed -i \"s/#PasswordAuthentication yes/PasswordAuthentication no/g\" /etc/ssh/sshd_config" &&
ssh pi@raspberrypi "sudo /etc/init.d/ssh restart"
```

Client settings:
```/etc/sane.d/net.conf```