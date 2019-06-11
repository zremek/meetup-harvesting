# docker run -d -p 4445:4444 -p 5901:5900 -v /dev/shm:/dev/shm selenium/standalone-firefox-debug:3.141.59-oxygen
# standalone is needed to view in VNC
library(RSelenium)
library(stringi)
remDr <- remoteDriver(remoteServerAddr = "192.168.99.100",
                      port = 4445L)
remDr$open()

### to stop container: docker stop my_container