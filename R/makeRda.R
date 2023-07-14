source("R/libs.R")
source("R/helpers.R")

path_to_rda = "data/processed"
path_to_raw = "data/raw"


# Spruce ####
## Files ####
files_spruce = get.files(dataset = "Spruce")
save(files_spruce, file = paste(path_to_rda, "files_spruce.rda", sep = "/"))

## Sensor settings ####
sensor_spruce = get_sensorfiles(files_spruce[files_spruce$file == "sensor", ],
                                "spruce")
save(sensor_spruce, file = paste(path_to_rda, "sensor_spruce.rda", sep = "/"))

## Wood properties ####
sapwood_spruce = fread(paste(path_to_raw, "spruce", 
                             "sapwood.txt", sep = "/"))
## K-values #####
k_spruce = get_kfiles(files_spruce[files_spruce$file == "K", ], "spruce")
save(k_spruce, file = paste(path_to_rda, "K_spruce.rda", sep = "/"))

## TWU ####
twu_spruce = get_twufiles(files_spruce[files_spruce$file == "TWU", ], "spruce")
save(twu_spruce, file = paste(path_to_rda, "twu_spruce.rda", sep = "/"))

## Sap flow ####
sapflow_spruce = get_sapflowfiles(files_spruce[files_spruce$file == "SapFlow", ],
                                  "spruce")
save(sapflow_spruce, file = paste(path_to_rda, "sapflow_spruce.rda", sep = "/"))


# Hornbeam ####
## Files ####
files_hornbeam = get.files(dataset = "Hornbeam")
save(files_hornbeam, file = paste(path_to_rda, "files_hornbeam.rda", sep = "/"))

## Sensor settings ####
sensor_hornbeam = get_sensorfiles(files_hornbeam[files_hornbeam$file == "sensor", ],
                                  "hornbeam")
save(sensor_hornbeam, file = paste(path_to_rda, "sensor_hornbeam.rda", sep = "/"))

## Wood properties ####
sapwood_hornbeam = fread(paste(path_to_raw, "hornbeam", 
                               "sapwood.txt", sep = "/"))

## K-values #####
k_hornbeam = get_kfiles(files_hornbeam[files_hornbeam$file == "K", ], "hornbeam")
save(k_hornbeam, file = paste(path_to_rda, "K_hornbeam.rda", sep = "/"))

## TWU ####
twu_hornbeam = get_twufiles(files_hornbeam[files_hornbeam$file == "TWU", ], "hornbeam")
save(twu_hornbeam, file = paste(path_to_rda, "twu_hornbeam.rda", sep = "/"))

## Sap flow ####
sapflow_hornbeam = get_sapflowfiles(files_hornbeam[files_hornbeam$file == "SapFlow", ],
                                    "hornbeam")
save(sapflow_hornbeam, file = paste(path_to_rda, "sapflow_hornbeam.rda", sep = "/"))


# Mangrove ####
## Files ####
files_mangrove = get.files(dataset = "Mangrove")
save(files_mangrove, file = paste(path_to_rda, "files_mangrove.rda", sep = "/"))

## Sensor settings ####
sensor_mangrove = get_sensorfiles(files_mangrove[files_mangrove$file == "sensor", ],
                                  "mangrove")
save(sensor_mangrove, file = paste(path_to_rda, "sensor_mangrove.rda", sep = "/"))

## Wood properties ####
sapwood_mangrove = fread(paste(path_to_raw, "mangrove", 
                               "sapwood.txt", sep = "/"))

## K-values #####
k_mangrove = get_kfiles(files_mangrove[files_mangrove$file == "K", ], "mangrove")
save(k_mangrove, file = paste(path_to_rda, "K_mangrove.rda", sep = "/"))

## TWU ####
twu_mangrove = get_twufiles(files_mangrove[files_mangrove$file == "TWU", ], "mangrove")
save(twu_mangrove, file = paste(path_to_rda, "twu_mangrove.rda", sep = "/"))

## Sap flow ####
sapflow_mangrove = get_sapflowfiles(files_mangrove[files_mangrove$file == "SapFlow", ],
                                    "mangrove")
save(sapflow_mangrove, file = paste(path_to_rda, "sapflow_mangrove.rda", sep = "/"))

