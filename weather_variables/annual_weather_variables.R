#####################################################
##                                                 ##
##     Global climate and population dynamics      ##
##                                                 ##
##        Annual CHELSA weather measures           ##
##                                                 ##
##               April 20th 2020                   ##
##                                                 ##
#####################################################
rm(list = ls())
options(width = 100)

library(tidyverse)
library(grid)
library(gridExtra)
library(psych)
library(moments)

chelsa_stl <- readRDS("data/chelsa_stl.RDS") 

##__________________________________________________________________________________________________
#### 1. Annual weather measures ####

mam_chelsa_annual <- chelsa_stl %>% 
  group_by(ID, scale) %>% 
  # adding summary stats for 8 and 9 for the full time series - odd values
  mutate(temp_anomaly_sd = sd(temp_anomaly),
         temp_anomaly_mean = mean(temp_anomaly),
         precip_anomaly_sd = sd(precip_anomaly),
         precip_anomaly_mean = mean(precip_anomaly),
         temp_odd = temp_anomaly_mean + (2*temp_anomaly_sd),
         precip_odd = precip_anomaly_mean + (2*precip_anomaly_sd)) %>% 
  ungroup() %>% 
  group_by(ID, year, scale) %>% 
  summarise(Binomial = Binomial[1], 
            Longitude = Longitude[1], 
            Latitude = Latitude[1],
            
            # 1) Mean climate variable - raw central tendency
            mean_temp = mean(temp),
            mean_precip = mean(precip),
            
            # 2) Mean anomaly - central tendency
            mean_temp_anomaly = mean(temp_anomaly),
            mean_precip_anomaly = mean(precip_anomaly),
            
            # 3) Mean absolute anomaly - central tendency
            mean_abtemp_anomaly = mean(abs(temp_anomaly)),
            mean_abprecip_anomaly = mean(abs(precip_anomaly)),
            
            # 4) Maximum/minimum anomaly
            max_temp_anomaly = max(temp_anomaly),
            max_precip_anomaly = max(precip_anomaly),
            
            min_temp_anomaly = min(temp_anomaly),
            min_precip_anomaly = min(precip_anomaly),
            
            # 5) Weather variance
            temp_variance = var(temp),
            precip_variance = var(precip),
            
            # 6) Anomaly skewness - Symmetry of the distribution
            temp_anomaly_skewness = skewness(temp_anomaly),
            precip_anomaly_skewness = skewness(precip_anomaly),
            
            # 7) Anomaly Kurtosis - weight of the tails relative to the rest of the distribution - not peakedness
            temp_anomaly_kurtosis = kurtosis(temp_anomaly),
            precip_anomaly_kurtosis = kurtosis(precip_anomaly),
            
            # 8) no. odd months - extreme values
            num_odd_months_temp = length(which(abs(temp_anomaly) > temp_odd[1])),
            num_odd_months_precip = length(which(abs(precip_anomaly) > precip_odd[1])),
            
            # 9) no. consecutive odd months - extreme values
            num_consecutive_odd_months_temp = 
              length(which(diff(which(abs(temp_anomaly) > temp_odd[1])) == 1)),
            num_consecutive_odd_months_precip = 
              length(which(diff(which(abs(precip_anomaly) > precip_odd[1])) == 1))) %>% 
  ungroup()

##__________________________________________________________________________________________________
#### 2. Plots ####

# test to demonstrate (6) - Temperature in Tanzania for the Cheetah
ts_ID28 <- filter(chelsa_stl, ID == 28 & temp_scale == "temp")
ID28 <- filter(chelsa_stl, ID == 28 & temp_scale == "temp", year == 1979)

ts_an_mean <- mean(ts_ID28$temp_anomaly)
ts_an_sd <- sd(ts_ID28$temp_anomaly)

ggplot(ts_ID28, aes(x = date)) +
  geom_segment(aes(xend = date, y = 0, yend = temp_anomaly)) +
  geom_hline(yintercept = ts_an_mean + 2*ts_an_sd, colour = "red", 
             linetype = "dashed") +
  geom_hline(yintercept = ts_an_mean - 2*ts_an_sd, colour = "red", 
           linetype = "dashed") +
  labs(x = NULL, y = "Temperature anomaly", title = "Record 28: Cheetah") +
  theme_bw(base_size = 17) +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  ggsave(filename = "plots/developing_annual_weather_variables/ID28_anomaly_sd.jpeg",
         width = 7, height = 4, units = "in", dpi = 400)


#________________________________________________________
# Pairs plot of annual measures

jpeg(filename = "plots/developing_annual_weather_variables/temp_annual_weather_correlations.jpeg",
     width = 15, height = 15, units = "in",res = 400)
pairs.panels(dplyr::select(mam_chelsa_annual, contains("temp")),
             smooth = FALSE, lm = TRUE,  ellipses = FALSE)
dev.off()

jpeg(filename = "plots/developing_annual_weather_variables/precip_annual_weather_correlations.jpeg",
     width = 15, height = 15, units = "in",res = 400)
pairs.panels(dplyr::select(mam_chelsa_annual, contains("precip")),
             smooth = FALSE, lm = TRUE,  ellipses = FALSE)
dev.off()

##__________________________________________________________________________________________________
#### 2. Save ####

saveRDS(mam_chelsa_annual, file = "data/mam_chelsa_annual.RDS")






