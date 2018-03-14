# plot soil moisture transect data

library(ggplot2)

head(sm_db)

sm_db$site <- substr(sm_db$samplingfeaturecode, 5, 6)
sm_db$chamberID <- substr(sm_db$samplingfeaturecode, 11, 11)
sm_db$dateday <- as.Date(sm_db$valuedatetime)
  
sm_db %>%
  filter(variablecode == "volumetricWaterContent") %>%
  group_by(samplingfeaturecode, valuedatetime, site, chamberID, dateday) %>%
  summarise(vwc = mean(datavalue), vwc_sd = sd(datavalue)) %>%
  ggplot(aes(x = chamberID, y = vwc, fill = chamberID, group = 1)) +
  geom_line() +
  geom_point(pch = 21, size = 2.5) +
  facet_grid(site~dateday) +
  theme_bw() +
  theme(legend.position="none")

sm_db %>%
  filter(variablecode == "volumetricWaterContent") %>%
  group_by(samplingfeaturecode, valuedatetime, site, chamberID) %>%
  summarise(vwc = mean(datavalue), vwc_sd = sd(datavalue)) %>%
  ggplot(aes(x = valuedatetime, y = vwc, fill = site, group = 1)) +
  geom_line() +
  geom_point(pch = 21, size = 2.5) +
  facet_grid(site ~ chamberID) +
  theme_bw() +
  guides(fill=FALSE)

sm_db %>%
  filter(variablecode == "volumetricWaterContent") %>%
  group_by(samplingfeaturecode, valuedatetime, site, chamberID) %>%
  summarise(vwc = mean(datavalue), vwc_sd = sd(datavalue)) %>%
  ggplot(aes(x = valuedatetime, y = vwc, fill = chamberID)) +
  geom_line(aes(color = chamberID, group = chamberID)) +
  geom_point(pch = 21, size = 2.5) +
  facet_wrap(~site) +
  theme_bw() +
  guides(fill=FALSE)

sm_db %>%
  filter(variablecode == "temperature") %>%
  group_by(samplingfeaturecode, valuedatetime, site, chamberID, dateday) %>%
  summarise(temp_C = mean(datavalue), temp_sd = sd(datavalue)) %>%
  ggplot(aes(x = chamberID, y = temp_C, fill = chamberID, group = 1)) +
  geom_line() +
  geom_point(pch = 21, size = 2.5) +
  facet_grid(site~dateday) +
  theme_bw() +
  theme(legend.position="none")

sm_db %>%
  filter(variablecode == "temperature") %>%
  group_by(samplingfeaturecode, valuedatetime, site, chamberID) %>%
  summarise(temp_C = mean(datavalue), temp_sd = sd(datavalue)) %>%
  ggplot(aes(x = valuedatetime, y = temp_C, fill = site, group = 1)) +
  geom_line() +
  geom_point(pch = 21, size = 2.5) +
  facet_grid(site ~ chamberID) +
  theme_bw() +
  guides(fill=FALSE)
